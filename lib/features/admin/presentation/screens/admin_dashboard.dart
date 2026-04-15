// lib/features/admin/presentation/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../../core/constants/app_colors.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'admin_shell.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

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

  void _showLogoutDialog(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?',
          style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel',
              style: TextStyle(fontFamily: 'Poppins',
                color: AppColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(dialogContext).pop();
              // Sign out from Supabase directly, then navigate
              Supabase.instance.client.auth.signOut().then((_) {
                pageContext.go('/auth/login');
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(10)),
              child: const Text('Sign Out',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(
        title: 'Dashboard',
        actions: [
          // Home button
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.storefront_rounded,
                color: AppColors.textPrimary, size: 20),
            ),
          ),
          // Logout button
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded,
                color: AppColors.accentRed, size: 20),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          Map<String, int> stats = {};
          List recentProducts = [];

          if (state is ProductStatsLoaded) {
            stats = state.stats;
            recentProducts = state.recentProducts;
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () async =>
                context.read<ProductBloc>().add(const ProductLoadStats()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Welcome Banner ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1040), Color(0xFF6C63FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Welcome back! 👋',
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                  color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              const Text('Athimart Admin',
                                style: TextStyle(fontFamily: 'PlayfairDisplay',
                                  fontSize: 20, fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                              const SizedBox(height: 6),
                              Text('Manage your store from here',
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                  color: Colors.white.withOpacity(0.6))),
                              const SizedBox(height: 14),
                              // View Store button
                              GestureDetector(
                                onTap: () => context.go('/home'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.storefront_rounded,
                                        color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text('View Store',
                                        style: TextStyle(fontFamily: 'Poppins',
                                          fontSize: 12, fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('🏪', style: TextStyle(fontSize: 42)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Overview heading ───────────────────────────────────
                  const Text('Overview',
                    style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),

                  // ── Stat Cards — horizontal Row layout, no fixed height ─
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _StatCard(
                            label: 'Total Products',
                            value: '${stats['total_products'] ?? 0}',
                            icon: Icons.inventory_2_rounded,
                            color: AppColors.primary,
                            gradient: AppColors.primaryGradient,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            label: 'Active',
                            value: '${stats['active_products'] ?? 0}',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.accentGreen,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C896), Color(0xFF00A878)]),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatCard(
                            label: 'Total Users',
                            value: '${stats['total_users'] ?? 0}',
                            icon: Icons.people_rounded,
                            color: AppColors.accent,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF4A42DD)]),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            label: 'Orders',
                            value: '—',
                            icon: Icons.receipt_long_rounded,
                            color: AppColors.accentOrange,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFDD4A12)]),
                          )),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Quick Actions ──────────────────────────────────────
                  const Text('Quick Actions',
                    style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _QuickAction(
                        icon: Icons.add_circle_rounded,
                        label: 'Add Product',
                        color: AppColors.primary,
                        onTap: () => context.go('/admin/products/add'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(
                        icon: Icons.inventory_2_rounded,
                        label: 'Products',
                        color: AppColors.accent,
                        onTap: () => context.go('/admin/products'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(
                        icon: Icons.people_rounded,
                        label: 'Users',
                        color: AppColors.accentGreen,
                        onTap: () => context.go('/admin/users'),
                      )),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Recent Products ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Products',
                        style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                          fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      TextButton(
                        onPressed: () => context.go('/admin/products'),
                        child: const Text('See All',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (recentProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('📦', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text('No products yet',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                              color: AppColors.textSecondary)),
                        ]),
                      ),
                    )
                  else
                    ...recentProducts.map((p) => _RecentProductRow(product: p)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Stat Card — Row layout, height is intrinsic ─────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  const _StatCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 20,
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                    color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action ────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Product Row ──────────────────────────────────────────────────────
class _RecentProductRow extends StatelessWidget {
  final dynamic product;
  const _RecentProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(product.emoji,
                style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(product.category,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: product.isActive
                      ? AppColors.accentGreen.withOpacity(0.15)
                      : AppColors.accentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: product.isActive
                        ? AppColors.accentGreen : AppColors.accentRed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}