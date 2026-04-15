// lib/features/admin/presentation/bloc/product_event.dart
import 'package:equatable/equatable.dart';
import '../../data/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductLoadAll extends ProductEvent {
  final String? search;
  final String? category;
  const ProductLoadAll({this.search, this.category});
  @override
  List<Object?> get props => [search, category];
}

class ProductCreate extends ProductEvent {
  final AdminProduct product;
  const ProductCreate(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductUpdate extends ProductEvent {
  final AdminProduct product;
  const ProductUpdate(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductDelete extends ProductEvent {
  final String id;
  const ProductDelete(this.id);
  @override
  List<Object?> get props => [id];
}

class ProductToggleActive extends ProductEvent {
  final String id;
  final bool isActive;
  const ProductToggleActive(this.id, this.isActive);
  @override
  List<Object?> get props => [id, isActive];
}

class ProductToggleFeatured extends ProductEvent {
  final String id;
  final bool isFeatured;
  const ProductToggleFeatured(this.id, this.isFeatured);
  @override
  List<Object?> get props => [id, isFeatured];
}

class ProductLoadStats extends ProductEvent {
  const ProductLoadStats();
}