import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/home_tokens.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController(viewportFraction: 0.78);
  Timer? _timer;
  int _currentIndex = 0;

  final List<_BannerItem> _items = const [
    _BannerItem(
      tag: 'NEW ARRIVAL',
      title: 'AI Gadgets',
      subtitle: 'Smart devices for everyday life',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFFE2DBD2),
    ),
    _BannerItem(
      tag: 'PREMIUM',
      title: 'Natural Essences',
      subtitle: 'Oud, sandalwood and rare oils',
      icon: Icons.spa_outlined,
      color: Color(0xFFDCD4CA),
    ),
    _BannerItem(
      tag: 'FITNESS',
      title: 'Fitness Tech',
      subtitle: 'Wearables and gym accessories',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFE7E0D8),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;

      final nextIndex = (_currentIndex + 1) % _items.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _BannerCard(item: _items[index]);
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
                (index) {
              final active = index == _currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 28 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: active ? HomeTokens.text : HomeTokens.border,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerItem item;

  const _BannerCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(18),
      color: item.color,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(item.tag, style: HomeTokens.label()),
                const SizedBox(height: 8),
                Text(item.title, style: HomeTokens.displayMedium()),
                const SizedBox(height: 8),
                Text(item.subtitle, style: HomeTokens.body(size: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SHOP NOW',
                      style: HomeTokens.label(color: HomeTokens.text),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 24, height: 1, color: HomeTokens.text),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: HomeTokens.text,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            item.icon,
            size: 66,
            color: HomeTokens.text.withOpacity(0.25),
          ),
        ],
      ),
    );
  }
}

class _BannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _BannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}