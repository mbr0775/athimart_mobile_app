// ============================================================
// ATHIMART HOME SCREEN — Editorial Fashion Redesign
// Matches the web app's linen/dark aesthetic:
//   - Background: #F2EDE7 (linen)
//   - Text: #171717 (near black)
//   - Accent: border lines, not gradients
//   - Typography: Oswald-style uppercase labels + Poppins body
//   - Cards: flat, image-first, grayscale-border style
// ============================================================
//
// USAGE: Replace your existing home_screen.dart with this file.
// Make sure you have these packages in pubspec.yaml:
//   google_fonts: ^6.x
//   cached_network_image: ^3.x
//   supabase_flutter: ^2.x
//   flutter_bloc: ^8.x
//
// This file contains:
//   1. Design tokens (_AT class)
//   2. HomeScreen (full replacement)
//   3. All section widgets redesigned:
//      - _AthimartHeroBanner
//      - HomeBannerSlider (New Arrivals)
//      - HomeCategoryGrid (Collections)
//      - HomeFlashSale
//      - HomeFeaturedProducts (Featured Pieces)
//      - HomeTopVendors
//      - HomeNewArrivals (Lookbook)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

// ── You'll keep these imports from your existing project ──
// import '../../../auth/presentation/bloc/auth_bloc.dart';
// import '../../../auth/presentation/bloc/auth_event.dart';
// import '../../../auth/presentation/bloc/auth_state.dart' as app_auth;
// import '../../../cart/presentation/bloc/cart_bloc.dart';
// import '../../../cart/presentation/bloc/cart_state.dart';
// import '../../../cart/presentation/screens/cart_screen.dart';
// import '../../../../core/services/product_service.dart';
// import '../../../cart/presentation/bloc/cart_event.dart';
// import '../../../cart/data/cart_item.dart';

// ============================================================
// DESIGN TOKENS — matches web config
// ============================================================
class _AT {
  // Colors
  static const Color linen = Color(0xFFF2EDE7);
  static const Color text = Color(0xFF171717);
  static const Color darkGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFF888888);
  static const Color border = Color(0xFFE8E3DD);
  static const Color card = Color(0xFFEDE8E2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Spacing
  static const double pageH = 20.0;
  static const double sectionGap = 40.0;

  // Typography helpers
  static TextStyle displayLg({Color? color, FontWeight? weight}) =>
      GoogleFonts.oswald(
        fontSize: 32,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? text,
        letterSpacing: 2,
        height: 1.0,
      );

  static TextStyle displayMd({Color? color, FontWeight? weight}) =>
      GoogleFonts.oswald(
        fontSize: 24,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? text,
        letterSpacing: 1.5,
        height: 1.0,
      );

  static TextStyle displaySm({Color? color, FontWeight? weight}) =>
      GoogleFonts.oswald(
        fontSize: 18,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? text,
        letterSpacing: 1,
      );

  static TextStyle label({Color? color}) =>
      GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: color ?? lightGray,
        letterSpacing: 2.5,
      );

  static TextStyle body({Color? color, double size = 13}) =>
      GoogleFonts.poppins(
        fontSize: size,
        color: color ?? darkGray,
        height: 1.6,
      );

  static TextStyle bodyBold({Color? color, double size = 13}) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? text,
      );

  static TextStyle price({Color? color}) =>
      GoogleFonts.oswald(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color ?? text,
        letterSpacing: 0.5,
      );
}

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _AT.linen,
      body: _buildBody(),
      bottomNavigationBar: _AthimartBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 2:
        // return const CartScreen();
        return _PlaceholderPage(label: 'CART');
      default:
        if (_currentNavIndex != 0) {
          return _PlaceholderPage(
            label: ['HOME', 'SHOP', 'CART', 'ORDERS', 'PROFILE'][_currentNavIndex],
          );
        }
        return _HomeBody(
          searchController: _searchController,
          onCartTap: () => setState(() => _currentNavIndex = 2),
        );
    }
  }
}

// ============================================================
// HOME BODY
// ============================================================
class _HomeBody extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onCartTap;

  const _HomeBody({required this.searchController, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = user?.userMetadata?['full_name']
        ?.toString()
        .split(' ')
        .first ?? 'there';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sticky Header ────────────────────────────────────
        SliverAppBar(
          pinned: true,
          floating: false,
          snap: false,
          expandedHeight: 120,
          collapsedHeight: 56 + MediaQuery.of(context).padding.top,
          backgroundColor: _AT.linen,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final expanded = 120.0 + MediaQuery.of(context).padding.top;
              final collapsed = 56.0 + MediaQuery.of(context).padding.top;
              final progress = ((expanded - constraints.maxHeight) /
                  (expanded - collapsed)).clamp(0.0, 1.0);
              final isCompact = progress > 0.6;

              return Container(
                color: _AT.linen,
                child: SafeArea(
                  bottom: false,
                  child: isCompact
                      ? _CompactHeader(onCartTap: onCartTap)
                      : _ExpandedHeader(
                    firstName: firstName,
                    searchController: searchController,
                    onCartTap: onCartTap,
                  ),
                ),
              );
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _AT.border),
          ),
        ),

        // ── Page Content ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Hero Banner
              const _AthimartHeroBanner(),
              const SizedBox(height: _AT.sectionGap),

              // New Arrivals (Banner Slider)
              _SectionHeader(title: 'NEW ARRIVALS', showAll: true),
              const SizedBox(height: 16),
              const AthimartNewArrivalSlider(),
              const SizedBox(height: _AT.sectionGap),

              // Collections
              _SectionHeader(title: 'COLLECTIONS', showAll: false),
              const SizedBox(height: 16),
              const AthimartCategoryGrid(),
              const SizedBox(height: _AT.sectionGap),

              // Flash Sale Banner
              const _FlashSaleBanner(),
              const SizedBox(height: 8),
              const AthimartFlashSale(),
              const SizedBox(height: _AT.sectionGap),

              // Featured Pieces
              _SectionHeader(title: 'FEATURED PIECES', showAll: true),
              const SizedBox(height: 16),
              const AthimartFeaturedProducts(),
              const SizedBox(height: _AT.sectionGap),

              // Sustainable Banner
              const _SustainableBanner(),
              const SizedBox(height: _AT.sectionGap),

              // Top Vendors
              _SectionHeader(title: 'TOP VENDORS', showAll: true),
              const SizedBox(height: 16),
              const AthimartTopVendors(),
              const SizedBox(height: _AT.sectionGap),

              // Lookbook
              _SectionHeader(title: 'LOOKBOOK', showAll: true),
              const SizedBox(height: 16),
              const AthimartLookbook(),
              const SizedBox(height: _AT.sectionGap),

              // Vendor CTA
              const _VendorCTA(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HEADER VARIANTS
// ============================================================
class _ExpandedHeader extends StatefulWidget {
  final String firstName;
  final TextEditingController searchController;
  final VoidCallback onCartTap;

  const _ExpandedHeader({
    required this.firstName,
    required this.searchController,
    required this.onCartTap,
  });

  @override
  State<_ExpandedHeader> createState() => _ExpandedHeaderState();
}

class _ExpandedHeaderState extends State<_ExpandedHeader> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_AT.pageH, 6, _AT.pageH, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SS26 LOOKBOOK', style: _AT.label()),
                    const SizedBox(height: 2),
                    Text('ATHIMART', style: _AT.displayLg()),
                  ],
                ),
              ),
              _HeaderActions(onCartTap: widget.onCartTap),
            ],
          ),
          const SizedBox(height: 10),
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: _focused ? _AT.text : _AT.border,
                width: _focused ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded,
                    size: 17,
                    color: _focused ? _AT.text : _AT.lightGray),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    onTap: () => setState(() => _focused = true),
                    onTapOutside: (_) => setState(() => _focused = false),
                    style: _AT.body(color: _AT.text, size: 12),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search fabrics, collections...',
                      hintStyle: _AT.body(color: _AT.lightGray, size: 12),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 32,
                  color: _AT.text,
                  child: const Icon(Icons.tune_rounded, size: 14, color: _AT.linen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final VoidCallback onCartTap;
  const _CompactHeader({required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_AT.pageH, 10, _AT.pageH, 10),
      child: Row(
        children: [
          Text('ATHIMART', style: _AT.displayMd()),
          const Spacer(),
          _HeaderActions(onCartTap: onCartTap),
        ],
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onCartTap;
  const _HeaderActions({required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MinimalIconBtn(icon: Icons.notifications_outlined, onTap: () {}),
        const SizedBox(width: 6),
        _MinimalIconBtn(icon: Icons.shopping_bag_outlined, badge: 0, onTap: onCartTap),
        const SizedBox(width: 6),
        _MinimalIconBtn(
          icon: Icons.logout_rounded,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _AT.linen,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIGN OUT', style: _AT.displaySm()),
              const SizedBox(height: 8),
              Container(height: 1, color: _AT.border),
              const SizedBox(height: 16),
              Text('You will be returned to the login screen.', style: _AT.body()),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: _AT.border)),
                        child: Center(child: Text('CANCEL', style: _AT.label(color: _AT.darkGray))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        Supabase.instance.client.auth.signOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: _AT.text,
                        child: Center(child: Text('SIGN OUT', style: _AT.label(color: _AT.linen))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinimalIconBtn extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;
  const _MinimalIconBtn({required this.icon, this.badge = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(border: Border.all(color: _AT.border)),
            child: Icon(icon, color: _AT.text, size: 17),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: _AT.text, shape: BoxShape.circle),
                child: Center(
                  child: Text('$badge',
                      style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: _AT.linen)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showAll;
  const _SectionHeader({required this.title, this.showAll = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: _AT.displayMd()),
                const SizedBox(height: 8),
                Container(height: 1, color: _AT.border),
              ],
            ),
          ),
          if (showAll) ...[
            const SizedBox(width: 16),
            Row(
              children: [
                Text('VIEW ALL', style: _AT.label(color: _AT.darkGray)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 12, color: _AT.darkGray),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// HERO BANNER
// ============================================================
class _AthimartHeroBanner extends StatelessWidget {
  const _AthimartHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: Container(
        height: 400,
        width: double.infinity,
        color: const Color(0xFFDDD8D0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Watermark text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ATHI',
                      style: GoogleFonts.oswald(
                          fontSize: 68,
                          fontWeight: FontWeight.w300,
                          color: _AT.text.withOpacity(0.12),
                          letterSpacing: 8,
                          height: 0.9)),
                  Text('MART',
                      style: GoogleFonts.oswald(
                          fontSize: 68,
                          fontWeight: FontWeight.w700,
                          color: _AT.text.withOpacity(0.12),
                          letterSpacing: 8,
                          height: 0.9)),
                ],
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, _AT.text.withOpacity(0.55)],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SS26 LOOKBOOK', style: _AT.label(color: _AT.linen.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Text('Fashion textiles,\ndesigned to drape.',
                      style: GoogleFonts.oswald(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: _AT.linen,
                          height: 1.2)),
                  const SizedBox(height: 16),
                  _AthimartCTA(label: 'EXPLORE THE COLLECTION', light: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CTA BUTTON
// ============================================================
class _AthimartCTA extends StatelessWidget {
  final String label;
  final bool light;
  const _AthimartCTA({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? _AT.linen : _AT.text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _AT.label(color: color)),
        const SizedBox(width: 8),
        Container(width: 24, height: 1, color: color.withOpacity(0.6)),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward, size: 12, color: color),
      ],
    );
  }
}

// ============================================================
// NEW ARRIVALS SLIDER  (replaces HomeBannerSlider)
// ============================================================
class AthimartNewArrivalSlider extends StatefulWidget {
  const AthimartNewArrivalSlider({super.key});

  @override
  State<AthimartNewArrivalSlider> createState() => _AthimartNewArrivalSliderState();
}

class _AthimartNewArrivalSliderState extends State<AthimartNewArrivalSlider> {
  final PageController _ctrl = PageController(viewportFraction: 0.72);
  int _current = 0;
  Timer? _timer;

  final List<_SlideItem> _slides = const [
    _SlideItem(
      tag: 'COLLECTION',
      title: 'Silk & Sheer',
      subtitle: 'Ethereal fabrics for elegant designs',
      emoji: '🌸',
      bgColor: Color(0xFFE8E0D8),
    ),
    _SlideItem(
      tag: 'NEW ARRIVAL',
      title: 'Tailored Wool',
      subtitle: 'Structured sophistication',
      emoji: '🧵',
      bgColor: Color(0xFFDED6CC),
    ),
    _SlideItem(
      tag: 'FEATURED',
      title: 'Silk Blouse',
      subtitle: 'Fluid drape, day-to-night',
      emoji: '✨',
      bgColor: Color(0xFFE4DDD5),
    ),
    _SlideItem(
      tag: 'LOOKBOOK',
      title: 'Runway Motion',
      subtitle: 'See fabric in action',
      emoji: '🎬',
      bgColor: Color(0xFFD8D0C8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_current + 1) % _slides.length;
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _NewArrivalCard(slide: _slides[i]),
          ),
        ),
        const SizedBox(height: 14),
        // Dot indicator — editorial style
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _current ? 24 : 6,
            height: 1,
            color: i == _current ? _AT.text : _AT.border,
          )),
        ),
      ],
    );
  }
}

class _SlideItem {
  final String tag, title, subtitle, emoji;
  final Color bgColor;
  const _SlideItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.bgColor,
  });
}

class _NewArrivalCard extends StatelessWidget {
  final _SlideItem slide;
  const _NewArrivalCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: slide.bgColor,
      child: Stack(
        children: [
          // Large emoji watermark
          Positioned(
            right: -10,
            top: -10,
            child: Text(slide.emoji,
                style: const TextStyle(fontSize: 120)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(slide.tag, style: _AT.label()),
                const SizedBox(height: 6),
                Text(slide.title,
                    style: GoogleFonts.oswald(
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        color: _AT.text,
                        height: 1.1)),
                const SizedBox(height: 4),
                Text(slide.subtitle, style: _AT.body(size: 11)),
                const SizedBox(height: 14),
                _AthimartCTA(label: 'SHOP NOW'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COLLECTIONS GRID  (replaces HomeCategoryGrid)
// ============================================================
class AthimartCategoryGrid extends StatelessWidget {
  const AthimartCategoryGrid({super.key});

  static const _cats = [
    _CatItem('IT Solutions', '💻', 'Software & ERP'),
    _CatItem('AI Gadgets', '🤖', 'Smart Devices'),
    _CatItem('Fitness Tech', '💪', 'Gym & Sports'),
    _CatItem('Essences', '🌿', 'Oud & Oils'),
    _CatItem('Agarwood', '🪵', 'Premium Export'),
    _CatItem('Fashion', '👗', 'Clothing'),
    _CatItem('Vehicles', '🚗', 'Buy & Sell'),
    _CatItem('Real Estate', '🏠', 'Land & Property'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
        itemCount: _cats.length,
        itemBuilder: (_, i) => _CategoryTile(cat: _cats[i]),
      ),
    );
  }
}

class _CatItem {
  final String name, emoji, tag;
  const _CatItem(this.name, this.emoji, this.tag);
}

class _CategoryTile extends StatelessWidget {
  final _CatItem cat;
  const _CategoryTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Square tile with border
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: _AT.border),
                color: _AT.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 26)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: _AT.body(size: 9, color: _AT.darkGray)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FLASH SALE BANNER
// ============================================================
class _FlashSaleBanner extends StatefulWidget {
  const _FlashSaleBanner();

  @override
  State<_FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<_FlashSaleBanner> {
  int _h = 4, _m = 38, _s = 12;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_s > 0) { _s--; }
        else if (_m > 0) { _m--; _s = 59; }
        else if (_h > 0) { _h--; _m = 59; _s = 59; }
      });
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: _AT.text,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FLASH SALE',
                      style: GoogleFonts.oswald(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: _AT.linen,
                          letterSpacing: 2,
                          height: 1.0)),
                  const SizedBox(height: 6),
                  Text('Limited-time offers on\nselected fabric pieces.',
                      style: _AT.body(color: _AT.lightGray, size: 11)),
                  const SizedBox(height: 14),
                  _AthimartCTA(label: 'SHOP NOW', light: true),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ENDS IN',
                    style: _AT.label(color: _AT.lightGray)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _TimeBox('${_h.toString().padLeft(2, '0')}'),
                    Text(':', style: GoogleFonts.oswald(fontSize: 18, color: _AT.lightGray)),
                    _TimeBox('${_m.toString().padLeft(2, '0')}'),
                    Text(':', style: GoogleFonts.oswald(fontSize: 18, color: _AT.lightGray)),
                    _TimeBox('${_s.toString().padLeft(2, '0')}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  const _TimeBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: _AT.linen.withOpacity(0.2)),
      ),
      child: Text(value,
          style: GoogleFonts.oswald(
              fontSize: 18, fontWeight: FontWeight.w300, color: _AT.linen)),
    );
  }
}

// ============================================================
// FLASH SALE PRODUCTS  (replaces HomeFlashSale)
// ============================================================
class AthimartFlashSale extends StatefulWidget {
  const AthimartFlashSale({super.key});

  @override
  State<AthimartFlashSale> createState() => _AthimartFlashSaleState();
}

class _AthimartFlashSaleState extends State<AthimartFlashSale> {
  // Mock data – replace with real Supabase fetch
  final List<Map<String, dynamic>> _products = [
    {'name': 'Smart AI Watch Pro', 'category': 'AI Gadgets', 'price': 89.99, 'originalPrice': 149.99, 'discount': 40, 'emoji': '⌚'},
    {'name': 'Oud Royal Collection', 'category': 'Essences', 'price': 45.00, 'originalPrice': 75.00, 'discount': 40, 'emoji': '🌹'},
    {'name': 'Fitness Tracker X3', 'category': 'Fitness Tech', 'price': 59.99, 'originalPrice': 99.99, 'discount': 40, 'emoji': '📊'},
    {'name': 'Smart Home Hub', 'category': 'AI Gadgets', 'price': 129.99, 'originalPrice': 199.99, 'discount': 35, 'emoji': '🏠'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
        itemCount: _products.length,
        itemBuilder: (_, i) => _FlashCard(product: _products[i]),
      ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _FlashCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      margin: const EdgeInsets.only(right: 12),
      color: _AT.card,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Container(
                height: 150,
                width: double.infinity,
                color: const Color(0xFFD8D2CA),
                child: Center(
                  child: Text(product['emoji'],
                      style: const TextStyle(fontSize: 62)),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['category'],
                        style: _AT.label(color: _AT.lightGray)),
                    const SizedBox(height: 2),
                    Text(product['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _AT.bodyBold(size: 12, color: _AT.text)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product['originalPrice'].toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _AT.lightGray,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text('\$${product['price'].toStringAsFixed(0)}',
                                style: _AT.price()),
                          ],
                        ),
                        // Add button
                        Container(
                          width: 32,
                          height: 32,
                          color: _AT.text,
                          child: const Icon(Icons.add_rounded,
                              size: 16, color: _AT.linen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Discount badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: _AT.text,
              child: Text('-${product['discount']}%',
                  style: _AT.label(color: _AT.linen)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEATURED PRODUCTS  (replaces HomeFeaturedProducts)
// ============================================================
class AthimartFeaturedProducts extends StatefulWidget {
  const AthimartFeaturedProducts({super.key});

  @override
  State<AthimartFeaturedProducts> createState() => _AthimartFeaturedProductsState();
}

class _AthimartFeaturedProductsState extends State<AthimartFeaturedProducts> {
  // Mock data — replace with real Supabase fetch
  final List<Map<String, dynamic>> _products = [
    {'name': 'Sandalwood Premium Oil', 'category': 'Essences', 'price': 35.00, 'isNew': true, 'emoji': '🌸'},
    {'name': 'ERP Business Suite', 'category': 'IT Solutions', 'price': 299.00, 'isNew': false, 'emoji': '📊'},
    {'name': 'Smart Gym Mirror', 'category': 'Fitness Tech', 'price': 199.99, 'isNew': true, 'emoji': '🪞'},
    {'name': 'Frankincense Resin', 'category': 'Essences', 'price': 22.00, 'isNew': false, 'emoji': '✨'},
    {'name': 'AI Noise-Cancel Buds', 'category': 'AI Gadgets', 'price': 79.99, 'isNew': true, 'emoji': '🎧'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
        itemCount: _products.length,
        itemBuilder: (_, i) => _FeaturedCard(product: _products[i]),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _FeaturedCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      color: _AT.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image — tall ratio
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: _AT.card,
                child: Center(
                  child: Text(product['emoji'],
                      style: const TextStyle(fontSize: 72)),
                ),
              ),
              if (product['isNew'] == true)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: _AT.text,
                    child: Text('NEW', style: _AT.label(color: _AT.linen)),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _AT.linen.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded,
                      size: 14, color: _AT.darkGray),
                ),
              ),
            ],
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['category'],
                    style: _AT.label(color: _AT.lightGray)),
                const SizedBox(height: 2),
                Text(product['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _AT.bodyBold(size: 12, color: _AT.text)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product['price'].toStringAsFixed(2)}',
                        style: _AT.price()),
                    Container(
                      width: 30,
                      height: 30,
                      color: _AT.text,
                      child: const Icon(Icons.add_shopping_cart_rounded,
                          size: 14, color: _AT.linen),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUSTAINABLE TEXTILES BANNER
// ============================================================
class _SustainableBanner extends StatelessWidget {
  const _SustainableBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _AT.card,
          border: Border.all(color: _AT.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SUSTAINABLE\nTEXTILES',
                style: GoogleFonts.oswald(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: _AT.text,
                    letterSpacing: 1.5,
                    height: 1.1)),
            const SizedBox(height: 12),
            Container(height: 1, color: _AT.border),
            const SizedBox(height: 12),
            Text(
              'We believe in fashion that respects both the craft and the planet. '
                  'Ethically sourced materials and eco-friendly production.',
              style: _AT.body(size: 12, color: _AT.darkGray),
            ),
            const SizedBox(height: 16),
            _AthimartCTA(label: 'READ OUR STORY'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOP VENDORS  (replaces HomeTopVendors)
// ============================================================
class AthimartTopVendors extends StatelessWidget {
  const AthimartTopVendors({super.key});

  static const _vendors = [
    _VendorItem('Goviceylon', 'Agarwood Exports', 4.9, 48, '🪵'),
    _VendorItem('TechNova', 'AI Gadgets', 4.8, 124, '🤖'),
    _VendorItem('NaturalCeylon', 'Essences & Oils', 4.9, 67, '🌿'),
    _VendorItem('FitZone Pro', 'Fitness Tech', 4.7, 89, '💪'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
        itemCount: _vendors.length,
        itemBuilder: (_, i) => _VendorCard(vendor: _vendors[i]),
      ),
    );
  }
}

class _VendorItem {
  final String name, category, emoji;
  final double rating;
  final int count;
  const _VendorItem(this.name, this.category, this.rating, this.count, this.emoji);
}

class _VendorCard extends StatelessWidget {
  final _VendorItem vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AT.white,
        border: Border.all(color: _AT.border),
      ),
      child: Row(
        children: [
          // Avatar box
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _AT.card,
              border: Border.all(color: _AT.border),
            ),
            child: Center(
              child: Text(vendor.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vendor.name, style: _AT.bodyBold(size: 13, color: _AT.text)),
                const SizedBox(height: 2),
                Text(vendor.category, style: _AT.body(size: 10, color: _AT.lightGray)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: _AT.text),
                    const SizedBox(width: 3),
                    Text('${vendor.rating}',
                        style: _AT.bodyBold(size: 11, color: _AT.text)),
                    const SizedBox(width: 8),
                    Text('${vendor.count} items',
                        style: _AT.body(size: 10, color: _AT.lightGray)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOOKBOOK GRID  (replaces HomeNewArrivals)
// ============================================================
class AthimartLookbook extends StatefulWidget {
  const AthimartLookbook({super.key});

  @override
  State<AthimartLookbook> createState() => _AthimartLookbookState();
}

class _AthimartLookbookState extends State<AthimartLookbook> {
  // Mock data — replace with real Supabase fetch
  final List<Map<String, dynamic>> _items = [
    {'name': 'Rose Otto Pure Oil', 'category': 'Essences', 'price': 55.00, 'emoji': '🌹'},
    {'name': 'Smart Security Cam', 'category': 'AI Gadgets', 'price': 69.99, 'emoji': '📸'},
    {'name': 'Agarwood Bracelet', 'category': 'Agarwood', 'price': 120.00, 'emoji': '📿'},
    {'name': 'Yoga Smart Mat', 'category': 'Fitness Tech', 'price': 89.99, 'emoji': '🧘'},
    {'name': 'Premium Oud Oil', 'category': 'Essences', 'price': 95.00, 'emoji': '🌸'},
    {'name': 'AI Fitness Coach', 'category': 'AI Gadgets', 'price': 149.99, 'emoji': '🏋️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.68,
        ),
        itemCount: _items.length,
        itemBuilder: (_, i) => _LookbookCard(product: _items[i]),
      ),
    );
  }
}

class _LookbookCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _LookbookCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _AT.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image — portrait ratio
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: _AT.card,
                  child: Center(
                    child: Text(product['emoji'],
                        style: const TextStyle(fontSize: 56)),
                  ),
                ),
                // NEW badge
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    color: _AT.text,
                    child: Text('NEW', style: _AT.label(color: _AT.linen)),
                  ),
                ),
                // Wishlist
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: _AT.linen.withOpacity(0.8),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 12, color: _AT.darkGray),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['category'],
                    style: _AT.label(color: _AT.lightGray)),
                const SizedBox(height: 2),
                Text(product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _AT.bodyBold(size: 11, color: _AT.text)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product['price'].toStringAsFixed(0)}',
                        style: _AT.price(color: _AT.text)),
                    Container(
                      width: 28,
                      height: 28,
                      color: _AT.text,
                      child: const Icon(Icons.add_rounded,
                          size: 14, color: _AT.linen),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VENDOR CTA BANNER
// ============================================================
class _VendorCTA extends StatelessWidget {
  const _VendorCTA();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _AT.pageH),
      child: Container(
        padding: const EdgeInsets.all(24),
        color: _AT.text,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("LET'S BUILD YOUR\nNEXT COLLECTION.",
                      style: GoogleFonts.oswald(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: _AT.linen,
                          height: 1.2)),
                  const SizedBox(height: 10),
                  Text('Sell globally across Gulf,\nSri Lanka & Europe.',
                      style: _AT.body(color: _AT.lightGray, size: 11)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: _AT.linen.withOpacity(0.5)),
                    ),
                    child: Text('BECOME A VENDOR',
                        style: _AT.label(color: _AT.linen)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text('A',
                style: GoogleFonts.oswald(
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                    color: _AT.linen.withOpacity(0.08),
                    height: 1)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================
class _AthimartBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _AthimartBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _AT.linen,
        border: Border(top: BorderSide(color: _AT.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                  label: 'HOME', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded,
                  label: 'SHOP', index: 1, current: currentIndex, onTap: onTap),
              _CartNavItem(current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded,
                  label: 'ORDERS', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                  label: 'PROFILE', index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final void Function(int) onTap;
  const _NavItem({required this.icon, required this.activeIcon,
    required this.label, required this.index,
    required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: isActive ? 1 : 0,
              color: _AT.text,
              margin: const EdgeInsets.only(bottom: 4),
            ),
            Icon(isActive ? activeIcon : icon,
                size: 20, color: isActive ? _AT.text : _AT.lightGray),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? _AT.text : _AT.lightGray,
                  letterSpacing: 1,
                )),
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int current;
  final void Function(int) onTap;
  const _CartNavItem({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == 2;
    // Replace with BlocBuilder<CartBloc, CartState> for real cart count
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 48,
        height: 48,
        color: isActive ? _AT.text : _AT.card,
        child: Icon(Icons.shopping_bag_outlined,
            color: isActive ? _AT.linen : _AT.text, size: 20),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER PAGE
// ============================================================
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AT.linen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 64, height: 1, color: _AT.text),
            const SizedBox(height: 24),
            Text(label,
                style: GoogleFonts.oswald(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: _AT.text,
                    letterSpacing: 4)),
            const SizedBox(height: 12),
            Text('Coming in next phase.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _AT.lightGray, letterSpacing: 1)),
            const SizedBox(height: 24),
            Container(width: 64, height: 1, color: _AT.border),
          ],
        ),
      ),
    );
  }
}