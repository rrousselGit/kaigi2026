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
    final state = ShopScope.of(context);
    final product = productById(productId);
    final inCart = state.quantityOf(productId);

    return Scaffold(
      backgroundColor: Colors.white,
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
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 12, color: ShopColors.muted),
                    ),
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ShopColors.ink,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: inCart == 0
                      ? const FakeButton(
                          'Add to cart',
                          icon: Icons.add_shopping_cart_rounded,
                        )
                      : FakeButton(
                          'In cart · $inCart',
                          icon: Icons.check_rounded,
                          color: ShopColors.success,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: ShopColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: ShopColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Rating(product, showReviews: true),
        const SizedBox(height: 20),
        const Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ShopColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.description,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: ShopColors.muted,
          ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Icon(icon, size: 20, color: ShopColors.primary),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: ShopColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
