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
  static const pumpkin = Color(0xFFF97316);
  static const candyCorn = Color(0xFFFBBF24);

  /// The red-orange of torii gates.
  static const vermilion = Color(0xFFEF4A2F);
  static const sakura = Color(0xFFF9A8D4);
  static const wisteria = Color(0xFFB794F6);
  static const matcha = Color(0xFFA3C76D);

  /// The pale blue of onibi, Japanese ghost fire.
  static const onibi = Color(0xFF67E8F9);
  static const moon = Color(0xFFFDF3C7);
  static const slate = Color(0xFF64748B);
  static const codeText = Color(0xFFCBD5E1);
  static const codeBg = Color(0xFF0B1120);
}

/// Each slide belongs to a topic, which drives the background glow and the
/// eyebrow label above slide titles.
enum Topic {
  intro('Introduction', Color(0xFF3B1A0B), Color(0xFF0D0807), Hues.pumpkin),
  why('Why tools', Color(0xFF3A0F1A), Color(0xFF0D0608), Hues.vermilion),
  lints('Custom lints', Color(0xFF1F2A12), Color(0xFF080A06), Hues.matcha),
  codegen(
    'Code generation',
    Color(0xFF3A2A0A),
    Color(0xFF0D0A05),
    Hues.candyCorn,
  ),
  cli('CLIs', Color(0xFF0E2A33), Color(0xFF05090C), Hues.onibi),
  mcp('MCP servers', Color(0xFF2A1745), Color(0xFF0A0711), Hues.wisteria),
  devtools('DevTools', Color(0xFF3D1230), Color(0xFF0E060B), Hues.sakura),
  creation('Building tools', Color(0xFF1C1A40), Color(0xFF07070F), Hues.violet),
  conclusion('Wrap-up', Color(0xFF4A1D08), Color(0xFF0F0714), Hues.pumpkin);

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

  /// A haunted night in sumi ink, lit by jack-o'-lanterns.
  static const dark = Palette(
    isLight: false,
    cardBg: Color.fromRGBO(24, 16, 14, 0.75),
    cardBorder: Color.fromRGBO(249, 115, 22, 0.14),
    textMain: Color(0xFFFAF5EB),
    textMuted: Color(0xFFB8A99A),
    textDim: Color(0xFF7A6B5E),
    accent: Hues.pumpkin,
    heading: Color(0xFFFFF7ED),
    surface: Color.fromRGBO(28, 18, 14, 0.65),
    calloutText: Color(0xFFF1E6D6),
    navBg: Color.fromRGBO(10, 6, 5, 0.6),
  );

  /// Onibi: ghost fire flickering over a wisteria night.
  static const neon = Palette(
    isLight: false,
    cardBg: Color.fromRGBO(18, 12, 30, 0.82),
    cardBorder: Color.fromRGBO(183, 148, 246, 0.25),
    textMain: Color(0xFFF5F3FF),
    textMuted: Color(0xFFA9A3C2),
    textDim: Color(0xFF6E6889),
    accent: Hues.onibi,
    heading: Colors.white,
    surface: Color.fromRGBO(20, 14, 34, 0.65),
    calloutText: Color(0xFFE4E0F5),
    navBg: Color.fromRGBO(6, 4, 14, 0.6),
  );

  /// Washi paper and vermilion ink.
  static const light = Palette(
    isLight: true,
    cardBg: Color.fromRGBO(255, 251, 242, 0.92),
    cardBorder: Color.fromRGBO(120, 40, 20, 0.14),
    textMain: Color(0xFF1C1210),
    textMuted: Color(0xFF5C4A42),
    textDim: Color(0xFF9C8B80),
    accent: Color(0xFFC2361D),
    heading: Color(0xFF1C1210),
    surface: Color.fromRGBO(255, 251, 242, 0.75),
    calloutText: Color(0xFF2B1D18),
    navBg: Color.fromRGBO(250, 243, 230, 0.75),
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
    if (isLight) return (const Color(0xFFF1E4CC), const Color(0xFFFAF4E8));
    if (identical(this, neon)) return (topic.glow, const Color(0xFF07040F));
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
