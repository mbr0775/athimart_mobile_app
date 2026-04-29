// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      label: 'TECH',
      title: AppStrings.onboardingTitles[0],
      subtitle: AppStrings.onboardingSubtitles[0],
      icon: Icons.smart_toy_outlined,
      heroText: 'AI\nGADGETS',
      imageUrl:
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=85',
    ),
    _OnboardingData(
      label: 'ESSENCE',
      title: AppStrings.onboardingTitles[1],
      subtitle: AppStrings.onboardingSubtitles[1],
      icon: Icons.spa_outlined,
      heroText: 'NATURAL\nESSENCES',
      imageUrl:
      'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=1400&q=85',
    ),
    _OnboardingData(
      label: 'LIFESTYLE',
      title: AppStrings.onboardingTitles[2],
      subtitle: AppStrings.onboardingSubtitles[2],
      icon: Icons.style_outlined,
      heroText: 'GLOBAL\nSTYLE',
      imageUrl:
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1400&q=85',
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    context.go('/auth/login');
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _finishOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _OnboardingTokens.text,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _OnboardingTokens.linen,
        body: Container(
          decoration: const BoxDecoration(
            gradient: _OnboardingTokens.pageGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 18, 26, 0),
                  child: Row(
                    children: [
                      Text(
                        'ATHIMART',
                        style: _OnboardingTokens.label(
                          color: _OnboardingTokens.text,
                          size: 11,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLastPage)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _skip,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Text(
                              'SKIP',
                              style: _OnboardingTokens.label(
                                color: _OnboardingTokens.text,
                                size: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        pageNumber: index + 1,
                        totalPages: _pages.length,
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 26),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: _pages.length,
                            effect: const ExpandingDotsEffect(
                              activeDotColor: _OnboardingTokens.text,
                              dotColor: _OnboardingTokens.border,
                              dotHeight: 7,
                              dotWidth: 7,
                              expansionFactor: 4,
                              spacing: 7,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentPage + 1}/${_pages.length}',
                            style: _OnboardingTokens.label(size: 10),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _OnboardingButton(
                        label: _isLastPage ? 'GET STARTED' : 'NEXT',
                        onTap: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int pageNumber;
  final int totalPages;

  const _OnboardingPage({
    required this.data,
    required this.pageNumber,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;

        return Padding(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: _OnboardingTokens.label(size: 10),
              ),

              const SizedBox(height: 14),

              Container(
                height: 1.2,
                width: double.infinity,
                color: _OnboardingTokens.text,
              ),

              const SizedBox(height: 22),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _OnboardingTokens.white.withValues(alpha: 0.58),
                    border: Border.all(
                      color: _OnboardingTokens.border,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          data.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return Container(
                              color: _OnboardingTokens.card,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _OnboardingTokens.text,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: _OnboardingTokens.card,
                              child: Center(
                                child: Icon(
                                  data.icon,
                                  color: _OnboardingTokens.text,
                                  size: 72,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.60),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 22,
                        right: 22,
                        top: 24,
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _OnboardingTokens.linen
                                    .withValues(alpha: 0.92),
                                border: Border.all(
                                  color: _OnboardingTokens.text,
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                data.icon,
                                color: _OnboardingTokens.text,
                                size: 25,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              color: _OnboardingTokens.linen
                                  .withValues(alpha: 0.92),
                              child: Text(
                                '$pageNumber/$totalPages',
                                style: _OnboardingTokens.label(
                                  color: _OnboardingTokens.text,
                                  size: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        left: 22,
                        right: 22,
                        bottom: compact ? 20 : 26,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.heroText,
                              style: _OnboardingTokens.displayLarge(
                                color: _OnboardingTokens.linen,
                                size: compact ? 38 : 45,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Container(
                              height: 1.2,
                              width: double.infinity,
                              color: _OnboardingTokens.linen,
                            ),

                            const SizedBox(height: 15),

                            Text(
                              data.title,
                              style: _OnboardingTokens.bodyBold(
                                color: _OnboardingTokens.linen,
                                size: 15,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              data.subtitle,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: _OnboardingTokens.body(
                                color: _OnboardingTokens.linen
                                    .withValues(alpha: 0.82),
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OnboardingButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _OnboardingTokens.text,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: _OnboardingTokens.label(
                    color: _OnboardingTokens.linen,
                    size: 11,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: _OnboardingTokens.linen,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final String heroText;
  final String imageUrl;

  const _OnboardingData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.heroText,
    required this.imageUrl,
  });
}

class _OnboardingTokens {
  _OnboardingTokens._();

  static const Color linen = Color(0xFFF2EDE7);
  static const Color softLinen = Color(0xFFF7F2EC);
  static const Color warmLinen = Color(0xFFEEE8E1);
  static const Color text = Color(0xFF171717);
  static const Color darkGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFF888888);
  static const Color border = Color(0xFFE0D8CE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFEDE8E2);

  static const LinearGradient pageGradient = LinearGradient(
    colors: [
      softLinen,
      linen,
      warmLinen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle displayLarge({
    Color color = text,
    double size = 44,
  }) {
    return GoogleFonts.oswald(
      fontSize: size,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 2.2,
      height: 1.05,
    );
  }

  static TextStyle label({
    Color color = lightGray,
    double size = 10,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.6,
    );
  }

  static TextStyle body({
    Color color = darkGray,
    double size = 13,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.55,
    );
  }

  static TextStyle bodyBold({
    Color color = text,
    double size = 13,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.35,
    );
  }
}