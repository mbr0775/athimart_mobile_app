// lib/core/services/profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;

  static Future<String> getUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'guest';
    final data = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();
    return data['role'] ?? 'user';
  }
}