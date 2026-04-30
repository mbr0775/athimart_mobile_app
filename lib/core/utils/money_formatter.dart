// lib/core/utils/money_formatter.dart
import 'package:athimart/core/constants/market_config.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static String priceKey(String currencyCode) {
    return 'price_${currencyCode.toLowerCase()}';
  }

  static String originalPriceKey(String currencyCode) {
    return 'original_price_${currencyCode.toLowerCase()}';
  }

  static double toDouble(
      dynamic value, {
        double fallback = 0,
      }) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double productPrice(
      Map<String, dynamic> product,
      String currencyCode,
      ) {
    final value = product[priceKey(currencyCode)] ?? product['price'];
    return toDouble(value);
  }

  static double productOriginalPrice(
      Map<String, dynamic> product,
      String currencyCode,
      ) {
    final price = productPrice(product, currencyCode);

    final value = product[originalPriceKey(currencyCode)] ??
        product['original_price'] ??
        product['originalPrice'];

    return toDouble(value, fallback: price);
  }

  static bool hasProductPrice(
      Map<String, dynamic> product,
      String currencyCode,
      ) {
    return productPrice(product, currencyCode) > 0;
  }

  static String format(
      num value,
      String currencyCode,
      ) {
    final currency = MarketConfig.currencyByCode(currencyCode);
    final amount = value.toStringAsFixed(currency.decimals);
    return '${currency.symbol} $amount';
  }
}