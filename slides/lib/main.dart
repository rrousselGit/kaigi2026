// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'confetti.dart';
import 'slides.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  runApp(const SlidesApp());
}

/// The logical size slides are laid out at, before being scaled to fit.
const _canvas = Size(1440, 810);
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
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
                              child: _SlideViewport(index: _index),
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

class _SlideViewport extends StatelessWidget {
  const _SlideViewport({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: _transitionCurve,
      switchOutCurve: _transitionCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final t = animation.value;
              return Transform.translate(
                offset: Offset(0, 20 * (1 - t)),
                child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
              );
            },
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(index),
        child: FittedBox(
          child: SizedBox.fromSize(
            size: _canvas,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 40),
              child: slides[index].child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      height: 4,
      color: const Color(0x0DFFFFFF),
      alignment: Alignment.centerLeft,
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: palette.accent,
            boxShadow: [BoxShadow(color: palette.accent, blurRadius: 8)],
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
        border: Border(top: BorderSide(color: palette.cardBorder)),
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
          Text(
            'Slide ${index + 1} / ${slides.length}',
            style: TextStyle(
              fontFamily: Fonts.code,
              fontSize: 13.6,
              color: palette.textMuted,
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
                : palette.textMain.withValues(alpha: 0.05),
            border: Border.all(
              color: hovered ? palette.accent : palette.cardBorder,
            ),
            borderRadius: BorderRadius.circular(7.2),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.6,
              fontWeight: FontWeight.w500,
              color: hovered ? palette.heading : palette.textMain,
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
