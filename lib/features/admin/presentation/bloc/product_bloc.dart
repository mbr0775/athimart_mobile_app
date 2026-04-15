// lib/features/admin/presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repo = ProductRepository();

  ProductBloc() : super(const ProductInitial()) {
    on<ProductLoadAll>(_onLoadAll);
    on<ProductCreate>(_onCreate);
    on<ProductUpdate>(_onUpdate);
    on<ProductDelete>(_onDelete);
    on<ProductToggleActive>(_onToggleActive);
    on<ProductToggleFeatured>(_onToggleFeatured);
    on<ProductLoadStats>(_onLoadStats);
  }

  Future<void> _onLoadAll(ProductLoadAll event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      final products = await _repo.fetchAll(
        search: event.search,
        category: event.category,
      );
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreate(ProductCreate event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      await _repo.create(event.product);
      final products = await _repo.fetchAll();
      emit(ProductOperationSuccess(
        message: '✅ Product created successfully!',
        products: products,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdate(ProductUpdate event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      await _repo.update(event.product);
      final products = await _repo.fetchAll();
      emit(ProductOperationSuccess(
        message: '✅ Product updated successfully!',
        products: products,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDelete(ProductDelete event, Emitter<ProductState> emit) async {
    try {
      await _repo.delete(event.id);
      final products = await _repo.fetchAll();
      emit(ProductOperationSuccess(
        message: '🗑️ Product deleted.',
        products: products,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onToggleActive(ProductToggleActive event, Emitter<ProductState> emit) async {
    try {
      await _repo.toggleActive(event.id, event.isActive);
      final products = await _repo.fetchAll();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onToggleFeatured(ProductToggleFeatured event, Emitter<ProductState> emit) async {
    try {
      await _repo.toggleFeatured(event.id, event.isFeatured);
      final products = await _repo.fetchAll();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadStats(ProductLoadStats event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      final stats = await _repo.getStats();
      final recent = await _repo.fetchAll();
      emit(ProductStatsLoaded(
        stats: stats,
        recentProducts: recent.take(5).toList(),
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}