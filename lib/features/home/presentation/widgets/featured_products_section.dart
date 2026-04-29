//lib/features/home/presentation/widgets/featured_products_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../theme/home_tokens.dart';
import 'home_section_header.dart';
import 'product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final products = state.featuredProducts;

        if (state.isLoading && products.isEmpty) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(
                color: HomeTokens.text,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionHeader(
              title: 'Featured Pieces',
              subtitle: 'Selected products from Athimart',
              actionLabel: 'See all',
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 304,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeTokens.pagePadding,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      product: products[index],
                      width: 190,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}