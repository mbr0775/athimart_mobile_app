import 'package:flutter/material.dart';

import '../theme/home_tokens.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTokens.linen,
      padding: const EdgeInsets.fromLTRB(
        HomeTokens.pagePadding,
        26,
        HomeTokens.pagePadding,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEW EDITORIAL STORE', style: HomeTokens.label()),
          const SizedBox(height: 12),
          Text(
            'TECH, LIFESTYLE\nAND TRADITION',
            style: HomeTokens.displayLarge(),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: HomeTokens.border,
          ),
          const SizedBox(height: 16),
          Text(
            'Discover AI gadgets, fitness tech, premium essences, agarwood, fashion, vehicles and real estate in one curated marketplace.',
            style: HomeTokens.body(size: 13),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _HeroButton(
                label: 'SHOP NOW',
                dark: true,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _HeroButton(
                label: 'EXPLORE',
                dark: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 260,
            width: double.infinity,
            color: HomeTokens.card,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 110,
                      color: HomeTokens.text.withOpacity(0.15),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  right: 18,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Curated collections for modern living.',
                          style: HomeTokens.bodyBold(size: 13),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: HomeTokens.text,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final bool dark;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: dark ? HomeTokens.text : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: HomeTokens.text),
            ),
            child: Center(
              child: Text(
                label,
                style: HomeTokens.label(
                  color: dark ? HomeTokens.linen : HomeTokens.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}