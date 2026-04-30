// lib/core/constants/market_config.dart

class AppCurrency {
  final String code;
  final String name;
  final String symbol;
  final int decimals;

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
  });
}

class MarketCountry {
  final String code;
  final String name;
  final String flag;
  final String defaultCurrency;
  final List<String> allowedCurrencies;
  final List<String> restrictedCategories;
  final String heroTitle;
  final String heroSubtitle;
  final double deliveryFee;
  final double freeDeliveryFrom;

  const MarketCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.defaultCurrency,
    required this.allowedCurrencies,
    required this.restrictedCategories,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.deliveryFee,
    required this.freeDeliveryFrom,
  });
}

class MarketConfig {
  MarketConfig._();

  static const MarketCountry sriLanka = MarketCountry(
    code: 'LK',
    name: 'Sri Lanka',
    flag: '🇱🇰',
    defaultCurrency: 'LKR',
    allowedCurrencies: ['LKR', 'USD'],
    restrictedCategories: [],
    heroTitle: 'SHOP\nSRI LANKA',
    heroSubtitle:
    'Local products, digital services and lifestyle picks for Sri Lanka.',
    deliveryFee: 350,
    freeDeliveryFrom: 5000,
  );

  static const MarketCountry maldives = MarketCountry(
    code: 'MV',
    name: 'Maldives',
    flag: '🇲🇻',
    defaultCurrency: 'MVR',
    allowedCurrencies: ['MVR', 'USD'],
    restrictedCategories: [
      'Vehicles',
      'Real Estate',
    ],
    heroTitle: 'SHOP\nMALDIVES',
    heroSubtitle:
    'Selected products and digital services available for Maldives.',
    deliveryFee: 50,
    freeDeliveryFrom: 800,
  );

  static const List<MarketCountry> countries = [
    sriLanka,
    maldives,
  ];

  static const Map<String, AppCurrency> currencies = {
    'LKR': AppCurrency(
      code: 'LKR',
      name: 'Sri Lankan Rupee',
      symbol: 'Rs',
      decimals: 0,
    ),
    'MVR': AppCurrency(
      code: 'MVR',
      name: 'Maldivian Rufiyaa',
      symbol: 'MVR',
      decimals: 0,
    ),
    'USD': AppCurrency(
      code: 'USD',
      name: 'US Dollar',
      symbol: r'$',
      decimals: 2,
    ),
  };

  static MarketCountry countryByCode(String code) {
    return countries.firstWhere(
          (country) => country.code == code,
      orElse: () => sriLanka,
    );
  }

  static AppCurrency currencyByCode(String code) {
    return currencies[code] ?? currencies['LKR']!;
  }

  static bool isCategoryAllowed({
    required String countryCode,
    required String category,
  }) {
    final country = countryByCode(countryCode);
    return !country.restrictedCategories.contains(category);
  }

  static List<String> allowedCategories({
    required String countryCode,
    required List<String> categories,
  }) {
    return categories.where((category) {
      return isCategoryAllowed(
        countryCode: countryCode,
        category: category,
      );
    }).toList();
  }
}