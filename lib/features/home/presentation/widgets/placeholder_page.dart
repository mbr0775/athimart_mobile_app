//lib/features/home/presentation/widgets/placeholder_page.dart

import 'package:flutter/material.dart';

import '../theme/home_tokens.dart';

class PlaceholderPage extends StatelessWidget {
  final String label;

  const PlaceholderPage({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTokens.linen,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForLabel(label),
                color: HomeTokens.text,
                size: 54,
              ),
              const SizedBox(height: 18),
              Text(
                label,
                style: HomeTokens.displayMedium(),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: HomeTokens.body(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForLabel(String value) {
    switch (value.toUpperCase()) {
      case 'SHOP':
        return Icons.storefront_outlined;
      case 'CART':
        return Icons.shopping_bag_outlined;
      case 'ORDERS':
        return Icons.receipt_long_outlined;
      case 'PROFILE':
        return Icons.person_outline_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}