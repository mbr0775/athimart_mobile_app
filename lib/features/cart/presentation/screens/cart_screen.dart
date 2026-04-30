// lib/features/cart/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/market_preference_service.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../data/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onOrderPlaced;

  const CartScreen({
    super.key,
    this.onOrderPlaced,
  });

  Future<void> _openCheckout(
      BuildContext context,
      CartState state,
      ) async {
    if (state.items.isEmpty) return;

    final placed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          return CheckoutScreen(
            items: state.items,
            subtotal: state.subtotal,
            deliveryFee: state.deliveryFee,
            total: state.total,
          );
        },
      ),
    );

    if (placed == true && context.mounted) {
      context.read<CartBloc>().add(const CartClear());
      onOrderPlaced?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = MarketPreferenceService.customerCountry;
    final currency = MarketPreferenceService.customerCurrency;

    return Scaffold(
      backgroundColor: HomeTokens.linen,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F2EC),
              Color(0xFFF2EDE7),
              Color(0xFFEEE8E1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return const _EmptyCart();
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SHOPPING\nCART',
                            style: HomeTokens.displayLarge().copyWith(
                              fontSize: 46,
                              letterSpacing: 2.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1.2,
                            width: double.infinity,
                            color: HomeTokens.text,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '${country.flag} ${country.name} cart • ${currency.code}',
                            style: HomeTokens.body(size: 14),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HomeTokens.pagePadding,
                    ),
                    sliver: SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];

                        return _CartItemCard(
                          item: item,
                          onDecrease: () {
                            context
                                .read<CartBloc>()
                                .add(CartDecrementItem(item.id));
                          },
                          onIncrease: () {
                            context
                                .read<CartBloc>()
                                .add(CartIncrementItem(item.id));
                          },
                          onRemove: () {
                            context
                                .read<CartBloc>()
                                .add(CartRemoveItem(item.id));
                          },
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        HomeTokens.pagePadding,
                        18,
                        HomeTokens.pagePadding,
                        40,
                      ),
                      child: _CartSummary(
                        state: state,
                        onCheckout: () => _openCheckout(context, state),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCode = MarketPreferenceService.customerCurrencyCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: HomeTokens.white.withValues(alpha: 0.68),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: HomeTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              color: HomeTokens.card,
              child: item.imageUrl == null
                  ? Center(
                child: Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              )
                  : Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.companyName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.label(size: 8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.bodyBold(size: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    MoneyFormatter.format(item.price, currencyCode),
                    style: HomeTokens.price(size: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: onDecrease,
                      ),
                      Container(
                        width: 34,
                        height: 32,
                        color: HomeTokens.linen,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: HomeTokens.label(
                              color: HomeTokens.text,
                              size: 9,
                            ),
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onTap: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  child: const Icon(
                    Icons.close_rounded,
                    color: HomeTokens.text,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  MoneyFormatter.format(item.lineTotal, currencyCode),
                  style: HomeTokens.price(size: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTokens.text,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            color: HomeTokens.linen,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartState state;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.state,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCode = MarketPreferenceService.customerCurrencyCode;

    return Column(
      children: [
        _SummaryRow(
          label: 'Subtotal',
          value: MoneyFormatter.format(state.subtotal, currencyCode),
        ),
        _SummaryRow(
          label: 'Delivery',
          value: state.deliveryFee == 0
              ? 'FREE'
              : MoneyFormatter.format(state.deliveryFee, currencyCode),
        ),
        Container(
          height: 1.2,
          color: HomeTokens.text,
          margin: const EdgeInsets.symmetric(vertical: 14),
        ),
        _SummaryRow(
          label: 'Total',
          value: MoneyFormatter.format(state.total, currencyCode),
          large: true,
        ),
        const SizedBox(height: 24),
        Material(
          color: HomeTokens.text,
          child: InkWell(
            onTap: onCheckout,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Center(
                child: Text(
                  'CHECKOUT',
                  style: HomeTokens.label(
                    color: HomeTokens.linen,
                    size: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: large
                ? HomeTokens.displayMedium().copyWith(fontSize: 28)
                : HomeTokens.label(color: HomeTokens.text, size: 10),
          ),
          const Spacer(),
          Text(
            value,
            style: large
                ? HomeTokens.price(size: 20)
                : HomeTokens.bodyBold(size: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: HomeTokens.text,
              size: 58,
            ),
            const SizedBox(height: 18),
            Text(
              'EMPTY CART',
              style: HomeTokens.displayMedium().copyWith(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products from Home or Shop to start checkout.',
              textAlign: TextAlign.center,
              style: HomeTokens.body(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}