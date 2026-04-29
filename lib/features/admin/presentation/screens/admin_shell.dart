// lib/features/admin/presentation/screens/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../bloc/product_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../theme/admin_tokens.dart';
import '../widgets/admin_ui.dart';

const _topLevelRoutes = {
  '/admin',
  '/admin/products',
  '/admin/orders',
  '/admin/users',
};

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(),
      child: Scaffold(
        backgroundColor: AdminTokens.linen,
        drawer: const _AdminDrawer(),
        body: child,
      ),
    );
  }
}

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoon(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
    );
  }
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoon(
      label: 'Users',
      icon: Icons.people_outline_rounded,
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ComingSoon({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTokens.linen,
      appBar: AdminAppBar(title: label),
      body: AdminPage(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AdminTokens.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: AdminTokens.text,
                  size: 62,
                ),
                const SizedBox(height: 22),
                Text(
                  label.toUpperCase(),
                  style: AdminTokens.displayLarge(size: 42),
                ),
                const SizedBox(height: 10),
                Text(
                  'Coming soon',
                  style: AdminTokens.body(size: 15),
                ),
                const SizedBox(height: 34),
                AdminPrimaryButton(
                  text: 'Back to Dashboard',
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.go('/admin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
  });

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

  void _openDrawer(BuildContext context) {
    final rootScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
    rootScaffold?.openDrawer();
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: AdminTokens.linen,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leadingWidth: 58,
      leading: Builder(
        builder: (buttonContext) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isTop) {
                _openDrawer(buttonContext);
              } else {
                _handleBack(context);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminTokens.card,
                border: Border.all(color: AdminTokens.border),
              ),
              child: Icon(
                isTop ? Icons.menu_rounded : Icons.arrow_back_rounded,
                color: AdminTokens.text,
                size: 22,
              ),
            ),
          );
        },
      ),
      title: Text(
        title.toUpperCase(),
        style: AdminTokens.title(size: 22),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AdminTokens.border,
        ),
      ),
      actions: actions,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) {
        return const AdminConfirmDialog(
          title: 'Sign Out',
          message: 'Are you sure you want to sign out from the admin panel?',
          confirmText: 'Sign Out',
          confirmColor: AdminTokens.danger,
        );
      },
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go('/auth/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Admin';

    String currentRoute = '/admin';

    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    return Drawer(
      backgroundColor: AdminTokens.linen,
      child: AdminPage(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AdminTokens.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATHIMART',
                      style: AdminTokens.label(
                        color: AdminTokens.text,
                        size: 11,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ADMIN\nPANEL',
                      style: AdminTokens.displayLarge(size: 38),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTokens.body(size: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _DrawerItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                route: '/admin',
                currentRoute: currentRoute,
              ),
              _DrawerItem(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                route: '/admin/products',
                currentRoute: currentRoute,
              ),
              _DrawerItem(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                route: '/admin/orders',
                currentRoute: currentRoute,
              ),
              _DrawerItem(
                icon: Icons.people_outline_rounded,
                label: 'Users',
                route: '/admin/users',
                currentRoute: currentRoute,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Divider(color: AdminTokens.border),
              ),

              _DrawerItem(
                icon: Icons.storefront_outlined,
                label: 'Back to Store',
                route: '/home',
                currentRoute: currentRoute,
                accent: true,
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(20),
                child: AdminOutlineButton(
                  text: 'Sign Out',
                  icon: Icons.logout_rounded,
                  color: AdminTokens.danger,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final bool accent;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = currentRoute == route || currentRoute.startsWith('$route/');
    final color = accent
        ? AdminTokens.success
        : active
        ? AdminTokens.text
        : AdminTokens.darkGray;

    return Material(
      color: active ? AdminTokens.text : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        child: Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? AdminTokens.text : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: active ? AdminTokens.linen : color,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AdminTokens.label(
                    color: active ? AdminTokens.linen : color,
                    size: 10,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 24,
                  height: 1,
                  color: AdminTokens.linen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}