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
  static const slate = Color(0xFF64748B);
  static const codeText = Color(0xFFCBD5E1);
  static const codeBg = Color(0xFF0B1120);
}

/// Each slide belongs to a topic, which drives the background glow.
enum Topic {
  intro(Color(0xFF1E293B), Color(0xFF0B0F19)),
  why(Color(0xFF311B92), Color(0xFF090A16)),
  lints(Color(0xFF064E3B), Color(0xFF051210)),
  codegen(Color(0xFF0C4A6E), Color(0xFF061019)),
  cli(Color(0xFF134E4A), Color(0xFF051314)),
  mcp(Color(0xFF4C1D95), Color(0xFF0C0717)),
  devtools(Color(0xFF881337), Color(0xFF15060B)),
  creation(Color(0xFF1E1B4B), Color(0xFF090A17)),
  conclusion(Color(0xFF0E7490), Color(0xFF060D14));

  const Topic(this.glow, this.base);

  final Color glow;
  final Color base;
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
    navBg: Color.fromRGBO(15, 23, 42, 0.95),
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
    navBg: Color.fromRGBO(15, 23, 42, 0.95),
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
    navBg: Color.fromRGBO(255, 255, 255, 0.95),
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
