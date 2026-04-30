// lib/core/services/market_preference_service.dart
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/market_config.dart';

class MarketPreferenceService {
  MarketPreferenceService._();

  static const String _countryKey = 'customer_country_code';
  static const String _currencyKey = 'customer_currency_code';
  static const String _configuredKey = 'has_seen_onboarding';

  static String customerCountryCode = MarketConfig.sriLanka.code;
  static String customerCurrencyCode = MarketConfig.sriLanka.defaultCurrency;
  static bool customerConfigured = false;

  static MarketCountry get customerCountry {
    return MarketConfig.countryByCode(customerCountryCode);
  }

  static AppCurrency get customerCurrency {
    return MarketConfig.currencyByCode(customerCurrencyCode);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    customerConfigured = prefs.getBool(_configuredKey) ?? false;

    final savedCountryCode = prefs.getString(_countryKey);
    final savedCurrencyCode = prefs.getString(_currencyKey);

    final country = MarketConfig.countryByCode(
      savedCountryCode ?? MarketConfig.sriLanka.code,
    );

    final currencyCode =
    savedCurrencyCode != null &&
        country.allowedCurrencies.contains(savedCurrencyCode)
        ? savedCurrencyCode
        : country.defaultCurrency;

    customerCountryCode = country.code;
    customerCurrencyCode = currencyCode;
  }

  static Future<void> saveCustomerMarket({
    required String countryCode,
    required String currencyCode,
  }) async {
    final country = MarketConfig.countryByCode(countryCode);

    final safeCurrencyCode = country.allowedCurrencies.contains(currencyCode)
        ? currencyCode
        : country.defaultCurrency;

    customerCountryCode = country.code;
    customerCurrencyCode = safeCurrencyCode;
    customerConfigured = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, customerCountryCode);
    await prefs.setString(_currencyKey, customerCurrencyCode);
    await prefs.setBool(_configuredKey, true);
  }

  static Future<void> clear() async {
    customerCountryCode = MarketConfig.sriLanka.code;
    customerCurrencyCode = MarketConfig.sriLanka.defaultCurrency;
    customerConfigured = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countryKey);
    await prefs.remove(_currencyKey);
    await prefs.remove(_configuredKey);
  }
}