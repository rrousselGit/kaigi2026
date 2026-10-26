// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'cart.dart';
import 'models.dart';
import 'shop_app.dart';
import 'widgets.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ShopHeader(
              'Checkout',
              trailing: state.expressCheckout
                  ? FakeIconButton(
                      Icons.edit_outlined,
                      onTap: () => ShopScope.update(
                        context,
                        (state) => state.copyWith(
                          checkout: CheckoutStep.none,
                          cartOpen: true,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  const _Section(
                    title: 'Shipping address',
                    icon: Icons.location_on_outlined,
                    lines: ['Dash the Dart', '42 Widget Lane', 'Paris, France'],
                  ),
                  const _Section(
                    title: 'Delivery',
                    icon: Icons.local_shipping_outlined,
                    lines: ['Standard · 2-4 business days'],
                  ),
                  const _Section(
                    title: 'Payment',
                    icon: Icons.credit_card_rounded,
                    lines: ['Visa ending in 4242'],
                  ),
                  ShopCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in state.cart)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${item.quantity} × ${item.product.name}',
                              style: const TextStyle(color: ShopColors.ink),
                            ),
                          ),
                        const Divider(height: 20, color: ShopColors.border),
                        OrderSummary(state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomBar(
              child: FakeButton(
                'Place order · ${formatPrice(state.total)}',
                icon: Icons.check_circle_outline_rounded,
                onTap: () => ShopScope.update(
                  context,
                  (state) => state.copyWith(checkout: CheckoutStep.confirmed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShopCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ShopColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ShopColors.primary, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ShopColors.ink,
                    ),
                  ),
                  for (final line in lines)
                    Text(line, style: const TextStyle(color: ShopColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ShopColors.muted),
          ],
        ),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: ShopColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 64,
                    color: ShopColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Order placed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ShopColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #SH-20481 · ${formatPrice(state.total)}\n'
                'Arriving Thursday',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: ShopColors.muted,
                ),
              ),
              const Spacer(flex: 2),
              FakeButton(
                'Continue shopping',
                onTap: () => ShopScope.update(
                  context,
                  (state) => state.continueShopping(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
