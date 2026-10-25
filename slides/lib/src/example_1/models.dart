// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.emoji,
    required this.color,
    required this.rating,
    required this.reviews,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String emoji;
  final Color color;
  final double rating;
  final int reviews;
  final String description;
}

const categories = ['All', 'Audio', 'Wearables', 'Home', 'Outdoor'];

const products = [
  Product(
    id: 'headphones',
    name: 'Studio Headphones',
    category: 'Audio',
    price: 149,
    emoji: '🎧',
    color: Color(0xFF6366F1),
    rating: 4.7,
    reviews: 1284,
    description:
        'Wireless over-ear headphones with active noise cancelling and a '
        '30-hour battery. Folds flat for travel.',
  ),
  Product(
    id: 'watch',
    name: 'Smart Watch S2',
    category: 'Wearables',
    price: 229,
    emoji: '⌚',
    color: Color(0xFF0EA5E9),
    rating: 4.5,
    reviews: 862,
    description:
        'Track workouts, sleep and heart rate. Always-on display and a week '
        'of battery life.',
  ),
  Product(
    id: 'speaker',
    name: 'Pocket Speaker',
    category: 'Audio',
    price: 59,
    emoji: '🔊',
    color: Color(0xFFF97316),
    rating: 4.3,
    reviews: 532,
    description:
        'Waterproof bluetooth speaker with surprisingly deep bass. Clips onto '
        'any bag.',
  ),
  Product(
    id: 'lamp',
    name: 'Desk Lamp',
    category: 'Home',
    price: 39,
    emoji: '💡',
    color: Color(0xFFEAB308),
    rating: 4.6,
    reviews: 341,
    description:
        'Dimmable LED lamp with warm and cool modes, and a USB-C port to '
        'charge your phone.',
  ),
  Product(
    id: 'backpack',
    name: 'Trail Backpack',
    category: 'Outdoor',
    price: 89,
    emoji: '🎒',
    color: Color(0xFF10B981),
    rating: 4.8,
    reviews: 2011,
    description:
        '28L backpack with a padded laptop sleeve, rain cover and plenty of '
        'pockets.',
  ),
  Product(
    id: 'mug',
    name: 'Ceramic Mug',
    category: 'Home',
    price: 18,
    emoji: '☕',
    color: Color(0xFFA16207),
    rating: 4.4,
    reviews: 198,
    description: 'Hand-glazed 350ml mug. Dishwasher and microwave safe.',
  ),
  Product(
    id: 'earbuds',
    name: 'True Wireless Earbuds',
    category: 'Audio',
    price: 99,
    emoji: '🎵',
    color: Color(0xFFEC4899),
    rating: 4.2,
    reviews: 745,
    description:
        'Compact earbuds with a charging case, touch controls and IPX4 '
        'sweat resistance.',
  ),
  Product(
    id: 'tent',
    name: 'Two-Person Tent',
    category: 'Outdoor',
    price: 179,
    emoji: '⛺',
    color: Color(0xFF22C55E),
    rating: 4.6,
    reviews: 412,
    description:
        'Lightweight tent that sets up in under five minutes. Packs down to '
        'the size of a water bottle.',
  ),
  Product(
    id: 'ring',
    name: 'Fitness Ring',
    category: 'Wearables',
    price: 199,
    emoji: '💍',
    color: Color(0xFF8B5CF6),
    rating: 4.1,
    reviews: 167,
    description:
        'A titanium ring that tracks sleep and activity, without a screen to '
        'distract you.',
  ),
  Product(
    id: 'plant',
    name: 'Potted Monstera',
    category: 'Home',
    price: 45,
    emoji: '🪴',
    color: Color(0xFF16A34A),
    rating: 4.9,
    reviews: 903,
    description: 'A low-maintenance houseplant, delivered in a ceramic pot.',
  ),
  Product(
    id: 'bottle',
    name: 'Insulated Bottle',
    category: 'Outdoor',
    price: 29,
    emoji: '🧴',
    color: Color(0xFF06B6D4),
    rating: 4.5,
    reviews: 1520,
    description: 'Keeps drinks cold for 24 hours, or hot for 12.',
  ),
  Product(
    id: 'glasses',
    name: 'Blue-Light Glasses',
    category: 'Wearables',
    price: 49,
    emoji: '👓',
    color: Color(0xFF64748B),
    rating: 4.0,
    reviews: 276,
    description: 'Lightweight frames that reduce eye strain from screens.',
  ),
];

Product productById(String id) => products.firstWhere((p) => p.id == id);

class CartItem {
  const CartItem(this.productId, {this.quantity = 1});

  final String productId;
  final int quantity;

  Product get product => productById(productId);
  double get total => product.price * quantity;
}

/// How far the user went in the checkout flow.
enum CheckoutStep { none, review, confirmed }

/// Everything the example app shows.
///
/// The app has no state of its own: each slide describes what the app looks
/// like, and moving between slides animates from one [ShopState] to the next.
class ShopState {
  const ShopState({
    this.category = 'All',
    this.catalogScroll = 0,
    this.productId,
    this.cart = const [],
    this.cartOpen = false,
    this.checkout = CheckoutStep.none,
  });

  /// The selected filter on the catalog.
  final String category;

  /// The scroll offset of the catalog, in logical pixels.
  final double catalogScroll;

  /// The product whose details are open, if any.
  final String? productId;

  final List<CartItem> cart;

  /// Whether the cart is open, on top of the catalog/product page.
  final bool cartOpen;

  final CheckoutStep checkout;

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get shipping => subtotal == 0 || subtotal >= 100 ? 0 : 7.99;
  double get total => subtotal + shipping;

  int quantityOf(String productId) {
    for (final item in cart) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }
}

String formatPrice(double price) => '\$${price.toStringAsFixed(2)}';
