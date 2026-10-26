// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'models.dart';
import 'shop_app.dart';
import 'widgets.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ShopHeader('Wishlist (${state.wishlist.length})'),
            Expanded(
              child: state.wishlist.isEmpty
                  ? const _EmptyWishlist()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        for (final productId in state.wishlist)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Tappable(
                              onTap: () => ShopScope.update(
                                context,
                                (state) =>
                                    state.copyWith(productId: () => productId),
                              ),
                              child: _WishlistItem(productById(productId)),
                            ),
                          ),
                      ],
                    ),
            ),
            if (state.wishlist.isNotEmpty)
              BottomBar(
                child: FakeButton(
                  'Add all to cart',
                  icon: Icons.add_shopping_cart_rounded,
                  onTap: () => ShopScope.update(context, (state) {
                    for (final productId in state.wishlist) {
                      state = state.addToCart(productId);
                    }
                    return state.copyWith(cartOpen: true);
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text('💜', style: TextStyle(fontSize: 64)),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ShopColors.ink,
            ),
          ),
          Text(
            'Tap the heart on a product to save it.',
            style: TextStyle(color: ShopColors.muted),
          ),
        ],
      ),
    );
  }
}

class _WishlistItem extends StatelessWidget {
  const _WishlistItem(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ShopCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        spacing: 14,
        children: [
          SizedBox.square(
            dimension: 72,
            child: ProductImage(product, size: 34, radius: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ShopColors.ink,
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ShopColors.primary,
                      ),
                    ),
                    Rating(product),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899)),
        ],
      ),
    );
  }
}
