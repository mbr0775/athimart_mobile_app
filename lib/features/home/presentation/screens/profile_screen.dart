// lib/features/home/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/services/user_profile_service.dart';
import '../theme/home_tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;

  String? _error;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await UserProfileService.getMyProfile();

      if (!mounted) return;

      _profile = profile;
      _fillControllers(profile);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _fillControllers(UserProfile profile) {
    _fullNameCtrl.text = profile.fullName;
    _phoneCtrl.text = profile.phone;
    _emailCtrl.text = profile.email;
    _address1Ctrl.text = profile.addressLine1;
    _address2Ctrl.text = profile.addressLine2;
    _cityCtrl.text = profile.city;
    _stateCtrl.text = profile.state;
    _postalCodeCtrl.text = profile.postalCode;
    _countryCtrl.text = profile.country;
  }

  void _startEditing() {
    final profile = _profile;
    if (profile != null) {
      _fillControllers(profile);
    }

    setState(() {
      _editing = true;
      _error = null;
    });
  }

  void _cancelEditing() {
    final profile = _profile;
    if (profile != null) {
      _fillControllers(profile);
    }

    setState(() {
      _editing = false;
      _error = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final current = _profile;
    if (current == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = current.copyWith(
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        addressLine1: _address1Ctrl.text.trim(),
        addressLine2: _address2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        postalCode: _postalCodeCtrl.text.trim(),
        country: _countryCtrl.text.trim().isEmpty
            ? 'Sri Lanka'
            : _countryCtrl.text.trim(),
      );

      await UserProfileService.updateMyProfile(updated);

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _saving = false;
        _editing = false;
      });

      _showSnack('Profile updated successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.toString();
      });

      _showSnack('Failed to update profile', error: true);
    }
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? HomeTokens.sale : HomeTokens.text,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _initialFor(UserProfile profile) {
    final name = profile.fullName.trim();

    if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }

    final email = profile.email.trim();

    if (email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }

    return 'A';
  }

  String _valueOrEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not added yet' : trimmed;
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
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(
              color: HomeTokens.text,
              strokeWidth: 2,
            ),
          )
              : _error != null && _profile == null
              ? _ErrorView(
            message: _error!,
            onRetry: _loadProfile,
          )
              : RefreshIndicator(
            color: HomeTokens.text,
            backgroundColor: HomeTokens.linen,
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 120),
              child: _editing
                  ? _buildEditMode()
                  : _buildViewMode(_profile!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileTitle(
          title: 'MY\nPROFILE',
          trailing: _SquareIconButton(
            icon: Icons.edit_outlined,
            onTap: _startEditing,
          ),
        ),

        const SizedBox(height: 22),

        _ProfileHeader(
          initial: _initialFor(profile),
          name: _valueOrEmpty(profile.fullName),
          email: profile.email,
          role: profile.role,
        ),

        const SizedBox(height: 36),

        const _SectionTitle(
          title: 'Account Details',
          subtitle: 'Your personal account information.',
        ),

        const SizedBox(height: 18),

        _DetailsCard(
          children: [
            _InfoRow(
              label: 'Full Name',
              value: _valueOrEmpty(profile.fullName),
              icon: Icons.person_outline_rounded,
            ),
            _InfoRow(
              label: 'Phone Number',
              value: _valueOrEmpty(profile.phone),
              icon: Icons.phone_outlined,
            ),
            _InfoRow(
              label: 'Email Address',
              value: profile.email,
              icon: Icons.email_outlined,
              showDivider: false,
            ),
          ],
        ),

        const SizedBox(height: 40),

        const _SectionTitle(
          title: 'Shipping Details',
          subtitle: 'This address will be used during checkout.',
        ),

        const SizedBox(height: 18),

        _DetailsCard(
          children: [
            _InfoRow(
              label: 'Address Line 1',
              value: _valueOrEmpty(profile.addressLine1),
              icon: Icons.location_on_outlined,
            ),
            _InfoRow(
              label: 'Address Line 2',
              value: _valueOrEmpty(profile.addressLine2),
              icon: Icons.add_road_outlined,
            ),
            _InfoRow(
              label: 'City',
              value: _valueOrEmpty(profile.city),
              icon: Icons.location_city_outlined,
            ),
            _InfoRow(
              label: 'State / Province',
              value: _valueOrEmpty(profile.state),
              icon: Icons.map_outlined,
            ),
            _InfoRow(
              label: 'Postal Code',
              value: _valueOrEmpty(profile.postalCode),
              icon: Icons.local_post_office_outlined,
            ),
            _InfoRow(
              label: 'Country',
              value: _valueOrEmpty(profile.country),
              icon: Icons.public_outlined,
              showDivider: false,
            ),
          ],
        ),

        const SizedBox(height: 34),

        _PrimaryButton(
          text: 'Edit Profile',
          icon: Icons.edit_outlined,
          loading: false,
          onTap: _startEditing,
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileTitle(
            title: 'EDIT\nPROFILE',
            trailing: _SquareIconButton(
              icon: Icons.close_rounded,
              onTap: _cancelEditing,
            ),
          ),

          const SizedBox(height: 22),

          const _SectionTitle(
            title: 'Account Details',
            subtitle: 'Update your personal account information.',
          ),

          const SizedBox(height: 18),

          _ProfileTextField(
            controller: _fullNameCtrl,
            hint: 'Full name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          _ProfileTextField(
            controller: _phoneCtrl,
            hint: 'Phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          _ProfileTextField(
            controller: _emailCtrl,
            hint: 'Email address',
            readOnly: true,
          ),

          const SizedBox(height: 42),

          const _SectionTitle(
            title: 'Shipping Details',
            subtitle: 'This address will be used during checkout.',
          ),

          const SizedBox(height: 18),

          _ProfileTextField(
            controller: _address1Ctrl,
            hint: 'Address line 1',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Shipping address is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          _ProfileTextField(
            controller: _address2Ctrl,
            hint: 'Address line 2',
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _ProfileTextField(
                  controller: _cityCtrl,
                  hint: 'City',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ProfileTextField(
                  controller: _stateCtrl,
                  hint: 'State',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _ProfileTextField(
                  controller: _postalCodeCtrl,
                  hint: 'Postal code',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ProfileTextField(
                  controller: _countryCtrl,
                  hint: 'Country',
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 20),
            Text(
              _error!,
              style: HomeTokens.body(
                size: 12,
                color: HomeTokens.sale,
              ),
            ),
          ],

          const SizedBox(height: 36),

          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  text: 'Cancel',
                  onTap: _saving ? null : _cancelEditing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryButton(
                  text: 'Save',
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onTap: _saving ? null : _saveProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _ProfileTitle({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: HomeTokens.displayLarge().copyWith(
                  fontSize: 46,
                  letterSpacing: 2.4,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1.2,
          width: double.infinity,
          color: HomeTokens.text,
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final String role;

  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTokens.white.withValues(alpha: 0.62),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: HomeTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                border: Border.all(
                  color: HomeTokens.text,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: HomeTokens.displayMedium().copyWith(
                    fontSize: 34,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.toUpperCase(),
                    style: HomeTokens.label(size: 9),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.bodyBold(size: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTokens.body(size: 12),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: HomeTokens.displayMedium().copyWith(
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: HomeTokens.body(size: 13),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTokens.white.withValues(alpha: 0.62),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: HomeTokens.border),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.showDivider = true,
  });

  bool get _empty => value == 'Not added yet';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                color: _empty ? HomeTokens.lightGray : HomeTokens.text,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: HomeTokens.label(size: 8),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: HomeTokens.bodyBold(
                        size: 14,
                        color: _empty ? HomeTokens.lightGray : HomeTokens.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: HomeTokens.border,
          ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _ProfileTextField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      cursorColor: HomeTokens.text,
      style: HomeTokens.displayMedium().copyWith(
        fontSize: 25,
        letterSpacing: 0.2,
        color: readOnly ? HomeTokens.darkGray : HomeTokens.text,
      ),
      validator: validator,
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        hintText: hint,
        hintStyle: HomeTokens.displayMedium(
          color: const Color(0xFFB8B8B8),
        ).copyWith(
          fontSize: 25,
          letterSpacing: 0.2,
        ),
        errorStyle: HomeTokens.body(
          size: 12,
          color: HomeTokens.sale,
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
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: HomeTokens.sale, width: 1.2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: HomeTokens.sale, width: 1.6),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTokens.card,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: HomeTokens.border),
          ),
          child: Icon(
            icon,
            color: HomeTokens.text,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.text,
    required this.loading,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? HomeTokens.lightGray : HomeTokens.text,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Center(
            child: loading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: HomeTokens.linen,
                strokeWidth: 2,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: HomeTokens.linen,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text.toUpperCase(),
                  style: HomeTokens.label(
                    color: HomeTokens.linen,
                    size: 11,
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

class _OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _OutlineButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: HomeTokens.text),
          ),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: HomeTokens.label(
                color: HomeTokens.text,
                size: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: HomeTokens.sale,
              size: 48,
            ),
            const SizedBox(height: 18),
            Text(
              'PROFILE ERROR',
              style: HomeTokens.displayMedium().copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: HomeTokens.body(size: 13),
            ),
            const SizedBox(height: 26),
            _PrimaryButton(
              text: 'Retry',
              loading: false,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}