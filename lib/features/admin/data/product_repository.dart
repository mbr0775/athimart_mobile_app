// lib/features/admin/data/product_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_model.dart';

class ProductRepository {
  final _supabase = Supabase.instance.client;

  Future<List<AdminProduct>> fetchAll({String? search, String? category}) async {
    var query = _supabase.from('products').select();
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => AdminProduct.fromMap(e)).toList();
  }

  Future<AdminProduct> create(AdminProduct product) async {
    final data = await _supabase
        .from('products')
        .insert(product.toMap())
        .select()
        .single();
    return AdminProduct.fromMap(data);
  }

  Future<AdminProduct> update(AdminProduct product) async {
    final data = await _supabase
        .from('products')
        .update(product.toMap())
        .eq('id', product.id!)
        .select()
        .single();
    return AdminProduct.fromMap(data);
  }

  Future<void> delete(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _supabase.from('products').update({'is_active': isActive}).eq('id', id);
  }

  Future<void> toggleFeatured(String id, bool isFeatured) async {
    await _supabase.from('products').update({'is_featured': isFeatured}).eq('id', id);
  }

  Future<Map<String, int>> getStats() async {
    final products = await _supabase.from('products').select('is_active');
    final totalProducts = products.length;
    final activeProducts = (products as List).where((p) => p['is_active'] == true).length;

    int totalUsers = 0;
    try {
      final users = await _supabase.from('profiles').select('id');
      totalUsers = (users as List).length;
    } catch (_) {}

    return {
      'total_products': totalProducts,
      'active_products': activeProducts,
      'total_users': totalUsers,
    };
  }
}