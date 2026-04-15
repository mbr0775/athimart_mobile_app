// lib/features/home/presentation/widgets/home_featured_products.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/product_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/product_service.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/data/cart_item.dart';

class HomeFeaturedProducts extends StatefulWidget {
  const HomeFeaturedProducts({super.key});
  @override
  State<HomeFeaturedProducts> createState() => _HomeFeaturedProductsState();
}

class _HomeFeaturedProductsState extends State<HomeFeaturedProducts> {
  List<Map<String, dynamic>> _real = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ProductService.getFeaturedProducts();
    if (mounted) setState(() { _real = data; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    final useReal = _loaded && _real.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(width: 4, height: 22,
              decoration: BoxDecoration(color: AppColors.accent,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text('Featured',
              style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Spacer(),
            TextButton(onPressed: () {},
              child: const Text('See All',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  color: AppColors.primary, fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: useReal
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _real.length,
                  itemBuilder: (context, i) =>
                      _RealFeaturedCard(product: _real[i]))
              : !_loaded
                  ? const Center(child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: MockData.featuredProducts.length,
                      itemBuilder: (context, i) =>
                          _MockFeaturedCard(product: MockData.featuredProducts[i])),
        ),
      ],
    );
  }
}

// ── Real product card (from Supabase) ────────────────────────────────────────
class _RealFeaturedCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _RealFeaturedCard({required this.product});

  void _addToCart(BuildContext context) {
    final price = (product['price'] as num).toDouble();
    final origPrice = product['original_price'] != null
        ? (product['original_price'] as num).toDouble() : null;

    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product['id'],
      name: product['name'],
      emoji: product['emoji'] ?? '📦',
      category: product['category'] ?? '',
      price: price,
      originalPrice: origPrice,
      discountPercent: product['discount_percent'] ?? 0,
    )));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(product['emoji'] ?? '📦', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text('${product['name']} added to cart!',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
            fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: AppColors.accentGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final price = (product['price'] as num).toDouble();
    final origPrice = product['original_price'] != null
        ? (product['original_price'] as num).toDouble() : null;
    final discount = product['discount_percent'] ?? 0;
    final isSale = discount > 0;
    final imageUrls = product['image_urls'] as List?;
    final hasImage = imageUrls != null && imageUrls.isNotEmpty;

    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        // Image / emoji area
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: SizedBox(
            height: 145,
            width: double.infinity,
            child: hasImage
                ? ProductImage(
                    imageUrls: imageUrls,
                    emoji: product['emoji'] ?? '📦',
                    fontSize: 60,
                    fit: BoxFit.cover)
                : Container(
                    color: AppColors.surface,
                    child: Center(child: Text(product['emoji'] ?? '📦',
                      style: const TextStyle(fontSize: 64)))),
          ),
        ),

        // Badges
        if (isSale)
          Positioned(top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(8)),
              child: Text('-$discount%',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                  fontWeight: FontWeight.w700, color: Colors.white)))),

        if (!isSale)
          Positioned(top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(8)),
              child: const Text('NEW',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                  fontWeight: FontWeight.w700, color: Colors.white,
                  letterSpacing: 1)))),

        // Wishlist
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 15, color: Colors.white))),

        // Bottom info
        Positioned(left: 0, right: 0, bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['category'] ?? '',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                    color: AppColors.textHint, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(product['name'] ?? '', maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (origPrice != null && isSale)
                          Text('\$${origPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 9, color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough)),
                        Text('\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                      ]),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        final inCart = cartState.containsId(product['id']);
                        return GestureDetector(
                          onTap: () => _addToCart(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: inCart ? null : AppColors.primaryGradient,
                              color: inCart ? AppColors.accentGreen : null,
                              borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              inCart ? Icons.check_rounded
                                  : Icons.add_shopping_cart_rounded,
                              size: 15, color: Colors.black)),
                        );
                      }),
                  ]),
              ]),
          )),
      ]),
    );
  }
}

// ── Mock product card (fallback) ──────────────────────────────────────────────
class _MockFeaturedCard extends StatelessWidget {
  final ProductModel product;
  const _MockFeaturedCard({required this.product});

  void _addToCart(BuildContext context) {
    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product.id, name: product.name, emoji: product.emoji,
      category: product.category, price: product.price,
      originalPrice: product.isSale ? product.originalPrice : null,
      discountPercent: product.discountPercent)));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(product.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text('${product.name} added to cart!',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
            fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Color(product.cardColor),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        if (product.isNew)
          Positioned(top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(8)),
              child: const Text('NEW', style: TextStyle(fontFamily: 'Poppins',
                fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white,
                letterSpacing: 1)))),
        if (product.isSale && !product.isNew)
          Positioned(top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(8)),
              child: Text('-${product.discountPercent}%',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                  fontWeight: FontWeight.w700, color: Colors.white)))),
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.card.withOpacity(0.5),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 15, color: AppColors.textSecondary))),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              Center(child: Text(product.emoji,
                style: const TextStyle(fontSize: 66))),
              const SizedBox(height: 12),
              Text(product.category, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 10, color: AppColors.textHint, letterSpacing: 0.5)),
              const SizedBox(height: 3),
              Text(product.name, maxLines: 2,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  height: 1.3)),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (product.isSale)
                    Text('\$${product.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough)),
                  Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    final inCart = cartState.containsId(product.id);
                    return GestureDetector(
                      onTap: () => _addToCart(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: inCart ? null : AppColors.primaryGradient,
                          color: inCart ? AppColors.accentGreen : null,
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          inCart ? Icons.check_rounded
                              : Icons.add_shopping_cart_rounded,
                          size: 16, color: Colors.black)));
                  }),
              ]),
            ]),
        ),
      ]),
    );
  }
}