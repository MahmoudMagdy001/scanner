import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/entities/saved_scan_entity.dart';

class SavedDataCard extends StatelessWidget {
  const SavedDataCard({super.key, this.savedData});
  final SavedScanEntity? savedData;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    decoration: BoxDecoration(
      color: colorSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colorBorder, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: colorPrimary.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        // ─── Left accent ───
        Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            color: colorAccent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 14),

        // ─── Data ───
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DataRow(label: 'PIN', value: savedData?.pin ?? '—'),
              const SizedBox(height: 6),
              _DataRow(label: 'Serial', value: savedData?.serial ?? '—'),
            ],
          ),
        ),

        // ─── Edit icon ───
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorPrimary.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.edit_outlined, size: 18, color: colorPrimary),
        ),
      ],
    ),
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '$label: ',
        style: AppTextStyles.labelMedium.copyWith(color: colorTextSecondary),
      ),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
