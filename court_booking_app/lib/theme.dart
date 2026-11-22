import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF1F7A4D);
  static const deepGreen = Color(0xFF0F3D2E);
  static const sage = Color(0xFFEAF2EC);
  static const background = Color(0xFFF4F7F2);
  static const ink = Color(0xFF0F2A20);
  static const muted = Color(0xFF5B6B62);
  static const border = Color(0xFFCBD6CF);
  static const tint = Color(0xFFE3F0E8);
  static const lime = Color(0xFFC6F432);
  static const danger = Color(0xFFB3261E);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
}

/// Rounded green tile with the tennis-ball icon (app logo).
class LogoTile extends StatelessWidget {
  final double size;
  const LogoTile({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(Icons.sports_tennis, color: Colors.white, size: size * 0.55),
    );
  }
}

OutlineInputBorder _border(Color c, [double w = 1.5]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );

/// Text field with a label above it.
class LabeledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const LabeledField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF26362E),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7D8B83)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffix,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.green, 2),
            errorBorder: _border(AppColors.danger),
            focusedErrorBorder: _border(AppColors.danger, 2),
          ),
        ),
      ],
    );
  }
}

/// Full-width green button with a loading state.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          disabledBackgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Themed message bar. Green for success, red for errors.
void showAppMessage(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? AppColors.green : AppColors.danger,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 4),
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}