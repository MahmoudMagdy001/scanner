import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline }

@immutable
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text = '',
    this.fontSize = 16,
    this.onPress,
    this.widthButton,
    this.heightButton,
    this.isBold = true,
    this.isIcon = false,
    this.icon,
    this.bgColor,
    this.borderColor,
    this.fontColor,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
  });

  final String text;
  final double fontSize;
  final bool isBold;
  final VoidCallback? onPress;
  final double? widthButton;
  final double? heightButton;
  final bool isIcon;
  final Widget? icon;
  final Color? bgColor;
  final Color? borderColor;
  final Color? fontColor;
  final bool isLoading;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final h = heightButton ?? 52.0;
    final w = widthButton ?? double.infinity;

    final Color bg =
        bgColor ??
        (variant == ButtonVariant.outline
            ? Colors.transparent
            : variant == ButtonVariant.secondary
            ? colorSurfaceVariant
            : colorPrimary);
    final Color fg =
        fontColor ??
        (variant == ButtonVariant.outline
            ? colorPrimary
            : variant == ButtonVariant.secondary
            ? colorTextPrimary
            : colorSurface);
    final Color border =
        borderColor ??
        (variant == ButtonVariant.outline ? colorPrimary : Colors.transparent);

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isIcon && icon != null) ...[icon!, const SizedBox(width: 8)],
          if (text.isNotEmpty)
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: fg,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
        boxShadow: (variant == ButtonVariant.primary && !isLoading)
            ? [
                BoxShadow(
                  color: colorPrimary.withAlpha(36),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLoading ? null : onPress,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withAlpha(30),
          highlightColor: Colors.white.withAlpha(15),
          child: Center(child: content),
        ),
      ),
    );
  }
}
