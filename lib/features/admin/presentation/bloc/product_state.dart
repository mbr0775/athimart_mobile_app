// lib/features/admin/presentation/bloc/product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<AdminProduct> products;
  const ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductStatsLoaded extends ProductState {
  final Map<String, int> stats;
  final List<AdminProduct> recentProducts;
  const ProductStatsLoaded({required this.stats, required this.recentProducts});
  @override
  List<Object?> get props => [stats, recentProducts];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final List<AdminProduct> products;
  const ProductOperationSuccess({required this.message, required this.products});
  @override
  List<Object?> get props => [message, products];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}