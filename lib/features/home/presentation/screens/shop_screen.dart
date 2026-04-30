// lib/features/home/presentation/screens/shop_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/market_config.dart';
import '../../../../core/constants/product_taxonomy.dart';
import '../../../../core/services/market_preference_service.dart';
import '../../../../core/services/product_service.dart';
import '../theme/home_tokens.dart';
import '../widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;

  String _selectedCategory = 'All';
  String _selectedSubCategory = 'All';
  String _selectedBrand = 'All Brands';

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  List<String> get _categories {
    final countryCode = MarketPreferenceService.customerCountryCode;

    return [
      'All',
      ...MarketConfig.allowedCategories(
        countryCode: countryCode,
        categories: ProductTaxonomy.categories,
      ),
    ];
  }

  List<String> get _subCategories {
    if (_selectedCategory == 'All') {
      return const ['All'];
    }

    return [
      'All',
      ...ProductTaxonomy.subcategoriesFor(_selectedCategory),
    ];
  }

  List<String> get _brands {
    final productsForSelectedFilters = _allProducts.where((product) {
      final category = product['category']?.toString() ?? '';
      final subCategory = product['sub_category']?.toString() ?? 'General';

      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;

      final matchesSubCategory =
          _selectedSubCategory == 'All' || subCategory == _selectedSubCategory;

      return matchesCategory && matchesSubCategory;
    }).toList();

    final brands = productsForSelectedFilters
        .map((product) => product['company_name']?.toString().trim() ?? '')
        .where((brand) => brand.isNotEmpty)
        .toSet()
        .toList();

    brands.sort();

    return [
      'All Brands',
      ...brands,
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
    });

    try {
      final products = await ProductService.getAllActive();

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _loading = false;
      });

      _applyFilters();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _allProducts = [];
        _filteredProducts = [];
        _loading = false;
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = 'All';
      _selectedBrand = 'All Brands';
    });

    _applyFilters();
  }

  void _selectSubCategory(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
      _selectedBrand = 'All Brands';
    });

    _applyFilters();
  }

  void _selectBrand(String brand) {
    setState(() {
      _selectedBrand = brand;
    });

    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = _allProducts.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final company = product['company_name']?.toString().toLowerCase() ?? '';
      final category = product['category']?.toString() ?? '';
      final subCategory = product['sub_category']?.toString() ?? 'General';
      final description =
          product['description']?.toString().toLowerCase() ?? '';

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          company.contains(query) ||
          category.toLowerCase().contains(query) ||
          subCategory.toLowerCase().contains(query) ||
          description.contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;

      final matchesSubCategory =
          _selectedSubCategory == 'All' || subCategory == _selectedSubCategory;

      final matchesBrand = _selectedBrand == 'All Brands' ||
          company == _selectedBrand.toLowerCase();

      return matchesSearch &&
          matchesCategory &&
          matchesSubCategory &&
          matchesBrand;
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = MarketPreferenceService.customerCountry;
    final currency = MarketPreferenceService.customerCurrency;

    return Scaffold(
      backgroundColor: HomeTokens.linen,
      body: Container(
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
          child: RefreshIndicator(
            color: HomeTokens.text,
            backgroundColor: HomeTokens.linen,
            onRefresh: _loadProducts,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHOP\n${country.name.toUpperCase()}',
                          style: HomeTokens.displayLarge().copyWith(
                            fontSize: 46,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1.2,
                          width: double.infinity,
                          color: HomeTokens.text,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${country.flag} Products for ${country.name}. Prices shown in ${currency.code}.',
                          style: HomeTokens.body(size: 14),
                        ),
                        const SizedBox(height: 28),
                        _SearchField(
                          controller: _searchCtrl,
                          onChanged: (_) => _applyFilters(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterList(
                    title: 'Category',
                    items: _categories,
                    selected: _selectedCategory,
                    onSelected: _selectCategory,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterList(
                    title: 'Product Type',
                    items: _subCategories,
                    selected: _selectedSubCategory,
                    onSelected: _selectSubCategory,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterList(
                    title: 'Brand',
                    items: _brands,
                    selected: _selectedBrand,
                    onSelected: _selectBrand,
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: HomeTokens.text,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyShop(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      HomeTokens.pagePadding,
                      16,
                      HomeTokens.pagePadding,
                      40,
                    ),
                    sliver: SliverGrid.builder(
                      itemCount: _filteredProducts.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: _filteredProducts[index],
                          compact: true,
                        );
                      },
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: HomeTokens.text,
      textInputAction: TextInputAction.search,
      style: HomeTokens.displayMedium().copyWith(
        fontSize: 28,
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hintText: 'Search products...',
        hintStyle: HomeTokens.displayMedium(
          color: const Color(0xFFB8B8B8),
        ).copyWith(
          fontSize: 28,
          letterSpacing: 0.2,
        ),
        suffixIcon: controller.text.isEmpty
            ? const Icon(
          Icons.search_rounded,
          color: HomeTokens.text,
        )
            : IconButton(
          onPressed: () {
            controller.clear();
            onChanged('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: HomeTokens.text,
          ),
        ),
        contentPadding: const EdgeInsets.only(bottom: 10),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: HomeTokens.text, width: 1.2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: HomeTokens.text, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: HomeTokens.text, width: 1.6),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _FilterList extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterList({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 74,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeTokens.pagePadding,
              ),
              child: Text(
                title.toUpperCase(),
                style: HomeTokens.label(
                  color: HomeTokens.text,
                  size: 9,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeTokens.pagePadding,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final active = selected == item;

                  return GestureDetector(
                    onTap: () => onSelected(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? HomeTokens.text : Colors.transparent,
                        border: Border.all(color: HomeTokens.text),
                      ),
                      child: Center(
                        child: Text(
                          item.toUpperCase(),
                          style: HomeTokens.label(
                            color:
                            active ? HomeTokens.linen : HomeTokens.text,
                            size: 9,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShop extends StatelessWidget {
  const _EmptyShop();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              color: HomeTokens.text,
              size: 58,
            ),
            const SizedBox(height: 18),
            Text(
              'NO PRODUCTS',
              style: HomeTokens.displayMedium().copyWith(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'No products found for this country or filter.',
              textAlign: TextAlign.center,
              style: HomeTokens.body(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}