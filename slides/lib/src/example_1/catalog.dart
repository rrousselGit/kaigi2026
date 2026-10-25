// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import 'models.dart';
import 'shop_app.dart';
import 'widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  ScrollController? _controller;
  double? _scrollTarget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final target = ShopScope.of(context).catalogScroll;
    if (target == _scrollTarget) return;
    _scrollTarget = target;

    final controller = _controller ??= ScrollController(
      initialScrollOffset: target,
    );
    // Only follow the slides when they ask for a different offset, so that
    // scrolling manually isn't undone by unrelated state changes.
    if (controller.hasClients) {
      final position = controller.position;
      controller.animateTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    final visible = [
      for (final product in products)
        if (state.category == 'All' || product.category == state.category)
          product,
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  const Expanded(child: _Logo()),
                  const FakeIconButton(Icons.favorite_border_rounded),
                  const SizedBox(width: 10),
                  FakeIconButton(
                    Icons.shopping_bag_outlined,
                    badge: state.cartCount,
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: _controller,
                slivers: [
                  const SliverToBoxAdapter(child: _SearchField()),
                  const SliverToBoxAdapter(child: _PromoBanner()),
                  SliverToBoxAdapter(
                    child: _Categories(selected: state.category),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text(
                        state.category == 'All'
                            ? 'Popular right now'
                            : state.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ShopColors.ink,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            mainAxisExtent: 226,
                          ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) => _ProductCard(
                        visible[index],
                        inCart: state.quantityOf(visible[index].id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ShopColors.primary, Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
        ),
        const Text(
          'Shoply',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ShopColors.ink,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShopColors.border),
      ),
      child: const Row(
        spacing: 10,
        children: [
          Icon(Icons.search_rounded, color: ShopColors.muted),
          Expanded(
            child: Text(
              'Search products',
              style: TextStyle(color: ShopColors.muted, fontSize: 15),
            ),
          ),
          Icon(Icons.tune_rounded, color: ShopColors.muted, size: 20),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [ShopColors.primary, Color(0xFF9333EA)],
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                Text(
                  'SUMMER SALE',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Up to 30% off\naudio gear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text('🎧', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: category == selected ? ShopColors.ink : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: category == selected
                        ? ShopColors.ink
                        : ShopColors.border,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: category == selected ? Colors.white : ShopColors.ink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product, {required this.inCart});

  final Product product;

  /// How many of [product] are in the cart.
  final int inCart;

  @override
  Widget build(BuildContext context) {
    return ShopCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: ProductImage(product, size: 52)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    scale: inCart == 0 ? 0 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ShopColors.success,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '×$inCart in cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ShopColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ShopColors.primary,
                  ),
                ),
              ),
              Rating(product),
            ],
          ),
        ],
      ),
    );
  }
}
