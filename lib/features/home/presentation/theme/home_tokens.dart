import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTokens {
  HomeTokens._();

  static const Color linen = Color(0xFFF2EDE7);
  static const Color text = Color(0xFF171717);
  static const Color darkGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFF888888);
  static const Color border = Color(0xFFE8E3DD);
  static const Color card = Color(0xFFEDE8E2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color sale = Color(0xFFB42318);
  static const Color success = Color(0xFF0E7A4F);

  static const double pagePadding = 20;
  static const double sectionGap = 38;

  static TextStyle displayLarge({
    Color color = text,
  }) {
    return GoogleFonts.oswald(
      fontSize: 34,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 2,
      height: 1.05,
    );
  }

  static TextStyle displayMedium({
    Color color = text,
  }) {
    return GoogleFonts.oswald(
      fontSize: 24,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 1.4,
      height: 1.1,
    );
  }

  static TextStyle title({
    Color color = text,
    double size = 18,
  }) {
    return GoogleFonts.oswald(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 1.1,
      height: 1.15,
    );
  }

  static TextStyle label({
    Color color = lightGray,
    double size = 10,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.6,
    );
  }

  static TextStyle body({
    Color color = darkGray,
    double size = 13,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.55,
    );
  }

  static TextStyle bodyBold({
    Color color = text,
    double size = 13,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.35,
    );
  }

  static TextStyle price({
    Color color = text,
    double size = 15,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}