// lib/features/admin/presentation/screens/admin_products.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../theme/admin_tokens.dart';
import '../widgets/admin_ui.dart';
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

  final List<String> _categories = const [
    'All',
    'IT Solutions',
    'AI Gadgets',
    'Fitness Tech',
    'Essences',
    'Agarwood',
    'Fashion',
    'Vehicles',
    'Real Estate',
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
    context.read<ProductBloc>().add(
      ProductLoadAll(
        search: _searchCtrl.text.trim(),
        category: _selectedCategory,
      ),
    );
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AdminTokens.danger : AdminTokens.text,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(AdminProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) {
        return AdminConfirmDialog(
          title: 'Delete Product',
          message:
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
          confirmText: 'Delete',
          confirmColor: AdminTokens.danger,
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<ProductBloc>().add(ProductDelete(product.id!));
    }
  }

  Future<void> _refresh() async {
    context.read<ProductBloc>().add(
      ProductLoadAll(
        search: _searchCtrl.text.trim(),
        category: _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTokens.linen,
      appBar: AdminAppBar(
        title: 'Products',
        actions: [
          Material(
            color: AdminTokens.text,
            child: InkWell(
              onTap: () => context.push('/admin/products/add'),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AdminTokens.linen,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ADD',
                      style: AdminTokens.label(
                        color: AdminTokens.linen,
                        size: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AdminPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchPanel(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: (_) => _search(),
            ),

            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminTokens.pagePadding,
                ),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final category = _categories[index];
                  final selected = category == _selectedCategory;

                  return AdminChip(
                    label: category,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _search();
                    },
                  );
                },
              ),
            ),

            Container(
              height: 1,
              color: AdminTokens.border,
            ),

            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is ProductOperationSuccess) {
                    _showSnack(state.message);
                  }

                  if (state is ProductError) {
                    _showSnack(state.message, error: true);
                  }
                },
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AdminTokens.text,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  List<AdminProduct> products = [];

                  if (state is ProductLoaded) {
                    products = state.products;
                  }

                  if (state is ProductOperationSuccess) {
                    products = state.products;
                  }

                  if (products.isEmpty) {
                    return _EmptyProducts(
                      onAdd: () => context.push('/admin/products/add'),
                    );
                  }

                  return RefreshIndicator(
                    color: AdminTokens.text,
                    backgroundColor: AdminTokens.linen,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(AdminTokens.pagePadding),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];

                        return _ProductCard(
                          product: product,
                          onEdit: () {
                            context.push(
                              '/admin/products/edit',
                              extra: product.toMap()..['id'] = product.id,
                            );
                          },
                          onDelete: () => _confirmDelete(product),
                          onToggleActive: (value) {
                            context.read<ProductBloc>().add(
                              ProductToggleActive(product.id!, value),
                            );
                          },
                          onToggleFeatured: (value) {
                            context.read<ProductBloc>().add(
                              ProductToggleFeatured(product.id!, value),
                            );
                          },
                        );
                      },
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

class _SearchPanel extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SearchPanel({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AdminTokens.pagePadding,
        22,
        AdminTokens.pagePadding,
        16,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: AdminTokens.text,
        textInputAction: TextInputAction.search,
        style: AdminTokens.displayMedium(size: 28),
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          hintText: 'Search products...',
          hintStyle: AdminTokens.displayMedium(
            size: 28,
            color: const Color(0xFFB8B8B8),
          ),
          suffixIcon: controller.text.isEmpty
              ? const Icon(
            Icons.search_rounded,
            color: AdminTokens.text,
          )
              : IconButton(
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AdminTokens.text,
            ),
          ),
          contentPadding: const EdgeInsets.only(bottom: 10),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: AdminTokens.text, width: 1.2),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AdminTokens.text, width: 1.2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AdminTokens.text, width: 1.6),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<bool> onToggleFeatured;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final image = product.primaryImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: AdminTokens.white.withValues(alpha: 0.68),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AdminTokens.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    color: AdminTokens.card,
                    child: image == null
                        ? Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    )
                        : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 34),
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
                          product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AdminTokens.label(size: 9),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AdminTokens.bodyBold(size: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _MiniLabel(
                              text: product.isActive ? 'ACTIVE' : 'INACTIVE',
                              color: product.isActive
                                  ? AdminTokens.success
                                  : AdminTokens.danger,
                            ),
                            if (product.isFeatured)
                              const _MiniLabel(
                                text: 'FEATURED',
                                color: AdminTokens.text,
                              ),
                            if (product.discountPercent > 0)
                              _MiniLabel(
                                text: '-${product.discountPercent}%',
                                color: AdminTokens.danger,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AdminTokens.price(size: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'STOCK ${product.stock}',
                        style: AdminTokens.label(size: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(height: 1, color: AdminTokens.border),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ProductSwitch(
                          label: 'Active',
                          value: product.isActive,
                          activeColor: AdminTokens.success,
                          onChanged: onToggleActive,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ProductSwitch(
                          label: 'Featured',
                          value: product.isFeatured,
                          activeColor: AdminTokens.text,
                          onChanged: onToggleFeatured,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AdminOutlineButton(
                          text: 'Edit',
                          icon: Icons.edit_outlined,
                          onTap: onEdit,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminOutlineButton(
                          text: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: AdminTokens.danger,
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ProductSwitch({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          inactiveThumbColor: AdminTokens.lightGray,
          inactiveTrackColor: AdminTokens.border,
        ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: AdminTokens.label(
            color: value ? activeColor : AdminTokens.lightGray,
            size: 9,
          ),
        ),
      ],
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniLabel({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AdminTokens.label(
        color: color,
        size: 8,
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyProducts({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminTokens.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AdminTokens.text,
              size: 58,
            ),
            const SizedBox(height: 20),
            Text(
              'NO PRODUCTS',
              style: AdminTokens.displayMedium(size: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below to create your first product.',
              textAlign: TextAlign.center,
              style: AdminTokens.body(size: 14),
            ),
            const SizedBox(height: 26),
            AdminPrimaryButton(
              text: 'Add Product',
              icon: Icons.add_rounded,
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}