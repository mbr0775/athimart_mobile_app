// lib/features/orders/presentation/screens/order_details_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/services/order_service.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class OrderDetailsScreen extends StatefulWidget {
  final AppOrder order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late AppOrder _order;
  bool _loading = true;
  bool _cancelling = false;
  List<AppOrderItem> _items = [];

  bool get _canCancel {
    return _order.status == 'Pending';
  }

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });

    final items = await OrderService.getOrderItems(_order.id);

    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _cancelling = true;
    });

    try {
      await OrderService.updateOrderStatus(
        orderId: _order.id,
        status: 'Cancelled',
      );

      if (!mounted) return;

      setState(() {
        _order = _order.copyWith(status: 'Cancelled');
        _cancelling = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel order'),
          backgroundColor: HomeTokens.sale,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: HomeTokens.border),
                      color: HomeTokens.card,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: HomeTokens.text,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ORDER\nDETAILS',
                  style: HomeTokens.displayLarge().copyWith(
                    fontSize: 46,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 1.2, color: HomeTokens.text),
                const SizedBox(height: 18),
                Text(
                  _order.orderNumber,
                  style: HomeTokens.displayMedium().copyWith(fontSize: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  _order.status.toUpperCase(),
                  style: HomeTokens.label(
                    color: _order.status == 'Cancelled'
                        ? HomeTokens.sale
                        : HomeTokens.text,
                    size: 10,
                  ),
                ),
                const SizedBox(height: 34),
                _SectionTitle(title: 'Items'),
                const SizedBox(height: 14),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: HomeTokens.text,
                      strokeWidth: 2,
                    ),
                  )
                else
                  ..._items.map((item) => _OrderItemTile(item: item)),
                const SizedBox(height: 30),
                _SectionTitle(title: 'Shipping'),
                const SizedBox(height: 14),
                _InfoBox(
                  lines: [
                    _order.shippingName,
                    _order.shippingPhone,
                    _order.shippingAddressLine1,
                    if (_order.shippingAddressLine2.isNotEmpty)
                      _order.shippingAddressLine2,
                    '${_order.shippingCity}, ${_order.shippingState}',
                    '${_order.shippingPostalCode}, ${_order.shippingCountry}',
                  ],
                ),
                const SizedBox(height: 30),
                _SectionTitle(title: 'Summary'),
                const SizedBox(height: 14),
                _SummaryRow(
                  label: 'Subtotal',
                  value: '\$${_order.subtotal.toStringAsFixed(2)}',
                ),
                _SummaryRow(
                  label: 'Delivery',
                  value: _order.deliveryFee == 0
                      ? 'FREE'
                      : '\$${_order.deliveryFee.toStringAsFixed(2)}',
                ),
                Container(
                  height: 1.2,
                  color: HomeTokens.text,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: '\$${_order.total.toStringAsFixed(2)}',
                  large: true,
                ),
                if (_canCancel) ...[
                  const SizedBox(height: 28),
                  Material(
                    color: HomeTokens.sale,
                    child: InkWell(
                      onTap: _cancelling ? null : _cancelOrder,
                      child: SizedBox(
                        height: 54,
                        width: double.infinity,
                        child: Center(
                          child: _cancelling
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: HomeTokens.linen,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'CANCEL ORDER',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final AppOrderItem item;

  const _OrderItemTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: HomeTokens.white.withValues(alpha: 0.72),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: HomeTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              color: HomeTokens.card,
              child: item.imageUrl == null
                  ? Center(
                child: Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              )
                  : Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.companyName.toUpperCase(),
                    style: HomeTokens.label(size: 8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.productName,
                    style: HomeTokens.bodyBold(size: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty ${item.quantity}',
                    style: HomeTokens.body(size: 11),
                  ),
                ],
              ),
            ),
            Text(
              '\$${item.total.toStringAsFixed(2)}',
              style: HomeTokens.price(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: HomeTokens.displayMedium().copyWith(fontSize: 30),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final List<String> lines;

  const _InfoBox({
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: HomeTokens.border),
        color: HomeTokens.white.withValues(alpha: 0.62),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              style: HomeTokens.body(size: 13),
            ),
          );
        }).toList(),
      ),
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