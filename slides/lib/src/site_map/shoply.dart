// Demo data, written by hand.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import '../example_1/cart.dart';
import '../example_1/catalog.dart';
import '../example_1/checkout.dart';
import '../example_1/models.dart';
import '../example_1/product.dart';
import '../example_1/shop_app.dart';
import '../example_1/widgets.dart';
import '../example_1/wishlist.dart';
import 'diff.dart';
import 'site_map.dart';

/// Fake data the pages are previewed with.
const _fakeCart = [CartItem('headphones'), CartItem('speaker', quantity: 2)];
const _fakeOrder = ShopState(cart: _fakeCart);

const _fakeWishlist = ['watch', 'lamp', 'backpack'];

/// The site map of `slides/lib/src/example_1`, before the wishlist was added.
///
/// A real devtool would generate this from the code (with the analyzer, or
/// from typed routes). For the demo, it is written by hand.
final shoplySiteMap = _shoply(wishlist: false);

/// The site map once the wishlist page is added.
final shoplyWishlistSiteMap = _shoply(wishlist: true);

/// The site map once products can be bought without going through the cart.
final shoplyBuyNowSiteMap = _shoply(expressCheckout: true);

/// The pull request adding the wishlist, as a devtool would read it from git.
final shoplyWishlistDiff = SiteMapDiff(
  base: shoplySiteMap,
  head: shoplyWishlistSiteMap,
  baseRef: 'main',
  headRef: 'feature/wishlist',
  files: const [
    FileChange(
      'wishlist.dart',
      change: Change.added,
      additions: 133,
      declarations: ['WishlistScreen', '_EmptyWishlist', '_WishlistItem'],
    ),
    FileChange(
      'catalog.dart',
      change: Change.modified,
      additions: 4,
      deletions: 1,
      declarations: ['_CatalogScreenState'],
    ),
    FileChange(
      'models.dart',
      change: Change.modified,
      additions: 8,
      declarations: ['ShopState'],
    ),
    FileChange(
      'shop_app.dart',
      change: Change.modified,
      additions: 6,
      declarations: ['ShopApp'],
    ),
  ],
);

/// The pull request adding a "Buy now" button: no new page, but new paths
/// between existing ones.
final shoplyBuyNowDiff = SiteMapDiff(
  base: shoplySiteMap,
  head: shoplyBuyNowSiteMap,
  baseRef: 'main',
  headRef: 'feature/buy-now',
  files: const [
    FileChange(
      'product.dart',
      change: Change.modified,
      additions: 24,
      deletions: 12,
      declarations: ['ProductScreen'],
    ),
    FileChange(
      'checkout.dart',
      change: Change.modified,
      additions: 6,
      deletions: 1,
      declarations: ['CheckoutScreen'],
    ),
    FileChange(
      'models.dart',
      change: Change.modified,
      additions: 4,
      declarations: ['ShopState'],
    ),
  ],
);

SiteMap _shoply({bool wishlist = false, bool expressCheckout = false}) =>
    SiteMap(
      source: 'slides/lib/src/example_1',
      routes: [
        RouteNode(
          id: 'catalog',
          title: 'Catalog',
          screen: 'CatalogScreen',
          location: 'catalog.dart:10',
          preview: _ShopPreview(
            state: ShopState(
              cart: const [CartItem('headphones')],
              wishlist: wishlist ? _fakeWishlist : const [],
            ),
            child: const CatalogScreen(),
          ),
          elements: [
            UiElement(
              ElementKind.iconButton,
              'Favorites',
              location: 'catalog.dart:68',
              target: wishlist ? 'wishlist' : null,
              finder: _iconButton(Icons.favorite_border_rounded),
            ),
            UiElement(
              ElementKind.iconButton,
              'Shopping bag',
              location: 'catalog.dart:70',
              target: 'cart',
              finder: _iconButton(Icons.shopping_bag_outlined),
            ),
            UiElement(
              ElementKind.tile,
              'Product card',
              location: 'catalog.dart:117',
              target: 'product',
              finder: _named('_ProductCard'),
            ),
          ],
        ),
        if (wishlist)
          RouteNode(
            id: 'wishlist',
            title: 'Wishlist',
            screen: 'WishlistScreen',
            location: 'wishlist.dart:10',
            condition: 'state.wishlistOpen',
            preview: const _ShopPreview(
              state: ShopState(wishlist: _fakeWishlist),
              child: WishlistScreen(),
            ),
            elements: [
              UiElement(
                ElementKind.back,
                'Back',
                location: 'wishlist.dart:22',
                finder: _iconButton(Icons.arrow_back_rounded),
              ),
              UiElement(
                ElementKind.tile,
                'Saved product',
                location: 'wishlist.dart:32',
                target: 'product',
                finder: _named('_WishlistItem'),
              ),
              UiElement(
                ElementKind.button,
                'Add all to cart',
                location: 'wishlist.dart:39',
                target: 'cart',
                finder: _button('Add all to cart'),
              ),
            ],
          ),
        RouteNode(
          id: 'product',
          title: 'Product',
          screen: 'ProductScreen',
          location: 'product.dart:10',
          condition: 'productId != null',
          params: ['productId'],
          preview: _ShopPreview(
            state: ShopState(
              productId: 'headphones',
              expressCheckout: expressCheckout,
            ),
            child: const ProductScreen(productId: 'headphones'),
          ),
          elements: [
            UiElement(
              ElementKind.back,
              'Back',
              location: 'product.dart:42',
              finder: _iconButton(Icons.arrow_back_rounded),
            ),
            UiElement(
              ElementKind.iconButton,
              'Shopping bag',
              location: 'product.dart:44',
              target: 'cart',
              finder: _iconButton(Icons.shopping_bag_outlined),
            ),
            UiElement(
              ElementKind.button,
              'Add to cart',
              location: 'product.dart:87',
              finder: _button('Add to cart'),
            ),
            if (expressCheckout)
              UiElement(
                ElementKind.button,
                'Buy now',
                location: 'product.dart:95',
                target: 'checkout',
                finder: _button('Buy now'),
              ),
          ],
        ),
        RouteNode(
          id: 'cart',
          title: 'Cart',
          screen: 'CartScreen',
          location: 'cart.dart:10',
          condition: 'state.cartOpen',
          preview: const _ShopPreview(state: _fakeOrder, child: CartScreen()),
          elements: [
            UiElement(
              ElementKind.back,
              'Back',
              location: 'cart.dart:22',
              finder: _iconButton(Icons.arrow_back_rounded),
            ),
            UiElement(
              ElementKind.button,
              'Quantity −/+',
              location: 'cart.dart:124',
              finder: _named('_Quantity'),
            ),
            UiElement(
              ElementKind.button,
              'Checkout · \$…',
              location: 'cart.dart:41',
              target: 'checkout',
              finder: _button('Checkout'),
            ),
          ],
        ),
        RouteNode(
          id: 'checkout',
          title: 'Checkout',
          screen: 'CheckoutScreen',
          location: 'checkout.dart:11',
          condition: 'state.checkout != CheckoutStep.none',
          preview: _ShopPreview(
            state: ShopState(cart: _fakeCart, expressCheckout: expressCheckout),
            child: const CheckoutScreen(),
          ),
          elements: [
            UiElement(
              ElementKind.back,
              'Back',
              location: 'checkout.dart:23',
              finder: _iconButton(Icons.arrow_back_rounded),
            ),
            if (expressCheckout)
              UiElement(
                ElementKind.iconButton,
                'Edit cart',
                location: 'checkout.dart:26',
                target: 'cart',
                finder: _iconButton(Icons.edit_outlined),
              ),
            UiElement(
              ElementKind.tile,
              'Address / Delivery / Payment',
              location: 'checkout.dart:28',
              finder: _named('_Section'),
            ),
            UiElement(
              ElementKind.button,
              'Place order · \$…',
              location: 'checkout.dart:64',
              target: 'confirmed',
              finder: _button('Place order'),
            ),
          ],
        ),
        RouteNode(
          id: 'confirmed',
          title: 'Order placed',
          screen: 'ConfirmationScreen',
          location: 'checkout.dart:129',
          condition: 'state.checkout == CheckoutStep.confirmed',
          preview: const _ShopPreview(
            state: _fakeOrder,
            child: ConfirmationScreen(),
          ),
          elements: [
            UiElement(
              ElementKind.button,
              'Continue shopping',
              location: 'checkout.dart:185',
              target: 'catalog',
              finder: _button('Continue shopping'),
            ),
          ],
        ),
      ],
    );

bool Function(Widget) _iconButton(IconData icon) =>
    (widget) => widget is FakeIconButton && widget.icon == icon;

bool Function(Widget) _button(String label) =>
    (widget) => widget is FakeButton && widget.label.startsWith(label);

/// Matches private widgets of the example, by their class name.
bool Function(Widget) _named(String type) =>
    (widget) => widget.runtimeType.toString() == type;

/// A single screen of the [ShopApp], without its navigator.
///
/// It can be clicked through like the app, starting from [state]. Without a
/// navigator, buttons opening other pages do nothing: the site map disables
/// them.
class _ShopPreview extends StatefulWidget {
  const _ShopPreview({required this.state, required this.child});

  final ShopState state;
  final Widget child;

  @override
  State<_ShopPreview> createState() => _ShopPreviewState();
}

class _ShopPreviewState extends State<_ShopPreview> {
  late var _state = widget.state;

  // Same as ShopApp's theme.
  static final _theme = ThemeData(
    colorSchemeSeed: const Color(0xFF4F46E5),
    fontFamily: Fonts.body,
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  );

  @override
  void didUpdateWidget(_ShopPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) _state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _theme,
      child: ShopScope(
        state: _state,
        onChanged: (state) => setState(() => _state = state),
        child: widget.child,
      ),
    );
  }
}
