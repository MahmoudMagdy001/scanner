import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

@immutable
class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    this.text = '',
    this.fontSize,
    this.color,
    this.alignment,
    this.fontWeight,
    this.verticalMargin = 0,
    this.horizontalMargin = 0,
    this.textAlign,
    this.decoration,
    this.fontFamily,
    this.maxLines,
    this.style,
  });

  final String text;
  final double? fontSize;
  final String? fontFamily;
  final Color? color;
  final Alignment? alignment;
  final FontWeight? fontWeight;
  final double verticalMargin;
  final double horizontalMargin;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Default to bodyLarge if no style or specific props are provided
    final baseStyle = style ?? AppTextStyles.bodyLarge;

    final finalStyle = baseStyle.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      fontFamily: fontFamily,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin,
        horizontal: horizontalMargin,
      ),
      alignment: alignment,
      child: Text(
        text,
        maxLines: maxLines,
        style: finalStyle,
        textAlign: textAlign,
      ),
    );
  }
}
