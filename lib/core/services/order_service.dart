// lib/core/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/cart/data/cart_item.dart';

class ShippingDetails {
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const ShippingDetails({
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    this.state = '',
    this.postalCode = '',
    this.country = 'Sri Lanka',
  });
}

class AppOrder {
  final String id;
  final String userId;
  final String orderNumber;
  final String status;
  final int itemsCount;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddressLine1;
  final String shippingAddressLine2;
  final String shippingCity;
  final String shippingState;
  final String shippingPostalCode;
  final String shippingCountry;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.itemsCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddressLine1,
    required this.shippingAddressLine2,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.createdAt,
  });

  factory AppOrder.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return AppOrder(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      orderNumber: map['order_number']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending',
      itemsCount: map['items_count'] is num
          ? (map['items_count'] as num).toInt()
          : int.tryParse(map['items_count']?.toString() ?? '') ?? 0,
      subtotal: toDouble(map['subtotal']),
      deliveryFee: toDouble(map['delivery_fee']),
      total: toDouble(map['total']),
      paymentMethod: map['payment_method']?.toString() ?? 'Cash on Delivery',
      shippingName: map['shipping_name']?.toString() ?? '',
      shippingPhone: map['shipping_phone']?.toString() ?? '',
      shippingAddressLine1: map['shipping_address_line1']?.toString() ?? '',
      shippingAddressLine2: map['shipping_address_line2']?.toString() ?? '',
      shippingCity: map['shipping_city']?.toString() ?? '',
      shippingState: map['shipping_state']?.toString() ?? '',
      shippingPostalCode: map['shipping_postal_code']?.toString() ?? '',
      shippingCountry: map['shipping_country']?.toString() ?? 'Sri Lanka',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  AppOrder copyWith({
    String? status,
  }) {
    return AppOrder(
      id: id,
      userId: userId,
      orderNumber: orderNumber,
      status: status ?? this.status,
      itemsCount: itemsCount,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      shippingName: shippingName,
      shippingPhone: shippingPhone,
      shippingAddressLine1: shippingAddressLine1,
      shippingAddressLine2: shippingAddressLine2,
      shippingCity: shippingCity,
      shippingState: shippingState,
      shippingPostalCode: shippingPostalCode,
      shippingCountry: shippingCountry,
      createdAt: createdAt,
    );
  }
}

class AppOrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String companyName;
  final String category;
  final String subCategory;
  final String emoji;
  final String? imageUrl;
  final int quantity;
  final double price;
  final double total;

  const AppOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.companyName,
    required this.category,
    required this.subCategory,
    required this.emoji,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory AppOrderItem.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return AppOrderItem(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? 'Athimart',
      category: map['category']?.toString() ?? 'General',
      subCategory: map['sub_category']?.toString() ?? 'General',
      emoji: map['emoji']?.toString() ?? '📦',
      imageUrl: map['image_url']?.toString(),
      quantity: map['quantity'] is num
          ? (map['quantity'] as num).toInt()
          : int.tryParse(map['quantity']?.toString() ?? '') ?? 1,
      price: toDouble(map['price']),
      total: toDouble(map['total']),
    );
  }
}

class OrderService {
  OrderService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  static String _generateOrderNumber() {
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch.toString();
    return 'ATH-${millis.substring(millis.length - 8)}';
  }

  static Future<AppOrder> createOrder({
    required List<CartItem> items,
    required ShippingDetails shipping,
    required double subtotal,
    required double deliveryFee,
    required double total,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final orderNumber = _generateOrderNumber();

    final orderMap = await _supabase
        .from('orders')
        .insert({
      'user_id': user.id,
      'order_number': orderNumber,
      'status': 'Pending',
      'items_count': items.fold<int>(0, (sum, item) => sum + item.quantity),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'payment_method': paymentMethod,
      'shipping_name': shipping.name,
      'shipping_phone': shipping.phone,
      'shipping_address_line1': shipping.addressLine1,
      'shipping_address_line2': shipping.addressLine2,
      'shipping_city': shipping.city,
      'shipping_state': shipping.state,
      'shipping_postal_code': shipping.postalCode,
      'shipping_country': shipping.country,
    })
        .select()
        .single();

    final order = AppOrder.fromMap(orderMap);

    final itemRows = items.map((item) {
      return {
        'order_id': order.id,
        'product_id': item.id,
        'product_name': item.name,
        'company_name': item.companyName,
        'category': item.category,
        'sub_category': item.subCategory,
        'emoji': item.emoji,
        'image_url': item.imageUrl,
        'quantity': item.quantity,
        'price': item.price,
        'total': item.lineTotal,
      };
    }).toList();

    await _supabase.from('order_items').insert(itemRows);

    return order;
  }

  static Future<List<AppOrder>> getMyOrders() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final data = await _supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List).map((item) {
      return AppOrder.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<List<AppOrder>> getAllOrdersForAdmin() async {
    final data = await _supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((item) {
      return AppOrder.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<List<AppOrderItem>> getOrderItems(String orderId) async {
    final data = await _supabase
        .from('order_items')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (data as List).map((item) {
      return AppOrderItem.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _supabase.from('orders').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }
}