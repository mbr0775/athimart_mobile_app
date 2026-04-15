import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Checkout',
          style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22,
            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: Center(
        child: Text('Checkout process here',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
      ),
    );
  }
}
