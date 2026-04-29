//lib/features/home/presentation/widgets/flash_sale_section.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../theme/home_tokens.dart';
import 'home_section_header.dart';
import 'product_card.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({super.key});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  Timer? _timer;
  int _hours = 5;
  int _minutes = 47;
  int _seconds = 23;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else if (_hours > 0) {
          _hours--;
          _minutes = 59;
          _seconds = 59;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final products = state.flashSaleProducts;

        if (state.isLoading && products.isEmpty) {
          return const _SectionLoader();
        }

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(
              title: 'Flash Sale',
              subtitle: 'Limited time offers',
              actionLabel: '${_pad(_hours)}:${_pad(_minutes)}:${_pad(_seconds)}',
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 286,
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
                      width: 172,
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

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
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
}