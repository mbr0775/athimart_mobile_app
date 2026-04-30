// lib/features/home/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';

import 'package:athimart/core/services/market_preference_service.dart';
import 'package:athimart/core/utils/money_formatter.dart';
import 'package:athimart/features/home/presentation/theme/home_tokens.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double? width;
  final bool compact;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.compact = false,
    this.onTap,
  });

  String _stringValue(String key, {String fallback = ''}) {
    final value = product[key];
    if (value == null) return fallback;

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _intValue(String key, {int fallback = 0}) {
    final value = product[key];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String? get _imageUrl {
    final rawImages = product['image_urls'];

    if (rawImages is List && rawImages.isNotEmpty) {
      final first = rawImages.first?.toString().trim();
      if (first != null && first.isNotEmpty) return first;
    }

    final singleImage = product['image_url'] ?? product['imageUrl'];
    final text = singleImage?.toString().trim();

    if (text == null || text.isEmpty) return null;
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = MarketPreferenceService.customerCurrencyCode;

    final name = _stringValue('name', fallback: 'Product');
    final companyName = _stringValue('company_name', fallback: 'Athimart');
    final category = _stringValue('category', fallback: 'General');
    final emoji = _stringValue('emoji', fallback: '📦');

    final price = MoneyFormatter.productPrice(product, currencyCode);
    final originalPrice = MoneyFormatter.productOriginalPrice(
      product,
      currencyCode,
    );

    final discountPercent = _intValue('discount_percent');
    final hasDiscount = discountPercent > 0 && originalPrice > price;

    final imageUrl = _imageUrl;

    final card = Container(
      width: width,
      decoration: BoxDecoration(
        color: HomeTokens.white.withValues(alpha: 0.72),
        border: Border.all(color: HomeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: compact ? 132 : 152,
            width: double.infinity,
            color: HomeTokens.card,
            child: imageUrl == null
                ? Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: compact ? 40 : 48),
              ),
            )
                : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: compact ? 40 : 48),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTokens.label(size: 8),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTokens.bodyBold(size: compact ? 12 : 13),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTokens.body(size: 10),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        MoneyFormatter.format(price, currencyCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HomeTokens.price(size: compact ? 13 : 15),
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        '-$discountPercent%',
                        style: HomeTokens.label(
                          color: HomeTokens.sale,
                          size: 8,
                        ),
                      ),
                  ],
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 3),
                  Text(
                    MoneyFormatter.format(originalPrice, currencyCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.body(size: 10).copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: card,
      ),
    );
  }
}