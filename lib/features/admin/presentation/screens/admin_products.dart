// lib/features/admin/presentation/screens/admin_products.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../data/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'admin_shell.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _selectedCategory = 'All';

  final _categories = [
    'All', 'IT Solutions', 'AI Gadgets', 'Fitness Tech',
    'Essences', 'Agarwood', 'Fashion', 'Vehicles', 'Real Estate',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductLoadAll());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _search() {
    context.read<ProductBloc>().add(ProductLoadAll(
      search: _searchCtrl.text,
      category: _selectedCategory,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── AppBar with back button + search + Add button ─────────────────────
      appBar: _ProductsAppBar(
        searchCtrl: _searchCtrl,
        searchFocus: _searchFocus,
        onSearch: _search,
      ),
      body: Column(
        children: [
          // ── Category filter chips only (search is in AppBar) ──────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _search();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        color: selected ? null : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Text(cat,
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 11,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                            color: selected ? Colors.black : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(height: 1, color: AppColors.border),

          // ── Products list ─────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    backgroundColor: AppColors.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
                if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    backgroundColor: AppColors.accentRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
                }

                List<AdminProduct> products = [];
                if (state is ProductLoaded) products = state.products;
                if (state is ProductOperationSuccess) products = state.products;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        const Text('No products found',
                          style: TextStyle(fontFamily: 'PlayfairDisplay',
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('Tap + Add to create your first product',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: AppColors.textSecondary)),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => context.push('/admin/products/add'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(50)),
                            child: const Text('Add First Product',
                              style: TextStyle(fontFamily: 'Poppins',
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  onRefresh: () async =>
                      context.read<ProductBloc>().add(const ProductLoadAll()),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _ProductCard(
                      product: products[i],
                      onEdit: () => context.push('/admin/products/edit',
                        extra: products[i].toMap()..['id'] = products[i].id),
                      onDelete: () => _confirmDelete(context, products[i]),
                      onToggleActive: (v) => context.read<ProductBloc>()
                          .add(ProductToggleActive(products[i].id!, v)),
                      onToggleFeatured: (v) => context.read<ProductBloc>()
                          .add(ProductToggleFeatured(products[i].id!, v)),
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

  void _confirmDelete(BuildContext context, AdminProduct product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?',
          style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary))),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<ProductBloc>().add(ProductDelete(product.id!));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(10)),
              child: const Text('Delete',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Products AppBar: back arrow + inline search + Add button ──────────────────
class _ProductsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final VoidCallback onSearch;

  const _ProductsAppBar({
    required this.searchCtrl,
    required this.searchFocus,
    required this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<_ProductsAppBar> createState() => _ProductsAppBarState();
}

class _ProductsAppBarState extends State<_ProductsAppBar> {
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border)),

      // ── Back button ───────────────────────────────────────────────────────
      leading: GestureDetector(
        onTap: () {
          if (_searching) {
            setState(() {
              _searching = false;
              widget.searchCtrl.clear();
              widget.onSearch();
            });
            widget.searchFocus.unfocus();
          } else {
            // Navigate back to dashboard
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
          child: Icon(
            _searching
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 18),
        ),
      ),

      // ── Title or inline search field ──────────────────────────────────────
      title: _searching
          ? TextField(
              controller: widget.searchCtrl,
              focusNode: widget.searchFocus,
              autofocus: true,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search products...',
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (_) => widget.onSearch(),
            )
          : const Text('Products',
              style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20,
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),

      actions: [
        // Search toggle button
        if (!_searching)
          GestureDetector(
            onTap: () {
              setState(() => _searching = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.searchFocus.requestFocus();
              });
            },
            child: Container(
              width: 38, height: 38,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.search_rounded,
                color: AppColors.textPrimary, size: 20),
            ),
          ),

        // Add product button
        GestureDetector(
          onTap: () => context.push('/admin/products/add'),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.add_rounded, color: Colors.black, size: 16),
              SizedBox(width: 4),
              Text('Add',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w700, color: Colors.black)),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<bool> onToggleFeatured;

  const _ProductCard({
    required this.product, required this.onEdit, required this.onDelete,
    required this.onToggleActive, required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        // ── Top row: image/emoji + name + price ───────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            // Image or emoji thumbnail
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
              clipBehavior: Clip.antiAlias,
              child: product.hasImages
                  ? Image.network(
                      product.primaryImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(product.emoji,
                          style: const TextStyle(fontSize: 26))))
                  : Center(child: Text(product.emoji,
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),

            // Name + category badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, children: [
                    _Badge(label: product.category,
                      color: AppColors.accent),
                    if (product.isFeatured)
                      _Badge(label: '⭐ Featured',
                        color: AppColors.primary),
                    if (product.discountPercent > 0)
                      _Badge(label: '-${product.discountPercent}%',
                        color: AppColors.accentRed),
                  ]),
                ],
              ),
            ),

            // Price + stock
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text('Stock: ${product.stock}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                  color: AppColors.textSecondary)),
            ]),
          ]),
        ),

        Container(height: 1, color: AppColors.border),

        // ── Bottom: toggles + action buttons ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(children: [
            // Toggles row
            Row(children: [
              _Toggle(label: 'Active', value: product.isActive,
                activeColor: AppColors.accentGreen,
                onChanged: onToggleActive),
              const SizedBox(width: 20),
              _Toggle(label: 'Featured', value: product.isFeatured,
                activeColor: AppColors.primary,
                onChanged: onToggleFeatured),
            ]),
            const SizedBox(height: 10),
            // Edit + Delete buttons
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.25))),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, size: 14,
                          color: AppColors.accent),
                        SizedBox(width: 5),
                        Text('Edit',
                          style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.accent)),
                      ]),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.accentRed.withOpacity(0.25))),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_rounded, size: 14,
                          color: AppColors.accentRed),
                        SizedBox(width: 5),
                        Text('Delete',
                          style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.accentRed)),
                      ]),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6)),
      child: Text(label,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: color)),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.label, required this.value,
    required this.activeColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        height: 22,
        child: Switch.adaptive(
          value: value, onChanged: onChanged,
          activeColor: activeColor,
          inactiveThumbColor: AppColors.textHint,
          inactiveTrackColor: AppColors.border)),
      const SizedBox(width: 4),
      Text(label,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
          color: AppColors.textSecondary)),
    ]);
  }
}