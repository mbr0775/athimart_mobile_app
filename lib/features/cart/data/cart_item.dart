// lib/features/cart/data/cart_item.dart

class CartItem {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final double price;
  final double? originalPrice;
  final int discountPercent;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.price,
    this.originalPrice,
    this.discountPercent = 0,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id, name: name, emoji: emoji, category: category,
    price: price, originalPrice: originalPrice,
    discountPercent: discountPercent,
    quantity: quantity ?? this.quantity,
  );
}