// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'confetti.dart';
import 'example_panel.dart';
import 'slides.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  runApp(const SlidesApp());
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
  var _index = 0;
  var _showNotes = false;
  var _showOverview = false;
  var _themeIndex = 0;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    final target = index.clamp(0, slides.length - 1);
    if (target == _index) return;
    setState(() => _index = target);
    if (target == slides.length - 1) _confetti.currentState?.fire();
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

    if (_showOverview) {
      if (key == LogicalKeyboardKey.escape) _toggleOverview(false);
      return KeyEventResult.handled;
    }

    final repeatable = event is KeyRepeatEvent;
    switch (key) {
      case LogicalKeyboardKey.arrowRight ||
          LogicalKeyboardKey.pageDown ||
          LogicalKeyboardKey.space:
        _goTo(_index + 1);
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.pageUp:
        _goTo(_index - 1);
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
    final slide = slides[_index];
    final (glow, base) = palette.background(slide.topic);

    return DeckTheme(
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
                  child: _Background(
                    glow: glow,
                    base: base,
                    accent: palette.topicAccent(slide.topic),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _focusNode.requestFocus,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SlideViewport(index: _index),
                                  ),
                                  ExamplePanel(example: slide.example),
                                ],
                              ),
                            ),
                            if (_showNotes)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _NotesPanel(notes: slide.notes),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _NavBar(
                      index: _index,
                      onPrevious: () => _goTo(_index - 1),
                      onNext: () => _goTo(_index + 1),
                      onOverview: _toggleOverview,
                      onNotes: () => setState(() => _showNotes = !_showNotes),
                      onTheme: _cycleTheme,
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ProgressBar(progress: (_index + 1) / slides.length),
                ),
                Positioned.fill(child: Confetti(key: _confetti)),
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
              ],
            ),
          ),
        ),
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
  const _SlideViewport({required this.index});

  final int index;

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
  _SlidePose _outgoingFrom = _hidden;
  _SlidePose _incomingFrom = _hidden;

  @override
  void didUpdateWidget(_SlideViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index) return;

    final current = _incomingPose;
    // Going back to the slide that is still leaving resumes it from where it
    // is, instead of restarting it from hidden.
    _incomingFrom = widget.index == _outgoing ? _outgoingPose : _hidden;
    _outgoing = oldWidget.index;
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
              _slide(outgoing, _outgoingPose),
            _slide(widget.index, _incomingPose),
          ],
        );
      },
    );
  }

  Widget _slide(int index, _SlidePose pose) {
    return KeyedSubtree(
      // Keyed so that a slide keeps its state (e.g. text fields) when it moves
      // between the incoming and outgoing positions.
      key: ValueKey(index),
      child: Opacity(
        opacity: pose.opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - pose.progress)),
          child: Transform.scale(
            scale: 0.96 + 0.04 * pose.progress,
            child: FittedBox(
              child: SizedBox.fromSize(
                size: slides[index].example == null ? _canvas : _splitCanvas,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 72,
                    vertical: 40,
                  ),
                  child: SlideTopic(
                    topic: slides[index].topic,
                    child: slides[index].child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The page background: a glow from the top, a faint orb of the topic's
/// accent in the bottom-right corner, and a dot grid fading out from the top.
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
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [Colors.white, Color(0x00FFFFFF)],
          ).createShader(bounds),
          child: CustomPaint(painter: _DotGrid(palette.texture)),
        ),
      ],
    );
  }
}

class _DotGrid extends CustomPainter {
  _DotGrid(this.color);

  final Color color;

  static const _spacing = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGrid oldDelegate) => color != oldDelegate.color;
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
  });

  final int index;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onOverview;
  final VoidCallback onNotes;
  final VoidCallback onTheme;

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
          const Spacer(),
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
          _NavButton('Theme', tooltip: 'Toggle Theme (T)', onTap: onTheme),
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
