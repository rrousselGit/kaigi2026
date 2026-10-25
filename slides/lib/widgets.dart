// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

// ---------------------------------------------------------------------------
// Rich text
// ---------------------------------------------------------------------------

final _markup = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`([^`]+)`|\[(.+?)\]\((.+?)\)');

/// Renders a tiny markdown subset: `**bold**`, `*italic*`, `` `code` `` and
/// `[label](url)`.
class Md extends StatelessWidget {
  const Md(this.source, {super.key, this.style, this.textAlign});

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    return Text.rich(
      TextSpan(children: _parse(context, source, base)),
      style: base,
      textAlign: textAlign,
    );
  }

  static List<InlineSpan> _parse(
    BuildContext context,
    String source,
    TextStyle style,
  ) {
    final palette = Palette.of(context);
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _markup.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      cursor = match.end;

      if (match[1] case final bold?) {
        final boldStyle = style.copyWith(
          fontWeight: FontWeight.w700,
          color: palette.heading,
        );
        spans.add(
          TextSpan(
            style: boldStyle,
            children: _parse(context, bold, boldStyle),
          ),
        );
      } else if (match[2] case final italic?) {
        final italicStyle = style.copyWith(fontStyle: FontStyle.italic);
        spans.add(
          TextSpan(
            style: italicStyle,
            children: _parse(context, italic, italicStyle),
          ),
        );
      } else if (match[3] case final code?) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InlineCode(
              code,
              fontSize: (style.fontSize ?? 16) * 0.9,
              // Inside links, keep the link color.
              color: style.decoration == TextDecoration.underline
                  ? style.color
                  : null,
            ),
          ),
        );
      } else {
        final url = match[5]!;
        final linkStyle = style.copyWith(
          color: palette.accent,
          decoration: TextDecoration.underline,
          decorationColor: palette.accent,
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(url)),
                child: Text.rich(
                  TextSpan(children: _parse(context, match[4]!, linkStyle)),
                  style: linkStyle,
                ),
              ),
            ),
          ),
        );
      }
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }
    return spans;
  }
}

// ---------------------------------------------------------------------------
// Code
// ---------------------------------------------------------------------------

final _dartToken = RegExp(
  r"(//[^\n]*)"
  r"|('''[\s\S]*?'''|'(?:\\.|[^'\\])*')"
  r"|(@\w+)"
  r"|\b(final|async|await|class|const|var|return|void)\b"
  r"|\b([A-Z]\w*)\b"
  r"|\b(\w+)(?=\()",
);

/// A minimal Dart syntax highlighter, good enough for slide snippets.
TextSpan highlightDart(String code) {
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in _dartToken.allMatches(code)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: code.substring(cursor, match.start)));
    }
    cursor = match.end;

    final style = switch (match) {
      _ when match[1] != null => const TextStyle(
        color: Hues.slate,
        fontStyle: FontStyle.italic,
      ),
      _ when match[2] != null => const TextStyle(color: Hues.lime),
      _ when match[4] != null => const TextStyle(
        color: Hues.rose,
        fontWeight: FontWeight.w600,
      ),
      _ => const TextStyle(color: Hues.sky),
    };
    spans.add(TextSpan(text: match[0], style: style));
  }
  if (cursor < code.length) spans.add(TextSpan(text: code.substring(cursor)));
  return TextSpan(children: spans);
}

class InlineCode extends StatelessWidget {
  const InlineCode(this.code, {super.key, this.fontSize = 15, this.color});

  final String code;
  final double fontSize;

  /// The color of unhighlighted code. Defaults to the main text color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: palette.isLight
            ? const Color(0x14000000)
            : const Color(0x66000000),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        highlightDart(code),
        style: TextStyle(
          fontFamily: Fonts.code,
          fontSize: fontSize,
          color: color ?? palette.textMain,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key, this.fontSize = 13.6});

  final String code;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Hues.codeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0x08FFFFFF),
            child: const Row(
              spacing: 6,
              children: [
                _WindowDot(Color(0xFFFF5F57)),
                _WindowDot(Color(0xFFFEBC2E)),
                _WindowDot(Color(0xFF28C840)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Text.rich(
              highlightDart(code),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: Fonts.code,
                fontSize: fontSize,
                height: 1.45,
                color: Hues.codeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

class H1 extends StatelessWidget {
  const H1(this.text, {super.key, this.fontSize = 56});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: Fonts.heading,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -fontSize * 0.02,
        color: Palette.of(context).heading,
      ),
    );
  }
}

class H2 extends StatelessWidget {
  const H2(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: Fonts.heading,
        fontSize: 36.8,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: Palette.of(context).heading,
      ),
    );
  }
}

class H3 extends StatelessWidget {
  const H3(
    this.text, {
    super.key,
    this.fontSize = 21.6,
    this.color,
    this.textAlign,
  });

  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: Fonts.heading,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color ?? Palette.of(context).accent,
        ),
      ),
    );
  }
}

/// A paragraph of [Md] text.
class P extends StatelessWidget {
  const P(this.text, {super.key, this.fontSize = 17.6, this.bottom = 12});

  final String text;
  final double fontSize;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Md(
        text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.5,
          color: Palette.of(context).textMuted,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

/// The standard slide: a title followed by vertically-centered content.
class ContentSlide extends StatelessWidget {
  const ContentSlide({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow(),
        Padding(padding: const EdgeInsets.only(bottom: 28), child: H2(title)),
        ...children,
      ],
    );
  }
}

/// The small "── TOPIC" label above slide titles, in the topic's accent.
class Eyebrow extends StatelessWidget {
  const Eyebrow({super.key, this.center = false});

  final bool center;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final topic = SlideTopic.of(context);
    final accent = palette.topicAccent(topic);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        spacing: 10,
        children: [
          Container(
            width: 28,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0), accent],
              ),
            ),
          ),
          Text(
            topic.label.toUpperCase(),
            style: TextStyle(
              fontFamily: Fonts.heading,
              fontSize: 13.6,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: accent,
            ),
          ),
          if (center)
            Container(
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lays out [children] in rows of [columns] equally-wide, equally-tall cells.
class Grid extends StatelessWidget {
  const Grid({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 28,
  });

  final int columns;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = (children.length / columns).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) SizedBox(width: gap),
                  Expanded(
                    child: row * columns + col < children.length
                        ? children[row * columns + col]
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class DeckCard extends StatelessWidget {
  const DeckCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.accentBar = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool accentBar;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.cardBg,
        border: Border.all(color: palette.cardBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.isLight
                ? const Color(0x14000000)
                : const Color(0x59000000),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [child],
            ),
          ),
          // A soft highlight along the top edge, as if lit from above.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    palette.heading.withValues(alpha: 0),
                    palette.heading.withValues(alpha: 0.18),
                    palette.heading.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          if (accentBar)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.accent,
                      palette.accent.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FeatureList extends StatelessWidget {
  const FeatureList(
    this.items, {
    super.key,
    this.fontSize = 16.8,
    this.gap = 10.4,
    this.top = 8,
  });

  final List<String> items;
  final double fontSize;
  final double gap;
  final double top;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, item) in items.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : gap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '✦',
                      style: TextStyle(
                        color: palette.accent,
                        fontSize: 14.4,
                        height: fontSize * 1.45 / 14.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Md(
                      item,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.45,
                        color: palette.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Callout extends StatelessWidget {
  const Callout(this.text, {super.key, this.fontSize = 16.8, this.top = 12});

  final String text;
  final double fontSize;
  final double top;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 12),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(9.6),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.05),
            border: Border(left: BorderSide(color: palette.accent, width: 3)),
          ),
          child: Md(
            text,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.5,
              color: palette.calloutText,
            ),
          ),
        ),
      ),
    );
  }
}

/// The centered "💡 PRO TIP" / "⚠️ DANGER" card.
class BadgeCardSlide extends StatelessWidget {
  const BadgeCardSlide({
    super.key,
    required this.children,
    this.danger = false,
    this.maxWidth = 900,
    this.padding = const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
  });

  final List<Widget> children;
  final bool danger;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final tint = danger ? Hues.rose : palette.accent;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: padding,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: danger ? 0.06 : 0.05),
                border: Border.all(
                  color: tint.withValues(alpha: danger ? 0.3 : 0.25),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // The card is translucent, so the shadow shows through.
                    color: palette.isLight
                        ? const Color(0x0D000000)
                        : const Color(0x4D000000),
                    blurRadius: 40,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 19,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: tint.withValues(alpha: 0.5),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Text(
                    danger ? '⚠️ DANGER' : '💡 PRO TIP',
                    style: TextStyle(
                      fontFamily: Fonts.heading,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.6,
                      letterSpacing: 1.1,
                      color: danger ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeTitle extends StatelessWidget {
  const BadgeTitle(
    this.text, {
    super.key,
    this.bottom = 24,
    this.fontSize = 35.2,
  });

  final String text;
  final double bottom;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: Fonts.heading,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.35,
          color: Palette.of(context).heading,
        ),
      ),
    );
  }
}

class BadgeSubtitle extends StatelessWidget {
  const BadgeSubtitle(this.text, {super.key, this.height = 1.6});

  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Md(
      text,
      style: TextStyle(
        fontSize: 18.4,
        height: height,
        color: Palette.of(context).textMuted,
      ),
    );
  }
}

/// A screenshot with rounded corners, border and drop shadow.
class FramedImage extends StatelessWidget {
  const FramedImage(
    this.asset, {
    super.key,
    required this.aspectRatio,
    required this.maxHeight,
  });

  final String asset;
  final double aspectRatio;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1AFFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x73000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// A bordered, tinted box used to draw architecture diagrams.
class DiagramBox extends StatelessWidget {
  const DiagramBox({
    super.key,
    required this.child,
    this.tint,
    this.highlight = false,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.maxWidth = 800,
  });

  /// When null, uses the neutral surface color.
  final Color? tint;

  /// Draws the thick accent border with a glow.
  final bool highlight;
  final List<Color>? gradient;
  final EdgeInsets padding;
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null
              ? tint?.withValues(alpha: 0.1) ?? palette.surface
              : null,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    for (final color in gradient!)
                      color.withValues(alpha: 0.15),
                  ],
                ),
          border: Border.all(
            color: highlight
                ? palette.accent
                : tint?.withValues(alpha: 0.3) ?? palette.cardBorder,
            width: highlight ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(highlight ? 12 : 9.6),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// An emoji + title + caption node of a diagram.
class DiagramNode extends StatelessWidget {
  const DiagramNode({
    super.key,
    required this.emoji,
    required this.title,
    required this.caption,
    required this.color,
    this.tint,
    this.emojiSize = 24,
    this.titleSize = 16,
    this.captionSize = 12.8,
  });

  final String emoji;
  final String title;
  final String caption;
  final Color color;
  final Color? tint;
  final double emojiSize;
  final double titleSize;
  final double captionSize;

  @override
  Widget build(BuildContext context) {
    return DiagramBox(
      tint: tint,
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: emojiSize)),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: captionSize,
              color: Palette.of(context).textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of arrow glyphs, one centered per column.
class Arrows extends StatelessWidget {
  const Arrows(this.arrows, {super.key, this.maxWidth = 800});

  final List<String> arrows;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        children: [
          for (final arrow in arrows)
            Expanded(
              child: Text(
                arrow,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.of(context).accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Calls [builder] with whether the mouse is hovering it.
class Hoverable extends StatefulWidget {
  const Hoverable({super.key, required this.builder, this.onTap});

  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(context, _hovered),
      ),
    );
  }
}
