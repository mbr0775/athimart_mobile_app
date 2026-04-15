// lib/features/admin/presentation/screens/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

// Top-level admin routes → show hamburger. Sub-routes → show back arrow.
const _topLevelRoutes = {'/admin', '/admin/products', '/admin/orders', '/admin/users'};

// ── Placeholder screens ───────────────────────────────────────────────────────
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => _ComingSoon(label: 'Orders', icon: Icons.receipt_long_rounded);
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});
  @override
  Widget build(BuildContext context) => _ComingSoon(label: 'Users', icon: Icons.people_rounded);
}

class _ComingSoon extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ComingSoon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AdminAppBar(title: label),
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border)),
          child: Icon(icon, color: AppColors.primary, size: 36)),
        const SizedBox(height: 16),
        Text(label,
          style: const TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 24,
            color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Coming soon...',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
            color: AppColors.textSecondary)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => context.go('/admin'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12)),
            child: const Text('Back to Dashboard',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.black))),
        ),
      ]),
    ),
  );
}

// ── Admin Shell ───────────────────────────────────────────────────────────────
class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const _AdminDrawer(),
        body: child,
      ),
    );
  }
}

// ── Drawer ────────────────────────────────────────────────────────────────────
class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final loc = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1040), Color(0xFF0A0A0F)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('A',
                        style: TextStyle(fontFamily: 'PlayfairDisplay',
                          fontSize: 28, fontWeight: FontWeight.bold,
                          color: Colors.black))),
                  ),
                  const SizedBox(height: 12),
                  const Text('Athimart Admin',
                    style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 18,
                      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(email,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4))),
                    child: const Text('ADMIN',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                        fontWeight: FontWeight.w700, color: AppColors.primary,
                        letterSpacing: 1.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _DrawerItem(icon: Icons.dashboard_rounded,    label: 'Dashboard',
              route: '/admin',          currentRoute: loc),
            _DrawerItem(icon: Icons.inventory_2_rounded,  label: 'Products',
              route: '/admin/products', currentRoute: loc),
            _DrawerItem(icon: Icons.receipt_long_rounded, label: 'Orders',
              route: '/admin/orders',   currentRoute: loc),
            _DrawerItem(icon: Icons.people_rounded,       label: 'Users',
              route: '/admin/users',    currentRoute: loc),

            const Divider(color: AppColors.border, height: 32, indent: 20, endIndent: 20),

            _DrawerItem(icon: Icons.storefront_rounded, label: 'Back to Store',
              route: '/home', currentRoute: loc, isAccent: true),

            const Spacer(),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Supabase.instance.client.auth.signOut().then((_) {
                    if (context.mounted) context.go('/auth/login');
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentRed.withOpacity(0.3))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.accentRed, size: 18),
                      SizedBox(width: 8),
                      Text('Logout',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w600, color: AppColors.accentRed)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final bool isAccent;

  const _DrawerItem({
    required this.icon, required this.label,
    required this.route, required this.currentRoute,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = currentRoute == route || currentRoute.startsWith('$route/');
    final color = isAccent
        ? AppColors.accentGreen
        : (active ? AppColors.primary : AppColors.textSecondary);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: AppColors.primary.withOpacity(0.25)) : null),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Text(label,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: color)),
          if (active) ...[
            const Spacer(),
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
          ],
        ]),
      ),
    );
  }
}

// ── Admin App Bar ─────────────────────────────────────────────────────────────
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AdminAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  bool _isTopLevel(BuildContext context) {
    try {
      final loc = GoRouterState.of(context).matchedLocation;
      return _topLevelRoutes.contains(loc);
    } catch (_) {
      return true;
    }
  }

  void _handleBack(BuildContext context) {
    // Try GoRouter pop first (works when pushed via context.push)
    if (context.canPop()) {
      context.pop();
      return;
    }
    // Fallback: navigate up based on current route
    try {
      final loc = GoRouterState.of(context).matchedLocation;
      if (loc.startsWith('/admin/products')) {
        context.go('/admin/products');
      } else {
        context.go('/admin');
      }
    } catch (_) {
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop = _isTopLevel(context);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: isTop
          // Hamburger — opens drawer
          ? Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                  child: const Icon(Icons.menu_rounded,
                    color: AppColors.textPrimary, size: 20)),
              ),
            )
          // Back arrow — navigates back
          : GestureDetector(
              onTap: () => _handleBack(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 18)),
            ),
      title: Text(title,
        style: const TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
          fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      actions: actions,
    );
  }
}