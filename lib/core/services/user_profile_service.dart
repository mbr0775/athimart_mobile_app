// lib/core/services/user_profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.role,
  });

  factory UserProfile.empty({
    required String id,
    required String email,
    String fullName = '',
    String phone = '',
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      addressLine1: '',
      addressLine2: '',
      city: '',
      state: '',
      postalCode: '',
      country: 'Sri Lanka',
      role: 'customer',
    );
  }

  factory UserProfile.fromMap({
    required Map<String, dynamic> map,
    required String email,
  }) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: email,
      fullName: map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      addressLine1: map['address_line1']?.toString() ?? '',
      addressLine2: map['address_line2']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      postalCode: map['postal_code']?.toString() ?? '',
      country: map['country']?.toString() ?? 'Sri Lanka',
      role: map['role']?.toString() ?? 'customer',
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      role: role,
    );
  }
}

class UserProfileService {
  UserProfileService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<UserProfile> getMyProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final email = user.email ?? '';
    final metadata = user.userMetadata ?? {};

    final fallbackFullName = metadata['full_name']?.toString() ?? '';
    final fallbackPhone = metadata['phone']?.toString() ?? '';

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      final profile = UserProfile.empty(
        id: user.id,
        email: email,
        fullName: fallbackFullName,
        phone: fallbackPhone,
      );

      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': profile.fullName,
        'phone': profile.phone,
        'role': profile.role,
        'country': profile.country,
      });

      return profile;
    }

    return UserProfile.fromMap(
      map: data,
      email: email,
    );
  }

  static Future<void> updateMyProfile(UserProfile profile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _supabase
        .from('profiles')
        .update(profile.toUpdateMap())
        .eq('id', user.id);
  }
}