// lib/features/home/presentation/widgets/home_new_arrivals.dart
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

class HomeNewArrivals extends StatefulWidget {
  const HomeNewArrivals({super.key});
  @override
  State<HomeNewArrivals> createState() => _HomeNewArrivalsState();
}

class _HomeNewArrivalsState extends State<HomeNewArrivals> {
  List<Map<String, dynamic>> _real = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ProductService.getNewArrivals();
    if (mounted) setState(() { _real = data; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    final useReal = _loaded && _real.isNotEmpty;
    final items = useReal ? _real : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(width: 4, height: 22,
              decoration: BoxDecoration(color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text('New Arrivals',
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
        if (!_loaded)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: useReal ? _real.length : MockData.newArrivals.length,
              itemBuilder: (context, i) {
                if (useReal) {
                  return _RealArrivalCard(product: _real[i]);
                } else {
                  return _MockArrivalCard(product: MockData.newArrivals[i]);
                }
              },
            ),
          ),
      ],
    );
  }
}

// ── Real card ────────────────────────────────────────────────────────────────
class _RealArrivalCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _RealArrivalCard({required this.product});

  void _addToCart(BuildContext context) {
    final price = (product['price'] as num).toDouble();
    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product['id'], name: product['name'],
      emoji: product['emoji'] ?? '📦',
      category: product['category'] ?? '', price: price)));
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
    final discount = product['discount_percent'] ?? 0;
    final imageUrls = product['image_urls'] as List?;
    final hasImage = imageUrls != null && imageUrls.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        Column(children: [
          // Image area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                width: double.infinity,
                child: hasImage
                    ? ProductImage(
                        imageUrls: imageUrls, emoji: product['emoji'] ?? '📦',
                        fit: BoxFit.cover)
                    : Container(
                        color: AppColors.surface,
                        child: Center(child: Text(product['emoji'] ?? '📦',
                          style: const TextStyle(fontSize: 54)))),
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['category'] ?? '',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                    color: AppColors.textHint, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(product['name'] ?? '', maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    height: 1.3)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        final inCart = cartState.containsId(product['id']);
                        return GestureDetector(
                          onTap: () => _addToCart(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: inCart ? null : AppColors.primaryGradient,
                              color: inCart ? AppColors.accentGreen : null,
                              borderRadius: BorderRadius.circular(8)),
                            child: Icon(
                              inCart ? Icons.check_rounded : Icons.add_rounded,
                              size: 14, color: Colors.black)));
                      }),
                  ]),
              ]),
          ),
        ]),

        // NEW badge
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              gradient: discount > 0 ? null : AppColors.primaryGradient,
              color: discount > 0 ? AppColors.accentRed : null,
              borderRadius: BorderRadius.circular(6)),
            child: Text(discount > 0 ? '-$discount%' : 'NEW',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 8,
                fontWeight: FontWeight.w800, color: Colors.black,
                letterSpacing: 1)))),

        // Wishlist
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 13, color: Colors.white))),
      ]),
    );
  }
}

// ── Mock card (fallback) ──────────────────────────────────────────────────────
class _MockArrivalCard extends StatelessWidget {
  final ProductModel product;
  const _MockArrivalCard({required this.product});

  void _addToCart(BuildContext context) {
    context.read<CartBloc>().add(CartAddItem(CartItem(
      id: product.id, name: product.name, emoji: product.emoji,
      category: product.category, price: product.price)));
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
      decoration: BoxDecoration(color: Color(product.cardColor),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(6)),
            child: const Text('NEW', style: TextStyle(fontFamily: 'Poppins',
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black,
              letterSpacing: 1)))),
        Positioned(top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: AppColors.card.withOpacity(0.5),
              shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
              size: 14, color: AppColors.textSecondary))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              Center(child: Text(product.emoji,
                style: const TextStyle(fontSize: 58))),
              const SizedBox(height: 8),
              Text(product.category, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 9, color: AppColors.textHint,
                letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(product.name, maxLines: 2,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  height: 1.3)),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
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
                            borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            inCart ? Icons.check_rounded : Icons.add_rounded,
                            size: 15, color: Colors.black)));
                    }),
                ]),
            ])),
      ]),
    );
  }
}