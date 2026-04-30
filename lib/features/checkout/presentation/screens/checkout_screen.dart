// lib/features/checkout/presentation/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/order_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../cart/data/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Sri Lanka');

  bool _loadingProfile = true;
  bool _placing = false;

  int get _totalItems {
    return widget.items.fold<int>(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserProfileService.getMyProfile();

      if (!mounted) return;

      _nameCtrl.text = profile.fullName;
      _phoneCtrl.text = profile.phone;
      _address1Ctrl.text = profile.addressLine1;
      _address2Ctrl.text = profile.addressLine2;
      _cityCtrl.text = profile.city;
      _stateCtrl.text = profile.state;
      _postalCtrl.text = profile.postalCode;
      _countryCtrl.text =
      profile.country.trim().isEmpty ? 'Sri Lanka' : profile.country;
    } catch (_) {
      // Keep fields empty if profile loading fails.
    }

    if (!mounted) return;

    setState(() {
      _loadingProfile = false;
    });
  }

  Future<void> _placeOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: HomeTokens.sale,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _placing = true;
    });

    try {
      final shipping = ShippingDetails(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        addressLine1: _address1Ctrl.text.trim(),
        addressLine2: _address2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        country: _countryCtrl.text.trim().isEmpty
            ? 'Sri Lanka'
            : _countryCtrl.text.trim(),
      );

      await OrderService.createOrder(
        items: widget.items,
        shipping: shipping,
        subtotal: widget.subtotal,
        deliveryFee: widget.deliveryFee,
        total: widget.total,
      );

      if (!mounted) return;

      context.read<CartBloc>().add(const CartClear());

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully'),
          backgroundColor: HomeTokens.text,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _placing = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: HomeTokens.sale,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
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
          child: _loadingProfile
              ? const Center(
            child: CircularProgressIndicator(
              color: HomeTokens.text,
              strokeWidth: 2,
            ),
          )
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 80),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: false,
                  fillColor: Colors.transparent,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      onBack: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'CHECKOUT',
                      style: HomeTokens.displayLarge().copyWith(
                        fontSize: 46,
                        letterSpacing: 2.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      height: 1.2,
                      color: HomeTokens.text,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Confirm your shipping details and place your order.',
                      style: HomeTokens.body(size: 14),
                    ),

                    const SizedBox(height: 34),

                    const _SectionTitle(title: 'Shipping Details'),

                    const SizedBox(height: 18),

                    _CheckoutField(
                      controller: _nameCtrl,
                      hint: 'Full name',
                      validator: _required,
                    ),

                    const SizedBox(height: 22),

                    _CheckoutField(
                      controller: _phoneCtrl,
                      hint: 'Phone number',
                      keyboardType: TextInputType.phone,
                      validator: _required,
                    ),

                    const SizedBox(height: 22),

                    _CheckoutField(
                      controller: _address1Ctrl,
                      hint: 'Address line 1',
                      validator: _required,
                    ),

                    const SizedBox(height: 22),

                    _CheckoutField(
                      controller: _address2Ctrl,
                      hint: 'Address line 2',
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _CheckoutField(
                            controller: _cityCtrl,
                            hint: 'City',
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CheckoutField(
                            controller: _stateCtrl,
                            hint: 'State',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _CheckoutField(
                            controller: _postalCtrl,
                            hint: 'Postal code',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CheckoutField(
                            controller: _countryCtrl,
                            hint: 'Country',
                            validator: _required,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    const _SectionTitle(title: 'Payment'),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: HomeTokens.border),
                        color: HomeTokens.white.withValues(alpha: 0.62),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: HomeTokens.text,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cash on Delivery',
                            style: HomeTokens.bodyBold(size: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    const _SectionTitle(title: 'Order Summary'),

                    const SizedBox(height: 14),

                    _SummaryRow(
                      label: 'Items',
                      value: '$_totalItems',
                    ),

                    _SummaryRow(
                      label: 'Subtotal',
                      value: '\$${widget.subtotal.toStringAsFixed(2)}',
                    ),

                    _SummaryRow(
                      label: 'Delivery',
                      value: widget.deliveryFee == 0
                          ? 'FREE'
                          : '\$${widget.deliveryFee.toStringAsFixed(2)}',
                    ),

                    Container(
                      height: 1.2,
                      color: HomeTokens.text,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    _SummaryRow(
                      label: 'Total',
                      value: '\$${widget.total.toStringAsFixed(2)}',
                      large: true,
                    ),

                    const SizedBox(height: 30),

                    Material(
                      color: _placing
                          ? HomeTokens.lightGray
                          : HomeTokens.text,
                      child: InkWell(
                        onTap: _placing ? null : _placeOrder,
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: Center(
                            child: _placing
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: HomeTokens.linen,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'PLACE ORDER',
                              style: HomeTokens.label(
                                color: HomeTokens.linen,
                                size: 11,
                              ),
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
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: HomeTokens.border),
          color: HomeTokens.card,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: HomeTokens.text,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: HomeTokens.displayMedium().copyWith(
        fontSize: 30,
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CheckoutField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: HomeTokens.text,
      cursorWidth: 1.4,
      validator: validator,
      style: HomeTokens.displayMedium(
        color: HomeTokens.text,
      ).copyWith(
        fontSize: 24,
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        isDense: true,
        hintText: hint,
        hintStyle: HomeTokens.displayMedium(
          color: const Color(0xFFB8B8B8),
        ).copyWith(
          fontSize: 24,
          letterSpacing: 0.2,
        ),
        errorStyle: HomeTokens.body(
          size: 11,
          color: HomeTokens.sale,
        ),
        contentPadding: const EdgeInsets.only(bottom: 10),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: HomeTokens.text,
            width: 1.2,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: HomeTokens.text,
            width: 1.2,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: HomeTokens.text,
            width: 1.6,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: HomeTokens.sale,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: HomeTokens.sale,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: large
                ? HomeTokens.displayMedium().copyWith(fontSize: 28)
                : HomeTokens.label(
              color: HomeTokens.text,
              size: 10,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: large
                ? HomeTokens.price(size: 20)
                : HomeTokens.bodyBold(size: 14),
          ),
        ],
      ),
    );
  }
}