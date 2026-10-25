import 'package:material_ui/material_ui.dart';

abstract final class Fonts {
  static const body = 'Inter';
  static const heading = 'Outfit';
  static const code = 'FiraCode';
}

/// Fixed colors used regardless of the active theme.
abstract final class Hues {
  static const sky = Color(0xFF38BDF8);
  static const cyan = Color(0xFF06B6D4);
  static const purple = Color(0xFFA855F7);
  static const purpleLight = Color(0xFFC084FC);
  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFF34D399);
  static const rose = Color(0xFFF43F5E);
  static const roseLight = Color(0xFFFB7185);
  static const lime = Color(0xFFA3E635);
  static const teal = Color(0xFF2DD4BF);
  static const violet = Color(0xFFA78BFA);
  static const indigo = Color(0xFF818CF8);
  static const slate = Color(0xFF64748B);
  static const codeText = Color(0xFFCBD5E1);
  static const codeBg = Color(0xFF0B1120);
}

/// Each slide belongs to a topic, which drives the background glow and the
/// eyebrow label above slide titles.
enum Topic {
  intro('Introduction', Color(0xFF1E293B), Color(0xFF0B0F19), Hues.sky),
  why('Why tools', Color(0xFF311B92), Color(0xFF090A16), Hues.purpleLight),
  lints(
    'Custom lints',
    Color(0xFF064E3B),
    Color(0xFF051210),
    Hues.emeraldLight,
  ),
  codegen('Code generation', Color(0xFF0C4A6E), Color(0xFF061019), Hues.sky),
  cli('CLIs', Color(0xFF134E4A), Color(0xFF051314), Hues.teal),
  mcp('MCP servers', Color(0xFF4C1D95), Color(0xFF0C0717), Hues.violet),
  devtools('DevTools', Color(0xFF881337), Color(0xFF15060B), Hues.roseLight),
  creation('Building tools', Color(0xFF1E1B4B), Color(0xFF090A17), Hues.indigo),
  conclusion('Wrap-up', Color(0xFF0E7490), Color(0xFF060D14), Hues.cyan);

  const Topic(this.label, this.glow, this.base, this.accent);

  final String label;
  final Color glow;
  final Color base;
  final Color accent;
}

/// Exposes the [Topic] of the slide being built.
class SlideTopic extends InheritedWidget {
  const SlideTopic({super.key, required this.topic, required super.child});

  final Topic topic;

  static Topic of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SlideTopic>()?.topic ??
      Topic.intro;

  @override
  bool updateShouldNotify(SlideTopic oldWidget) => topic != oldWidget.topic;
}

class Palette {
  const Palette({
    required this.isLight,
    required this.cardBg,
    required this.cardBorder,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.accent,
    required this.heading,
    required this.surface,
    required this.calloutText,
    required this.navBg,
  });

  static const dark = Palette(
    isLight: false,
    cardBg: Color.fromRGBO(17, 24, 39, 0.7),
    cardBorder: Color.fromRGBO(255, 255, 255, 0.08),
    textMain: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
    textDim: Color(0xFF64748B),
    accent: Hues.sky,
    heading: Colors.white,
    surface: Color.fromRGBO(15, 23, 42, 0.6),
    calloutText: Color(0xFFE2E8F0),
    navBg: Color.fromRGBO(2, 6, 23, 0.55),
  );

  static const neon = Palette(
    isLight: false,
    cardBg: Color.fromRGBO(15, 23, 42, 0.8),
    cardBorder: Color.fromRGBO(56, 189, 248, 0.2),
    textMain: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
    textDim: Color(0xFF64748B),
    accent: Hues.sky,
    heading: Colors.white,
    surface: Color.fromRGBO(15, 23, 42, 0.6),
    calloutText: Color(0xFFE2E8F0),
    navBg: Color.fromRGBO(2, 6, 23, 0.55),
  );

  static const light = Palette(
    isLight: true,
    cardBg: Color.fromRGBO(255, 255, 255, 0.9),
    cardBorder: Color.fromRGBO(0, 0, 0, 0.1),
    textMain: Color(0xFF0F172A),
    textMuted: Color(0xFF475569),
    textDim: Color(0xFF94A3B8),
    accent: Color(0xFF0284C7),
    heading: Color(0xFF0F172A),
    surface: Color.fromRGBO(255, 255, 255, 0.7),
    calloutText: Color(0xFF1E293B),
    navBg: Color.fromRGBO(255, 255, 255, 0.7),
  );

  static const all = [dark, neon, light];

  final bool isLight;
  final Color cardBg;
  final Color cardBorder;
  final Color textMain;
  final Color textMuted;
  final Color textDim;
  final Color accent;
  final Color heading;
  final Color surface;
  final Color calloutText;
  final Color navBg;

  /// The accent of [topic], darkened on light backgrounds for contrast.
  Color topicAccent(Topic topic) {
    if (!isLight) return topic.accent;
    return HSLColor.fromColor(topic.accent).withLightness(0.36).toColor();
  }

  /// Faint lines and dots drawn over the page background.
  Color get texture =>
      isLight ? const Color(0x14000000) : const Color(0x0FFFFFFF);

  /// The (glow, base) colors of the page background for a topic.
  (Color, Color) background(Topic topic) {
    if (isLight) return (const Color(0xFFE2E8F0), const Color(0xFFF8FAFC));
    if (identical(this, neon)) return (topic.glow, const Color(0xFF050515));
    return (topic.glow, topic.base);
  }

  static Palette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DeckTheme>()!.palette;
}

class DeckTheme extends InheritedWidget {
  const DeckTheme({super.key, required this.palette, required super.child});

  final Palette palette;

  @override
  bool updateShouldNotify(DeckTheme oldWidget) => palette != oldWidget.palette;
}
