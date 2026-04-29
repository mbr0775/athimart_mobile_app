// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTokens.linen,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showSnack(state.message);
            context.go('/auth/login');
          }

          if (state is AuthError) {
            _showSnack(state.message, error: true);
          }
        },
        child: SafeArea(
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
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go('/auth/login'),
                    child: const SizedBox(
                      width: 54,
                      height: 54,
                      child: Icon(
                        Icons.close_rounded,
                        color: HomeTokens.text,
                        size: 42,
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 34),

                        Text(
                          'ATHIMART',
                          style: HomeTokens.label(
                            color: HomeTokens.text,
                            size: 11,
                          ),
                        ),

                        const SizedBox(height: 84),

                        Text(
                          'CREATE\nACCOUNT',
                          style: HomeTokens.displayLarge().copyWith(
                            fontSize: 42,
                            letterSpacing: 2.2,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Join Athimart and start shopping.',
                          style: HomeTokens.body(size: 15),
                        ),

                        const SizedBox(height: 38),

                        _AuthTextField(
                          controller: _nameCtrl,
                          hint: 'Full name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        _AuthTextField(
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

                        _AuthTextField(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        _AuthTextField(
                          controller: _passwordCtrl,
                          hint: 'Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: HomeTokens.darkGray,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        _AuthTextField(
                          controller: _confirmPasswordCtrl,
                          hint: 'Confirm password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: HomeTokens.darkGray,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password is required';
                            }
                            if (value != _passwordCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 36),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final loading = state is AuthLoading;

                            return _AuthPrimaryButton(
                              text: 'CREATE ACCOUNT',
                              loading: loading,
                              onTap: loading ? null : _register,
                            );
                          },
                        ),

                        const SizedBox(height: 26),

                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/auth/login'),
                            child: RichText(
                              text: TextSpan(
                                style: HomeTokens.body(size: 13),
                                children: [
                                  const TextSpan(
                                    text: 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: HomeTokens.bodyBold(size: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
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

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: HomeTokens.text,
      style: HomeTokens.displayMedium().copyWith(
        fontSize: 25,
        letterSpacing: 0.2,
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
        suffixIcon: suffixIcon,
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

class _AuthPrimaryButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onTap;

  const _AuthPrimaryButton({
    required this.text,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? HomeTokens.lightGray : HomeTokens.text,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
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
                : Text(
              text,
              style: HomeTokens.label(
                color: HomeTokens.linen,
                size: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}