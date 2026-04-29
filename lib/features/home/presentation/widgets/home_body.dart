import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../theme/home_tokens.dart';
import 'banner_slider.dart';
import 'category_grid.dart';
import 'featured_products_section.dart';
import 'flash_sale_section.dart';
import 'hero_banner.dart';
import 'home_app_bar.dart';
import 'new_arrivals_section.dart';
import 'top_vendors_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: HomeTokens.text,
          backgroundColor: HomeTokens.white,
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeAppBar(),

                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      state.errorMessage ?? 'Something went wrong.',
                      style: HomeTokens.body(color: HomeTokens.sale),
                    ),
                  ),

                const HeroBanner(),

                const SizedBox(height: HomeTokens.sectionGap),
                const BannerSlider(),

                const SizedBox(height: HomeTokens.sectionGap),
                const CategoryGrid(),

                const SizedBox(height: HomeTokens.sectionGap),
                const FlashSaleSection(),

                const SizedBox(height: HomeTokens.sectionGap),
                const FeaturedProductsSection(),

                const SizedBox(height: HomeTokens.sectionGap),
                const TopVendorsSection(),

                const SizedBox(height: HomeTokens.sectionGap),
                const NewArrivalsSection(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}