// Page keys are identifiers, not user-facing text.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'cart.dart';
import 'catalog.dart';
import 'checkout.dart';
import 'models.dart';
import 'product.dart';

/// A small e-commerce app, entirely driven by [state].
///
/// It has no interactive controls: the slides change [state] instead, and the
/// navigation stack is derived from it. Pages are therefore pushed when moving
/// forward through the slides, and popped when going back.
class ShopApp extends StatelessWidget {
  const ShopApp({super.key, required this.state});

  final ShopState state;

  static final _theme = ThemeData(
    colorSchemeSeed: const Color(0xFF4F46E5),
    fontFamily: Fonts.body,
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  );

  @override
  Widget build(BuildContext context) {
    final productId = state.productId;
    return Theme(
      data: _theme,
      child: ShopScope(
        state: state,
        child: Navigator(
          pages: [
            const _ShopPage(key: ValueKey('catalog'), child: CatalogScreen()),
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
          // Pages are only ever removed by the slides changing the state.
          onDidRemovePage: (_) {},
        ),
      ),
    );
  }
}

/// Exposes the [ShopState] to the screens of the [ShopApp].
class ShopScope extends InheritedWidget {
  const ShopScope({super.key, required this.state, required super.child});

  final ShopState state;

  static ShopState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShopScope>()!.state;

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
/// gesture of platform routes: the example must not react to the mouse.
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
