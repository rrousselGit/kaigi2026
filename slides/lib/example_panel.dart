// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// The logical size examples are laid out at, before being scaled to fit.
const _phoneSize = Size(390, 844);
const _bezel = 12.0;
const _padding = EdgeInsets.fromLTRB(8, 24, 32, 24);
const _curve = Cubic(0.16, 1, 0.3, 1);

/// A side panel showing [example] in a phone frame, next to the slide.
///
/// The panel slides in when [example] becomes non-null, and out when it
/// becomes null. Between two slides with an example, the example widget is
/// updated in place rather than recreated, so it can animate between the
/// states that each slide describes.
class ExamplePanel extends StatefulWidget {
  const ExamplePanel({super.key, required this.example});

  final Widget? example;

  @override
  State<ExamplePanel> createState() => _ExamplePanelState();
}

class _ExamplePanelState extends State<ExamplePanel> {
  /// The last non-null example, kept visible while the panel slides out.
  late Widget? _example = widget.example;

  @override
  void didUpdateWidget(ExamplePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _example = widget.example ?? _example;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneHeight = constraints.maxHeight - _padding.vertical;
        final phoneWidth =
            phoneHeight *
            (_phoneSize.width + 2 * _bezel) /
            (_phoneSize.height + 2 * _bezel);
        final width = phoneWidth + _padding.horizontal;

        return TweenAnimationBuilder(
          tween: Tween(end: widget.example == null ? 0.0 : 1.0),
          duration: const Duration(milliseconds: 600),
          curve: _curve,
          builder: (context, t, child) {
            if (t == 0) return const SizedBox.shrink();
            return SizedBox(
              width: width * t,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: width,
                  maxWidth: width,
                  child: Opacity(
                    opacity: t.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(60 * (1 - t), 0),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: _padding,
            child: FittedBox(child: _Phone(child: _example)),
          ),
        );
      },
    );
  }
}

/// A phone frame, rendering [child] as if it was a full-screen app.
class _Phone extends StatelessWidget {
  const _Phone({required this.child});

  final Widget? child;

  static const _insets = EdgeInsets.only(top: 50, bottom: 30);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _phoneSize.width + 2 * _bezel,
      height: _phoneSize.height + 2 * _bezel,
      padding: const EdgeInsets.all(_bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0F),
        borderRadius: BorderRadius.circular(56),
        border: Border.all(color: const Color(0xFF3F3F46), width: 2),
        boxShadow: [
          BoxShadow(
            color: Palette.of(context).accent.withValues(alpha: 0.18),
            blurRadius: 60,
          ),
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: _phoneSize,
            padding: _insets,
            viewPadding: _insets,
            viewInsets: EdgeInsets.zero,
            textScaler: TextScaler.noScaling,
          ),
          child: ScrollConfiguration(
            // Examples aren't clickable, but should still be scrollable with
            // any device, including by dragging with the mouse.
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
              scrollbars: false,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white, child: child),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(child: _StatusBar()),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: IgnorePointer(child: _HomeIndicator()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  static const _color = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Row(
              spacing: 4,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    fontFamily: Fonts.body,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: 17,
                  color: _color,
                ),
                Icon(Icons.wifi_rounded, size: 17, color: _color),
                Icon(Icons.battery_full_rounded, size: 17, color: _color),
              ],
            ),
            // The camera cutout.
            Container(
              width: 120,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 134,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
