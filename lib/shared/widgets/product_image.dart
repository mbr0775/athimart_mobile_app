// lib/shared/widgets/product_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

/// Shows the product's primary image if available,
/// falls back to emoji inside a colored card.
class ProductImage extends StatelessWidget {
  final List<dynamic>? imageUrls;
  final String emoji;
  final double? fontSize;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrls,
    required this.emoji,
    this.fontSize,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls;
    final hasImage = urls != null && urls.isNotEmpty &&
        urls.first.toString().startsWith('http');

    if (hasImage) {
      final url = urls!.first.toString();
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          placeholder: (_, __) => Container(
            color: AppColors.card,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2))),
          errorWidget: (_, __, ___) => _EmojiFallback(
            emoji: emoji, fontSize: fontSize),
        ),
      );
    }

    return _EmojiFallback(emoji: emoji, fontSize: fontSize);
  }
}

class _EmojiFallback extends StatelessWidget {
  final String emoji;
  final double? fontSize;
  const _EmojiFallback({required this.emoji, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(emoji,
        style: TextStyle(fontSize: fontSize ?? 54)),
    );
  }
}