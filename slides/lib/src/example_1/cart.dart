// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'models.dart';
import 'shop_app.dart';
import 'widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ShopHeader('My cart (${state.cartCount})'),
            Expanded(
              child: state.cart.isEmpty
                  ? const _EmptyCart()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        for (final item in state.cart)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CartLine(item),
                          ),
                        const SizedBox(height: 8),
                        ShopCard(child: OrderSummary(state)),
                      ],
                    ),
            ),
            if (state.cart.isNotEmpty)
              BottomBar(
                child: FakeButton(
                  'Checkout · ${formatPrice(state.total)}',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => ShopScope.update(
                    context,
                    (state) => state.copyWith(checkout: CheckoutStep.review),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text('🛒', style: TextStyle(fontSize: 64)),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ShopColors.ink,
            ),
          ),
          Text(
            'Items you add will show up here.',
            style: TextStyle(color: ShopColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine(this.item);

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
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
                Text(
                  formatPrice(item.total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ShopColors.primary,
                  ),
                ),
              ],
            ),
          ),
          _Quantity(item),
        ],
      ),
    );
  }
}

class _Quantity extends StatelessWidget {
  const _Quantity(this.item);

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final quantity = item.quantity;
    void add(int quantity) => ShopScope.update(
      context,
      (state) => state.addToCart(item.productId, quantity: quantity),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Tappable(
            onTap: () => add(-1),
            child: const Icon(
              Icons.remove_rounded,
              size: 16,
              color: ShopColors.muted,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ShopColors.ink,
              ),
            ),
          ),
          Tappable(
            onTap: () => add(1),
            child: const Icon(
              Icons.add_rounded,
              size: 16,
              color: ShopColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtotal, shipping and total of the cart.
class OrderSummary extends StatelessWidget {
  const OrderSummary(this.state, {super.key});

  final ShopState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryRow('Subtotal', formatPrice(state.subtotal)),
        SummaryRow(
          'Shipping',
          state.shipping == 0 ? 'Free' : formatPrice(state.shipping),
        ),
        const Divider(height: 20, color: ShopColors.border),
        SummaryRow('Total', formatPrice(state.total), bold: true),
      ],
    );
  }
}
