// lib/features/home/presentation/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../theme/home_tokens.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: HomeTokens.linen,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIGN OUT',
                  style: HomeTokens.displayMedium().copyWith(
                    fontSize: 30,
                    letterSpacing: 1.8,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  height: 1.2,
                  width: double.infinity,
                  color: HomeTokens.text,
                ),

                const SizedBox(height: 18),

                Text(
                  'Are you sure you want to sign out from Athimart?',
                  style: HomeTokens.body(
                    size: 14,
                    color: HomeTokens.darkGray,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'CANCEL',
                        dark: false,
                        onTap: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _DialogButton(
                        label: 'SIGN OUT',
                        dark: true,
                        onTap: () {
                          Navigator.of(dialogContext).pop(true);
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
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go('/auth/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          HomeTokens.pagePadding,
          14,
          HomeTokens.pagePadding,
          14,
        ),
        decoration: const BoxDecoration(
          color: HomeTokens.linen,
          border: Border(
            bottom: BorderSide(color: HomeTokens.border),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Text(
                'ATHIMART',
                style: HomeTokens.title(size: 22),
              ),
            ),

            const Spacer(),

            _AppBarIcon(
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => context.go('/admin'),
            ),

            const SizedBox(width: 10),

            _AppBarIcon(
              icon: Icons.search_rounded,
              onTap: () => context.push('/search'),
            ),

            const SizedBox(width: 10),

            _AppBarIcon(
              icon: Icons.logout_rounded,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIcon({
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: HomeTokens.border),
          ),
          child: Icon(
            icon,
            color: HomeTokens.text,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final bool dark;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? HomeTokens.text : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: HomeTokens.text),
          ),
          child: Center(
            child: Text(
              label,
              style: HomeTokens.label(
                color: dark ? HomeTokens.linen : HomeTokens.text,
                size: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}