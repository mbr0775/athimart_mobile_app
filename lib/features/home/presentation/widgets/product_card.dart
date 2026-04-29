// lib/features/home/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/data/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../theme/home_tokens.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double? width;
  final bool compact;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.compact = false,
  });

  String get id {
    return product['id']?.toString() ??
        product['name']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
  }

  String get name {
    return product['name']?.toString() ?? 'Product';
  }

  String get companyName {
    return product['company_name']?.toString() ?? 'Athimart';
  }

  String get category {
    return product['category']?.toString() ?? 'General';
  }

  String get emoji {
    return product['emoji']?.toString() ?? '📦';
  }

  double get price {
    final value = product['price'];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double get originalPrice {
    final value = product['original_price'] ?? product['originalPrice'];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? price;
  }

  int get discountPercent {
    final value = product['discount_percent'] ?? product['discountPercent'];

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? get imageUrl {
    final raw = product['image_urls'] ?? product['imageUrls'];

    if (raw is List && raw.isNotEmpty) {
      return raw.first.toString();
    }

    final single = product['image_url'] ?? product['imageUrl'];

    if (single != null && single.toString().isNotEmpty) {
      return single.toString();
    }

    return null;
  }

  bool get hasDiscount {
    return discountPercent > 0 || originalPrice > price;
  }

  void _addToCart(BuildContext context) {
    context.read<CartBloc>().add(
      CartAddItem(
        CartItem(
          id: id,
          name: name,
          emoji: emoji,
          category: category,
          price: price,
          originalPrice: originalPrice,
          discountPercent: discountPercent,
        ),
      ),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name added to cart',
          style: const TextStyle(color: HomeTokens.linen),
        ),
        backgroundColor: HomeTokens.text,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productImage = imageUrl;
    final imageHeight = compact ? 138.0 : 172.0;

    return Container(
      width: width,
      color: HomeTokens.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: imageHeight,
                width: double.infinity,
                color: HomeTokens.card,
                child: productImage == null
                    ? Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 52),
                  ),
                )
                    : Image.network(
                  productImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                    );
                  },
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    color: HomeTokens.text,
                    child: Text(
                      '-$discountPercent%',
                      style: HomeTokens.label(
                        color: HomeTokens.linen,
                        size: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.label(size: 9),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.bodyBold(size: compact ? 11 : 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.body(
                      size: 10,
                      color: HomeTokens.lightGray,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text(
                                '\$${originalPrice.toStringAsFixed(2)}',
                                style: HomeTokens.body(
                                  size: 10,
                                  color: HomeTokens.lightGray,
                                ).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: HomeTokens.price(size: compact ? 13 : 15),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          final inCart = cartState.containsId(id);

                          return GestureDetector(
                            onTap: inCart ? null : () => _addToCart(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 34,
                              height: 34,
                              color: inCart
                                  ? HomeTokens.success
                                  : HomeTokens.text,
                              child: Icon(
                                inCart
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                color: HomeTokens.linen,
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}