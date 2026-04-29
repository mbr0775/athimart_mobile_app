//lib/features/home/presentation/widgets/vendor_card.dart

import 'package:flutter/material.dart';

import '../theme/home_tokens.dart';

class VendorData {
  final String name;
  final String category;
  final double rating;
  final int products;
  final IconData icon;

  const VendorData({
    required this.name,
    required this.category,
    required this.rating,
    required this.products,
    required this.icon,
  });
}

class VendorCard extends StatelessWidget {
  final VendorData vendor;

  const VendorCard({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      color: HomeTokens.white,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            color: HomeTokens.card,
            child: Icon(
              vendor.icon,
              color: HomeTokens.text,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vendor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTokens.bodyBold(size: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  vendor.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTokens.body(size: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: HomeTokens.text,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vendor.rating.toStringAsFixed(1),
                      style: HomeTokens.bodyBold(size: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${vendor.products} products',
                      style: HomeTokens.body(size: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}