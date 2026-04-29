// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';

import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/admin/presentation/screens/admin_products.dart';
import '../../features/admin/presentation/screens/admin_add_product.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;

      // Always allow splash and onboarding
      if (loc == '/splash' || loc == '/onboarding') {
        return null;
      }

      // Allow auth pages
      if (loc.startsWith('/auth')) {
        return null;
      }

      // If not logged in, send to login
      if (!isLoggedIn) {
        return '/auth/login';
      }

      // Logged in users can access all other routes
      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),

      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboard(),
          ),

          GoRoute(
            path: '/admin/products',
            builder: (_, __) => const AdminProductsScreen(),
          ),

          GoRoute(
            path: '/admin/products/add',
            builder: (_, __) => const AdminAddProductScreen(product: null),
          ),

          GoRoute(
            path: '/admin/products/edit',
            builder: (_, state) {
              return AdminAddProductScreen(
                product: state.extra as Map<String, dynamic>?,
              );
            },
          ),

          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const AdminUsersScreen(),
          ),

          GoRoute(
            path: '/admin/orders',
            builder: (_, __) => const AdminOrdersScreen(),
          ),
        ],
      ),
    ],
  );
}