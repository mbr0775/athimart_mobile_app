// lib/features/admin/presentation/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../theme/admin_tokens.dart';
import '../widgets/admin_ui.dart';
import 'admin_shell.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductLoadStats());
  }

  Future<void> _refresh() async {
    context.read<ProductBloc>().add(const ProductLoadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTokens.linen,
      appBar: AdminAppBar(
        title: 'Dashboard',
        actions: [
          _AppBarAction(
            icon: Icons.storefront_outlined,
            onTap: () => context.go('/home'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AdminPage(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AdminTokens.text,
                  strokeWidth: 2,
                ),
              );
            }

            Map<String, int> stats = {};
            List<AdminProduct> recentProducts = [];

            if (state is ProductStatsLoaded) {
              stats = state.stats;
              recentProducts = state.recentProducts;
            }

            if (state is ProductError) {
              return _ErrorView(
                message: state.message,
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              color: AdminTokens.text,
              backgroundColor: AdminTokens.linen,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 26),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminTokens.pagePadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STORE\nCONTROL',
                            style: AdminTokens.displayLarge(size: 44),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 1.2,
                            width: double.infinity,
                            color: AdminTokens.text,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Manage your Athimart products, users, orders and storefront content from one place.',
                            style: AdminTokens.body(size: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    const AdminSectionTitle(
                      title: 'Overview',
                      subtitle: 'Quick performance summary',
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminTokens.pagePadding,
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.05,
                        children: [
                          _StatCard(
                            label: 'Total Products',
                            value: '${stats['total_products'] ?? 0}',
                            icon: Icons.inventory_2_outlined,
                          ),
                          _StatCard(
                            label: 'Active',
                            value: '${stats['active_products'] ?? 0}',
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          _StatCard(
                            label: 'Total Users',
                            value: '${stats['total_users'] ?? 0}',
                            icon: Icons.people_outline_rounded,
                          ),
                          const _StatCard(
                            label: 'Orders',
                            value: '-',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 38),

                    const AdminSectionTitle(
                      title: 'Quick Actions',
                      subtitle: 'Common admin tasks',
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminTokens.pagePadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.add_rounded,
                              label: 'Add Product',
                              onTap: () => context.go('/admin/products/add'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.inventory_2_outlined,
                              label: 'Products',
                              onTap: () => context.go('/admin/products'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.people_outline_rounded,
                              label: 'Users',
                              onTap: () => context.go('/admin/users'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 38),

                    AdminSectionTitle(
                      title: 'Recent Products',
                      subtitle: 'Latest items in your catalog',
                      actionLabel: 'See all',
                      onActionTap: () => context.go('/admin/products'),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminTokens.pagePadding,
                      ),
                      child: recentProducts.isEmpty
                          ? const _EmptyProducts()
                          : Column(
                        children: recentProducts
                            .map(
                              (product) => _RecentProductRow(
                            product: product,
                          ),
                        )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 34),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminTokens.card,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: AdminTokens.border),
          ),
          child: Icon(
            icon,
            color: AdminTokens.text,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTokens.white.withValues(alpha: 0.68),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AdminTokens.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AdminTokens.text,
              size: 22,
            ),

            const Spacer(),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AdminTokens.displayMedium(size: 28),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AdminTokens.label(size: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminTokens.white.withValues(alpha: 0.62),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AdminTokens.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AdminTokens.text,
                size: 26,
              ),
              const SizedBox(height: 10),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AdminTokens.label(
                  color: AdminTokens.text,
                  size: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentProductRow extends StatelessWidget {
  final AdminProduct product;

  const _RecentProductRow({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final image = product.primaryImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: AdminTokens.white.withValues(alpha: 0.68),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AdminTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              color: AdminTokens.card,
              child: image == null
                  ? Center(
                child: Text(
                  product.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              )
                  : Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 28),
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
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTokens.label(size: 9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTokens.bodyBold(size: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AdminTokens.price(size: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  product.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: AdminTokens.label(
                    size: 8,
                    color: product.isActive
                        ? AdminTokens.success
                        : AdminTokens.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: AdminTokens.border),
        color: AdminTokens.white.withValues(alpha: 0.55),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AdminTokens.text,
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            'NO PRODUCTS YET',
            style: AdminTokens.label(color: AdminTokens.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first product to start selling.',
            textAlign: TextAlign.center,
            style: AdminTokens.body(size: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminTokens.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AdminTokens.danger,
              size: 46,
            ),
            const SizedBox(height: 18),
            Text(
              'FAILED TO LOAD',
              style: AdminTokens.displayMedium(),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AdminTokens.body(size: 13),
            ),
            const SizedBox(height: 24),
            AdminPrimaryButton(
              text: 'Retry',
              onTap: () => onRetry(),
            ),
          ],
        ),
      ),
    );
  }
}