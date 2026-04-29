// lib/features/admin/presentation/widgets/admin_ui.dart
import 'package:flutter/material.dart';

import '../theme/admin_tokens.dart';

class AdminPage extends StatelessWidget {
  final Widget child;

  const AdminPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AdminTokens.pageGradient,
      ),
      child: child,
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const AdminSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdminTokens.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AdminTokens.displayMedium(),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: AdminTokens.body(size: 12),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!.toUpperCase(),
                    style: AdminTokens.label(color: AdminTokens.text),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 1,
                    color: AdminTokens.text,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AdminPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;

  const AdminPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AdminTokens.lightGray : AdminTokens.text,
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
                color: AdminTokens.linen,
                strokeWidth: 2,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AdminTokens.linen,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text.toUpperCase(),
                  style: AdminTokens.label(
                    color: AdminTokens.linen,
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

class AdminOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;

  const AdminOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.color = AdminTokens.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: color),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 7),
                ],
                Text(
                  text.toUpperCase(),
                  style: AdminTokens.label(
                    color: color,
                    size: 10,
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

class AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AdminTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: AdminTokens.text,
      style: AdminTokens.displayMedium().copyWith(
        fontSize: 24,
        letterSpacing: 0.2,
      ),
      validator: validator,
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        hintText: hint,
        hintStyle: AdminTokens.displayMedium(
          color: const Color(0xFFB8B8B8),
        ).copyWith(
          fontSize: 24,
          letterSpacing: 0.2,
        ),
        errorStyle: AdminTokens.body(
          size: 12,
          color: AdminTokens.danger,
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
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AdminTokens.danger, width: 1.2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AdminTokens.danger, width: 1.6),
        ),
      ),
    );
  }
}

class AdminChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AdminChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminTokens.text : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AdminTokens.text),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: AdminTokens.label(
                color: selected ? AdminTokens.linen : AdminTokens.text,
                size: 9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;

  const AdminConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.confirmColor = AdminTokens.text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminTokens.linen,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        decoration: const BoxDecoration(
          gradient: AdminTokens.pageGradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AdminTokens.displayMedium()),
            const SizedBox(height: 14),
            Container(height: 1.2, color: AdminTokens.text),
            const SizedBox(height: 18),
            Text(message, style: AdminTokens.body(size: 14)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AdminOutlineButton(
                    text: 'Cancel',
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: confirmColor,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            confirmText.toUpperCase(),
                            style: AdminTokens.label(
                              color: AdminTokens.linen,
                              size: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}