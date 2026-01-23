import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const OrangeButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: AppTextStyles.textnoir.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
