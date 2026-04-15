// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFD4A017);        // Gold
  static const Color primaryDark = Color(0xFFB8860B);    // Dark Gold
  static const Color primaryLight = Color(0xFFFFD700);   // Light Gold

  // Background Colors
  static const Color background = Color(0xFF0A0A0F);     // Near Black
  static const Color surface = Color(0xFF12121A);        // Dark Surface
  static const Color card = Color(0xFF1A1A26);           // Card Background
  static const Color cardElevated = Color(0xFF22223A);   // Elevated Card

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5);    // White
  static const Color textSecondary = Color(0xFFB0B0C0);  // Muted
  static const Color textHint = Color(0xFF606070);       // Hint

  // Accent Colors
  static const Color accent = Color(0xFF6C63FF);         // Purple Accent
  static const Color accentGreen = Color(0xFF00C896);    // Success Green
  static const Color accentRed = Color(0xFFFF4757);      // Error Red
  static const Color accentOrange = Color(0xFFFF6B35);   // Warning Orange

  // Border & Divider
  static const Color border = Color(0xFF2A2A3A);
  static const Color divider = Color(0xFF1E1E2E);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A), Color(0xFF1A1A26)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A26), Color(0xFF22223A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}