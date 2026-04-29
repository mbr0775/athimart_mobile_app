// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(
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
          if (state is AuthAuthenticated) {
            if (state.isAdmin) {
              context.go('/admin');
            } else {
              context.go('/home');
            }
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
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
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

                      SizedBox(height: MediaQuery.of(context).size.height * 0.16),

                      Text(
                        'WELCOME\nBACK',
                        style: HomeTokens.displayLarge().copyWith(
                          fontSize: 44,
                          letterSpacing: 2.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Sign in to continue shopping.',
                        style: HomeTokens.body(size: 15),
                      ),

                      const SizedBox(height: 42),

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

                      const SizedBox(height: 28),

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
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/auth/forgot-password'),
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: HomeTokens.label(
                              color: HomeTokens.text,
                              size: 10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 38),

                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;

                          return _AuthPrimaryButton(
                            text: 'SIGN IN',
                            loading: loading,
                            onTap: loading ? null : _login,
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/auth/register'),
                          child: RichText(
                            text: TextSpan(
                              style: HomeTokens.body(size: 13),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Create one',
                                  style: HomeTokens.bodyBold(size: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),
                    ],
                  ),
                ),
              ),
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