// lib/core/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:athimart/core/constants/market_config.dart';
import 'package:athimart/core/services/market_preference_service.dart';
import 'package:athimart/core/utils/money_formatter.dart';

class ProductService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static List<Map<String, dynamic>> _applyCustomerMarketRules(
      List<Map<String, dynamic>> products,
      ) {
    final countryCode = MarketPreferenceService.customerCountryCode;
    final currencyCode = MarketPreferenceService.customerCurrencyCode;

    return products.where((product) {
      final category = product['category']?.toString() ?? 'General';

      final categoryAllowed = MarketConfig.isCategoryAllowed(
        countryCode: countryCode,
        category: category,
      );

      if (!categoryAllowed) return false;

      return MoneyFormatter.hasProductPrice(product, currencyCode);
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      final countryCode = MarketPreferenceService.customerCountryCode;

      final data = await _supabase
          .from('products')
          .select()
          .eq('country_code', countryCode)
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);

      return _applyCustomerMarketRules(
        List<Map<String, dynamic>>.from(data),
      );
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFlashSaleProducts() async {
    try {
      final countryCode = MarketPreferenceService.customerCountryCode;

      final data = await _supabase
          .from('products')
          .select()
          .eq('country_code', countryCode)
          .eq('is_active', true)
          .gt('discount_percent', 0)
          .order('discount_percent', ascending: false)
          .limit(10);

      return _applyCustomerMarketRules(
        List<Map<String, dynamic>>.from(data),
      );
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getNewArrivals() async {
    try {
      final countryCode = MarketPreferenceService.customerCountryCode;

      final data = await _supabase
          .from('products')
          .select()
          .eq('country_code', countryCode)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(8);

      return _applyCustomerMarketRules(
        List<Map<String, dynamic>>.from(data),
      );
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllActive() async {
    try {
      final countryCode = MarketPreferenceService.customerCountryCode;

      final data = await _supabase
          .from('products')
          .select()
          .eq('country_code', countryCode)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return _applyCustomerMarketRules(
        List<Map<String, dynamic>>.from(data),
      );
    } catch (_) {
      return [];
    }
  }
}