// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../home/presentation/theme/home_tokens.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendReset() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(
        email: _emailCtrl.text.trim(),
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
          if (state is AuthPasswordResetSent) {
            setState(() {
              _emailSent = true;
            });
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: _emailSent ? _SuccessView(email: _emailCtrl.text) : _FormView(
                      formKey: _formKey,
                      emailCtrl: _emailCtrl,
                      onSubmit: _sendReset,
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

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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

          SizedBox(height: MediaQuery.of(context).size.height * 0.20),

          Text(
            'RESET\nPASSWORD',
            style: HomeTokens.displayLarge().copyWith(
              fontSize: 42,
              letterSpacing: 2.2,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Enter your email and we'll send you a reset link.",
            style: HomeTokens.body(size: 15),
          ),

          const SizedBox(height: 42),

          _AuthTextField(
            controller: emailCtrl,
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

          const SizedBox(height: 38),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final loading = state is AuthLoading;

              return _AuthPrimaryButton(
                text: 'SEND RESET LINK',
                loading: loading,
                onTap: loading ? null : onSubmit,
              );
            },
          ),

          const SizedBox(height: 26),

          Center(
            child: GestureDetector(
              onTap: () => context.go('/auth/login'),
              child: Text(
                'BACK TO SIGN IN',
                style: HomeTokens.label(
                  color: HomeTokens.text,
                  size: 10,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;

  const _SuccessView({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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

        SizedBox(height: MediaQuery.of(context).size.height * 0.22),

        const Icon(
          Icons.mark_email_read_outlined,
          color: HomeTokens.text,
          size: 58,
        ),

        const SizedBox(height: 24),

        Text(
          'CHECK\nEMAIL',
          style: HomeTokens.displayLarge().copyWith(
            fontSize: 42,
            letterSpacing: 2.2,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'We sent a password reset link to:\n$email',
          style: HomeTokens.body(size: 15),
        ),

        const SizedBox(height: 38),

        _AuthPrimaryButton(
          text: 'BACK TO SIGN IN',
          loading: false,
          onTap: () => context.go('/auth/login'),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AuthTextField({
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