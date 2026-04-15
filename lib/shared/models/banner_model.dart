// lib/shared/models/banner_model.dart
class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final List<int> gradientColors;
  final String emoji;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.gradientColors,
    required this.emoji,
  });
}