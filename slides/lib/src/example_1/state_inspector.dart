// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'debug_panel.dart';
import 'models.dart';
import 'shop_app.dart';

/// Colors of the inspector, which looks like a devtool rather than the app.
abstract final class _Colors {
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const border = Color(0xFF334155);
  static const text = Color(0xFFF1F5F9);
  static const muted = Color(0xFF94A3B8);
  static const accent = Color(0xFF22D3EE);
}

/// The pages of the app, as the inspector navigates between them.
enum _Page { catalog, product, cart, checkout }

/// Shows the state of the inspected [ShopApp], and edits it.
///
/// See [ShopInspection].
class StateInspector extends StatelessWidget {
  const StateInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ShopInspection.current,
      builder: (context, inspected, _) {
        if (inspected == null) return const SizedBox.shrink();

        void edit(ShopState state, {String? user}) {
          ShopInspection.current.value = (
            state: state,
            user: user ?? inspected.user,
          );
        }

        final state = inspected.state;
        return DefaultTextStyle(
          style: const TextStyle(
            fontFamily: Fonts.body,
            fontSize: 15,
            color: _Colors.text,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _Section(
                      title: 'Current user',
                      child: _Users(
                        current: inspected.user,
                        onLogin: (user) => edit(user.state, user: user.email),
                      ),
                    ),
                    _Section(
                      title: 'Page',
                      child: _Pages(state: state, onChanged: edit),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _Section(
                      title: 'Cart',
                      child: _Cart(state: state, onChanged: edit),
                    ),
                    _Section(
                      title: 'Catalog',
                      child: _Catalog(state: state, onChanged: edit),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _Colors.accent,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Users extends StatelessWidget {
  const _Users({required this.current, required this.onLogin});

  final String? current;
  final ValueChanged<TestUser> onLogin;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final user in testUsers)
          _Chip(
            label: user.email,
            selected: user.email == current,
            onTap: () => onLogin(user),
          ),
      ],
    );
  }
}

class _Pages extends StatelessWidget {
  const _Pages({required this.state, required this.onChanged});

  final ShopState state;
  final ValueChanged<ShopState> onChanged;

  _Page get _current => switch (state) {
    ShopState(checkout: != CheckoutStep.none) => _Page.checkout,
    ShopState(cartOpen: true) => _Page.cart,
    ShopState(productId: _?) => _Page.product,
    _ => _Page.catalog,
  };

  ShopState _open(_Page page) => switch (page) {
    _Page.catalog => state.copyWith(
      productId: () => null,
      cartOpen: false,
      checkout: CheckoutStep.none,
    ),
    _Page.product => state.copyWith(
      productId: () => state.productId ?? products.first.id,
      cartOpen: false,
      checkout: CheckoutStep.none,
    ),
    _Page.cart => state.copyWith(cartOpen: true, checkout: CheckoutStep.none),
    _Page.checkout => state.copyWith(
      cartOpen: true,
      checkout: CheckoutStep.review,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final page in _Page.values)
          _Chip(
            label: switch (page) {
              _Page.catalog => 'Catalog',
              _Page.product => 'Product',
              _Page.cart => 'Cart',
              _Page.checkout => 'Checkout',
            },
            selected: page == _current,
            onTap: () => onChanged(_open(page)),
          ),
      ],
    );
  }
}

class _Cart extends StatelessWidget {
  const _Cart({required this.state, required this.onChanged});

  final ShopState state;
  final ValueChanged<ShopState> onChanged;

  @override
  Widget build(BuildContext context) {
    if (state.cart.isEmpty) {
      return const Text('Empty', style: TextStyle(color: _Colors.muted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in state.cart)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text(item.product.name)),
                _Stepper(
                  value: item.quantity,
                  onChanged: (delta) => onChanged(
                    state.addToCart(item.productId, quantity: delta),
                  ),
                ),
              ],
            ),
          ),
        const Divider(color: _Colors.border, height: 16),
        Row(
          children: [
            const Expanded(
              child: Text('Total', style: TextStyle(color: _Colors.muted)),
            ),
            Text(
              formatPrice(state.total),
              style: const TextStyle(
                fontFamily: Fonts.code,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Catalog extends StatelessWidget {
  const _Catalog({required this.state, required this.onChanged});

  final ShopState state;
  final ValueChanged<ShopState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              _Chip(
                label: category,
                selected: category == state.category,
                onTap: () => onChanged(state.copyWith(category: category)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final product in products.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text(product.name)),
                Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontFamily: Fonts.code,
                    color: _Colors.muted,
                  ),
                ),
                const SizedBox(width: 10),
                _IconButton(
                  icon: Icons.add_shopping_cart_rounded,
                  onTap: () => onChanged(state.addToCart(product.id)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// − value +, changing the value by one.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;

  /// Called with -1 or 1.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        _IconButton(icon: Icons.remove_rounded, onTap: () => onChanged(-1)),
        SizedBox(
          width: 24,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: Fonts.code,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _IconButton(icon: Icons.add_rounded, onTap: () => onChanged(1)),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Colors.border),
        ),
        child: Icon(icon, size: 16, color: _Colors.accent),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? _Colors.accent.withValues(alpha: 0.2)
              : _Colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _Colors.accent : _Colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.6,
            fontWeight: FontWeight.w600,
            color: selected ? _Colors.accent : _Colors.muted,
          ),
        ),
      ),
    );
  }
}
