// lib/features/home/presentation/screens/search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/product_service.dart';
import '../theme/home_tokens.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;

  bool _loading = true;
  bool _searched = false;

  String _query = '';

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _results = [];
  List<_SearchSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
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
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _allProducts = [];
        _results = [];
        _suggestions = [];
        _loading = false;
      });
    }
  }

  void _close() {
    _searchFocus.unfocus();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;

      final query = value.trim();

      if (query.isEmpty) {
        setState(() {
          _query = '';
          _searched = false;
          _results = [];
          _suggestions = [];
        });
        return;
      }

      final results = _filterProducts(query);
      final suggestions = _buildSuggestions(query);

      setState(() {
        _query = query;
        _searched = true;
        _results = results;
        _suggestions = suggestions;
      });
    });
  }

  void _search(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _query = '';
        _searched = false;
        _results = [];
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _query = query;
      _searched = true;
      _results = _filterProducts(query);
      _suggestions = _buildSuggestions(query);
    });
  }

  void _useSuggestion(_SearchSuggestion suggestion) {
    _searchCtrl.text = suggestion.value;
    _searchCtrl.selection = TextSelection.collapsed(
      offset: _searchCtrl.text.length,
    );

    _search(suggestion.value);
    _searchFocus.requestFocus();
  }

  List<Map<String, dynamic>> _filterProducts(String query) {
    final normalizedQuery = _normalize(query);
    final queryWords = normalizedQuery
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (queryWords.isEmpty) return [];

    final scored = <_ScoredProduct>[];

    for (final product in _allProducts) {
      final name = _normalize(_productName(product));
      final company = _normalize(_companyName(product));
      final category = _normalize(_category(product));
      final subCategory = _normalize(_subCategory(product));
      final description = _normalize(_description(product));

      final fullText = [
        name,
        company,
        category,
        subCategory,
        description,
      ].join(' ');

      final matchesAllWords = queryWords.every(fullText.contains);

      if (!matchesAllWords) continue;

      var score = 0;

      if (name == normalizedQuery) score += 100;
      if (company == normalizedQuery) score += 90;
      if (subCategory == normalizedQuery) score += 80;
      if (category == normalizedQuery) score += 70;

      if (name.startsWith(normalizedQuery)) score += 50;
      if (company.startsWith(normalizedQuery)) score += 45;
      if (subCategory.startsWith(normalizedQuery)) score += 40;
      if (category.startsWith(normalizedQuery)) score += 35;

      if (name.contains(normalizedQuery)) score += 25;
      if (company.contains(normalizedQuery)) score += 22;
      if (subCategory.contains(normalizedQuery)) score += 18;
      if (category.contains(normalizedQuery)) score += 15;
      if (description.contains(normalizedQuery)) score += 8;

      scored.add(_ScoredProduct(product: product, score: score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((item) => item.product).toList();
  }

  List<_SearchSuggestion> _buildSuggestions(String query) {
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) return [];

    final suggestions = <_SearchSuggestion>[];
    final used = <String>{};

    void addSuggestion({
      required String value,
      required String type,
      IconData icon = Icons.search_rounded,
    }) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;

      final key = '${type.toLowerCase()}-${trimmed.toLowerCase()}';
      if (used.contains(key)) return;

      final normalizedValue = _normalize(trimmed);

      if (!normalizedValue.contains(normalizedQuery)) return;

      used.add(key);

      suggestions.add(
        _SearchSuggestion(
          value: trimmed,
          type: type,
          icon: icon,
        ),
      );
    }

    for (final product in _allProducts) {
      addSuggestion(
        value: _productName(product),
        type: 'Product',
        icon: Icons.inventory_2_outlined,
      );

      addSuggestion(
        value: _companyName(product),
        type: 'Brand',
        icon: Icons.storefront_outlined,
      );

      addSuggestion(
        value: _category(product),
        type: 'Category',
        icon: Icons.category_outlined,
      );

      addSuggestion(
        value: _subCategory(product),
        type: 'Product Type',
        icon: Icons.widgets_outlined,
      );
    }

    suggestions.sort((a, b) {
      final typeOrder = {
        'Product': 0,
        'Brand': 1,
        'Product Type': 2,
        'Category': 3,
      };

      final aOrder = typeOrder[a.type] ?? 99;
      final bOrder = typeOrder[b.type] ?? 99;

      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      return a.value.toLowerCase().compareTo(b.value.toLowerCase());
    });

    return suggestions.take(8).toList();
  }

  String _normalize(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _productName(Map<String, dynamic> product) {
    return product['name']?.toString() ?? 'Product';
  }

  String _companyName(Map<String, dynamic> product) {
    return product['company_name']?.toString() ?? 'Athimart';
  }

  String _category(Map<String, dynamic> product) {
    return product['category']?.toString() ?? 'General';
  }

  String _subCategory(Map<String, dynamic> product) {
    return product['sub_category']?.toString() ?? 'General';
  }

  String _description(Map<String, dynamic> product) {
    return product['description']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: HomeTokens.linen,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
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
                  ),
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 38),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.28),

                              TextField(
                                controller: _searchCtrl,
                                focusNode: _searchFocus,
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                cursorColor: HomeTokens.text,
                                cursorWidth: 1.4,
                                style: HomeTokens.displayMedium(
                                  color: HomeTokens.text,
                                ).copyWith(
                                  fontSize: 30,
                                  letterSpacing: 0.1,
                                  height: 1.1,
                                ),
                                decoration: InputDecoration(
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  isCollapsed: true,
                                  hintText: 'Search products, brands...',
                                  hintStyle: HomeTokens.displayMedium(
                                    color: const Color(0xFFB8B8B8),
                                  ).copyWith(
                                    fontSize: 30,
                                    letterSpacing: 0.1,
                                    height: 1.1,
                                  ),
                                ),
                                onChanged: _onQueryChanged,
                                onSubmitted: _search,
                              ),

                              const SizedBox(height: 12),

                              Container(
                                height: 1.2,
                                width: double.infinity,
                                color: HomeTokens.text,
                              ),

                              const SizedBox(height: 18),

                              Text(
                                _loading
                                    ? 'Loading products...'
                                    : 'Search by product, brand, category or type',
                                style: HomeTokens.body(
                                  size: 14,
                                  color: HomeTokens.darkGray,
                                ),
                              ),

                              const SizedBox(height: 34),

                              if (_loading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: HomeTokens.text,
                                    strokeWidth: 2,
                                  ),
                                )
                              else ...[
                                if (_suggestions.isNotEmpty) ...[
                                  _SectionLabel(
                                    title: 'Suggestions',
                                    count: _suggestions.length,
                                  ),
                                  const SizedBox(height: 12),
                                  _SuggestionList(
                                    suggestions: _suggestions,
                                    onTap: _useSuggestion,
                                  ),
                                  const SizedBox(height: 30),
                                ],

                                if (_searched) ...[
                                  _SectionLabel(
                                    title: 'Results',
                                    count: _results.length,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_results.isEmpty)
                                    _EmptySearch(query: _query)
                                  else
                                    _SearchResults(results: _results),
                                ],
                              ],

                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  top: 18,
                  right: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _close,
                    child: const SizedBox(
                      width: 58,
                      height: 58,
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: HomeTokens.text,
                          size: 46,
                        ),
                      ),
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

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;

  const _SectionLabel({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: HomeTokens.displayMedium().copyWith(fontSize: 28),
        ),
        const Spacer(),
        Text(
          '$count',
          style: HomeTokens.label(
            color: HomeTokens.text,
            size: 10,
          ),
        ),
      ],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<_SearchSuggestion> suggestions;
  final ValueChanged<_SearchSuggestion> onTap;

  const _SuggestionList({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: suggestions.map((suggestion) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(suggestion),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HomeTokens.white.withValues(alpha: 0.64),
              border: Border.all(color: HomeTokens.border),
            ),
            child: Row(
              children: [
                Icon(
                  suggestion.icon,
                  color: HomeTokens.text,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.type.toUpperCase(),
                        style: HomeTokens.label(size: 8),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        suggestion.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HomeTokens.bodyBold(size: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.north_west_rounded,
                  color: HomeTokens.lightGray,
                  size: 17,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const _SearchResults({
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: results.map((product) {
        final name = product['name']?.toString() ?? 'Product';
        final company = product['company_name']?.toString() ?? 'Athimart';
        final category = product['category']?.toString() ?? 'General';
        final subCategory = product['sub_category']?.toString() ?? 'General';
        final emoji = product['emoji']?.toString() ?? '📦';

        final priceRaw = product['price'];
        final price = priceRaw is num
            ? priceRaw.toDouble()
            : double.tryParse(priceRaw?.toString() ?? '') ?? 0;

        final imageUrls = product['image_urls'];
        String? imageUrl;

        if (imageUrls is List && imageUrls.isNotEmpty) {
          imageUrl = imageUrls.first.toString();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          color: HomeTokens.white.withValues(alpha: 0.72),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                color: HomeTokens.card,
                child: imageUrl == null
                    ? Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                )
                    : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HomeTokens.label(size: 9),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HomeTokens.bodyBold(size: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$category • $subCategory',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HomeTokens.body(
                        size: 10,
                        color: HomeTokens.lightGray,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: HomeTokens.price(size: 13),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_rounded,
                color: HomeTokens.text,
                size: 18,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: HomeTokens.white.withValues(alpha: 0.62),
        border: Border.all(color: HomeTokens.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: HomeTokens.text,
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            'NO PRODUCTS FOUND',
            textAlign: TextAlign.center,
            style: HomeTokens.displayMedium().copyWith(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            'No results for "$query". Try another product, brand or type.',
            textAlign: TextAlign.center,
            style: HomeTokens.body(size: 13),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestion {
  final String value;
  final String type;
  final IconData icon;

  const _SearchSuggestion({
    required this.value,
    required this.type,
    required this.icon,
  });
}

class _ScoredProduct {
  final Map<String, dynamic> product;
  final int score;

  const _ScoredProduct({
    required this.product,
    required this.score,
  });
}