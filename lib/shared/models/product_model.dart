// lib/shared/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String emoji;
  final int cardColor;
  final bool isNew;
  final bool isSale;
  final int discountPercent;
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.emoji,
    required this.cardColor,
    this.isNew = false,
    this.isSale = false,
    this.discountPercent = 0,
    this.stock = 0,
  });
}