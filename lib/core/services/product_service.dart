// lib/core/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFlashSaleProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .gt('discount_percent', 0)
          .order('discount_percent', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getNewArrivals() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(8);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllActive() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}
