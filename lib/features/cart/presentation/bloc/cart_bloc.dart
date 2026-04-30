// lib/features/cart/presentation/bloc/cart_bloc.dart
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athimart/features/cart/data/cart_item.dart';
import 'package:athimart/features/cart/presentation/bloc/cart_event.dart';
import 'package:athimart/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _cartStorageKey = 'athimart_cart_items';

  CartBloc() : super(CartState.empty()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartAddItem>(_onAddItem);
    on<CartIncrementItem>(_onIncrementItem);
    on<CartDecrementItem>(_onDecrementItem);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartClear>(_onClear);
  }

  Future<void> _onLoadRequested(
      CartLoadRequested event,
      Emitter<CartState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartStorageKey);

    if (raw == null || raw.isEmpty) {
      emit(CartState.empty());
      return;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        emit(CartState.empty());
        return;
      }

      final items = decoded.whereType<Map>().map((item) {
        return CartItem.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      emit(CartState(items: List<CartItem>.unmodifiable(items)));
    } catch (_) {
      emit(CartState.empty());
    }
  }

  Future<void> _onAddItem(
      CartAddItem event,
      Emitter<CartState> emit,
      ) async {
    final items = List<CartItem>.from(state.items);

    final index = items.indexWhere((item) => item.id == event.item.id);

    if (index >= 0) {
      final current = items[index];

      items[index] = current.copyWith(
        quantity: current.quantity + event.item.quantity,
      );
    } else {
      items.add(event.item);
    }

    await _saveItems(items);
    emit(CartState(items: List<CartItem>.unmodifiable(items)));
  }

  Future<void> _onIncrementItem(
      CartIncrementItem event,
      Emitter<CartState> emit,
      ) async {
    final items = state.items.map((item) {
      if (item.id == event.id) {
        return item.copyWith(quantity: item.quantity + 1);
      }

      return item;
    }).toList();

    await _saveItems(items);
    emit(CartState(items: List<CartItem>.unmodifiable(items)));
  }

  Future<void> _onDecrementItem(
      CartDecrementItem event,
      Emitter<CartState> emit,
      ) async {
    final items = <CartItem>[];

    for (final item in state.items) {
      if (item.id == event.id) {
        final nextQuantity = item.quantity - 1;

        if (nextQuantity > 0) {
          items.add(item.copyWith(quantity: nextQuantity));
        }
      } else {
        items.add(item);
      }
    }

    await _saveItems(items);
    emit(CartState(items: List<CartItem>.unmodifiable(items)));
  }

  Future<void> _onRemoveItem(
      CartRemoveItem event,
      Emitter<CartState> emit,
      ) async {
    final items = state.items.where((item) {
      return item.id != event.id;
    }).toList();

    await _saveItems(items);
    emit(CartState(items: List<CartItem>.unmodifiable(items)));
  }

  Future<void> _onClear(
      CartClear event,
      Emitter<CartState> emit,
      ) async {
    await _clearStorage();
    emit(CartState.empty());
  }

  Future<void> _saveItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );

    await prefs.setString(_cartStorageKey, encoded);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartStorageKey);
  }
}