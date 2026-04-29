// lib/features/admin/presentation/screens/admin_add_product.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/product_taxonomy.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../data/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../theme/admin_tokens.dart';
import '../widgets/admin_ui.dart';
import 'admin_shell.dart';

class AdminAddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AdminAddProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _origPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _discountCtrl;

  String _selectedCategory = 'Digital Products';
  String _selectedSubCategory = 'Cameras';
  String _selectedEmoji = '📦';

  bool _isActive = true;
  bool _isFeatured = false;
  bool _uploading = false;

  final List<File> _newImageFiles = [];
  List<String> _existingImageUrls = [];
  final List<String> _removedUrls = [];

  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _companyCtrl = TextEditingController(
      text: product?['company_name']?.toString() ?? 'Athimart',
    );

    _nameCtrl = TextEditingController(
      text: product?['name']?.toString() ?? '',
    );

    _descCtrl = TextEditingController(
      text: product?['description']?.toString() ?? '',
    );

    _priceCtrl = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );

    _origPriceCtrl = TextEditingController(
      text: product?['original_price']?.toString() ?? '',
    );

    _stockCtrl = TextEditingController(
      text: product?['stock']?.toString() ?? '0',
    );

    _discountCtrl = TextEditingController(
      text: product?['discount_percent']?.toString() ?? '0',
    );

    if (product != null) {
      final rawCategory = product['category']?.toString() ?? 'Digital Products';

      _selectedCategory = ProductTaxonomy.isValidCategory(rawCategory)
          ? rawCategory
          : 'Digital Products';

      final rawSubCategory =
          product['sub_category']?.toString() ??
              ProductTaxonomy.firstSubcategoryFor(_selectedCategory);

      _selectedSubCategory =
      ProductTaxonomy.isValidSubcategory(_selectedCategory, rawSubCategory)
          ? rawSubCategory
          : ProductTaxonomy.firstSubcategoryFor(_selectedCategory);

      _selectedEmoji = product['emoji']?.toString() ?? '📦';
      _isActive = product['is_active'] == true;
      _isFeatured = product['is_featured'] == true;

      final rawImages = product['image_urls'];
      if (rawImages is List) {
        _existingImageUrls = rawImages.map((item) => item.toString()).toList();
      }
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _stockCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  int get _totalImages => _existingImageUrls.length + _newImageFiles.length;

  final List<String> _emojis = const [
    '📦',
    '💻',
    '🤖',
    '📱',
    '⌚',
    '🎧',
    '🌿',
    '🌹',
    '✨',
    '🪵',
    '💪',
    '🧘',
    '🏋️',
    '🚗',
    '🏠',
    '👗',
    '👟',
    '📊',
    '🔧',
    '📸',
    '🔋',
    '💡',
    '🎮',
    '🖥️',
    '⌨️',
    '🖱️',
    '🔑',
  ];

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AdminTokens.danger : AdminTokens.text,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImages() async {
    final allowed = 5 - _totalImages;

    if (allowed <= 0) {
      _showSnack('Maximum 5 images allowed', isError: true);
      return;
    }

    final picked = await _picker.pickMultiImage(imageQuality: 80);

    if (picked.isEmpty) return;

    final limited = picked.take(allowed).toList();

    setState(() {
      for (final image in limited) {
        _newImageFiles.add(File(image.path));
      }
    });
  }

  Future<void> _pickFromCamera() async {
    final allowed = 5 - _totalImages;

    if (allowed <= 0) {
      _showSnack('Maximum 5 images allowed', isError: true);
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _newImageFiles.add(File(picked.path));
    });
  }

  void _removeNewFile(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _removeExistingUrl(String url) {
    setState(() {
      _existingImageUrls.remove(url);
      _removedUrls.add(url);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminTokens.linen,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            decoration: const BoxDecoration(
              gradient: AdminTokens.pageGradient,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ADD IMAGE',
                  style: AdminTokens.displayMedium(size: 30),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1.2,
                  width: double.infinity,
                  color: AdminTokens.text,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _SourceOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImages();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SourceOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickFromCamera();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeCategory(String value) {
    setState(() {
      _selectedCategory = value;
      _selectedSubCategory = ProductTaxonomy.firstSubcategoryFor(value);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _uploading = true;
    });

    try {
      List<String> newUrls = [];

      if (_newImageFiles.isNotEmpty) {
        newUrls = await ImageUploadService.uploadImages(_newImageFiles);
      }

      for (final url in _removedUrls) {
        await ImageUploadService.deleteImage(url);
      }

      final allImages = [
        ..._existingImageUrls,
        ...newUrls,
      ];

      final parsedPrice = double.parse(_priceCtrl.text.trim());
      final parsedOriginalPrice =
          double.tryParse(_origPriceCtrl.text.trim()) ?? parsedPrice;

      final companyName = _companyCtrl.text.trim().isEmpty
          ? 'Athimart'
          : _companyCtrl.text.trim();

      final product = AdminProduct(
        id: widget.product?['id']?.toString(),
        name: _nameCtrl.text.trim(),
        companyName: companyName,
        subCategory: _selectedSubCategory,
        description: _descCtrl.text.trim(),
        price: parsedPrice,
        originalPrice: parsedOriginalPrice,
        category: _selectedCategory,
        emoji: _selectedEmoji,
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        discountPercent: int.tryParse(_discountCtrl.text.trim()) ?? 0,
        isActive: _isActive,
        isFeatured: _isFeatured,
        imageUrls: allImages,
      );

      if (!mounted) return;

      if (_isEditing) {
        context.read<ProductBloc>().add(ProductUpdate(product));
      } else {
        context.read<ProductBloc>().add(ProductCreate(product));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploading = false;
      });

      _showSnack('Failed to save product: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          setState(() {
            _uploading = false;
          });

          _showSnack(state.message);
          context.go('/admin/products');
        }

        if (state is ProductError) {
          setState(() {
            _uploading = false;
          });

          _showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AdminTokens.linen,
        appBar: AdminAppBar(
          title: _isEditing ? 'Edit Product' : 'Add Product',
        ),
        body: AdminPage(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AdminTokens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'EDIT\nPRODUCT' : 'NEW\nPRODUCT',
                    style: AdminTokens.displayLarge(size: 42),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1.2,
                    width: double.infinity,
                    color: AdminTokens.text,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add category, product type, company, images, price and stock.',
                    style: AdminTokens.body(size: 14),
                  ),

                  const SizedBox(height: 34),

                  _SectionLabel(
                    title: 'Product Images',
                    subtitle: 'Add up to 5 images. First image is main.',
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 112,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._existingImageUrls.asMap().entries.map((entry) {
                          final index = entry.key;
                          final url = entry.value;

                          return _ImageSlot(
                            child: _NetworkImageTile(
                              url: url,
                              isMain: index == 0,
                              onRemove: () => _removeExistingUrl(url),
                            ),
                          );
                        }),

                        ..._newImageFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          final isMain =
                              _existingImageUrls.isEmpty && index == 0;

                          return _ImageSlot(
                            child: _LocalImageTile(
                              file: file,
                              isMain: isMain,
                              onRemove: () => _removeNewFile(index),
                            ),
                          );
                        }),

                        if (_totalImages < 5)
                          _ImageSlot(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showImageSourceSheet,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                  AdminTokens.white.withValues(alpha: 0.65),
                                  border: Border.all(
                                    color: AdminTokens.border,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AdminTokens.text,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_totalImages/5',
                                      style: AdminTokens.label(size: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _SectionLabel(
                    title: 'Fallback Emoji',
                    subtitle: 'Used when product has no image.',
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emojis.map((emoji) {
                      final selected = emoji == _selectedEmoji;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: selected
                                ? AdminTokens.text
                                : AdminTokens.white.withValues(alpha: 0.58),
                            border: Border.all(
                              color: selected
                                  ? AdminTokens.text
                                  : AdminTokens.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 34),

                  _SectionLabel(title: 'Category'),
                  const SizedBox(height: 10),
                  _CategoryDropdown(
                    value: _selectedCategory,
                    items: ProductTaxonomy.categories,
                    onChanged: (value) {
                      if (value == null) return;
                      _changeCategory(value);
                    },
                  ),

                  const SizedBox(height: 24),

                  _SectionLabel(title: 'Product Type'),
                  const SizedBox(height: 10),
                  _CategoryDropdown(
                    value: _selectedSubCategory,
                    items: ProductTaxonomy.subcategoriesFor(_selectedCategory),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedSubCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  _SectionLabel(title: 'Company / Brand Name'),
                  const SizedBox(height: 8),
                  AdminTextField(
                    controller: _companyCtrl,
                    hint: 'Canon, Dell, Athimart, Goviceylon...',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _SectionLabel(title: 'Product Name'),
                  const SizedBox(height: 8),
                  AdminTextField(
                    controller: _nameCtrl,
                    hint: 'Canon EOS Camera, Website Package...',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _SectionLabel(title: 'Description'),
                  const SizedBox(height: 8),
                  AdminTextField(
                    controller: _descCtrl,
                    hint: 'Product description...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(title: 'Price'),
                            const SizedBox(height: 8),
                            AdminTextField(
                              controller: _priceCtrl,
                              hint: '0.00',
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _numberValidatorRequired,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(title: 'Original'),
                            const SizedBox(height: 8),
                            AdminTextField(
                              controller: _origPriceCtrl,
                              hint: '0.00',
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _numberValidatorOptional,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(title: 'Stock'),
                            const SizedBox(height: 8),
                            AdminTextField(
                              controller: _stockCtrl,
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(title: 'Discount %'),
                            const SizedBox(height: 8),
                            AdminTextField(
                              controller: _discountCtrl,
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _SectionLabel(
                    title: 'Settings',
                    subtitle: 'Control visibility and featured placement.',
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: BoxDecoration(
                      color: AdminTokens.white.withValues(alpha: 0.64),
                      border: Border.all(color: AdminTokens.border),
                    ),
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Active',
                          subtitle: 'Visible to customers',
                          value: _isActive,
                          activeColor: AdminTokens.success,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        Container(height: 1, color: AdminTokens.border),
                        _SettingRow(
                          icon: Icons.star_border_rounded,
                          label: 'Featured',
                          subtitle: 'Show in featured section',
                          value: _isFeatured,
                          activeColor: AdminTokens.text,
                          onChanged: (value) {
                            setState(() {
                              _isFeatured = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      final loading = state is ProductLoading || _uploading;

                      return AdminPrimaryButton(
                        text: _isEditing ? 'Save Changes' : 'Create Product',
                        icon: _isEditing
                            ? Icons.save_outlined
                            : Icons.add_rounded,
                        loading: loading,
                        onTap: loading ? null : _submit,
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _numberValidatorRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Invalid number';
    }

    return null;
  }

  String? _numberValidatorOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Invalid number';
    }

    return null;
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionLabel({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AdminTokens.label(
            color: AdminTokens.text,
            size: 10,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AdminTokens.body(size: 12),
          ),
        ],
      ],
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final Widget child;

  const _ImageSlot({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 102,
      margin: const EdgeInsets.only(right: 10),
      child: child,
    );
  }
}

class _NetworkImageTile extends StatelessWidget {
  final String url;
  final bool isMain;
  final VoidCallback onRemove;

  const _NetworkImageTile({
    required this.url,
    required this.isMain,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: AdminTokens.card,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AdminTokens.lightGray,
                  size: 30,
                ),
              );
            },
          ),
        ),
        if (isMain) const _ImageBadge(text: 'MAIN'),
        _RemoveImageButton(onTap: onRemove),
      ],
    );
  }
}

class _LocalImageTile extends StatelessWidget {
  final File file;
  final bool isMain;
  final VoidCallback onRemove;

  const _LocalImageTile({
    required this.file,
    required this.isMain,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
        if (isMain) const _ImageBadge(text: 'MAIN'),
        const Positioned(
          left: 6,
          bottom: 6,
          child: _SmallImageLabel(text: 'NEW'),
        ),
        _RemoveImageButton(onTap: onRemove),
      ],
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String text;

  const _ImageBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      left: 6,
      child: _SmallImageLabel(text: text),
    );
  }
}

class _SmallImageLabel extends StatelessWidget {
  final String text;

  const _SmallImageLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTokens.text,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        text,
        style: AdminTokens.label(
          color: AdminTokens.linen,
          size: 7,
        ),
      ),
    );
  }
}

class _RemoveImageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveImageButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          color: AdminTokens.danger,
          child: const Icon(
            Icons.close_rounded,
            color: AdminTokens.linen,
            size: 15,
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminOutlineButton(
      text: label,
      icon: icon,
      onTap: onTap,
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : items.first;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AdminTokens.text),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: AdminTokens.linen,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminTokens.text,
          ),
          style: AdminTokens.bodyBold(size: 13),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AdminTokens.bodyBold(size: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = value ? activeColor : AdminTokens.lightGray;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AdminTokens.label(
                    color: AdminTokens.text,
                    size: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AdminTokens.body(size: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            inactiveThumbColor: AdminTokens.lightGray,
            inactiveTrackColor: AdminTokens.border,
          ),
        ],
      ),
    );
  }
}