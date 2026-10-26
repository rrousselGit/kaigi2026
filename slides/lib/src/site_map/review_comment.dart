// Demo devtool UI, shown in the slides.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'diff.dart';
import 'site_map.dart';
import 'site_map_view.dart';

const _added = Color(0xFF22C55E);
const _removed = Color(0xFFEF4444);
const _modified = Color(0xFFF59E0B);

Color _colorOf(Change change) => switch (change) {
  Change.added => _added,
  Change.removed => _removed,
  _ => _modified,
};

/// What a bot could comment on a pull request, after rendering the site map
/// in CI: the pages it changes, before and after, and the links it adds or
/// removes.
class SiteMapReviewComment extends StatelessWidget {
  const SiteMapReviewComment({
    super.key,
    required this.diff,
    this.screenWidth = 132,
  });

  final SiteMapDiff diff;

  /// The width each screen is rendered at.
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final pages = diff.changedRouteIds;
    String plural(int count, String word) =>
        '$count $word${count == 1 ? '' : 's'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_tree_outlined,
                size: 18,
                color: palette.accent,
              ),
            ),
            Text(
              'site-map-bot',
              style: TextStyle(
                color: palette.heading,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: palette.cardBorder),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'bot',
                style: TextStyle(color: palette.textMuted, fontSize: 11),
              ),
            ),
            Text(
              'commented just now',
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: TextStyle(color: palette.textMain, fontSize: 15),
            children: [
              const TextSpan(text: 'This pull request changes '),
              TextSpan(
                text: plural(pages.length, 'page'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ', adds '),
              TextSpan(
                text: plural(diff.addedLinks, 'link'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _added,
                ),
              ),
              const TextSpan(text: ' and removes '),
              TextSpan(
                text: plural(diff.removedLinks, 'link'),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: diff.removedLinks == 0 ? null : _removed,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 28,
          runSpacing: 20,
          children: [
            for (final id in pages)
              _PageChange(diff: diff, id: id, screenWidth: screenWidth),
          ],
        ),
      ],
    );
  }
}

/// A changed page, before and after, with the links it gained or lost.
class _PageChange extends StatelessWidget {
  const _PageChange({
    required this.diff,
    required this.id,
    required this.screenWidth,
  });

  final SiteMapDiff diff;
  final String id;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final change = diff.routeChange(id);
    final before = diff.base.routeById(id);
    final after = diff.head.routeById(id);

    final links = [
      for (final link in diff.headLinks)
        if (link.from.id == id &&
            diff.linkChange(link, inHead: true) == Change.added)
          (Change.added, link),
      for (final link in diff.baseLinks)
        if (link.from.id == id &&
            diff.linkChange(link, inHead: false) == Change.removed)
          (Change.removed, link),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              (after ?? before)!.title,
              style: TextStyle(
                color: palette.heading,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            _Badge(switch (change) {
              Change.added => 'NEW',
              Change.removed => 'REMOVED',
              _ => 'CHANGED',
            }, color: _colorOf(change)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            if (before?.preview case final preview?)
              _Screen(
                label: diff.baseRef,
                width: screenWidth,
                preview: preview,
                highlights: _changed(before!, inHead: false),
                color: _removed,
              ),
            if (after?.preview case final preview?)
              _Screen(
                label: diff.headRef,
                width: screenWidth,
                preview: preview,
                highlights: _changed(after!, inHead: true),
                color: _added,
              ),
          ],
        ),
        for (final (change, link) in links)
          Text.rich(
            TextSpan(
              style: TextStyle(color: palette.textMuted, fontSize: 13),
              children: [
                TextSpan(
                  text: change == Change.added ? '+ ' : '− ',
                  style: TextStyle(
                    color: _colorOf(change),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: link.from.elements[link.elementIndex].label,
                  style: TextStyle(
                    color: palette.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' → ${link.to.title}'),
              ],
            ),
          ),
      ],
    );
  }

  /// Finds the buttons of [route] that the pull request added (in its head)
  /// or removed (in its base), to outline them.
  List<bool Function(Widget)> _changed(
    RouteNode route, {
    required bool inHead,
  }) {
    return [
      for (final element in route.elements)
        if (element.finder case final finder?)
          if (diff.routeChange(id) == Change.modified &&
              diff.elementChange(id, element, inHead: inHead) !=
                  Change.unchanged)
            finder,
    ];
  }
}

/// A page rendered for real, with some of its widgets outlined.
class _Screen extends StatefulWidget {
  const _Screen({
    required this.label,
    required this.width,
    required this.preview,
    required this.highlights,
    required this.color,
  });

  final String label;
  final double width;
  final Widget preview;
  final List<bool Function(Widget)> highlights;
  final Color color;

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  final _page = GlobalKey();
  var _outlines = <Rect>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(_Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The page may have moved or changed size.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  /// Finds the outlined widgets once the page is laid out.
  void _measure() {
    final page = _page.currentContext;
    if (!mounted || page == null) return;
    final box = page.findRenderObject()! as RenderBox;
    final outlines = <Rect>[];
    void visit(Element element) {
      if (widget.highlights.any((finder) => finder(element.widget))) {
        if (element.renderObject case final RenderBox found
            when found.hasSize) {
          outlines.add(
            MatrixUtils.transformRect(
              found.getTransformTo(box),
              Offset.zero & found.size,
            ),
          );
        }
        return;
      }
      element.visitChildren(visit);
    }

    (page as Element).visitChildren(visit);
    setState(() => _outlines = outlines);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final size = PreviewDevice.phone.size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: widget.width,
          height: widget.width * size.height / size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.cardBorder),
          ),
          child: IgnorePointer(
            child: CustomPaint(
              foregroundPainter: _OutlinesPainter(_outlines, widget.color),
              child: KeyedSubtree(
                key: _page,
                child: ScreenPreview(child: widget.preview),
              ),
            ),
          ),
        ),
        Text(
          widget.label,
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 11.5,
            fontFamily: Fonts.code,
          ),
        ),
      ],
    );
  }
}

class _OutlinesPainter extends CustomPainter {
  _OutlinesPainter(this.outlines, this.color);

  final List<Rect> outlines;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final outline in outlines) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(outline.inflate(3), const Radius.circular(6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OutlinesPainter oldDelegate) =>
      oldDelegate.outlines != outlines || oldDelegate.color != color;
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
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
