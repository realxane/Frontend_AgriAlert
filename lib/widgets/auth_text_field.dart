import 'package:flutter/material.dart';
import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool readOnly;
  final bool showCursor;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.showCursor = true,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      showCursor: showCursor,
      onTap: onTap,
      style: AppTextStyles.textnoir,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.textgris,
        filled: true,
        fillColor: AppColors.gris2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
