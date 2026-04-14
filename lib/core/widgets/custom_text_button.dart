import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    this.text = '',
    this.color,
    this.onPressed,
    this.alignment,
    this.fontWeight,
    this.textDecoration,
  });
  final String text;
  final Color? color;
  final VoidCallback? onPressed;
  final Alignment? alignment;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          decoration: textDecoration ?? TextDecoration.underline,
          color: color ?? colorPrimary,
          fontWeight: fontWeight ?? FontWeight.w600,
        ),
      ),
    ),
  );
}
