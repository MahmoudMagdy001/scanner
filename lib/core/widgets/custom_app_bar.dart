import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A clean, minimal PreferredSizeWidget app bar.
/// Replaces the old full-height container approach.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.text,
    this.showBackButton = true,
    this.actions,
    this.bottom,
  });

  final String? text;
  final bool showBackButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    title: text != null
        ? Text(
            text!,
            style: AppTextStyles.titleMedium.copyWith(color: colorTextPrimary),
          )
        : null,
    centerTitle: true,
    backgroundColor: colorSurface,
    foregroundColor: colorPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black.withAlpha(25),
    automaticallyImplyLeading: showBackButton,
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: colorPrimary,
            onPressed: () => Navigator.maybePop(context),
          )
        : null,
    actions: actions,
    bottom:
        bottom ??
        const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: colorDivider),
        ),
  );
}
