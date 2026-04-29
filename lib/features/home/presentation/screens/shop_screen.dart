// lib/features/home/presentation/screens/shop_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/product_taxonomy.dart';
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
    return [
      'All',
      ...ProductTaxonomy.categories,
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
    _selectedCategory = category;
    _selectedSubCategory = 'All';
    _selectedBrand = 'All Brands';
    _applyFilters();
  }

  void _selectSubCategory(String subCategory) {
    _selectedSubCategory = subCategory;
    _selectedBrand = 'All Brands';
    _applyFilters();
  }

  void _selectBrand(String brand) {
    _selectedBrand = brand;
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
                          'SHOP\nPRODUCTS',
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
                          'Filter by category, product type and company brand.',
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
                  child: _FilterSection(
                    title: 'Category',
                    items: _categories,
                    selectedItem: _selectedCategory,
                    onSelected: _selectCategory,
                  ),
                ),

                if (_selectedCategory != 'All') ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: _FilterSection(
                      title: 'Product Type',
                      items: _subCategories,
                      selectedItem: _selectedSubCategory,
                      onSelected: _selectSubCategory,
                    ),
                  ),
                ],

                if (_brands.length > 1) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: _FilterSection(
                      title: 'Company / Brand',
                      items: _brands,
                      selectedItem: _selectedBrand,
                      onSelected: _selectBrand,
                    ),
                  ),
                ],

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 24, 26, 16),
                    child: Row(
                      children: [
                        Text(
                          'PRODUCTS',
                          style: HomeTokens.displayMedium().copyWith(
                            fontSize: 30,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredProducts.length} ITEMS',
                          style: HomeTokens.label(
                            color: HomeTokens.text,
                            size: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 70, bottom: 160),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: HomeTokens.text,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else if (_filteredProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 10, 26, 150),
                      child: _EmptyShop(
                        searchText: _searchCtrl.text,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 110),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return ProductCard(
                            product: _filteredProducts[index],
                            compact: true,
                          );
                        },
                        childCount: _filteredProducts.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.56,
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

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;

  const _FilterSection({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: HomeTokens.label(
              color: HomeTokens.text,
              size: 10,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = item == selectedItem;

                return GestureDetector(
                  onTap: () => onSelected(item),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? HomeTokens.text : Colors.transparent,
                      border: Border.all(color: HomeTokens.text),
                    ),
                    child: Center(
                      child: Text(
                        item.toUpperCase(),
                        style: HomeTokens.label(
                          size: 9,
                          color: selected ? HomeTokens.linen : HomeTokens.text,
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
        fontSize: 26,
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        hintText: 'Search products, brands, types...',
        hintStyle: HomeTokens.displayMedium(
          color: const Color(0xFFB8B8B8),
        ).copyWith(
          fontSize: 26,
          letterSpacing: 0.2,
        ),
        suffixIcon: const Icon(
          Icons.search_rounded,
          color: HomeTokens.text,
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

class _EmptyShop extends StatelessWidget {
  final String searchText;

  const _EmptyShop({
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        color: HomeTokens.white.withValues(alpha: 0.62),
        border: Border.all(color: HomeTokens.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: HomeTokens.text,
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'NO RESULTS' : 'NO PRODUCTS',
            textAlign: TextAlign.center,
            style: HomeTokens.displayMedium().copyWith(
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try another product, brand or type.'
                : 'Products added from admin will appear here.',
            textAlign: TextAlign.center,
            style: HomeTokens.body(size: 13),
          ),
        ],
      ),
    );
  }
}