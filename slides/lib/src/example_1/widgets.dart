// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'models.dart';
import 'shop_app.dart';

/// The colors of the example app, in light or dark mode.
@immutable
class ShopColors extends ThemeExtension<ShopColors> {
  const ShopColors({
    required this.ink,
    required this.muted,
    required this.border,
    required this.primary,
    required this.success,
    required this.star,
    required this.surface,
    required this.background,
  });

  static const light = ShopColors(
    ink: Color(0xFF111827),
    muted: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    primary: Color(0xFF4F46E5),
    success: Color(0xFF16A34A),
    star: Color(0xFFF59E0B),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF6F7FB),
  );

  static const dark = ShopColors(
    ink: Color(0xFFF3F4F6),
    muted: Color(0xFF9CA3AF),
    border: Color(0xFF374151),
    primary: Color(0xFF6366F1),
    success: Color(0xFF22C55E),
    star: Color(0xFFFBBF24),
    surface: Color(0xFF1F2937),
    background: Color(0xFF111827),
  );

  static ShopColors of(BuildContext context) =>
      Theme.of(context).extension<ShopColors>() ?? light;

  /// Text and icons.
  final Color ink;
  final Color muted;
  final Color border;
  final Color primary;
  final Color success;
  final Color star;

  /// Cards, headers and bars.
  final Color surface;

  /// Behind cards.
  final Color background;

  @override
  ShopColors copyWith({
    Color? ink,
    Color? muted,
    Color? border,
    Color? primary,
    Color? success,
    Color? star,
    Color? surface,
    Color? background,
  }) {
    return ShopColors(
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      star: star ?? this.star,
      surface: surface ?? this.surface,
      background: background ?? this.background,
    );
  }

  @override
  ShopColors lerp(ShopColors? other, double t) {
    if (other == null) return this;
    return ShopColors(
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      star: Color.lerp(star, other.star, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
    );
  }
}

const _animationDuration = Duration(milliseconds: 300);

/// A product "photo": the product's emoji over a tint of its color.
class ProductImage extends StatelessWidget {
  const ProductImage(
    this.product, {
    super.key,
    this.size = 56,
    this.radius = 16,
  });

  final Product product;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            product.color.withValues(alpha: 0.14),
            product.color.withValues(alpha: 0.32),
          ],
        ),
      ),
      child: Center(
        child: Text(product.emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }
}

/// A button of the example. It does nothing without [onTap].
class FakeButton extends StatelessWidget {
  const FakeButton(this.label, {super.key, this.icon, this.color, this.onTap});

  final String label;
  final IconData? icon;

  /// Defaults to [ShopColors.primary].
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? ShopColors.of(context).primary;
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _animationDuration,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: _animationDuration,
          child: Row(
            key: ValueKey(label),
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 20),
              // Shrinks with large fonts on small screens, rather than
              // overflowing.
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round icon "button".
class FakeIconButton extends StatelessWidget {
  const FakeIconButton(this.icon, {super.key, this.badge = 0, this.onTap});

  final IconData icon;

  /// A counter drawn over the icon, hidden when 0.
  final int badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Tappable(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 8),
                  ],
                ),
                child: Icon(icon, size: 20, color: colors.ink),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: AnimatedScale(
                duration: _animationDuration,
                curve: Curves.easeOutBack,
                scale: badge == 0 ? 0 : 1,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: _animationDuration,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$badge',
                      key: ValueKey(badge),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
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

/// A header with a back arrow and a title, for pages pushed over the catalog.
class ShopHeader extends StatelessWidget {
  const ShopHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          FakeIconButton(
            Icons.arrow_back_rounded,
            onTap: () => ShopScope.update(context, (state) => state.pop()),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ),
          trailing ?? const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class Rating extends StatelessWidget {
  const Rating(this.product, {super.key, this.showReviews = false});

  final Product product;
  final bool showReviews;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(Icons.star_rounded, size: 16, color: colors.star),
        Text(
          product.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colors.ink,
          ),
        ),
        if (showReviews)
          Text(
            '(${product.reviews} reviews)',
            style: TextStyle(fontSize: 12.5, color: colors.muted),
          ),
      ],
    );
  }
}

/// A white rounded card.
class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A "label ... value" line of an order summary.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? colors.ink : colors.muted,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: style.copyWith(
              color: colors.ink,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bar pinned to the bottom of a screen, usually holding a [FakeButton].
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: child,
    );
  }
}

/// Makes [child] clickable when [onTap] is set, with a pointer cursor and a
/// slight press effect.
class Tappable extends StatefulWidget {
  const Tappable({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  var _pressed = false;

  void _press(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    if (onTap == null) return widget.child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapCancel: () => _press(false),
        onTapUp: (_) => _press(false),
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.95 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}
