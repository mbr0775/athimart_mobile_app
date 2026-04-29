//lib/features/home/presentation/widgets/top_vendors_section.dart

import 'package:flutter/material.dart';

import '../theme/home_tokens.dart';
import 'home_section_header.dart';
import 'vendor_card.dart';

class TopVendorsSection extends StatelessWidget {
  const TopVendorsSection({super.key});

  static const List<VendorData> _vendors = [
    VendorData(
      name: 'Goviceylon',
      category: 'Agarwood Exports',
      rating: 4.9,
      products: 48,
      icon: Icons.park_outlined,
    ),
    VendorData(
      name: 'TechNova',
      category: 'AI Gadgets',
      rating: 4.8,
      products: 124,
      icon: Icons.smart_toy_outlined,
    ),
    VendorData(
      name: 'NaturalCeylon',
      category: 'Essences and Oils',
      rating: 4.9,
      products: 67,
      icon: Icons.spa_outlined,
    ),
    VendorData(
      name: 'FitZone Pro',
      category: 'Fitness Tech',
      rating: 4.7,
      products: 89,
      icon: Icons.fitness_center_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(
          title: 'Top Vendors',
          subtitle: 'Trusted sellers on Athimart',
          actionLabel: 'View all',
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 116,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: HomeTokens.pagePadding,
            ),
            itemCount: _vendors.length,
            itemBuilder: (context, index) {
              return VendorCard(vendor: _vendors[index]);
            },
          ),
        ),
      ],
    );
  }
}