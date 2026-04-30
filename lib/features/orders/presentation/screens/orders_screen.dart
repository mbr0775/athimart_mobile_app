// lib/features/orders/presentation/screens/orders_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/services/order_service.dart';
import '../../../home/presentation/theme/home_tokens.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  final int refreshToken;

  const OrdersScreen({
    super.key,
    this.refreshToken = 0,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  String _selectedStatus = 'All';
  List<AppOrder> _orders = [];

  final List<String> _statuses = const [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  List<AppOrder> get _filteredOrders {
    if (_selectedStatus == 'All') return _orders;
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
    });

    try {
      final orders = await OrderService.getMyOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _orders = [];
        _loading = false;
      });
    }
  }

  Future<void> _openDetails(AppOrder order) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );

    if (mounted) {
      _loadOrders();
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
          child: RefreshIndicator(
            color: HomeTokens.text,
            backgroundColor: HomeTokens.linen,
            onRefresh: _loadOrders,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY\nORDERS',
                          style: HomeTokens.displayLarge().copyWith(
                            fontSize: 46,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1.2,
                          color: HomeTokens.text,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Track purchases, delivery status and order history.',
                          style: HomeTokens.body(size: 14),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _statuses.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final status = _statuses[index];
                              final selected = status == _selectedStatus;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? HomeTokens.text
                                        : Colors.transparent,
                                    border:
                                    Border.all(color: HomeTokens.text),
                                  ),
                                  child: Center(
                                    child: Text(
                                      status.toUpperCase(),
                                      style: HomeTokens.label(
                                        size: 9,
                                        color: selected
                                            ? HomeTokens.linen
                                            : HomeTokens.text,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: HomeTokens.text,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_filteredOrders.isEmpty)
                  const SliverFillRemaining(
                    child: _EmptyOrders(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 120),
                    sliver: SliverList.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];

                        return _OrderCard(
                          order: order,
                          onTap: () => _openDetails(order),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  Color get statusColor {
    switch (order.status) {
      case 'Delivered':
        return HomeTokens.success;
      case 'Cancelled':
        return HomeTokens.sale;
      case 'Shipped':
      case 'Processing':
        return HomeTokens.text;
      default:
        return HomeTokens.lightGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: HomeTokens.white.withValues(alpha: 0.72),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: HomeTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.status.toUpperCase(),
                style: HomeTokens.label(color: statusColor, size: 9),
              ),
              const SizedBox(height: 8),
              Text(
                order.orderNumber,
                style: HomeTokens.displayMedium().copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                '${order.itemsCount} items • ${order.shippingCity}',
                style: HomeTokens.body(size: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: HomeTokens.price(size: 16),
                  ),
                  const Spacer(),
                  Text(
                    'VIEW DETAILS',
                    style: HomeTokens.label(
                      color: HomeTokens.text,
                      size: 9,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 24, height: 1, color: HomeTokens.text),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: HomeTokens.text,
              size: 58,
            ),
            const SizedBox(height: 18),
            Text(
              'NO ORDERS',
              style: HomeTokens.displayMedium().copyWith(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'Your placed orders will appear here.',
              textAlign: TextAlign.center,
              style: HomeTokens.body(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}