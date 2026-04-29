// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _lineWidth = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.35,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        if (!mounted) return;

        final role = profile?['role']?.toString() ?? 'customer';

        if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } catch (_) {
        if (!mounted) return;
        context.go('/home');
      }

      return;
    }

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
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
    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: _SplashTokens.text,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: _SplashTokens.linen,
        body: Container(
          decoration: const BoxDecoration(
            gradient: _SplashTokens.pageGradient,
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;

                final bool compact = height < 720;
                final double horizontalPadding = compact ? 30 : 36;
                final double topGap =
                (height * 0.16).clamp(48.0, 120.0).toDouble();
                final double titleSize = compact ? 39 : 48;
                final double taglineSize = compact ? 12 : 14;
                final double logoSize = compact ? 46 : 52;
                final double bottomSpace = compact ? 22 : 34;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 26),

                              Text(
                                'ATHIMART',
                                style: _SplashTokens.label(
                                  color: _SplashTokens.text,
                                  size: 11,
                                ),
                              ),

                              SizedBox(height: topGap),

                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'WHERE\nTECHNOLOGY\nMEETS\nLIFESTYLE',
                                  style: _SplashTokens.displayLarge(
                                    size: titleSize,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              AnimatedBuilder(
                                animation: _lineWidth,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    widthFactor: _lineWidth.value,
                                    alignment: Alignment.centerLeft,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  height: 1.2,
                                  color: _SplashTokens.text,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                AppStrings.appTagline,
                                style: _SplashTokens.body(
                                  size: taglineSize,
                                ),
                              ),

                              SizedBox(height: compact ? 30 : 42),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: logoSize,
                                    height: logoSize,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _SplashTokens.text,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'A',
                                        style: _SplashTokens.displayMedium(
                                          size: compact ? 25 : 29,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      AppStrings.poweredBy.toUpperCase(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: _SplashTokens.label(size: 9),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: bottomSpace),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashTokens {
  _SplashTokens._();

  static const Color linen = Color(0xFFF2EDE7);
  static const Color softLinen = Color(0xFFF7F2EC);
  static const Color warmLinen = Color(0xFFEEE8E1);
  static const Color text = Color(0xFF171717);
  static const Color darkGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFF888888);

  static const LinearGradient pageGradient = LinearGradient(
    colors: [
      softLinen,
      linen,
      warmLinen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle displayLarge({
    Color color = text,
    double size = 44,
  }) {
    return GoogleFonts.oswald(
      fontSize: size,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 2.3,
      height: 1.05,
    );
  }

  static TextStyle displayMedium({
    Color color = text,
    double size = 28,
  }) {
    return GoogleFonts.oswald(
      fontSize: size,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 1.5,
      height: 1.1,
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
      height: 1.6,
    );
  }
}