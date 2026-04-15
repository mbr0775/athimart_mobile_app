// lib/features/admin/presentation/screens/admin_add_product.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../data/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'admin_shell.dart';

class AdminAddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AdminAddProductScreen({super.key, required this.product});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _origPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _discountCtrl;

  String _selectedCategory = 'AI Gadgets';
  String _selectedEmoji = '📦';
  bool _isActive = true;
  bool _isFeatured = false;
  bool get _isEditing => widget.product != null;

  // ── Image state ──────────────────────────────────────────────────────────
  final List<File> _newImageFiles = [];       // freshly picked, not yet uploaded
  List<String> _existingImageUrls = [];       // already on Supabase (edit mode)
  final List<String> _removedUrls = [];       // urls flagged for deletion
  bool _uploading = false;

  final _picker = ImagePicker();

  final _categories = [
    'IT Solutions', 'AI Gadgets', 'Fitness Tech', 'Essences',
    'Agarwood', 'Fashion', 'Vehicles', 'Real Estate',
  ];

  final _emojis = [
    '📦', '💻', '🤖', '📱', '⌚', '🎧', '🌿', '🌹', '✨', '🪵',
    '📿', '💪', '🧘', '🏋️', '🚗', '🏠', '👗', '👟', '📊', '🔧',
    '🌸', '🪞', '📸', '🔋', '💡', '🎮', '🖥️', '⌨️', '🖱️', '🔑',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?['name'] ?? '');
    _descCtrl = TextEditingController(text: p?['description'] ?? '');
    _priceCtrl = TextEditingController(text: p?['price']?.toString() ?? '');
    _origPriceCtrl =
        TextEditingController(text: p?['original_price']?.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?['stock']?.toString() ?? '0');
    _discountCtrl =
        TextEditingController(text: p?['discount_percent']?.toString() ?? '0');
    if (p != null) {
      _selectedCategory = p['category'] ?? 'AI Gadgets';
      _selectedEmoji = p['emoji'] ?? '📦';
      _isActive = p['is_active'] ?? true;
      _isFeatured = p['is_featured'] ?? false;
      final raw = p['image_urls'];
      if (raw is List) {
        _existingImageUrls = raw.map((e) => e.toString()).toList();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _origPriceCtrl.dispose(); _stockCtrl.dispose(); _discountCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final totalAllowed = 5 - _existingImageUrls.length - _newImageFiles.length;
    if (totalAllowed <= 0) {
      _showSnack('Maximum 5 images allowed', isError: true);
      return;
    }
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final limited = picked.take(totalAllowed).toList();
    setState(() {
      for (final xf in limited) {
        _newImageFiles.add(File(xf.path));
      }
    });
  }

  Future<void> _pickFromCamera() async {
    final totalAllowed = 5 - _existingImageUrls.length - _newImageFiles.length;
    if (totalAllowed <= 0) {
      _showSnack('Maximum 5 images allowed', isError: true);
      return;
    }
    final xf = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (xf == null) return;
    setState(() => _newImageFiles.add(File(xf.path)));
  }

  void _removeNewFile(int idx) =>
      setState(() => _newImageFiles.removeAt(idx));

  void _removeExistingUrl(String url) {
    setState(() {
      _existingImageUrls.remove(url);
      _removedUrls.add(url);
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);

    try {
      // 1. Upload new images → get URLs
      List<String> newUrls = [];
      if (_newImageFiles.isNotEmpty) {
        newUrls = await ImageUploadService.uploadImages(_newImageFiles);
      }

      // 2. Delete removed images from storage
      for (final url in _removedUrls) {
        await ImageUploadService.deleteImage(url);
      }

      // 3. Build final image list: kept existing + new
      final allImages = [..._existingImageUrls, ...newUrls];

      final product = AdminProduct(
        id: widget.product?['id'],
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        originalPrice:
            double.tryParse(_origPriceCtrl.text) ?? double.parse(_priceCtrl.text),
        category: _selectedCategory,
        emoji: _selectedEmoji,
        stock: int.tryParse(_stockCtrl.text) ?? 0,
        discountPercent: int.tryParse(_discountCtrl.text) ?? 0,
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
      setState(() => _uploading = false);
      _showSnack('Image upload failed: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      backgroundColor: isError ? AppColors.accentRed : AppColors.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Add Product Image',
              style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 18,
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: _SourceBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalImages = _existingImageUrls.length + _newImageFiles.length;

    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          setState(() => _uploading = false);
          _showSnack(state.message);
          context.go('/admin/products');
        }
        if (state is ProductError) {
          setState(() => _uploading = false);
          _showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(title: _isEditing ? 'Edit Product' : 'Add Product'),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── PRODUCT IMAGES ──────────────────────────────────────────
                const _SectionLabel('Product Images'),
                const SizedBox(height: 4),
                Text('Add up to 5 images • First image is the main display',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textHint)),
                const SizedBox(height: 12),

                // Image grid
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Existing uploaded images
                      ..._existingImageUrls.asMap().entries.map((entry) {
                        final i = entry.key;
                        final url = entry.value;
                        return _ImageSlot(
                          child: Stack(fit: StackFit.expand, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(url, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.card,
                                  child: const Icon(Icons.broken_image_rounded,
                                    color: AppColors.textHint, size: 30))),
                            ),
                            if (i == 0)
                              Positioned(top: 4, left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                  child: const Text('MAIN',
                                    style: TextStyle(fontFamily: 'Poppins',
                                      fontSize: 8, fontWeight: FontWeight.w800,
                                      color: Colors.black)))),
                            // Remove button
                            Positioned(top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => _removeExistingUrl(url),
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentRed,
                                    shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded,
                                    size: 13, color: Colors.white)))),
                          ]),
                        );
                      }),

                      // New local files
                      ..._newImageFiles.asMap().entries.map((entry) {
                        final i = entry.key;
                        final file = entry.value;
                        final isMain =
                            _existingImageUrls.isEmpty && i == 0;
                        return _ImageSlot(
                          child: Stack(fit: StackFit.expand, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(file, fit: BoxFit.cover)),
                            if (isMain)
                              Positioned(top: 4, left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                  child: const Text('MAIN',
                                    style: TextStyle(fontFamily: 'Poppins',
                                      fontSize: 8, fontWeight: FontWeight.w800,
                                      color: Colors.black)))),
                            // Remove button
                            Positioned(top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => _removeNewFile(i),
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentRed,
                                    shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded,
                                    size: 13, color: Colors.white)))),
                            // Upload pending indicator
                            Positioned(bottom: 4, right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(5)),
                                child: const Text('NEW',
                                  style: TextStyle(fontFamily: 'Poppins',
                                    fontSize: 7, color: Colors.white,
                                    fontWeight: FontWeight.w700)))),
                          ]),
                        );
                      }),

                      // Add image button (show if < 5 images)
                      if (totalImages < 5)
                        _ImageSlot(
                          child: GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                    width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle),
                                    child: const Icon(Icons.add_photo_alternate_rounded,
                                      color: Colors.black, size: 18)),
                                  const SizedBox(height: 6),
                                  Text('$totalImages/5',
                                    style: const TextStyle(fontFamily: 'Poppins',
                                      fontSize: 10, color: AppColors.textHint)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── EMOJI PICKER ────────────────────────────────────────────
                const SizedBox(height: 24),
                Row(children: [
                  const _SectionLabel('Fallback Emoji'),
                  const SizedBox(width: 8),
                  Text('(used if no image)',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                      color: AppColors.textHint)),
                ]),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _emojis.map((e) {
                    final selected = e == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 2 : 1)),
                        child: Center(child: Text(e,
                          style: const TextStyle(fontSize: 22))),
                      ),
                    );
                  }).toList(),
                ),

                // ── FIELDS ──────────────────────────────────────────────────
                const SizedBox(height: 24),
                const _SectionLabel('Product Name'),
                const SizedBox(height: 8),
                _Field(controller: _nameCtrl, hint: 'e.g. Smart AI Watch Pro',
                  validator: (v) => v!.isEmpty ? 'Name is required' : null),

                const SizedBox(height: 16),
                const _SectionLabel('Description'),
                const SizedBox(height: 8),
                _Field(controller: _descCtrl,
                  hint: 'Product description...', maxLines: 3),

                const SizedBox(height: 16),
                const _SectionLabel('Category'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        color: AppColors.textPrimary),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textHint),
                      items: _categories.map((c) => DropdownMenuItem(
                        value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Price (\$)'),
                      const SizedBox(height: 8),
                      _Field(controller: _priceCtrl, hint: '0.00',
                        inputType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null),
                    ],
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Original Price'),
                      const SizedBox(height: 8),
                      _Field(controller: _origPriceCtrl, hint: '0.00',
                        inputType: TextInputType.number),
                    ],
                  )),
                ]),

                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Stock'),
                      const SizedBox(height: 8),
                      _Field(controller: _stockCtrl, hint: '0',
                        inputType: TextInputType.number),
                    ],
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Discount %'),
                      const SizedBox(height: 8),
                      _Field(controller: _discountCtrl, hint: '0',
                        inputType: TextInputType.number),
                    ],
                  )),
                ]),

                const SizedBox(height: 24),
                const _SectionLabel('Settings'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    _SettingToggle(
                      icon: Icons.check_circle_rounded, label: 'Active',
                      subtitle: 'Visible to customers',
                      value: _isActive, color: AppColors.accentGreen,
                      onChanged: (v) => setState(() => _isActive = v),
                      showDivider: true),
                    _SettingToggle(
                      icon: Icons.star_rounded, label: 'Featured',
                      subtitle: 'Show in featured section',
                      value: _isFeatured, color: AppColors.primary,
                      onChanged: (v) => setState(() => _isFeatured = v),
                      showDivider: false),
                  ]),
                ),

                const SizedBox(height: 32),

                // Submit button
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    final loading = state is ProductLoading || _uploading;
                    return GestureDetector(
                      onTap: loading ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                          gradient: loading ? null : AppColors.primaryGradient,
                          color: loading ? AppColors.card : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: loading ? null : [
                            BoxShadow(color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Center(
                          child: loading
                              ? Row(mainAxisSize: MainAxisSize.min, children: [
                                  const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary, strokeWidth: 2)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _newImageFiles.isNotEmpty
                                        ? 'Uploading images...'
                                        : 'Saving...',
                                    style: const TextStyle(fontFamily: 'Poppins',
                                      fontSize: 14, color: AppColors.textSecondary)),
                                ])
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(_isEditing
                                      ? Icons.save_rounded
                                      : Icons.add_circle_rounded,
                                    color: Colors.black, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEditing ? 'Save Changes' : 'Create Product',
                                    style: const TextStyle(fontFamily: 'Poppins',
                                      fontSize: 16, fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                                ]),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Image slot widget ────────────────────────────────────────────────────────
class _ImageSlot extends StatelessWidget {
  final Widget child;
  const _ImageSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      margin: const EdgeInsets.only(right: 10),
      child: child,
    );
  }
}

// ─── Source button (gallery / camera) ────────────────────────────────────────
class _SourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SourceBtn(
      {required this.icon, required this.label, required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
      fontWeight: FontWeight.w600, color: AppColors.textSecondary));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType inputType;
  final String? Function(String?)? validator;

  const _Field({required this.controller, required this.hint,
    this.maxLines = 1, this.inputType = TextInputType.text,
    this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      keyboardType: inputType, validator: validator,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
        color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textHint),
        filled: true, fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed)),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value, showDivider;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({required this.icon, required this.label,
    required this.subtitle, required this.value, required this.color,
    required this.onChanged, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 11, color: AppColors.textSecondary)),
            ],
          )),
          Switch.adaptive(value: value, onChanged: onChanged,
            activeColor: color, inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.border),
        ]),
      ),
      if (showDivider) Container(height: 1, color: AppColors.border),
    ]);
  }
}