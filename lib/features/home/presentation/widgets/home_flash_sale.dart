// lib/features/home/presentation/widgets/home_flash_sale.dart
import 'dart:async';
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

class HomeFlashSale extends StatefulWidget {
  const HomeFlashSale({super.key});
  @override
  State<HomeFlashSale> createState() => _HomeFlashSaleState();
}

class _HomeFlashSaleState extends State<HomeFlashSale> {
  late Timer _timer;
  int _hours = 5, _minutes = 47, _seconds = 23;

  List<Map<String, dynamic>> _real = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_seconds > 0) { _seconds--; }
        else if (_minutes > 0) { _minutes--; _seconds = 59; }
        else if (_hours > 0) { _hours--; _minutes = 59; _seconds = 59; }
      });
    });
    _load();
  }

  Future<void> _load() async {
    final data = await ProductService.getFlashSaleProducts();
    if (mounted) setState(() { _real = data; _loaded = true; });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              decoration: BoxDecoration(gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text('⚡ Flash Sale',
              style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Spacer(),
            Row(children: [
              _TimeBox(value: _hours.toString().padLeft(2, '0')),
              const _TimeSeparator(),
              _TimeBox(value: _minutes.toString().padLeft(2, '0')),
              const _TimeSeparator(),
              _TimeBox(value: _seconds.toString().padLeft(2, '0')),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: useReal
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _real.length,
                  itemBuilder: (_, i) => _RealFlashCard(product: _real[i]))
              : !_loaded
                  ? const Center(child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: MockData.flashSaleProducts.length,
                      itemBuilder: (_, i) =>
                          _MockFlashCard(product: MockData.flashSaleProducts[i])),
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  const _TimeBox({required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(6)),
      child: Text(value, style: const TextStyle(fontFamily: 'Poppins',
        fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)));
  }
}

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(':', style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
        fontWeight: FontWeight.bold, color: AppColors.accentRed)));
  }
}

// ── Real flash sale card ──────────────────────────────────────────────────────
class _RealFlashCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _RealFlashCard({required this.product});

  void _addToCart(BuildContext context) {
    final price = (product['price'] as num).toDouble();
    final origPrice = product['original_price'] != null
        ? (product['original_price'] as num).toDouble() : null;
    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product['id'], name: product['name'],
      emoji: product['emoji'] ?? '📦',
      category: product['category'] ?? '', price: price,
      originalPrice: origPrice,
      discountPercent: product['discount_percent'] ?? 0)));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(product['emoji'] ?? '📦', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text('${product['name']} added!',
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
    final price = (product['price'] as num).toDouble();
    final origPrice = product['original_price'] != null
        ? (product['original_price'] as num).toDouble() : null;
    final discount = product['discount_percent'] ?? 0;
    final imageUrls = product['image_urls'] as List?;
    final hasImage = imageUrls != null && imageUrls.isNotEmpty;

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        Column(children: [
          // Image area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 130, width: double.infinity,
              child: hasImage
                  ? ProductImage(imageUrls: imageUrls,
                      emoji: product['emoji'] ?? '📦',
                      fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surface,
                      child: Center(child: Text(product['emoji'] ?? '📦',
                        style: const TextStyle(fontSize: 54)))),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? '', maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    height: 1.3)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${price.toStringAsFixed(0)}',
                          style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                        if (origPrice != null)
                          Text('\$${origPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 10, color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough)),
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
                              borderRadius: BorderRadius.circular(9)),
                            child: Icon(
                              inCart ? Icons.check_rounded
                                  : Icons.add_shopping_cart_rounded,
                              size: 14, color: Colors.black)));
                      }),
                  ]),
              ]),
          ),
        ]),

        // Discount badge
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentRed,
              borderRadius: BorderRadius.circular(8)),
            child: Text('-$discount%',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700, color: Colors.white)))),

        // Wishlist
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 14, color: Colors.white))),
      ]),
    );
  }
}

// ── Mock flash sale card (fallback) ──────────────────────────────────────────
class _MockFlashCard extends StatelessWidget {
  final ProductModel product;
  const _MockFlashCard({required this.product});

  void _addToCart(BuildContext context) {
    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product.id, name: product.name, emoji: product.emoji,
      category: product.category, price: product.price,
      originalPrice: product.originalPrice,
      discountPercent: product.discountPercent)));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(product.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text('${product.name} added!',
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
      width: 155, margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Color(product.cardColor),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentRed,
              borderRadius: BorderRadius.circular(8)),
            child: Text('-${product.discountPercent}%',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700, color: Colors.white)))),
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.card.withOpacity(0.6),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 14, color: AppColors.textSecondary))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(child: Text(product.emoji,
                style: const TextStyle(fontSize: 56))),
              const SizedBox(height: 10),
              Text(product.name, maxLines: 2,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  height: 1.3)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.primary, size: 13),
                const SizedBox(width: 3),
                Text(product.rating.toString(),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16,
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('\$${product.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough)),
                  ]),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    final inCart = cartState.containsId(product.id);
                    return GestureDetector(
                      onTap: () => _addToCart(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: inCart ? null : AppColors.primaryGradient,
                          color: inCart ? AppColors.accentGreen : null,
                          borderRadius: BorderRadius.circular(9)),
                        child: Icon(
                          inCart ? Icons.check_rounded
                              : Icons.add_shopping_cart_rounded,
                          size: 15, color: Colors.black)));
                  }),
              ]),
            ])),
      ]),
    );
  }
}