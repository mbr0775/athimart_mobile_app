// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/services/market_preference_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1400));

    await MarketPreferenceService.load();

    if (!mounted) return;

    if (!MarketPreferenceService.customerConfigured) {
      context.go('/onboarding');
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      context.go('/home');
    } else {
      context.go('/auth/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2EDE7);
    const text = Color(0xFF171717);
    const muted = Color(0xFF555555);

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F2EC),
              Color(0xFFF2EDE7),
              Color(0xFFEEE8E1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        color: text,
                        border: Border.all(
                          color: text,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: GoogleFonts.oswald(
                            color: background,
                            fontSize: 54,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.appName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        color: text,
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1.2,
                      width: 160,
                      color: text,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      AppStrings.poweredBy.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}