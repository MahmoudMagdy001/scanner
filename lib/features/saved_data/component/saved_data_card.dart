import 'package:flutter/material.dart';
import 'package:qrscanner/core/theme/app_colors.dart';
import 'package:qrscanner/core/theme/app_text_styles.dart';
import 'package:qrscanner/features/saved_data/domain/entities/saved_scan_entity.dart';

class SavedDataCard extends StatelessWidget {
  const SavedDataCard({super.key, this.savedData});
  final SavedScanEntity? savedData;

  String _formatPin(String? pin) {
    if (pin == null || pin.isEmpty) return '—';
    // ponytail: strip spaces and format standard 14-digit PINs into 4-3-4-3 groupings
    final clean = pin.replaceAll(RegExp(r'\s+'), '');
    if (clean.length == 14) {
      return '${clean.substring(0, 4)} ${clean.substring(4, 7)} ${clean.substring(7, 11)} ${clean.substring(11)}';
    }
    return pin;
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    decoration: BoxDecoration(
      color: colorSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colorBorder, width: 1.2),
      boxShadow: [BoxShadow(color: colorPrimary.withAlpha(10), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Row(
      children: [
        // ─── Left accent ───
        Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(color: colorAccent, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 14),

        // ─── Data ───
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DataRow(label: 'PIN', value: _formatPin(savedData?.pin)),
              const SizedBox(height: 6),
              _DataRow(label: 'Serial', value: savedData?.serial ?? '—'),
            ],
          ),
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
      Text('$label: ', style: AppTextStyles.labelMedium.copyWith(color: colorTextSecondary)),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(color: colorTextPrimary, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
