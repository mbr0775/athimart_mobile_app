// lib/features/admin/data/product_model.dart
class AdminProduct {
  final String? id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String category;
  final String emoji;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final int discountPercent;
  final List<String> imageUrls; // ← NEW: list of uploaded image URLs

  const AdminProduct({
    this.id,
    required this.name,
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

  // First image URL (used as thumbnail)
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get hasImages => imageUrls.isNotEmpty;

  factory AdminProduct.fromMap(Map<String, dynamic> m) {
    // image_urls stored as jsonb array in Supabase
    List<String> imgs = [];
    final raw = m['image_urls'];
    if (raw is List) {
      imgs = raw.map((e) => e.toString()).toList();
    }
    return AdminProduct(
      id: m['id'],
      name: m['name'] ?? '',
      description: m['description'] ?? '',
      price: (m['price'] as num).toDouble(),
      originalPrice: (m['original_price'] as num? ?? m['price'] as num).toDouble(),
      category: m['category'] ?? '',
      emoji: m['emoji'] ?? '📦',
      stock: m['stock'] ?? 0,
      isActive: m['is_active'] ?? true,
      isFeatured: m['is_featured'] ?? false,
      discountPercent: m['discount_percent'] ?? 0,
      imageUrls: imgs,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'original_price': originalPrice,
    'category': category,
    'emoji': emoji,
    'stock': stock,
    'is_active': isActive,
    'is_featured': isFeatured,
    'discount_percent': discountPercent,
    'image_urls': imageUrls, // ← stored as jsonb in Supabase
    'updated_at': DateTime.now().toIso8601String(),
  };

  AdminProduct copyWith({
    String? id, String? name, String? description, double? price,
    double? originalPrice, String? category, String? emoji, int? stock,
    bool? isActive, bool? isFeatured, int? discountPercent,
    List<String>? imageUrls,
  }) => AdminProduct(
    id: id ?? this.id, name: name ?? this.name,
    description: description ?? this.description, price: price ?? this.price,
    originalPrice: originalPrice ?? this.originalPrice,
    category: category ?? this.category, emoji: emoji ?? this.emoji,
    stock: stock ?? this.stock, isActive: isActive ?? this.isActive,
    isFeatured: isFeatured ?? this.isFeatured,
    discountPercent: discountPercent ?? this.discountPercent,
    imageUrls: imageUrls ?? this.imageUrls,
  );
}