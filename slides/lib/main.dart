// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

// The windowing API is experimental, and only exposed through internal files.
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';

import 'confetti.dart';
import 'example_panel.dart';
import 'pdf_export.dart';
import 'slides.dart';
import 'theme.dart';
import 'widgets.dart';

/// Whether the slides can open other windows, which the web does not support.
final _windowing = isWindowingEnabled && !kIsWeb;

void main() {
  if (kDebugMode || kProfileMode) enableFlutterDriverExtension();
  if (_windowing) {
    // The macOS runner starts without any window (see AppDelegate.swift), as
    // windows can only be added at runtime if the app creates all of them.
    runWidget(const _MainWindow());
  } else {
    runApp(const SlidesApp());
  }
}

/// The app's main window, when windowing is enabled.
class _MainWindow extends StatefulWidget {
  const _MainWindow();

  @override
  State<_MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<_MainWindow> {
  final _controller = WindowController(
    size: const Size(1440, 900),
    title: 'Build devtools for your app',
    delegate: _MainWindowDelegate(),
  );

  @override
  void dispose() {
    _controller.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Window(controller: _controller, child: const SlidesApp());
  }
}

/// Quits the app when the main window is closed.
class _MainWindowDelegate with WindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}

/// The logical size slides are laid out at, before being scaled to fit.
const _canvas = Size(1440, 810);

/// The logical size of slides that have an example shown next to them.
const _splitCanvas = Size(1040, 810);
const _navBarHeight = 60.0;
const _transitionCurve = Cubic(0.16, 1, 0.3, 1);

class SlidesApp extends StatelessWidget {
  const SlidesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build devtools for your app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: Fonts.body,
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0x5538BDF8),
        ),
      ),
      home: const Deck(),
    );
  }
}

class Deck extends StatefulWidget {
  const Deck({super.key});

  @override
  State<Deck> createState() => _DeckState();
}

class _DeckState extends State<Deck> {
  final _focusNode = FocusNode(debugLabel: 'deck');
  final _confetti = GlobalKey<ConfettiState>();
  final _audienceConfetti = GlobalKey<ConfettiState>();
  var _index = 0;

  /// How much of the current slide is revealed, up to its [SlideData.steps].
  var _step = 0;
  var _showNotes = false;
  var _showOverview = false;
  var _themeIndex = 0;

  /// Whether the presenter view (notes, timer) is shown.
  var _presenting = false;
  var _presentingSince = DateTime.now();

  /// The window showing only the slides, while presenting with windowing
  /// enabled (`flutter config --enable-windowing`).
  WindowController? _audience;

  /// The slide being rendered while exporting the deck to PDF, if any.
  int? _exportingPage;
  final _exportBoundary = GlobalKey();

  @override
  void dispose() {
    _focusNode.dispose();
    _audience?.destroy();
    super.dispose();
  }

  void _togglePresentation() {
    if (_presenting) {
      _stopPresenting();
      return;
    }

    setState(() {
      _presenting = true;
      _presentingSince = DateTime.now();
      if (_windowing) {
        _audience = WindowController(
          size: _canvas,
          title: 'Build devtools for your app',
          delegate: _AudienceWindowDelegate(_stopPresenting),
        );
      }
    });
  }

  void _stopPresenting() {
    final audience = _audience;
    setState(() {
      _presenting = false;
      _audience = null;
    });
    // Destroyed once its view is no longer in the tree.
    if (audience != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => audience.destroy());
    }
  }

  /// Shows the slide at [index], with nothing revealed, or everything when
  /// [revealed] (e.g. when coming back to it).
  void _goTo(int index, {bool revealed = false}) {
    final target = index.clamp(0, slides.length - 1);
    if (target == _index) return;
    setState(() {
      _index = target;
      _step = revealed ? slides[target].steps : 0;
    });
    if (target == slides.length - 1) {
      _confetti.currentState?.fire();
      _audienceConfetti.currentState?.fire();
    }
  }

  void _next() {
    if (_step < slides[_index].steps) {
      setState(() => _step++);
    } else {
      _goTo(_index + 1);
    }
  }

  void _previous() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      _goTo(_index - 1, revealed: true);
    }
  }

  /// Renders every slide, fully revealed, and saves them as a PDF.
  Future<void> _exportPdf() async {
    if (_exportingPage != null) return;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (!mounted) return;
    await Future.wait([
      for (final asset in manifest.listAssets())
        if (asset.startsWith('assets/img/'))
          precacheImage(AssetImage(asset), context),
    ]);

    final pages = <Future<Uint8List>>[];
    try {
      for (var i = 0; i < slides.length; i++) {
        setState(() => _exportingPage = i);
        await _settle();
        final boundary =
            _exportBoundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        pages.add(encodePage(image).whenComplete(image.dispose));
      }
    } finally {
      if (mounted) setState(() => _exportingPage = null);
    }

    await savePdf(
      await Future.wait(pages),
      pageSize: _canvas,
      title: 'Build devtools for your app',
      fileName: 'build_devtools_for_your_app.pdf',
    );
  }

  /// Waits for animations to end, for up to a second.
  static Future<void> _settle() async {
    final deadline = DateTime.now().add(const Duration(seconds: 1));
    do {
      await WidgetsBinding.instance.endOfFrame;
    } while (SchedulerBinding.instance.hasScheduledFrame &&
        DateTime.now().isBefore(deadline));
  }

  void _toggleOverview([bool? show]) {
    setState(() => _showOverview = show ?? !_showOverview);
    _focusNode.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final editing = FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<EditableText>();
    if (editing != null) {
      if (key == LogicalKeyboardKey.escape) _focusNode.requestFocus();
      return KeyEventResult.ignored;
    }

    if (_exportingPage != null) return KeyEventResult.handled;

    if (_showOverview) {
      if (key == LogicalKeyboardKey.escape) _toggleOverview(false);
      return KeyEventResult.handled;
    }

    final repeatable = event is KeyRepeatEvent;
    switch (key) {
      case LogicalKeyboardKey.arrowRight ||
          LogicalKeyboardKey.pageDown ||
          LogicalKeyboardKey.space:
        _next();
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.pageUp:
        _previous();
      case LogicalKeyboardKey.home when !repeatable:
        _goTo(0);
      case LogicalKeyboardKey.end when !repeatable:
        _goTo(slides.length - 1);
      case LogicalKeyboardKey.keyN when !repeatable:
        setState(() => _showNotes = !_showNotes);
      case LogicalKeyboardKey.keyM when !repeatable:
        _toggleOverview();
      case LogicalKeyboardKey.keyT when !repeatable:
        _cycleTheme();
      case LogicalKeyboardKey.keyP when !repeatable:
        _togglePresentation();
      case LogicalKeyboardKey.keyE when !repeatable:
        unawaited(_exportPdf());
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _cycleTheme() {
    setState(() => _themeIndex = (_themeIndex + 1) % Palette.all.length);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.all[_themeIndex];
    final (_, base) = palette.background(slides[_index].topic);
    final audience = _audience;

    return ViewAnchor(
      view: audience == null
          ? null
          : Window(
              controller: audience,
              child: _WindowApp(
                child: DeckTheme(
                  palette: palette,
                  child: Focus(
                    autofocus: true,
                    onKeyEvent: _onKey,
                    child: _stage(palette, confetti: _audienceConfetti),
                  ),
                ),
              ),
            ),
      child: DeckTheme(
        palette: palette,
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _onKey,
          child: Material(
            color: base,
            child: DefaultTextStyle.merge(
              style: TextStyle(fontFamily: Fonts.body, color: palette.textMain),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _presenting
                        ? _presenterLayout(palette)
                        : _normalLayout(palette),
                  ),
                  if (_showOverview)
                    Positioned.fill(
                      child: _Overview(
                        current: _index,
                        onSelect: (index) {
                          _goTo(index);
                          _toggleOverview(false);
                        },
                        onClose: () => _toggleOverview(false),
                      ),
                    ),
                  if (_exportingPage case final page?) ...[
                    // Laid out at the size of a PDF page whatever the size of
                    // the window, and hidden behind the progress.
                    Positioned(
                      left: 0,
                      top: 0,
                      child: RepaintBoundary(
                        key: _exportBoundary,
                        child: _exportedSlide(palette, page),
                      ),
                    ),
                    Positioned.fill(child: _ExportProgress(page: page)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The slide with its background, as the audience sees it.
  Widget _stage(Palette palette, {required GlobalKey<ConfettiState> confetti}) {
    final slide = slides[_index];
    final (glow, base) = palette.background(slide.topic);
    return Material(
      color: base,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: Fonts.body, color: palette.textMain),
        child: Stack(
          children: [
            Positioned.fill(
              child: _Background(
                glow: glow,
                base: base,
                accent: palette.topicAccent(slide.topic),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: _SlideViewport(index: _index, step: _step),
                  ),
                  ExamplePanel(example: slide.example),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _ProgressBar(progress: (_index + 1) / slides.length),
            ),
            Positioned.fill(child: Confetti(key: confetti)),
          ],
        ),
      ),
    );
  }

  /// The slide at [index] as in the exported PDF: with everything revealed,
  /// and without the progress bar.
  Widget _exportedSlide(Palette palette, int index) {
    final slide = slides[index];
    final (glow, base) = palette.background(slide.topic);
    return KeyedSubtree(
      // Not updating the previous slide in place, which would animate it.
      key: ValueKey(index),
      child: SizedBox.fromSize(
        size: _canvas,
        child: Material(
          color: base,
          child: DefaultTextStyle.merge(
            style: TextStyle(fontFamily: Fonts.body, color: palette.textMain),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _Background(
                    glow: glow,
                    base: base,
                    accent: palette.topicAccent(slide.topic),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(child: _slideCanvas(index, slide.steps)),
                      ExamplePanel(example: slide.example),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBar() {
    return _NavBar(
      index: _index,
      presenting: _presenting,
      onPrevious: _previous,
      onNext: _next,
      onOverview: _toggleOverview,
      onNotes: () => setState(() => _showNotes = !_showNotes),
      onTheme: _cycleTheme,
      onPresent: _togglePresentation,
      onExport: () => unawaited(_exportPdf()),
    );
  }

  Widget _normalLayout(Palette palette) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _focusNode.requestFocus,
            child: Stack(
              children: [
                Positioned.fill(child: _stage(palette, confetti: _confetti)),
                if (_showNotes)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _NotesPanel(notes: slides[_index].notes),
                  ),
              ],
            ),
          ),
        ),
        _navBar(),
      ],
    );
  }

  /// The presenter's window: the slide, with the notes and a timer next to it.
  Widget _presenterLayout(Palette palette) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _canvas.aspectRatio,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _focusNode.requestFocus,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: _stage(palette, confetti: _confetti),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 440,
                child: _PresenterPanel(
                  index: _index,
                  step: _step,
                  startedAt: _presentingSince,
                  audienceWindow: _audience != null,
                  onResetTimer: () =>
                      setState(() => _presentingSince = DateTime.now()),
                ),
              ),
            ],
          ),
        ),
        _navBar(),
      ],
    );
  }
}

/// The app around the content of a secondary window, which has its own
/// [MediaQuery] and [Navigator].
class _WindowApp extends StatelessWidget {
  const _WindowApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build devtools for your app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: Fonts.body),
      home: child,
    );
  }
}

/// Closes presentation mode when the audience window is closed.
class _AudienceWindowDelegate with WindowControllerDelegate {
  _AudienceWindowDelegate(this.onCloseRequested);

  final VoidCallback onCloseRequested;

  @override
  void onWindowCloseRequested(WindowController controller) {
    onCloseRequested();
  }
}

/// Speaker notes, a timer, and what comes next, for the presenter only.
class _PresenterPanel extends StatefulWidget {
  const _PresenterPanel({
    required this.index,
    required this.step,
    required this.startedAt,
    required this.audienceWindow,
    required this.onResetTimer,
  });

  final int index;
  final int step;
  final DateTime startedAt;

  /// Whether the slides are shown in a separate window.
  final bool audienceWindow;
  final VoidCallback onResetTimer;

  @override
  State<_PresenterPanel> createState() => _PresenterPanelState();
}

class _PresenterPanelState extends State<_PresenterPanel> {
  /// Updates the timer and the clock.
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  static String _twoDigits(int value) => '$value'.padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final slide = slides[widget.index];
    final elapsed = DateTime.now().difference(widget.startedAt);
    final now = TimeOfDay.now();
    final label = TextStyle(
      fontSize: 12.8,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: palette.accent,
    );

    final String upNext;
    if (widget.step < slide.steps) {
      final left = slide.steps - widget.step;
      upNext = '$left more on this slide';
    } else if (widget.index + 1 < slides.length) {
      upNext = slides[widget.index + 1].title;
    } else {
      upNext = 'The end';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_twoDigits(elapsed.inMinutes)}:'
                '${_twoDigits(elapsed.inSeconds % 60)}',
                style: TextStyle(
                  fontFamily: Fonts.code,
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: palette.heading,
                ),
              ),
              const SizedBox(width: 12),
              _NavButton(
                'Reset',
                tooltip: 'Restart the timer',
                onTap: widget.onResetTimer,
              ),
              const Spacer(),
              Text(
                '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}',
                style: TextStyle(
                  fontFamily: Fonts.code,
                  fontSize: 22,
                  color: palette.textDim,
                ),
              ),
            ],
          ),
          if (!widget.audienceWindow) ...[
            const SizedBox(height: 12),
            Text(
              'No audience window: enable it with flutter config --enable-windowing.',
              style: TextStyle(fontSize: 13.6, color: palette.textDim),
            ),
          ],
          const SizedBox(height: 24),
          Text('SLIDE ${widget.index + 1} / ${slides.length}', style: label),
          const SizedBox(height: 4),
          Text(
            slide.title,
            style: TextStyle(
              fontFamily: Fonts.heading,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: palette.heading,
            ),
          ),
          const SizedBox(height: 16),
          Text('UP NEXT', style: label),
          const SizedBox(height: 4),
          Text(
            upNext,
            style: TextStyle(fontSize: 16, color: palette.textMuted),
          ),
          const SizedBox(height: 24),
          Text('SPEAKER NOTES', style: label),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                slide.notes,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  color: palette.textMain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How visible a slide is: [opacity], and [progress] of its scale/slide-up
/// motion, where 0 is the hidden pose and 1 the resting pose.
typedef _SlidePose = ({double opacity, double progress});

const _SlidePose _hidden = (opacity: 0, progress: 0);

/// Cross-fades between the previous and current slide.
///
/// Every transition starts from what is currently on screen, so changing slide
/// mid-transition (including going back) never makes a slide jump or blink.
class _SlideViewport extends StatefulWidget {
  const _SlideViewport({required this.index, required this.step});

  final int index;
  final int step;

  @override
  State<_SlideViewport> createState() => _SlideViewportState();
}

class _SlideViewportState extends State<_SlideViewport>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: 1,
  );

  int? _outgoing;
  int _outgoingStep = 0;
  _SlidePose _outgoingFrom = _hidden;
  _SlidePose _incomingFrom = _hidden;

  @override
  void didUpdateWidget(_SlideViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Slides of the same group update in place, without a transition.
    if (_keyOf(widget.index) == _keyOf(oldWidget.index)) return;

    final current = _incomingPose;
    // Going back to the slide that is still leaving resumes it from where it
    // is, instead of restarting it from hidden.
    _incomingFrom = _keyOf(widget.index) == _keyOf(_outgoing)
        ? _outgoingPose
        : _hidden;
    _outgoing = oldWidget.index;
    _outgoingStep = oldWidget.step;
    _outgoingFrom = current;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Slides are mostly translucent cards, so two slides visible at once read
  // like a double exposure. The leaving slide is therefore faded out within the
  // first 20% of the transition, and the incoming one only starts fading in
  // once the leaving one is mostly gone.
  static const _fadeIn = Interval(0.1, 1, curve: _transitionCurve);
  static const _fadeOut = Interval(0, 0.2, curve: Curves.easeOut);

  _SlidePose get _incomingPose {
    final fade = _fadeIn.transform(_controller.value);
    final t = _transitionCurve.transform(_controller.value);
    return (
      opacity: lerpDouble(_incomingFrom.opacity, 1, fade)!,
      progress: lerpDouble(_incomingFrom.progress, 1, t)!,
    );
  }

  _SlidePose get _outgoingPose {
    final fade = _fadeOut.transform(_controller.value);
    final t = _transitionCurve.transform(_controller.value);
    return (
      opacity: lerpDouble(_outgoingFrom.opacity, 0, fade)!,
      progress: lerpDouble(_outgoingFrom.progress, 0, t)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final outgoing = _outgoing;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (outgoing != null && !_controller.isCompleted)
              _slide(outgoing, _outgoingStep, _outgoingPose),
            _slide(widget.index, widget.step, _incomingPose),
          ],
        );
      },
    );
  }

  static Object? _keyOf(int? index) => switch (index) {
    final index? => slides[index].group ?? index,
    null => null,
  };

  Widget _slide(int index, int step, _SlidePose pose) {
    return KeyedSubtree(
      // Keyed so that a slide keeps its state (e.g. text fields) when it moves
      // between the incoming and outgoing positions, and so that slides of a
      // group share it.
      key: ValueKey(_keyOf(index)),
      child: Opacity(
        opacity: pose.opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - pose.progress)),
          child: Transform.scale(
            scale: 0.96 + 0.04 * pose.progress,
            child: _slideCanvas(index, step),
          ),
        ),
      ),
    );
  }
}

/// The slide at [index], laid out on its canvas and scaled to fit.
Widget _slideCanvas(int index, int step) {
  return FittedBox(
    child: SizedBox.fromSize(
      size: slides[index].example == null ? _canvas : _splitCanvas,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 40),
        child: SlideTopic(
          topic: slides[index].topic,
          child: SlideStep(step: step, child: slides[index].child),
        ),
      ),
    ),
  );
}

/// The page background: a glow from the top, a faint orb of the topic's
/// accent in the bottom-right corner, and a haunted Japanese night drawn
/// over it.
class _Background extends StatelessWidget {
  const _Background({
    required this.glow,
    required this.base,
    required this.accent,
  });

  final Color glow;
  final Color base;
  final Color accent;

  static const _duration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: _duration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.4,
              colors: [glow, base],
              stops: const [0, 0.7],
            ),
          ),
        ),
        AnimatedContainer(
          duration: _duration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.1, 1.2),
              radius: 1.1,
              colors: [
                accent.withValues(alpha: palette.isLight ? 0.10 : 0.14),
                accent.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: _HauntedNight(
            texture: palette.texture,
            isLight: palette.isLight,
          ),
        ),
      ],
    );
  }
}

/// Stars, a full moon with bats, a torii gate and seigaiha waves.
///
/// On light themes the moon becomes a red rising sun, and the stars and bats
/// are left out.
class _HauntedNight extends CustomPainter {
  _HauntedNight({required this.texture, required this.isLight});

  final Color texture;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isLight) _paintStars(canvas, size);
    _paintMoon(canvas, size);
    if (!isLight) _paintBats(canvas, size);
    _paintTorii(canvas, size);
    _paintWaves(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size) {
    // Seeded so that the stars stay in place between repaints.
    final random = Random(31);
    final paint = Paint()..color = const Color(0x2EFFFFFF);
    for (var i = 0; i < 70; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      canvas.drawCircle(Offset(x, y), 0.6 + random.nextDouble() * 1.1, paint);
    }
  }

  void _paintMoon(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.87, size.height * 0.15);
    final radius = size.shortestSide * 0.075;
    final color = isLight ? Hues.vermilion : Hues.moon;

    canvas
      ..drawCircle(
        center,
        radius * 1.6,
        Paint()
          ..color = color.withValues(alpha: isLight ? 0.08 : 0.07)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius),
      )
      ..drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: isLight ? 0.13 : 0.12),
      );
    if (isLight) return;

    final crater = Paint()..color = const Color(0x0A000000);
    canvas
      ..drawCircle(
        center + Offset(-radius * 0.3, -radius * 0.2),
        radius * 0.2,
        crater,
      )
      ..drawCircle(
        center + Offset(radius * 0.35, radius * 0.25),
        radius * 0.14,
        crater,
      )
      ..drawCircle(
        center + Offset(-radius * 0.1, radius * 0.45),
        radius * 0.09,
        crater,
      );
  }

  void _paintBats(Canvas canvas, Size size) {
    final unit = size.shortestSide * 0.012;
    final paint = Paint()..color = const Color(0x33000000);
    for (final (dx, dy, scale) in const [
      (0.80, 0.12, 1.2),
      (0.84, 0.21, 0.8),
      (0.91, 0.09, 0.9),
      (0.76, 0.24, 0.6),
    ]) {
      final c = Offset(size.width * dx, size.height * dy);
      final s = unit * scale;
      final bat = Path()
        ..moveTo(c.dx, c.dy - s * 0.4)
        ..quadraticBezierTo(c.dx - s, c.dy - s * 1.6, c.dx - s * 3, c.dy - s)
        ..quadraticBezierTo(
          c.dx - s * 2.2,
          c.dy - s * 0.6,
          c.dx - s * 2.2,
          c.dy + s * 0.2,
        )
        ..quadraticBezierTo(
          c.dx - s * 1.6,
          c.dy - s * 0.3,
          c.dx - s * 1.1,
          c.dy + s * 0.3,
        )
        ..quadraticBezierTo(c.dx - s * 0.5, c.dy - s * 0.1, c.dx, c.dy + s)
        ..quadraticBezierTo(
          c.dx + s * 0.5,
          c.dy - s * 0.1,
          c.dx + s * 1.1,
          c.dy + s * 0.3,
        )
        ..quadraticBezierTo(
          c.dx + s * 1.6,
          c.dy - s * 0.3,
          c.dx + s * 2.2,
          c.dy + s * 0.2,
        )
        ..quadraticBezierTo(
          c.dx + s * 2.2,
          c.dy - s * 0.6,
          c.dx + s * 3,
          c.dy - s,
        )
        ..quadraticBezierTo(c.dx + s, c.dy - s * 1.6, c.dx, c.dy - s * 0.4)
        ..close();
      canvas.drawPath(bat, paint);
    }
  }

  void _paintTorii(Canvas canvas, Size size) {
    final h = size.height * 0.34;
    final w = h * 0.95;
    final left = size.width * 0.03;
    final bottom = size.height;
    final top = bottom - h;
    final paint = Paint()
      ..color = Hues.vermilion.withValues(alpha: isLight ? 0.10 : 0.09);

    final pillar = w * 0.07;
    final inset = w * 0.17;
    canvas
      // Pillars, slightly leaning inwards.
      ..drawPath(
        Path()
          ..moveTo(left + inset, bottom)
          ..lineTo(left + inset + pillar * 0.4, top + h * 0.1)
          ..lineTo(left + inset + pillar * 1.4, top + h * 0.1)
          ..lineTo(left + inset + pillar, bottom)
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(left + w - inset, bottom)
          ..lineTo(left + w - inset - pillar * 0.4, top + h * 0.1)
          ..lineTo(left + w - inset - pillar * 1.4, top + h * 0.1)
          ..lineTo(left + w - inset - pillar, bottom)
          ..close(),
        paint,
      )
      // Kasagi: the top beam, curving up at both ends.
      ..drawPath(
        Path()
          ..moveTo(left, top)
          ..quadraticBezierTo(left + w / 2, top + h * 0.08, left + w, top)
          ..lineTo(left + w * 0.97, top + h * 0.07)
          ..quadraticBezierTo(
            left + w / 2,
            top + h * 0.13,
            left + w * 0.03,
            top + h * 0.07,
          )
          ..close(),
        paint,
      )
      // Nuki: the lower tie beam.
      ..drawRect(
        Rect.fromLTWH(left + w * 0.08, top + h * 0.22, w * 0.84, h * 0.045),
        paint,
      )
      // Gakuzuka: the strut holding the name plaque.
      ..drawRect(
        Rect.fromLTWH(left + w * 0.47, top + h * 0.1, w * 0.06, h * 0.12),
        paint,
      );
  }

  void _paintWaves(Canvas canvas, Size size) {
    final radius = size.shortestSide * 0.035;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = texture;

    for (var row = 0; row < 3; row++) {
      final y = size.height - radius * (2 - row) * 0.9;
      final offset = row.isOdd ? radius : 0.0;
      for (var x = -offset; x < size.width + radius; x += radius * 2) {
        final center = Offset(x + offset, y + radius * 0.4);
        for (var ring = 1; ring <= 3; ring++) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * ring / 3),
            pi,
            pi,
            false,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HauntedNight oldDelegate) =>
      texture != oldDelegate.texture || isLight != oldDelegate.isLight;
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      height: 3,
      color: palette.texture,
      alignment: Alignment.centerLeft,
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [palette.accent, Hues.purple]),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(3),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.index,
    required this.onPrevious,
    required this.onNext,
    required this.onOverview,
    required this.onNotes,
    required this.onTheme,
    required this.presenting,
    required this.onPresent,
    required this.onExport,
  });

  final int index;
  final bool presenting;
  final VoidCallback onPresent;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onOverview;
  final VoidCallback onNotes;
  final VoidCallback onTheme;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      height: _navBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: palette.navBg,
        border: Border(top: BorderSide(color: palette.texture)),
      ),
      child: Row(
        spacing: 12,
        children: [
          _NavButton(
            '← Prev',
            tooltip: 'Previous Slide (Left Arrow / PageUp)',
            onTap: onPrevious,
          ),
          _NavButton(
            'Next →',
            tooltip: 'Next Slide (Right Arrow / Space / PageDown)',
            onTap: onNext,
          ),
          const SizedBox(width: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${index + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    color: palette.heading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: '  /  ${slides.length}'),
              ],
            ),
            style: TextStyle(
              fontFamily: Fonts.code,
              fontSize: 13.6,
              color: palette.textDim,
            ),
          ),
          // Scrolls instead of overflowing in narrow windows.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                spacing: 12,
                children: [
                  _NavButton(
                    'Grid Overview',
                    tooltip: 'Toggle Overview (M)',
                    onTap: onOverview,
                  ),
                  _NavButton(
                    'Speaker Notes',
                    tooltip: 'Toggle Speaker Notes (N)',
                    onTap: onNotes,
                  ),
                  _NavButton(
                    'Theme',
                    tooltip: 'Toggle Theme (T)',
                    onTap: onTheme,
                  ),
                  _NavButton(
                    presenting ? 'Stop Presenting' : 'Present',
                    tooltip: 'Toggle Presentation Mode (P)',
                    onTap: onPresent,
                  ),
                  _NavButton(
                    'Export PDF',
                    tooltip: 'Export to PDF (E)',
                    onTap: onExport,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(this.label, {required this.tooltip, required this.onTap});

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Hoverable(
        onTap: onTap,
        builder: (context, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: hovered
                ? palette.accent.withValues(alpha: 0.15)
                : palette.textMain.withValues(alpha: 0.04),
            border: Border.all(
              color: hovered
                  ? palette.accent.withValues(alpha: 0.6)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.6,
              fontWeight: FontWeight.w500,
              color: hovered ? palette.heading : palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Covers the deck while it is exported to PDF.
class _ExportProgress extends StatelessWidget {
  const _ExportProgress({required this.page});

  /// The index of the slide being rendered.
  final int page;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return AbsorbPointer(
      child: ColoredBox(
        color: palette.isLight
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF090D16),
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Text(
                  'Exporting slide ${page + 1} / ${slides.length}',
                  style: TextStyle(
                    fontFamily: Fonts.code,
                    fontSize: 13.6,
                    color: palette.textMuted,
                  ),
                ),
                LinearProgressIndicator(
                  value: (page + 1) / slides.length,
                  color: palette.accent,
                  backgroundColor: palette.texture,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesPanel extends StatelessWidget {
  const _NotesPanel({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: palette.isLight
            ? const Color(0xF5FFFFFF)
            : const Color(0xF5090D16),
        border: Border(top: BorderSide(color: palette.accent, width: 2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SPEAKER NOTES',
            style: TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.64,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: TextStyle(
              fontSize: 15.2,
              height: 1.45,
              color: palette.isLight
                  ? palette.textMuted
                  : const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.current,
    required this.onSelect,
    required this.onClose,
  });

  final int current;
  final ValueChanged<int> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: palette.isLight
            ? const Color(0xF5F8FAFC)
            : const Color(0xF5090D16),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: H2('Slide Deck Navigation Overview')),
                _NavButton(
                  'Close (Esc)',
                  tooltip: 'Close Overview',
                  onTap: onClose,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 140,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: slides.length,
                itemBuilder: (context, index) => _OverviewCard(
                  index: index,
                  active: index == current,
                  onTap: () => onSelect(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.index,
    required this.active,
    required this.onTap,
  });

  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Hoverable(
      onTap: onTap,
      builder: (context, hovered) {
        final highlighted = hovered || active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, highlighted ? -2 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.cardBg,
            border: Border.all(
              color: highlighted ? palette.accent : palette.cardBorder,
            ),
            borderRadius: BorderRadius.circular(9.6),
            boxShadow: [
              if (highlighted)
                BoxShadow(
                  color: palette.accent.withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SLIDE ${index + 1}',
                style: TextStyle(
                  fontFamily: Fonts.code,
                  fontSize: 12.8,
                  color: palette.accent,
                ),
              ),
              Text(
                slides[index].title,
                style: TextStyle(
                  fontFamily: Fonts.heading,
                  fontSize: 15.2,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: palette.heading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
