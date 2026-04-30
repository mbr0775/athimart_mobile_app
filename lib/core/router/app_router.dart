// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_add_product.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/admin/presentation/screens/admin_orders.dart';
import '../../features/admin/presentation/screens/admin_products.dart';
import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const SplashScreen(),
          );
        },
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const OnboardingScreen(),
          );
        },
      ),

      GoRoute(
        path: '/auth/login',
        name: 'login',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const LoginScreen(),
          );
        },
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const RegisterScreen(),
          );
        },
      ),

      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const ForgotPasswordScreen(),
          );
        },
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const HomeScreen(),
          );
        },
      ),

      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SearchScreen(),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const AdminShell(
              child: AdminDashboard(),
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const AdminShell(
              child: AdminDashboard(),
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin/products',
        name: 'admin-products',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const AdminShell(
              child: AdminProductsScreen(),
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin/products/add',
        name: 'admin-add-product',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const AdminShell(
              child: AdminAddProductScreen(
                product: null,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin/products/edit',
        name: 'admin-edit-product',
        pageBuilder: (context, state) {
          final product = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;

          return _fadePage(
            state: state,
            child: AdminShell(
              child: AdminAddProductScreen(
                product: product,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin/orders',
        name: 'admin-orders',
        pageBuilder: (context, state) {
          return _fadePage(
            state: state,
            child: const AdminShell(
              child: AdminOrdersManagementScreen(),
            ),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return _fadePage(
        state: state,
        child: _RouteErrorScreen(
          error: state.error?.toString() ?? 'Page not found',
        ),
      );
    },
  );

  static CustomTransitionPage<void> _fadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  final String error;

  const _RouteErrorScreen({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFF171717),
                  size: 48,
                ),
                const SizedBox(height: 18),
                const Text(
                  'PAGE ERROR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Material(
                  color: const Color(0xFF171717),
                  child: InkWell(
                    onTap: () => context.go('/home'),
                    child: const SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'GO HOME',
                          style: TextStyle(
                            color: Color(0xFFF2EDE7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                    ),
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