// lib/features/cart/data/cart_item.dart

class CartItem {
  final String id;
  final String name;
  final String companyName;
  final String category;
  final String subCategory;
  final String emoji;
  final String? imageUrl;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    this.companyName = 'Athimart',
    this.category = 'General',
    this.subCategory = 'General',
    this.emoji = '📦',
    this.imageUrl,
    required this.price,
    required this.originalPrice,
    this.discountPercent = 0,
    this.quantity = 1,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? companyName,
    String? category,
    String? subCategory,
    String? emoji,
    String? imageUrl,
    double? price,
    double? originalPrice,
    int? discountPercent,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'category': category,
      'sub_category': subCategory,
      'emoji': emoji,
      'image_url': imageUrl,
      'price': price,
      'original_price': originalPrice,
      'discount_percent': discountPercent,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int toInt(
        dynamic value, {
          int fallback = 0,
        }) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return CartItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      companyName: json['company_name']?.toString() ?? 'Athimart',
      category: json['category']?.toString() ?? 'General',
      subCategory: json['sub_category']?.toString() ?? 'General',
      emoji: json['emoji']?.toString() ?? '📦',
      imageUrl: json['image_url']?.toString(),
      price: toDouble(json['price']),
      originalPrice: toDouble(json['original_price']),
      discountPercent: toInt(json['discount_percent']),
      quantity: toInt(json['quantity'], fallback: 1),
    );
  }
}