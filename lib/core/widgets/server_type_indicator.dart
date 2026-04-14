import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServerTypeIndicator extends StatelessWidget {
  const ServerTypeIndicator({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final isIP = RegExp(r'^(\d{1,3}\.){3}\d{1,3}(:\d+)?$').hasMatch(text);

    final Color borderColor = isIP ? colorSuccess : colorAccent;
    final Color bgColor = isIP
        ? colorSuccess.withAlpha(18)
        : colorAccent.withAlpha(18);
    final IconData icon = isIP ? Icons.router_outlined : Icons.cloud_outlined;
    final String label = isIP ? 'Local Server' : 'Production Server';
    final String address = isIP ? 'http://$text' : 'https://$text';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withAlpha(120), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: borderColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: borderColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: AppTextStyles.bodySmall.copyWith(color: borderColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
