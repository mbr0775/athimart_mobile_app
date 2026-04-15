// lib/shared/data/mock_data.dart
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/vendor_model.dart';

class MockData {
  static const List<BannerModel> banners = [
    BannerModel(
      id: '1',
      title: 'AI Smart Gadgets',
      subtitle: 'Up to 40% off on smart wearables & home automation',
      tag: 'TECH DEAL',
      gradientColors: [0xFF1A1040, 0xFF6C63FF],
      emoji: '🤖',
    ),
    BannerModel(
      id: '2',
      title: 'Premium Oud Collection',
      subtitle: 'Authentic Agarwood & rare essential oils from Ceylon',
      tag: 'NEW ARRIVAL',
      gradientColors: [0xFF2D1500, 0xFFD4A017],
      emoji: '🌿',
    ),
    BannerModel(
      id: '3',
      title: 'Fitness Tech Sale',
      subtitle: 'Top-rated gym gadgets & fitness trackers on sale',
      tag: 'FLASH SALE',
      gradientColors: [0xFF001A0A, 0xFF00C896],
      emoji: '💪',
    ),
    BannerModel(
      id: '4',
      title: 'Fashion & Lifestyle',
      subtitle: 'Trend-driven collections from global brands',
      tag: 'TRENDING',
      gradientColors: [0xFF1A0010, 0xFFFF4757],
      emoji: '👗',
    ),
  ];

  static const List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'IT Solutions', icon: '💻', color: 0xFF6C63FF, tag: 'Software & ERP'),
    CategoryModel(id: '2', name: 'AI Gadgets',   icon: '🤖', color: 0xFF00C896, tag: 'Smart Devices'),
    CategoryModel(id: '3', name: 'Fitness Tech', icon: '💪', color: 0xFFFF6B35, tag: 'Gym & Sports'),
    CategoryModel(id: '4', name: 'Essences',     icon: '🌿', color: 0xFFD4A017, tag: 'Oud & Oils'),
    CategoryModel(id: '5', name: 'Agarwood',     icon: '🪵', color: 0xFF8B4513, tag: 'Premium Export'),
    CategoryModel(id: '6', name: 'Fashion',      icon: '👗', color: 0xFFFF4757, tag: 'Clothing'),
    CategoryModel(id: '7', name: 'Vehicles',     icon: '🚗', color: 0xFF3498DB, tag: 'Buy & Sell'),
    CategoryModel(id: '8', name: 'Real Estate',  icon: '🏠', color: 0xFF9B59B6, tag: 'Land & Property'),
  ];

  static const List<ProductModel> flashSaleProducts = [
    ProductModel(id: '1', name: 'Smart AI Watch Pro',    category: 'AI Gadgets', price: 89.99,  originalPrice: 149.99, rating: 4.8, reviewCount: 234, emoji: '⌚', cardColor: 0xFF1A1040, isSale: true, discountPercent: 40),
    ProductModel(id: '2', name: 'Oud Royal Collection',  category: 'Essences',   price: 45.00,  originalPrice: 75.00,  rating: 4.9, reviewCount: 189, emoji: '🌹', cardColor: 0xFF2D1500, isSale: true, discountPercent: 40),
    ProductModel(id: '3', name: 'Fitness Tracker X3',    category: 'Fitness Tech',price: 59.99,  originalPrice: 99.99,  rating: 4.7, reviewCount: 312, emoji: '📊', cardColor: 0xFF001A0A, isSale: true, discountPercent: 40),
    ProductModel(id: '4', name: 'Smart Home Hub',         category: 'AI Gadgets', price: 129.99, originalPrice: 199.99, rating: 4.6, reviewCount: 98,  emoji: '🏠', cardColor: 0xFF1A1040, isSale: true, discountPercent: 35),
  ];

  static const List<ProductModel> featuredProducts = [
    ProductModel(id: '5', name: 'Sandalwood Premium Oil', category: 'Essences',     price: 35.00,  originalPrice: 35.00,  rating: 4.9, reviewCount: 421, emoji: '🌸', cardColor: 0xFF2D1500),
    ProductModel(id: '6', name: 'ERP Business Suite',     category: 'IT Solutions', price: 299.00, originalPrice: 299.00, rating: 4.8, reviewCount: 67,  emoji: '📊', cardColor: 0xFF1A1040),
    ProductModel(id: '7', name: 'Smart Gym Mirror',        category: 'Fitness Tech', price: 199.99, originalPrice: 249.99, rating: 4.7, reviewCount: 143, emoji: '🪞', cardColor: 0xFF001A0A, isNew: true),
    ProductModel(id: '8', name: 'Frankincense Resin',      category: 'Essences',     price: 22.00,  originalPrice: 22.00,  rating: 4.9, reviewCount: 356, emoji: '✨', cardColor: 0xFF2D1500),
    ProductModel(id: '9', name: 'AI Noise Cancelling Buds',category: 'AI Gadgets',   price: 79.99,  originalPrice: 119.99, rating: 4.6, reviewCount: 278, emoji: '🎧', cardColor: 0xFF1A1040, isNew: true, isSale: true, discountPercent: 33),
  ];

  static const List<ProductModel> newArrivals = [
    ProductModel(id: '10', name: 'Rose Otto Pure Oil',  category: 'Essences',     price: 55.00, originalPrice: 55.00,  rating: 4.8, reviewCount: 92,  emoji: '🌹', cardColor: 0xFF1A000A, isNew: true),
    ProductModel(id: '11', name: 'Smart Security Cam',  category: 'AI Gadgets',   price: 69.99, originalPrice: 89.99,  rating: 4.5, reviewCount: 187, emoji: '📸', cardColor: 0xFF001830, isNew: true),
    ProductModel(id: '12', name: 'Agarwood Bracelet',   category: 'Agarwood',     price: 120.00,originalPrice: 120.00, rating: 4.9, reviewCount: 64,  emoji: '📿', cardColor: 0xFF1A0800, isNew: true),
    ProductModel(id: '13', name: 'Yoga Smart Mat',      category: 'Fitness Tech', price: 89.99, originalPrice: 129.99, rating: 4.7, reviewCount: 203, emoji: '🧘', cardColor: 0xFF001A10, isNew: true),
  ];

  static const List<VendorModel> topVendors = [
    VendorModel(id: '1', name: 'Goviceylon',    category: 'Agarwood Exports', rating: 4.9, productCount: 48,  emoji: '🪵', color: 0xFF8B4513),
    VendorModel(id: '2', name: 'TechNova',      category: 'AI Gadgets',       rating: 4.8, productCount: 124, emoji: '🤖', color: 0xFF6C63FF),
    VendorModel(id: '3', name: 'NaturalCeylon', category: 'Essences & Oils',  rating: 4.9, productCount: 67,  emoji: '🌿', color: 0xFF00C896),
    VendorModel(id: '4', name: 'FitZone Pro',   category: 'Fitness Tech',     rating: 4.7, productCount: 89,  emoji: '💪', color: 0xFFFF6B35),
  ];
}