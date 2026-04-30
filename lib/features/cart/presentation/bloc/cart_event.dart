// lib/features/cart/presentation/bloc/cart_event.dart
import 'package:athimart/features/cart/data/cart_item.dart';

abstract class CartEvent {
  const CartEvent();
}

class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

class CartAddItem extends CartEvent {
  final CartItem item;

  const CartAddItem(this.item);
}

class CartIncrementItem extends CartEvent {
  final String id;

  const CartIncrementItem(this.id);
}

class CartDecrementItem extends CartEvent {
  final String id;

  const CartDecrementItem(this.id);
}

class CartRemoveItem extends CartEvent {
  final String id;

  const CartRemoveItem(this.id);
}

class CartClear extends CartEvent {
  const CartClear();
}