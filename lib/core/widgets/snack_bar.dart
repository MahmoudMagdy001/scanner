import 'dart:async';

import 'package:flutter/material.dart';

import '../router/router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

void showSnackBar(
  String message, {
  bool upperSnackBar = false,
  bool popPage = false,
  int duration = 3,
  Color color = colorPrimary,
  bool isError = false,
  bool isSuccess = false,
}) {
  final context = MagicRouter.currentContext;
  if (!context.mounted) return;

  final Color bg = isError
      ? colorError
      : isSuccess
      ? colorSuccess
      : color;

  final IconData icon = isError
      ? Icons.error_outline_rounded
      : isSuccess
      ? Icons.check_circle_outline_rounded
      : Icons.info_outline_rounded;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      margin: upperSnackBar
          ? const EdgeInsets.only(bottom: 600)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      duration: Duration(seconds: duration),
    ),
  );
  if (popPage) Timer(Duration(seconds: duration), MagicRouter.pop);
}
