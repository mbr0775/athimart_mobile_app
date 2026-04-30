// lib/features/admin/presentation/screens/admin_orders.dart
import 'package:flutter/material.dart';

import '../../../../core/services/order_service.dart';
import '../theme/admin_tokens.dart';
import '../widgets/admin_ui.dart';
import 'admin_shell.dart';

class AdminOrdersManagementScreen extends StatefulWidget {
  const AdminOrdersManagementScreen({super.key});

  @override
  State<AdminOrdersManagementScreen> createState() =>
      _AdminOrdersManagementScreenState();
}

class _AdminOrdersManagementScreenState
    extends State<AdminOrdersManagementScreen> {
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

  Future<void> _loadOrders() async {
    setState(() => _loading = true);

    try {
      final orders = await OrderService.getAllOrdersForAdmin();

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

  Future<void> _updateStatus(AppOrder order, String status) async {
    await OrderService.updateOrderStatus(
      orderId: order.id,
      status: status,
    );

    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTokens.linen,
      appBar: const AdminAppBar(title: 'Orders'),
      body: AdminPage(
        child: RefreshIndicator(
          color: AdminTokens.text,
          backgroundColor: AdminTokens.linen,
          onRefresh: _loadOrders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER\nMANAGEMENT',
                        style: AdminTokens.displayLarge(size: 42),
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1.2, color: AdminTokens.text),
                      const SizedBox(height: 16),
                      Text(
                        'View customer orders and update delivery status.',
                        style: AdminTokens.body(size: 14),
                      ),
                      const SizedBox(height: 24),
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
                                padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AdminTokens.text
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: AdminTokens.text,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    status.toUpperCase(),
                                    style: AdminTokens.label(
                                      size: 9,
                                      color: selected
                                          ? AdminTokens.linen
                                          : AdminTokens.text,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AdminTokens.text,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_filteredOrders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'NO ORDERS',
                      style: AdminTokens.displayMedium(size: 34),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];

                      return _AdminOrderCard(
                        order: order,
                        onStatusChanged: (status) {
                          if (status == null) return;
                          _updateStatus(order, status);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final AppOrder order;
  final ValueChanged<String?> onStatusChanged;

  const _AdminOrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: AdminTokens.white.withValues(alpha: 0.68),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AdminTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.status.toUpperCase(),
              style: AdminTokens.label(
                color: order.status == 'Cancelled'
                    ? AdminTokens.danger
                    : AdminTokens.text,
                size: 9,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.orderNumber,
              style: AdminTokens.displayMedium(size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.shippingName} • ${order.shippingCity}',
              style: AdminTokens.body(size: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.itemsCount} items • \$${order.total.toStringAsFixed(2)}',
              style: AdminTokens.bodyBold(size: 13),
            ),
            const SizedBox(height: 14),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AdminTokens.text),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: statuses.contains(order.status)
                      ? order.status
                      : 'Pending',
                  isExpanded: true,
                  dropdownColor: AdminTokens.linen,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AdminTokens.text,
                  ),
                  items: statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: AdminTokens.bodyBold(size: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: onStatusChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}