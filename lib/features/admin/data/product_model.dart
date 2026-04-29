// lib/features/admin/data/product_model.dart

class AdminProduct {
  final String? id;
  final String name;
  final String companyName;
  final String subCategory;
  final String description;
  final double price;
  final double originalPrice;
  final String category;
  final String emoji;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final int discountPercent;
  final List<String> imageUrls;

  const AdminProduct({
    this.id,
    required this.name,
    this.companyName = 'Athimart',
    this.subCategory = 'General',
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.category,
    this.emoji = '📦',
    required this.stock,
    this.isActive = true,
    this.isFeatured = false,
    this.discountPercent = 0,
    this.imageUrls = const [],
  });

  String? get primaryImage {
    return imageUrls.isNotEmpty ? imageUrls.first : null;
  }

  bool get hasImages {
    return imageUrls.isNotEmpty;
  }

  factory AdminProduct.fromMap(Map<String, dynamic> map) {
    List<String> images = [];

    final rawImages = map['image_urls'];
    if (rawImages is List) {
      images = rawImages.map((item) => item.toString()).toList();
    }

    final priceValue = map['price'];
    final originalPriceValue = map['original_price'];

    final parsedPrice = priceValue is num
        ? priceValue.toDouble()
        : double.tryParse(priceValue?.toString() ?? '') ?? 0;

    return AdminProduct(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? 'Athimart',
      subCategory: map['sub_category']?.toString() ?? 'General',
      description: map['description']?.toString() ?? '',
      price: parsedPrice,
      originalPrice: originalPriceValue is num
          ? originalPriceValue.toDouble()
          : double.tryParse(originalPriceValue?.toString() ?? '') ??
          parsedPrice,
      category: map['category']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '📦',
      stock: map['stock'] is num
          ? (map['stock'] as num).toInt()
          : int.tryParse(map['stock']?.toString() ?? '') ?? 0,
      isActive: map['is_active'] ?? true,
      isFeatured: map['is_featured'] ?? false,
      discountPercent: map['discount_percent'] is num
          ? (map['discount_percent'] as num).toInt()
          : int.tryParse(map['discount_percent']?.toString() ?? '') ?? 0,
      imageUrls: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company_name': companyName,
      'sub_category': subCategory,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'category': category,
      'emoji': emoji,
      'stock': stock,
      'is_active': isActive,
      'is_featured': isFeatured,
      'discount_percent': discountPercent,
      'image_urls': imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  AdminProduct copyWith({
    String? id,
    String? name,
    String? companyName,
    String? subCategory,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? emoji,
    int? stock,
    bool? isActive,
    bool? isFeatured,
    int? discountPercent,
    List<String>? imageUrls,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      subCategory: subCategory ?? this.subCategory,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      discountPercent: discountPercent ?? this.discountPercent,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}