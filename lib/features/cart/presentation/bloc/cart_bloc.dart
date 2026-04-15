// lib/features/cart/presentation/bloc/cart_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../data/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAddItem>(_onAdd);
    on<CartRemoveItem>(_onRemove);
    on<CartUpdateQuantity>(_onUpdateQty);
    on<CartClear>(_onClear);
  }

  void _onAdd(CartAddItem event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.id == event.item.id);
    if (idx >= 0) {
      // Already in cart — increment quantity
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(event.item);
    }
    emit(CartState(items: items, lastAddedName: event.item.name));
  }

  void _onRemove(CartRemoveItem event, Emitter<CartState> emit) {
    final items = state.items.where((e) => e.id != event.itemId).toList();
    emit(CartState(items: items));
  }

  void _onUpdateQty(CartUpdateQuantity event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.id == event.itemId);
    if (idx >= 0) {
      if (event.quantity <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: event.quantity);
      }
    }
    emit(CartState(items: items));
  }

  void _onClear(CartClear event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}