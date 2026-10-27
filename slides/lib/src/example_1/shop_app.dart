// Page keys are identifiers, not user-facing text.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'cart.dart';
import 'catalog.dart';
import 'checkout.dart';
import 'debug_panel.dart';
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
  const ShopApp({
    super.key,
    required this.state,
    this.debug,
    this.inspect = false,
  });

  final ShopState state;

  /// The in-app debug panel, available when non-null, as in debug builds.
  final ShopDebug? debug;

  /// Whether the app shares its state through [ShopInspection], for a state
  /// inspector to show and edit it.
  final bool inspect;

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late var _state = widget.state;
  late var _debug = widget.debug;

  @override
  void initState() {
    super.initState();
    ShopInspection.current.addListener(_onInspected);
  }

  @override
  void dispose() {
    ShopInspection.current.removeListener(_onInspected);
    super.dispose();
  }

  /// Applies the edits made by the state inspector.
  void _onInspected() {
    final inspected = ShopInspection.current.value;
    if (!widget.inspect || inspected == null) return;
    if (identical(inspected.state, _state) && inspected.user == _debug?.user) {
      return;
    }
    setState(() {
      _state = inspected.state;
      if (inspected.user case final user?) {
        _debug = (_debug ?? const ShopDebug()).copyWith(user: user);
      }
    });
  }

  /// Shares the state with the state inspector, once the frame is built:
  /// listeners can't be notified while building.
  void _publish() {
    final inspected = (state: _state, user: _debug?.user);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.inspect) ShopInspection.current.value = inspected;
    });
  }

  @override
  void didUpdateWidget(ShopApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) _state = widget.state;
    if (widget.debug != oldWidget.debug) _debug = widget.debug;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final productId = state.productId;
    final debug = _debug;
    if (widget.inspect) _publish();
    final app = Theme(
      // The slides show the app in light mode, whatever the system's theme,
      // unless the debug panel changes it.
      data: shopTheme(debug?.brightness ?? Brightness.light),
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
    if (debug == null) return app;

    final media = MediaQuery.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(debug.textScale),
            ),
            child: app,
          ),
        ),
        if (debug.user case final user?)
          Positioned(
            top: media.padding.top + 8,
            left: 0,
            right: 0,
            child: Center(child: LoggedInBanner(email: user)),
          ),
        Positioned(
          right: 16,
          bottom: media.padding.bottom + 90,
          child: DebugButton(
            onTap: () =>
                setState(() => _debug = debug.copyWith(open: !debug.open)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: debug.open ? Offset.zero : const Offset(0, 1.1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: DebugPanel(
              debug: debug,
              onChanged: (debug) => setState(() => _debug = debug),
              onLogin: (user) => setState(() {
                _state = user.state;
                _debug = debug.copyWith(open: false, user: user.email);
              }),
            ),
          ),
        ),
      ],
    );
  }
}

/// The state of the [ShopApp] being inspected, and the test user it is
/// logged in as.
typedef InspectedShop = ({ShopState state, String? user});

/// Shares the state of the [ShopApp] with a state inspector shown next to it.
///
/// In a real app, the inspector would be a devtool reading and editing the
/// state through package:vm_service. In the slides, both live in the same
/// process, so they share this notifier instead.
abstract final class ShopInspection {
  static final current = ValueNotifier<InspectedShop?>(null);
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
