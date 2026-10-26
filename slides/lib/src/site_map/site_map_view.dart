// Demo devtool UI, shown in the slides.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:math' as math;
import 'dart:ui' show Tangent;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'diff.dart';
import 'layout.dart';
import 'site_map.dart';

abstract final class _Colors {
  static const canvas = Color(0xFF1E1E1E);
  static const dots = Color(0xFF3A3A3A);
  static const panel = Color(0xFF2C2C2C);
  static const panelBorder = Color(0xFF3D3D3D);
  static const label = Color(0xFFB3B3B3);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const row = Color(0xFFF3F4F6);
  static const accent = Color(0xFF818CF8);

  /// One hue per page: arrows take the color of the page they lead to.
  static const routes = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF0EA5E9),
    Color(0xFFA855F7),
    Color(0xFFEF4444),
  ];

  static Color of(Change change) => switch (change) {
    Change.added => const Color(0xFF22C55E),
    Change.removed => const Color(0xFFEF4444),
    Change.modified => const Color(0xFFF59E0B),
    Change.unchanged => label,
  };
}

const _mono = TextStyle(fontFamily: Fonts.code, fontSize: 11.5);

/// The space around the map, where arrows going back loop.
const _margin = EdgeInsets.fromLTRB(80, 60, 120, 140);

const _minScale = 0.2;
const _maxScale = 3.0;
const _animation = Duration(milliseconds: 300);
const _zoomDuration = Duration(milliseconds: 450);

/// The space taken by the toolbar, which the map is fitted below.
const _toolbarHeight = 64.0;

/// The width of the list of changes, which the map is fitted next to.
const _changesWidth = 280.0;

/// A Figma-like board: one frame per page, with arrows from buttons to the
/// pages they open.
///
/// [previews], [settings], [showSettings], [showBase] and [highlight] are
/// where the map starts, and can then be changed from its toolbar. Changing them animates the map to the new
/// value, which lets slides drive it.
class SiteMapView extends StatefulWidget {
  const SiteMapView({
    super.key,
    required this.siteMap,
    this.previews = false,
    this.settings = const PreviewSettings(),
    this.showSettings = false,
  }) : diff = null,
       showBase = false,
       highlight = false;

  /// Reviews [diff]: switches between the map before and after the change,
  /// and highlights what changed.
  SiteMapView.diff(
    SiteMapDiff this.diff, {
    super.key,
    this.previews = false,
    this.settings = const PreviewSettings(),
    this.showSettings = false,
    this.showBase = false,
    this.highlight = true,
  }) : siteMap = diff.head;

  final SiteMap siteMap;
  final SiteMapDiff? diff;

  /// Whether pages are rendered for real, rather than as wireframes.
  final bool previews;

  /// The theme, text size and device pages are rendered with.
  final PreviewSettings settings;

  /// Whether the panel changing the [settings] is open.
  final bool showSettings;

  /// Whether the [diff]'s base is shown, rather than its head.
  final bool showBase;

  /// Whether what the [diff] changed is highlighted.
  final bool highlight;

  @override
  State<SiteMapView> createState() => _SiteMapViewState();
}

class _SiteMapViewState extends State<SiteMapView>
    with SingleTickerProviderStateMixin {
  late var _previews = widget.previews;
  late var _showBase = widget.showBase;
  late var _highlight = widget.highlight;
  late var _settings = widget.settings;
  late var _showSettings = widget.showSettings;

  late var _layout = _makeLayout();
  final _transform = TransformationController();
  final _boardKey = GlobalKey();
  final _previewKeys = <String, GlobalKey>{};
  String? _selected;

  /// The page being used, after double-tapping it. It is drawn above the
  /// board rather than in it, so that the pointer goes to the app while over
  /// it, and to the board everywhere else.
  String? _focused;
  Link? _hovered;
  Size? _fittedTo;

  /// Animates the board when zooming on a page, along [_zoomTween].
  late final _zooming = AnimationController(
    vsync: this,
    duration: _zoomDuration,
  )..addListener(_onZoom);
  Matrix4Tween? _zoomTween;

  void _onZoom() {
    final t = Curves.easeInOutCubic.transform(_zooming.value);
    if (_zoomTween case final tween?) _transform.value = tween.transform(t);
  }

  /// Where the buttons of each link were found in the previews, in layout
  /// coordinates. Only the arrows depend on it, so that measuring repaints
  /// them without rebuilding the pages.
  final _sources = ValueNotifier(<Link, Rect>{});

  @override
  void didUpdateWidget(SiteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.previews != oldWidget.previews) _applyPreviews(widget.previews);
    if (widget.showBase != oldWidget.showBase) _applyShowBase(widget.showBase);
    if (widget.highlight != oldWidget.highlight) _highlight = widget.highlight;
    if (widget.settings != oldWidget.settings) _applySettings(widget.settings);
    if (widget.showSettings != oldWidget.showSettings) {
      _showSettings = widget.showSettings;
    }
  }

  @override
  void dispose() {
    _sources.dispose();
    _zooming.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _focus(String? id) {
    _focused = id;
    if (id != null) _selected = id;
  }

  /// Measures the buttons again after the next frame, so that arrows follow
  /// them as the user scrolls or clicks around the focused page.
  void _measureAfterFrame() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (mounted) _measure();
      })
      ..scheduleFrame();
  }

  SiteMapLayout _makeLayout() => SiteMapLayout(
    widget.siteMap,
    previews: _previews,
    screen: _settings.device.size,
    base: widget.diff?.base,
  );

  void _applySettings(PreviewSettings settings) {
    final relayout = settings.device != _settings.device;
    _settings = settings;
    if (!relayout) return;
    _focus(null);
    _layout = _makeLayout();
    _sources.value = {};
    // Refit on the next build, as the map changed size.
    _fittedTo = null;
  }

  late final List<String> _routeIds =
      widget.diff?.routeIds ??
      [for (final route in widget.siteMap.routes) route.id];

  /// The version of the map on screen.
  SiteMap get _shown => _showBase ? widget.diff!.base : widget.siteMap;

  /// The version of the map not on screen, if reviewing a diff.
  SiteMap? get _hidden => switch (widget.diff) {
    final diff? => _showBase ? diff.head : diff.base,
    null => null,
  };

  List<Link> get _links => switch (widget.diff) {
    final diff? => _showBase ? diff.baseLinks : diff.headLinks,
    null => _layout.links,
  };

  bool get _highlighting => widget.diff != null && _highlight;

  Change _routeChange(String id) =>
      widget.diff?.routeChange(id) ?? Change.unchanged;

  Change _linkChange(Link link) =>
      widget.diff?.linkChange(link, inHead: !_showBase) ?? Change.unchanged;

  /// Pages that are the same in both versions keep their widgets when
  /// switching versions, so only what changed animates.
  String _versionKey(String id) => _routeChange(id) == Change.unchanged
      ? id
      : '$id/${_showBase ? 'base' : 'head'}';

  Color _colorOf(String id) =>
      _Colors.routes[_routeIds.indexOf(id) % _Colors.routes.length];

  Color _linkColor(Link link) => switch (_linkChange(link)) {
    final change when _highlighting && change != Change.unchanged => _Colors.of(
      change,
    ),
    _ => _colorOf(link.to.id),
  };

  /// Where the layout's origin is drawn on the board.
  Offset get _offset => -_layout.bounds.topLeft + _margin.topLeft;

  Size get _contentSize {
    final bounds = _layout.bounds;
    return Size(
      bounds.width + _margin.horizontal,
      bounds.height + _margin.vertical,
    );
  }

  /// Zooms so that the whole map is visible, below the toolbar and next to
  /// the list of changes.
  void _fit(Size viewport) {
    _fittedTo = viewport;
    _zooming.stop();
    _transform.value = _fitting(
      Offset.zero & _contentSize,
      viewport,
      maxScale: 1,
    );
  }

  /// The transform showing [rect] of the board as large as possible, below
  /// the toolbar and next to the list of changes.
  Matrix4 _fitting(
    Rect rect,
    Size viewport, {
    double maxScale = _maxScale,
    double padding = 0,
  }) {
    final available = Rect.fromLTRB(
      padding,
      _toolbarHeight + padding,
      viewport.width - (widget.diff == null ? 0 : _changesWidth + 16) - padding,
      viewport.height - padding,
    );
    final scale = math.min(
      maxScale,
      math.min(available.width / rect.width, available.height / rect.height),
    );
    return Matrix4.identity()
      ..translateByDouble(
        available.center.dx - rect.center.dx * scale,
        available.center.dy - rect.center.dy * scale,
        0,
        1,
      )
      // Z is scaled too: InteractiveViewer reads the zoom as the largest
      // scale of any axis.
      ..scaleByDouble(scale, scale, scale, 1);
  }

  /// Zooms on the page [id], animating there.
  void _zoomOn(String id) {
    final viewport = _fittedTo;
    if (viewport == null) return;
    final target = _fitting(
      _layout.frames[id]!.shift(_offset),
      viewport,
      padding: 24,
    );
    _zoomTween = Matrix4Tween(begin: _transform.value, end: target);
    _zooming.forward(from: 0);
  }

  /// Zooms by [factor], around the center of the [viewport].
  void _zoomBy(double factor, Size viewport) {
    _zooming.stop();
    final current = _transform.value.getMaxScaleOnAxis();
    final scale = clampDouble(current * factor, _minScale, _maxScale) / current;
    final center = viewport.center(Offset.zero);
    _transform.value = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1)
      ..multiply(_transform.value);
  }

  void _applyPreviews(bool previews) {
    _focus(null);
    _previews = previews;
    _layout = _makeLayout();
    _sources.value = {};
    _hovered = null;
    // Refit on the next build, as the map changed size.
    _fittedTo = null;
  }

  void _applyShowBase(bool showBase) {
    _focus(null);
    _showBase = showBase;
    _sources.value = {};
    _hovered = null;
  }

  /// Finds the buttons of each link in the rendered previews.
  ///
  /// Only the visible part of a button counts: a button partly scrolled out
  /// of its page is clipped, and one fully scrolled out has no arrow.
  void _measure() {
    final board = _boardKey.currentContext?.findRenderObject();
    final sources = <Link, Rect>{};
    if (_previews && board is RenderBox) {
      // Through global coordinates: the focused page is not in the board,
      // and getTransformTo is wrong across branches of the tree.
      final fromGlobal = Matrix4.inverted(board.getTransformTo(null));
      Rect toBoard(RenderBox box) => MatrixUtils.transformRect(
        fromGlobal.multiplied(box.getTransformTo(null)),
        Offset.zero & box.size,
      ).shift(-_offset);

      for (final link in _links) {
        final finder = link.from.elements[link.elementIndex].finder;
        final preview = _previewKeys[_versionKey(link.from.id)]?.currentContext;
        if (finder == null || preview == null) continue;
        final element = _find(preview as Element, finder);
        final box = element?.renderObject;
        if (box is! RenderBox || !box.hasSize) continue;

        final frame = _layout.frames[link.from.id]!;
        var visible = Rect.fromLTRB(
          frame.left,
          frame.top + FrameMetrics.label,
          frame.right,
          frame.bottom,
        );
        if (Scrollable.maybeOf(element!)?.context.findRenderObject()
            case final RenderBox viewport? when viewport.hasSize) {
          visible = visible.intersect(toBoard(viewport));
        }
        final source = toBoard(box).intersect(visible);
        if (source.width > 0 && source.height > 0) sources[link] = source;
      }
    }
    if (!mapEquals(sources, _sources.value)) _sources.value = sources;
  }

  static Element? _find(Element root, bool Function(Widget) finder) =>
      _findAll(root, finder).firstOrNull;

  /// The elements below [root] whose widget matches [finder], in order.
  static Iterable<Element> _findAll(
    Element root,
    bool Function(Widget) finder,
  ) sync* {
    final matches = <Element>[];
    void visit(Element element) {
      if (finder(element.widget)) {
        matches.add(element);
      } else {
        element.visitChildren(visit);
      }
    }

    root.visitChildren(visit);
    yield* matches;
  }

  bool _isActive(Link link) {
    if (_hovered case final hovered?) return link == hovered;
    if (_selected case final selected?) {
      return link.from.id == selected || link.to.id == selected;
    }
    if (_highlighting) return _linkChange(link) != Change.unchanged;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _Colors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Colors.panelBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = constraints.biggest;
          if (_fittedTo != viewport) _fit(viewport);
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _DotGridPainter(_transform)),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _selected = null;
                  _showSettings = false;
                  _focus(null);
                }),
                child: InteractiveViewer(
                  transformationController: _transform,
                  constrained: false,
                  // A bounded canvas snaps to its edge when zoomed out past
                  // the viewport, making the map jump.
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: _minScale,
                  // Zooming by hand takes over from zooming on a page.
                  onInteractionStart: (_) => _zooming.stop(),
                  maxScale: _maxScale,
                  // Wireframes and screens have different layouts, so the
                  // new one fades in rather than jumping.
                  child: TweenAnimationBuilder(
                    key: ValueKey(_previews),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: _animation,
                    builder: (context, opacity, child) =>
                        Opacity(opacity: opacity, child: child),
                    child: _board(),
                  ),
                ),
              ),
              ?_focusedPage(),
              ?_focusedLinks(),
              Positioned(
                left: 16,
                top: 16,
                child: _Toolbar(
                  children: [
                    if (widget.diff case final diff?) ...[
                      _Segmented(
                        value: _showBase,
                        onChanged: (value) =>
                            setState(() => _applyShowBase(value)),
                        options: [
                          (
                            true,
                            'Before · ${diff.baseRef}',
                            Icons.history_rounded,
                          ),
                          (
                            false,
                            'After · ${diff.headRef}',
                            Icons.call_split_rounded,
                          ),
                        ],
                      ),
                      _Toggle(
                        label: 'Highlight changes',
                        icon: Icons.auto_awesome_outlined,
                        value: _highlight,
                        onChanged: (value) =>
                            setState(() => _highlight = value),
                      ),
                    ] else ...[
                      Text(
                        widget.siteMap.source,
                        style: _mono.copyWith(color: _Colors.label),
                      ),
                      Text(
                        '${widget.siteMap.routes.length} pages · '
                        '${_layout.links.length} links',
                        style: const TextStyle(
                          color: _Colors.label,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    _Segmented(
                      value: _previews,
                      onChanged: (value) =>
                          setState(() => _applyPreviews(value)),
                      options: const [
                        (false, 'Wireframes', Icons.view_agenda_outlined),
                        (true, 'Screens', Icons.smartphone_rounded),
                      ],
                    ),
                    if (_previews)
                      _Toggle(
                        label: 'Preview',
                        icon: Icons.tune_rounded,
                        value: _showSettings,
                        onChanged: (value) =>
                            setState(() => _showSettings = value),
                      ),
                    _ZoomControls(
                      transform: _transform,
                      onZoom: (factor) => _zoomBy(factor, viewport),
                      onFit: () => setState(() => _fit(viewport)),
                    ),
                  ],
                ),
              ),
              if (_showSettings && _previews)
                Positioned(
                  left: 16,
                  top: _toolbarHeight + 8,
                  child: _PreviewSettingsPanel(
                    settings: _settings,
                    onChanged: (settings) =>
                        setState(() => _applySettings(settings)),
                  ),
                ),
              if (widget.diff case final diff?)
                Positioned(
                  right: 16,
                  top: _toolbarHeight + 8,
                  bottom: 16,
                  width: _changesWidth,
                  child: _ChangesPanel(
                    diff: diff,
                    selected: _selected,
                    onSelect: (id) =>
                        setState(() => _selected = _selected == id ? null : id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _board() {
    return SizedBox.fromSize(
      key: _boardKey,
      size: _contentSize,
      child: Stack(
        children: [
          for (final id in _routeIds)
            Positioned.fromRect(
              rect: _layout.frames[id]!.shift(_offset),
              child: _frameOf(id),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: _animation,
                layoutBuilder: _stackExpanded,
                child: CustomPaint(
                  key: ValueKey(_showBase),
                  painter: _LinksPainter(
                    layout: _layout,
                    links: _links,
                    offset: _offset,
                    sources: _sources,
                    colorOf: _linkColor,
                    isActive: _isActive,
                    // Drawn above the focused page instead.
                    paints: (link) => link.from.id != _focused,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frameOf(String id) {
    final shown = _shown.routeById(id);
    // A page missing from this version fades out, rather than disappearing.
    final route = shown ?? _hidden!.routeById(id)!;
    final change = _routeChange(id);
    final changed = _highlighting && change != Change.unchanged;
    final isHome = id == _routeIds.first;
    final versionKey = _versionKey(id);

    final label = _FrameLabel(
      route: route,
      isHome: isHome,
      selected: id == _selected,
      color: _colorOf(id),
      change: changed ? change : null,
      showPath: _previews,
      focused: id == _focused,
    );
    final outline = changed ? _Colors.of(change) : null;

    final Widget frame = switch (route.preview) {
      final preview? when _previews => _PreviewFrame(
        label: label,
        selected: id == _selected,
        outline: outline,
        onTap: () => setState(() {
          _selected = id;
          if (_focused != id) _focus(null);
        }),
        onDoubleTap: () {
          setState(() => _focus(id));
          _zoomOn(id);
        },
        // The focused page is drawn above the board instead.
        child: id == _focused
            ? null
            : ScreenPreview(
                settings: _settings,
                links: const [],
                child: _previewOf(id, preview),
              ),
      ),
      _ => _Frame(
        route: route,
        label: label,
        isHome: isHome,
        selected: id == _selected,
        outline: outline,
        color: _colorOf(id),
        colorOf: _colorOf,
        titleOf: (id) =>
            (_shown.routeById(id) ?? _hidden?.routeById(id))?.title ?? id,
        changeOf: (element) => switch (widget.diff) {
          // Every button of a new page is new: the page's badge says it all.
          final diff? when _highlighting && change == Change.modified =>
            diff.elementChange(id, element, inHead: !_showBase),
          _ => Change.unchanged,
        },
        onTap: () => setState(() => _selected = id),
        onHoverElement: (index) => setState(() {
          _hovered = index == null
              ? null
              : _links
                    .where((link) => link.from.id == id)
                    .where((link) => link.elementIndex == index)
                    .firstOrNull;
        }),
      ),
    };

    return IgnorePointer(
      ignoring: shown == null,
      child: AnimatedOpacity(
        duration: _animation,
        opacity: shown == null
            ? 0
            : _highlighting && change == Change.unchanged
            ? 0.35
            : 1,
        child: AnimatedSwitcher(
          duration: _animation,
          layoutBuilder: _stackExpanded,
          child: KeyedSubtree(key: ValueKey(versionKey), child: frame),
        ),
      ),
    );
  }

  Widget _previewOf(String id, Widget preview) => KeyedSubtree(
    key: _previewKeys.putIfAbsent(_versionKey(id), GlobalKey.new),
    child: preview,
  );

  /// The focused page, drawn above the board where the board shows it, so
  /// that it gets the pointer instead of the board.
  Widget? _focusedPage() {
    final id = _focused;
    if (id == null) return null;
    final route = _shown.routeById(id);
    final preview = route?.preview;
    if (route == null || preview == null || !_previews) return null;

    final frame = _layout.frames[id]!.shift(_offset);
    final card = Rect.fromLTRB(
      frame.left,
      frame.top + FrameMetrics.label,
      frame.right,
      frame.bottom,
    );
    final change = _routeChange(id);

    return Positioned(
      left: 0,
      top: 0,
      child: AnimatedBuilder(
        animation: _transform,
        builder: (context, child) => Transform(
          transform: _transform.value.clone()
            ..translateByDouble(card.left, card.top, 0, 1),
          child: child,
        ),
        child: SizedBox.fromSize(
          size: card.size,
          // Clicks the app ignores must not reach the board below.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Listener(
              onPointerUp: (_) => _measureAfterFrame(),
              onPointerSignal: (_) => _measureAfterFrame(),
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (_) {
                  _measureAfterFrame();
                  return false;
                },
                child: _FrameCard(
                  selected: true,
                  outline: _highlighting && change != Change.unchanged
                      ? _Colors.of(change)
                      : null,
                  child: ScreenPreview(
                    settings: _settings,
                    // Without a navigator, buttons opening other pages can't
                    // work.
                    links: [
                      for (final element in route.elements)
                        if (element.finder case final finder?
                            when element.target != null ||
                                element.kind == ElementKind.back)
                          finder,
                    ],
                    child: _previewOf(id, preview),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The arrows leaving the focused page, drawn above it so that they stay
  /// visible where they cross it.
  Widget? _focusedLinks() {
    final id = _focused;
    if (id == null || !_previews) return null;
    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _transform,
          builder: (context, child) =>
              Transform(transform: _transform.value, child: child),
          child: CustomPaint(
            size: _contentSize,
            painter: _LinksPainter(
              layout: _layout,
              links: _links,
              offset: _offset,
              sources: _sources,
              colorOf: _linkColor,
              isActive: _isActive,
              paints: (link) => link.from.id == id,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _stackExpanded(Widget? current, List<Widget> previous) {
    return Stack(fit: StackFit.expand, children: [...previous, ?current]);
  }
}

/// The page name written above a frame, like in Figma.
class _FrameLabel extends StatelessWidget {
  const _FrameLabel({
    required this.route,
    required this.isHome,
    required this.selected,
    required this.color,
    required this.change,
    required this.showPath,
    required this.focused,
  });

  final RouteNode route;
  final bool isHome;
  final bool selected;
  final bool focused;
  final Color color;

  /// How the page changed, when highlighting changes.
  final Change? change;

  /// Whether to show the route's path, which wireframes show in their app bar.
  final bool showPath;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? _Colors.accent : _Colors.label;
    return SizedBox(
      height: FrameMetrics.label,
      child: Row(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHome ? Icons.home_outlined : Icons.crop_portrait_rounded,
            size: 14,
            color: textColor,
          ),
          Text(route.title, style: TextStyle(fontSize: 12.5, color: textColor)),
          if (change case final change?) _ChangeBadge(change),
          if (focused) const _Badge('LIVE', color: _Colors.accent),
          const Spacer(),
          if (showPath)
            Text(
              routePath(route, isHome: isHome),
              style: _mono.copyWith(color: color, fontSize: 10.5),
            ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge(this.change);

  final Change change;

  @override
  Widget build(BuildContext context) {
    return _Badge(switch (change) {
      Change.added => 'NEW',
      Change.removed => 'REMOVED',
      Change.modified => 'CHANGED',
      Change.unchanged => '',
    }, color: _Colors.of(change));
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// The white card of a frame, with an outline when selected or changed.
class _FrameCard extends StatelessWidget {
  const _FrameCard({
    required this.selected,
    required this.outline,
    required this.child,
  });

  final bool selected;
  final Color? outline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final border = selected ? _Colors.accent : outline;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
          if (outline case final outline?)
            BoxShadow(color: outline.withValues(alpha: 0.45), blurRadius: 32),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border ?? Colors.transparent,
          width: outline == null ? 2 : 3,
        ),
      ),
      child: child,
    );
  }
}

/// A page of the app, rendered for real with fake data.
///
/// Until double-tapped, the page is only a picture: the board handles the
/// pointer.
class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({
    required this.label,
    required this.selected,
    required this.outline,
    required this.onTap,
    required this.onDoubleTap,
    required this.child,
  });

  final Widget label;
  final bool selected;
  final Color? outline;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  /// The page, or null while it is drawn somewhere else.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          Expanded(
            child: _FrameCard(
              selected: selected,
              outline: outline,
              child: IgnorePointer(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

/// A page of the app at the size of a device, scaled to fit, with its
/// [links] to other pages disabled.
class ScreenPreview extends StatelessWidget {
  const ScreenPreview({
    super.key,
    this.settings = const PreviewSettings(),
    this.links = const [],
    required this.child,
  });

  final PreviewSettings settings;

  /// Matches the buttons opening other pages.
  final List<bool Function(Widget)> links;
  final Widget child;

  static const _insets = EdgeInsets.only(top: 44, bottom: 24);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox.fromSize(
        size: settings.device.size,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: settings.device.size,
            padding: _insets,
            viewPadding: _insets,
            viewInsets: EdgeInsets.zero,
            textScaler: TextScaler.linear(settings.textScale),
            platformBrightness: settings.brightness,
          ),
          child: ScrollConfiguration(
            // Mice scroll with their wheel, not by dragging: a drag starts
            // after 2 pixels, so the slightest movement while clicking would
            // turn the click into a scroll.
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: _LinkBlocker(links: links, child: child),
          ),
        ),
      ),
    );
  }
}

/// Disables taps on the widgets of [child] matching [links].
///
/// Only taps are blocked: the pointer still reaches everything, so scrolling
/// works even when it starts over a link.
class _LinkBlocker extends StatefulWidget {
  const _LinkBlocker({required this.links, required this.child});

  final List<bool Function(Widget)> links;
  final Widget child;

  @override
  State<_LinkBlocker> createState() => _LinkBlockerState();
}

class _LinkBlockerState extends State<_LinkBlocker> {
  /// Whether the global [position] is over a link.
  bool _isLink(Offset position) {
    for (final finder in widget.links) {
      for (final element in _SiteMapViewState._findAll(
        context as Element,
        finder,
      )) {
        final box = element.renderObject;
        if (box is! RenderBox || !box.hasSize || !box.attached) continue;
        final rect = MatrixUtils.transformRect(
          box.getTransformTo(null),
          Offset.zero & box.size,
        );
        if (rect.contains(position)) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _LinkTapBlocker: GestureRecognizerFactoryWithHandlers<_LinkTapBlocker>(
          () => _LinkTapBlocker(isLink: _isLink),
          (recognizer) => recognizer.isLink = _isLink,
        ),
      },
      child: widget.child,
    );
  }
}

/// Wins the gesture arena for taps on links, so that the links' own tap
/// handlers are cancelled.
///
/// It only claims the pointer when it is released: if it moved enough to
/// start a scroll first, the scroll wins instead.
class _LinkTapBlocker extends OneSequenceGestureRecognizer {
  _LinkTapBlocker({required this.isLink});

  bool Function(Offset position) isLink;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (isLink(event.position)) {
      startTrackingPointer(event.pointer, event.transform);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      resolve(GestureDisposition.accepted);
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'link tap blocker';
}

/// The environment pages are previewed in: theme, text size and device.
class _PreviewSettingsPanel extends StatelessWidget {
  const _PreviewSettingsPanel({
    required this.settings,
    required this.onChanged,
  });

  final PreviewSettings settings;
  final ValueChanged<PreviewSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, Widget control) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: _Colors.label, fontSize: 13),
            ),
          ),
          control,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.panelBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          row(
            'Theme',
            _Segmented(
              value: settings.brightness,
              onChanged: (brightness) =>
                  onChanged(settings.copyWith(brightness: brightness)),
              options: const [
                (Brightness.light, 'Light', Icons.light_mode_outlined),
                (Brightness.dark, 'Dark', Icons.dark_mode_outlined),
              ],
            ),
          ),
          row(
            'Text size',
            _Segmented(
              value: settings.textScale,
              onChanged: (textScale) =>
                  onChanged(settings.copyWith(textScale: textScale)),
              options: const [
                (1.0, '100%', Icons.text_fields_rounded),
                (1.3, '130%', Icons.text_fields_rounded),
                (1.6, '160%', Icons.text_fields_rounded),
              ],
            ),
          ),
          row(
            'Device',
            _Segmented(
              value: settings.device,
              onChanged: (device) =>
                  onChanged(settings.copyWith(device: device)),
              options: [
                for (final device in PreviewDevice.values)
                  (
                    device,
                    device.label,
                    device == PreviewDevice.tablet
                        ? Icons.tablet_mac_rounded
                        : Icons.smartphone_rounded,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Icon(
            Icons.account_tree_outlined,
            size: 18,
            color: _Colors.accent,
          ),
          const Text(
            'Site map',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Mutually exclusive options, like a segmented button.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String, IconData)> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _Colors.canvas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (option, label, icon) in options)
            _Chip(
              label: label,
              icon: icon,
              active: option == value,
              onTap: () => onChanged(option),
            ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _Colors.canvas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _Chip(
        label: label,
        icon: icon,
        active: value,
        onTap: () => onChanged(!value),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _Colors.accent.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? _Colors.accent : _Colors.label,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _Colors.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.transform,
    required this.onZoom,
    required this.onFit,
  });

  final TransformationController transform;
  final ValueChanged<double> onZoom;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom out',
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: () => onZoom(1 / 1.25),
          icon: const Icon(Icons.remove_rounded, color: _Colors.label),
        ),
        ListenableBuilder(
          listenable: transform,
          builder: (context, _) => SizedBox(
            width: 44,
            child: Text(
              '${(transform.value.getMaxScaleOnAxis() * 100).round()}%',
              textAlign: TextAlign.center,
              style: _mono.copyWith(color: _Colors.label, fontSize: 12),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Zoom in',
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: () => onZoom(1.25),
          icon: const Icon(Icons.add_rounded, color: _Colors.label),
        ),
        IconButton(
          tooltip: 'Fit to screen',
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: onFit,
          icon: const Icon(Icons.fit_screen_outlined, color: _Colors.label),
        ),
      ],
    );
  }
}

/// What a pull request changed: the pages first, then the files.
class _ChangesPanel extends StatelessWidget {
  const _ChangesPanel({
    required this.diff,
    required this.selected,
    required this.onSelect,
  });

  final SiteMapDiff diff;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final pages = diff.changedRouteIds;
    int count(Change change) =>
        pages.where((id) => diff.routeChange(id) == change).length;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _Colors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Colors.panelBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8,
              children: [
                const Icon(
                  Icons.call_split_rounded,
                  size: 16,
                  color: _Colors.accent,
                ),
                Expanded(
                  child: Text(
                    '${diff.baseRef} ← ${diff.headRef}',
                    overflow: TextOverflow.ellipsis,
                    style: _mono.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12.5, color: _Colors.label),
                children: [
                  for (final (change, sign) in [
                    (Change.added, '+'),
                    (Change.modified, '~'),
                    (Change.removed, '−'),
                  ])
                    if (count(change) > 0) ...[
                      TextSpan(
                        text:
                            '$sign${count(change)} '
                            '${count(change) == 1 ? 'page' : 'pages'}',
                        style: TextStyle(color: _Colors.of(change)),
                      ),
                      const TextSpan(text: '  '),
                    ],
                  TextSpan(
                    text: '+${diff.addedLinks}',
                    style: TextStyle(color: _Colors.of(Change.added)),
                  ),
                  TextSpan(
                    text: '/−${diff.removedLinks}',
                    style: TextStyle(color: _Colors.of(Change.removed)),
                  ),
                  const TextSpan(text: ' links'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PanelHeading('Pages'),
            for (final id in pages)
              _PageChange(
                route: (diff.head.routeById(id) ?? diff.base.routeById(id))!,
                change: diff.routeChange(id),
                selected: id == selected,
                onTap: () => onSelect(id),
              ),
            const SizedBox(height: 16),
            const _PanelHeading('Files'),
            for (final file in diff.files) _FileChangeRow(file),
          ],
        ),
      ),
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _Colors.label,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _PageChange extends StatelessWidget {
  const _PageChange({
    required this.route,
    required this.change,
    required this.selected,
    required this.onTap,
  });

  final RouteNode route;
  final Change change;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _Colors.accent.withValues(alpha: 0.18) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                route.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
            _ChangeBadge(change),
          ],
        ),
      ),
    );
  }
}

class _FileChangeRow extends StatelessWidget {
  const _FileChangeRow(this.file);

  final FileChange file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        spacing: 8,
        children: [
          Text(
            switch (file.change) {
              Change.added => 'A',
              Change.removed => 'D',
              _ => 'M',
            },
            style: _mono.copyWith(
              color: _Colors.of(file.change),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(file.path, style: _mono.copyWith(color: Colors.white)),
          ),
          if (file.additions > 0)
            Text(
              '+${file.additions}',
              style: _mono.copyWith(color: _Colors.of(Change.added)),
            ),
          if (file.deletions > 0)
            Text(
              '−${file.deletions}',
              style: _mono.copyWith(color: _Colors.of(Change.removed)),
            ),
        ],
      ),
    );
  }
}

/// A page, drawn as a frame listing what can be tapped on it.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.route,
    required this.label,
    required this.isHome,
    required this.selected,
    required this.outline,
    required this.color,
    required this.colorOf,
    required this.titleOf,
    required this.changeOf,
    required this.onTap,
    required this.onHoverElement,
  });

  final RouteNode route;
  final Widget label;
  final bool isHome;
  final bool selected;
  final Color? outline;
  final Color color;
  final Color Function(String routeId) colorOf;
  final String Function(String routeId) titleOf;
  final Change Function(UiElement element) changeOf;
  final VoidCallback onTap;
  final ValueChanged<int?> onHoverElement;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          Expanded(
            child: _FrameCard(
              selected: selected,
              outline: outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _appBar(),
                  _condition(),
                  const SizedBox(height: FrameMetrics.listPadding),
                  if (route.elements.isEmpty)
                    const SizedBox(
                      height: FrameMetrics.element,
                      child: Center(
                        child: Text(
                          'Nothing to tap',
                          style: TextStyle(color: _Colors.muted, fontSize: 13),
                        ),
                      ),
                    ),
                  for (final (index, element) in route.elements.indexed)
                    MouseRegion(
                      onEnter: (_) => onHoverElement(index),
                      onExit: (_) => onHoverElement(null),
                      child: _ElementRow(
                        element: element,
                        change: changeOf(element),
                        targetTitle: switch (element.target) {
                          final id? => titleOf(id),
                          null => null,
                        },
                        targetColor: switch (element.target) {
                          final id? => colorOf(id),
                          null => null,
                        },
                      ),
                    ),
                  const SizedBox(height: FrameMetrics.listPadding),
                  // Versions of a page with fewer buttons leave a gap, so that
                  // frames have the same size in both versions.
                  const Spacer(),
                  _footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      height: FrameMetrics.appBar,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              route.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Colors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              routePath(route, isHome: isHome),
              style: _mono.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _condition() {
    return Container(
      height: FrameMetrics.condition,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF9FAFB),
      alignment: Alignment.centerLeft,
      child: Text.rich(
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: [
            TextSpan(
              text: isHome ? 'Home page' : 'Shown when ',
              style: const TextStyle(color: _Colors.muted, fontSize: 12),
            ),
            if (route.condition case final condition? when !isHome)
              TextSpan(
                text: condition,
                style: _mono.copyWith(color: _Colors.ink, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      height: FrameMetrics.footer,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '${route.screen} · ${route.location}',
        overflow: TextOverflow.ellipsis,
        style: _mono.copyWith(color: _Colors.muted, fontSize: 10.5),
      ),
    );
  }
}

String routePath(RouteNode route, {required bool isHome}) {
  if (isHome) return '/';
  return ['', route.id, for (final param in route.params) ':$param'].join('/');
}

class _ElementRow extends StatelessWidget {
  const _ElementRow({
    required this.element,
    required this.change,
    required this.targetTitle,
    required this.targetColor,
  });

  final UiElement element;

  /// How the element changed, when highlighting changes.
  final Change change;
  final String? targetTitle;
  final Color? targetColor;

  static IconData iconOf(ElementKind kind) => switch (kind) {
    ElementKind.button => Icons.smart_button_outlined,
    ElementKind.iconButton => Icons.radio_button_checked_rounded,
    ElementKind.tile => Icons.grid_view_rounded,
    ElementKind.back => Icons.arrow_back_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final linked = targetColor != null;
    final changed = change != Change.unchanged;
    final changeColor = _Colors.of(change);
    final background = changed
        ? changeColor.withValues(alpha: 0.14)
        : linked
        ? targetColor!.withValues(alpha: 0.08)
        : _Colors.row;
    final border = changed
        ? changeColor
        : linked
        ? targetColor!.withValues(alpha: 0.35)
        : Colors.transparent;

    return Container(
      height: FrameMetrics.element - 6,
      margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        spacing: 8,
        children: [
          if (changed)
            Text(
              switch (change) {
                Change.added => '+',
                Change.removed => '−',
                _ => '~',
              },
              style: _mono.copyWith(
                color: changeColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Icon(
              iconOf(element.kind),
              size: 16,
              color: targetColor ?? _Colors.muted,
            ),
          Expanded(
            child: Tooltip(
              message: '${element.kind.name} · ${element.location}',
              child: Text(
                element.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: linked || changed ? _Colors.ink : _Colors.muted,
                  fontSize: 13.5,
                  fontWeight: linked || changed
                      ? FontWeight.w600
                      : FontWeight.w400,
                  decoration: change == Change.removed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ),
          if (targetTitle case final title?)
            Text(
              title,
              style: TextStyle(
                color: targetColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            )
          else if (element.kind == ElementKind.back)
            Text('pop', style: _mono.copyWith(color: _Colors.muted)),
        ],
      ),
    );
  }
}

class _LinksPainter extends CustomPainter {
  _LinksPainter({
    required this.layout,
    required this.links,
    required this.offset,
    required ValueListenable<Map<Link, Rect>> sources,
    required this.colorOf,
    required this.isActive,
    required this.paints,
  }) : _sources = sources,
       super(repaint: sources);

  /// Which of the [links] to paint. All links still get a lane, so that
  /// painters showing different links agree on where arrows go.
  final bool Function(Link link) paints;

  final SiteMapLayout layout;
  final List<Link> links;
  final Offset offset;

  /// The buttons measured in the previews, which arrows start from.
  final ValueListenable<Map<Link, Rect>> _sources;
  Map<Link, Rect> get sources => _sources.value;
  final Color Function(Link link) colorOf;
  final bool Function(Link link) isActive;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(offset.dx, offset.dy);

    // Arrows that don't go forward each get their own lane, so they don't
    // overlap.
    var lane = 0;
    final paths = [
      for (final link in links)
        // Previews are measured after they are laid out, so their arrows are
        // drawn one frame late.
        if (!layout.previews || sources.containsKey(link))
          (
            link,
            layout.pathOf(
              link,
              start: sources[link]?.centerRight,
              lane: layout.depth[link.to.id]! > layout.depth[link.from.id]!
                  ? 0
                  : lane++,
            ),
          ),
    ];

    // Inactive arrows are painted first, so that active ones are on top.
    for (final active in [false, true]) {
      for (final (link, path) in paths) {
        if (isActive(link) != active || !paints(link)) continue;
        final color = colorOf(link).withValues(alpha: active ? 1 : 0.18);
        final stroke = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 2.2 : 1.6
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, stroke);
        final metric = path.computeMetrics().last;
        final tip = metric.getTangentForOffset(metric.length)!;
        _arrowHead(canvas, tip, Paint()..color = color);
        _paintSource(
          canvas,
          sources[link],
          metric.getTangentForOffset(0)!.position,
          stroke,
        );
      }
    }
  }

  void _arrowHead(Canvas canvas, Tangent tip, Paint paint) {
    final direction = tip.vector / tip.vector.distance;
    final normal = Offset(-direction.dy, direction.dx);
    final base = tip.position - direction * 10;
    canvas.drawPath(
      Path()
        ..moveTo(tip.position.dx, tip.position.dy)
        ..lineTo((base + normal * 5).dx, (base + normal * 5).dy)
        ..lineTo((base - normal * 5).dx, (base - normal * 5).dy)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LinksPainter oldDelegate) => true;
}

/// Outlines the button an arrow starts from, if measured, and draws the dot
/// at the [start] of the arrow.
void _paintSource(Canvas canvas, Rect? source, Offset start, Paint stroke) {
  if (source != null) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(source.inflate(3), const Radius.circular(10)),
      stroke,
    );
  }
  canvas
    ..drawCircle(start, 5, Paint()..color = Colors.white)
    ..drawCircle(start, 3.5, Paint()..color = stroke.color);
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.transform) : super(repaint: transform);

  final TransformationController transform;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = transform.value.getMaxScaleOnAxis();
    final translation = transform.value.getTranslation();
    final spacing = 24 * scale;
    if (spacing < 6) return;
    final paint = Paint()..color = _Colors.dots;
    final startX = translation.x % spacing;
    final startY = translation.y % spacing;
    for (var x = startX; x < size.width; x += spacing) {
      for (var y = startY; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
