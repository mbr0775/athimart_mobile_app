// lib/features/home/presentation/widgets/category_grid.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/market_config.dart';
import '../../../../core/constants/product_taxonomy.dart';
import '../../../../core/services/market_preference_service.dart';
import '../theme/home_tokens.dart';
import 'home_section_header.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const Map<String, IconData> _icons = {
    'Digital Products': Icons.devices_other_rounded,
    'IT Solutions': Icons.code_rounded,
    'AI Gadgets': Icons.smart_toy_outlined,
    'Fitness Tech': Icons.fitness_center_rounded,
    'Natural Essences': Icons.spa_outlined,
    'Fashion': Icons.checkroom_outlined,
    'Vehicles': Icons.directions_car_outlined,
    'Real Estate': Icons.home_work_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final countryCode = MarketPreferenceService.customerCountryCode;
    final country = MarketConfig.countryByCode(countryCode);
    final categories = MarketConfig.allowedCategories(
      countryCode: countryCode,
      categories: ProductTaxonomy.categories,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Collections',
          subtitle: 'Shop by category in ${country.name}',
          actionLabel: 'See all',
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 116,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: HomeTokens.pagePadding,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final name = categories[index];

              return _CategoryTile(
                name: name,
                icon: _icons[name] ?? Icons.category_outlined,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;

  const _CategoryTile({
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: HomeTokens.card,
              border: Border.all(color: HomeTokens.border),
            ),
            child: Icon(
              icon,
              color: HomeTokens.text,
              size: 28,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: HomeTokens.body(size: 10),
          ),
        ],
      ),
    );
  }
}