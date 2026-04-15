// lib/features/cart/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../data/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('My Cart',
          style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22,
            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                      title: const Text('Clear Cart?',
                        style: TextStyle(fontFamily: 'PlayfairDisplay',
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                      content: const Text('Remove all items from cart?',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                          color: AppColors.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('Cancel',
                            style: TextStyle(color: AppColors.textSecondary))),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            context.read<CartBloc>().add(const CartClear());
                          },
                          child: const Text('Clear',
                            style: TextStyle(color: AppColors.accentRed,
                              fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                },
                child: const Text('Clear All',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    color: AppColors.accentRed, fontWeight: FontWeight.w500)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return _EmptyCart();
          }
          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) => _CartItemCard(item: state.items[i]),
                ),
              ),

              // Order summary + checkout
              _OrderSummary(state: state),
            ],
          );
        },
      ),
    );
  }
}

// ─── Empty Cart ───────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border)),
            child: const Center(
              child: Text('🛒', style: TextStyle(fontSize: 48)))),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
            style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22,
              fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Add products to get started',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Emoji thumbnail
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border)),
            child: Center(child: Text(item.emoji,
              style: const TextStyle(fontSize: 30)))),
          const SizedBox(width: 12),

          // Name + category + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    height: 1.3)),
                const SizedBox(height: 3),
                Text(item.category,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  if (item.originalPrice != null) ...[
                    Text('\$${item.originalPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 6),
                  ],
                  Text('\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Quantity controls + remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove button
              GestureDetector(
                onTap: () => context.read<CartBloc>()
                    .add(CartRemoveItem(item.id)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close_rounded,
                    size: 14, color: AppColors.accentRed))),
              const SizedBox(height: 10),

              // Qty stepper
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  _QtyBtn(
                    icon: Icons.remove_rounded,
                    onTap: () => context.read<CartBloc>().add(
                      CartUpdateQuantity(item.id, item.quantity - 1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary))),
                  _QtyBtn(
                    icon: Icons.add_rounded,
                    onTap: () => context.read<CartBloc>().add(
                      CartUpdateQuantity(item.id, item.quantity + 1)),
                  ),
                ]),
              ),

              const SizedBox(height: 8),
              // Item subtotal
              Text('\$${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.textPrimary)),
    );
  }
}

// ─── Order Summary ────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartState state;
  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final subtotal = state.totalPrice;
    const shipping = 5.00;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2),
            blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        children: [
          // Summary rows
          _SummaryRow('Subtotal (${state.totalItems} items)',
            '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _SummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 18,
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                child: Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 20,
                    fontWeight: FontWeight.w800, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16, offset: const Offset(0, 6))
                ],
              ),
              child: const Center(
                child: Text('Proceed to Checkout',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w700, color: Colors.black))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}