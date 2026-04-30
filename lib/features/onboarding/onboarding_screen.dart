// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athimart/core/constants/app_strings.dart';
import 'package:athimart/core/constants/market_config.dart';
import 'package:athimart/core/services/market_preference_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _page = 0;
  String _selectedCountryCode = 'LK';
  String _selectedCurrencyCode = 'LKR';

  MarketCountry get _selectedCountry {
    return MarketConfig.countryByCode(_selectedCountryCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectCountry(String countryCode) {
    final country = MarketConfig.countryByCode(countryCode);

    setState(() {
      _selectedCountryCode = country.code;
      _selectedCurrencyCode = country.defaultCurrency;
    });

    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectCurrency(String currencyCode) {
    setState(() {
      _selectedCurrencyCode = currencyCode;
    });
  }

  Future<void> _finish() async {
    await MarketPreferenceService.saveCustomerMarket(
      countryCode: _selectedCountryCode,
      currencyCode: _selectedCurrencyCode,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    context.go('/auth/login');
  }

  void _continue() {
    if (_page == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _OnboardingTokens.linen,
      body: Container(
        decoration: const BoxDecoration(
          gradient: _OnboardingTokens.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _page = index;
                    });
                  },
                  children: [
                    _CountryPage(
                      selectedCountryCode: _selectedCountryCode,
                      onSelected: _selectCountry,
                    ),
                    _CurrencyPage(
                      country: _selectedCountry,
                      selectedCurrencyCode: _selectedCurrencyCode,
                      onSelected: _selectCurrency,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Dot(active: _page == 0),
                        const SizedBox(width: 8),
                        _Dot(active: _page == 1),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _OnboardingButton(
                      label: _page == 0 ? 'CONTINUE' : 'START SHOPPING',
                      onTap: _continue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPage extends StatelessWidget {
  final String selectedCountryCode;
  final ValueChanged<String> onSelected;

  const _CountryPage({
    required this.selectedCountryCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            label: AppStrings.appName,
            title: 'SELECT\nCOUNTRY',
            subtitle:
            'Choose your shopping country first. Products, prices and delivery options will change based on this selection.',
          ),
          const SizedBox(height: 36),
          ...MarketConfig.countries.map((country) {
            return _SelectionCard(
              title: '${country.flag} ${country.name}',
              subtitle: country.code == 'LK'
                  ? 'Shop Sri Lankan products in LKR or USD.'
                  : 'Shop Maldives products in MVR or USD.',
              selected: selectedCountryCode == country.code,
              onTap: () => onSelected(country.code),
            );
          }),
        ],
      ),
    );
  }
}

class _CurrencyPage extends StatelessWidget {
  final MarketCountry country;
  final String selectedCurrencyCode;
  final ValueChanged<String> onSelected;

  const _CurrencyPage({
    required this.country,
    required this.selectedCurrencyCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            label: '${country.flag} ${country.name}',
            title: 'SELECT\nCURRENCY',
            subtitle: 'Choose how you want prices to appear in the app.',
          ),
          const SizedBox(height: 36),
          ...country.allowedCurrencies.map((code) {
            final currency = MarketConfig.currencyByCode(code);

            return _SelectionCard(
              title: '${currency.symbol} ${currency.code}',
              subtitle: currency.name,
              selected: selectedCurrencyCode == currency.code,
              onTap: () => onSelected(currency.code),
            );
          }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;

  const _Header({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: _OnboardingTokens.label(),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: _OnboardingTokens.displayLarge(size: 54),
        ),
        const SizedBox(height: 18),
        Container(
          height: 1.2,
          color: _OnboardingTokens.text,
        ),
        const SizedBox(height: 18),
        Text(
          subtitle,
          style: _OnboardingTokens.body(size: 14),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background =
    selected ? _OnboardingTokens.text : _OnboardingTokens.white;
    final foreground =
    selected ? _OnboardingTokens.linen : _OnboardingTokens.text;
    final secondary =
    selected ? _OnboardingTokens.border : _OnboardingTokens.darkGray;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: background.withValues(alpha: selected ? 1 : 0.66),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: _OnboardingTokens.text),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: _OnboardingTokens.bodyBold(
                          color: foreground,
                          size: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: _OnboardingTokens.body(
                          color: secondary,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
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
            child: Text(
              label,
              style: _OnboardingTokens.label(
                color: _OnboardingTokens.linen,
                size: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? _OnboardingTokens.text : _OnboardingTokens.border,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
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