// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'models.dart';
import 'shop_app.dart';
import 'widgets.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.productId});

  /// The product shown, passed explicitly rather than read from the state so
  /// that the page keeps its content while it is being popped.
  final String productId;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    final state = ShopScope.of(context);
    final product = productById(productId);
    final inCart = state.quantityOf(productId);
    void addToCart() =>
        ShopScope.update(context, (state) => state.addToCart(productId));

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 340,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ProductImage(product, size: 120, radius: 0),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: MediaQuery.paddingOf(context).top,
                          child: ShopHeader(
                            '',
                            trailing: FakeIconButton(
                              Icons.shopping_bag_outlined,
                              badge: state.cartCount,
                              onTap: () => ShopScope.update(
                                context,
                                (state) => state.copyWith(cartOpen: true),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: _Details(product),
                  ),
                ),
              ],
            ),
          ),
          BottomBar(
            child: Row(
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(fontSize: 12, color: colors.muted),
                    ),
                    Text(
                      formatPrice(product.price),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
                if (state.expressCheckout) ...[
                  // Two buttons don't fit with icons.
                  Expanded(
                    child: inCart == 0
                        ? FakeButton(
                            'Add to cart',
                            color: colors.ink,
                            onTap: addToCart,
                          )
                        : FakeButton(
                            'In cart · $inCart',
                            color: colors.success,
                            onTap: addToCart,
                          ),
                  ),
                  Expanded(
                    child: FakeButton(
                      'Buy now',
                      onTap: () => ShopScope.update(
                        context,
                        (state) =>
                            (inCart == 0 ? state.addToCart(productId) : state)
                                .copyWith(checkout: CheckoutStep.review),
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: inCart == 0
                        ? FakeButton(
                            'Add to cart',
                            icon: Icons.add_shopping_cart_rounded,
                            onTap: addToCart,
                          )
                        : FakeButton(
                            'In cart · $inCart',
                            icon: Icons.check_rounded,
                            color: colors.success,
                            onTap: addToCart,
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

class _Details extends StatelessWidget {
  const _Details(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Rating(product, showReviews: true),
        const SizedBox(height: 20),
        Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.description,
          style: TextStyle(fontSize: 14.5, height: 1.55, color: colors.muted),
        ),
        const SizedBox(height: 20),
        const Row(
          spacing: 10,
          children: [
            _Perk(Icons.local_shipping_outlined, 'Free shipping\nover \$100'),
            _Perk(Icons.replay_rounded, '30-day\nreturns'),
            _Perk(Icons.verified_outlined, '2-year\nwarranty'),
          ],
        ),
      ],
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = ShopColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Icon(icon, size: 20, color: colors.primary),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, height: 1.3, color: colors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
