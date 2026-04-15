// lib/shared/models/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String tag;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.tag,
  });
}