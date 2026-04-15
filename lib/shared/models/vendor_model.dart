// lib/shared/models/vendor_model.dart
class VendorModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int productCount;
  final String emoji;
  final int color;

  const VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.productCount,
    required this.emoji,
    required this.color,
  });
}