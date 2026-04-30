// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../cubit/home_cubit.dart';
import '../theme/home_tokens.dart';
import '../widgets/home_body.dart';
import '../widgets/home_bottom_nav.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _ordersRefreshToken = 0;

  void _openOrdersAfterCheckout() {
    setState(() {
      _ordersRefreshToken++;
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadHomeData(),
      child: Scaffold(
        backgroundColor: HomeTokens.linen,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeBody(),
            const ShopScreen(),
            CartScreen(onOrderPlaced: _openOrdersAfterCheckout),
            OrdersScreen(refreshToken: _ordersRefreshToken),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}