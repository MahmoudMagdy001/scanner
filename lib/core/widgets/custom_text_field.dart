import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.hint,
    this.labelText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.secure = false,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor = colorSurface,
    this.textColor,
    this.radius = 12,
    this.height = 16,
    this.keyboardType,
  });

  final String? hint;
  final String? labelText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  final bool secure;
  final bool isReadOnly;
  final int maxLines;
  final int? maxLength;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final Color fillColor;
  final Color? textColor;
  final double radius;
  final double height;
  final TextInputType? keyboardType;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.secure;
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    readOnly: widget.isReadOnly,
    obscureText: _obscure,
    keyboardType: widget.keyboardType,
    maxLines: widget.secure ? 1 : widget.maxLines,
    maxLength: widget.maxLength,
    onChanged: widget.onChanged,
    onTap: widget.onTap,
    onTapOutside: (_) => FocusScope.of(context).unfocus(),
    cursorColor: colorPrimary,
    style: AppTextStyles.inputText.copyWith(
      color: widget.textColor ?? colorTextPrimary,
    ),
    validator: widget.validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: widget.fillColor,
      hintText: widget.hint,
      hintStyle: AppTextStyles.inputHint,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.secure
          ? IconButton(
              iconSize: 20,
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorTextSecondary,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : widget.suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: widget.height,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: const BorderSide(color: colorBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: const BorderSide(color: colorBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: const BorderSide(color: colorPrimary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: const BorderSide(color: colorError, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: const BorderSide(color: colorError, width: 1.8),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: colorError),
    ),
  );
}
