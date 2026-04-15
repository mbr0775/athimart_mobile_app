// lib/features/cart/presentation/bloc/cart_state.dart
import 'package:equatable/equatable.dart';
import '../../data/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final String? lastAddedName; // for snackbar feedback

  const CartState({this.items = const [], this.lastAddedName});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool containsId(String id) => items.any((e) => e.id == id);

  @override
  List<Object?> get props => [items, lastAddedName];
}