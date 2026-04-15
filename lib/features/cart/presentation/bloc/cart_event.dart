// lib/features/cart/presentation/bloc/cart_event.dart
import 'package:equatable/equatable.dart';
import '../../data/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartAddItem extends CartEvent {
  final CartItem item;
  const CartAddItem(this.item);
  @override
  List<Object?> get props => [item.id];
}

class CartRemoveItem extends CartEvent {
  final String itemId;
  const CartRemoveItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartUpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;
  const CartUpdateQuantity(this.itemId, this.quantity);
  @override
  List<Object?> get props => [itemId, quantity];
}

class CartClear extends CartEvent {
  const CartClear();
}