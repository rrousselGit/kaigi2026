// Page keys are identifiers, not user-facing text.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'cart.dart';
import 'catalog.dart';
import 'checkout.dart';
import 'models.dart';
import 'product.dart';
import 'widgets.dart';
import 'wishlist.dart';

/// A small e-commerce app, driven by [state].
///
/// The slides change [state], and the navigation stack is derived from it:
/// pages are pushed when moving forward through the slides, and popped when
/// going back.
///
/// The app can also be clicked through. Clicks change a local copy of the
/// state, which is reset to [state] whenever the slides change it.
class ShopApp extends StatefulWidget {
  const ShopApp({super.key, required this.state});

  final ShopState state;

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late var _state = widget.state;

  @override
  void didUpdateWidget(ShopApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) _state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final productId = state.productId;
    return Theme(
      // The slides show the app in light mode, whatever the system's theme.
      data: shopTheme(Brightness.light),
      child: ShopScope(
        state: state,
        onChanged: (state) => setState(() => _state = state),
        child: Navigator(
          pages: [
            const _ShopPage(key: ValueKey('catalog'), child: CatalogScreen()),
            if (state.wishlistOpen)
              const _ShopPage(
                key: ValueKey('wishlist'),
                child: WishlistScreen(),
              ),
            if (productId != null)
              _ShopPage(
                key: ValueKey('product-$productId'),
                child: ProductScreen(productId: productId),
              ),
            if (state.cartOpen)
              const _ShopPage(key: ValueKey('cart'), child: CartScreen()),
            if (state.checkout != CheckoutStep.none)
              const _ShopPage(
                key: ValueKey('checkout'),
                child: CheckoutScreen(),
              ),
            if (state.checkout == CheckoutStep.confirmed)
              const _ShopPage(
                key: ValueKey('confirmed'),
                child: ConfirmationScreen(),
              ),
          ],
          // Pages are only ever removed by changing the state.
          onDidRemovePage: (_) {},
        ),
      ),
    );
  }
}

/// The theme of the [ShopApp], in light or dark mode.
ThemeData shopTheme(Brightness brightness) => switch (brightness) {
  Brightness.light => _lightTheme,
  Brightness.dark => _darkTheme,
};

final _lightTheme = _theme(Brightness.light, ShopColors.light);
final _darkTheme = _theme(Brightness.dark, ShopColors.dark);

ThemeData _theme(Brightness brightness, ShopColors colors) => ThemeData(
  brightness: brightness,
  colorSchemeSeed: const Color(0xFF4F46E5),
  fontFamily: Fonts.body,
  scaffoldBackgroundColor: colors.background,
  extensions: [colors],
);

/// Exposes the [ShopState] to the screens of the [ShopApp].
class ShopScope extends InheritedWidget {
  const ShopScope({
    super.key,
    required this.state,
    this.onChanged,
    required super.child,
  });

  final ShopState state;

  /// Called when the user clicks through the app. Null for static previews.
  final ValueChanged<ShopState>? onChanged;

  static ShopState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShopScope>()!.state;

  /// Applies [change] to the state, if the app is interactive.
  static void update(
    BuildContext context,
    ShopState Function(ShopState state) change,
  ) {
    final scope = context.getInheritedWidgetOfExactType<ShopScope>()!;
    scope.onChanged?.call(change(scope.state));
  }

  @override
  bool updateShouldNotify(ShopScope oldWidget) => state != oldWidget.state;
}

class _ShopPage extends Page<void> {
  const _ShopPage({required LocalKey super.key, required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => _ShopRoute(this);
}

/// A route that slides in from the right, without the swipe-to-go-back
/// gesture of platform routes: going back is done with the back buttons.
class _ShopRoute extends PageRoute<void> {
  _ShopRoute(_ShopPage page) : super(settings: page);

  _ShopPage get _page => settings as _ShopPage;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _page.child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final covered = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(incoming),
      child: SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: const Offset(-0.3, 0),
        ).animate(covered),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 16)],
          ),
          child: child,
        ),
      ),
    );
  }
}
