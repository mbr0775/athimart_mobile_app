// lib/features/cart/presentation/bloc/cart_state.dart
import 'package:athimart/core/services/market_preference_service.dart';
import 'package:athimart/features/cart/data/cart_item.dart';

class CartState {
  final List<CartItem> items;

  const CartState({
    required this.items,
  });

  factory CartState.empty() {
    return const CartState(items: []);
  }

  int get totalItems {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return items.fold<double>(0, (sum, item) => sum + item.lineTotal);
  }

  double get deliveryFee {
    if (items.isEmpty) return 0;

    final country = MarketPreferenceService.customerCountry;

    return subtotal >= country.freeDeliveryFrom ? 0 : country.deliveryFee;
  }

  double get total {
    return subtotal + deliveryFee;
  }

  bool containsId(String id) {
    return items.any((item) => item.id == id);
  }

  int quantityOf(String id) {
    for (final item in items) {
      if (item.id == id) return item.quantity;
    }

    return 0;
  }

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: List<CartItem>.unmodifiable(items ?? this.items),
    );
  }
}