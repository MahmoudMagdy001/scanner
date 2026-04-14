import 'package:flutter/material.dart';

import '../../core/dioHelper/dio_helper.dart';
import '../../core/router/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../card_type/presentation/card_type_view.dart';
import '../saved_data/presentation/saved_data_view.dart';

class CardScannerView extends StatelessWidget {
  const CardScannerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: colorBackground,
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorPrimary.withAlpha(60),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Housing System',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Card Scanner & Management',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Section Title ───
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text('Quick Actions', style: AppTextStyles.titleSmall),
            ),
          ),

          // ─── Action Cards ───
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _ActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan Card',
                  description: 'Start a new scan',
                  iconColor: colorPrimary,
                  iconBg: colorPrimary.withAlpha(18),
                  onTap: () => MagicRouter.navigateTo(const CardTypeView()),
                ),
                _ActionCard(
                  icon: Icons.bookmarks_outlined,
                  label: 'Saved Scans',
                  description: 'View history',
                  iconColor: colorAccent,
                  iconBg: colorAccent.withAlpha(22),
                  onTap: () => MagicRouter.navigateTo(const SavedDataView()),
                ),
              ]),
            ),
          ),

          // ─── Danger Zone ───
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text('Data Management', style: AppTextStyles.titleSmall),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverToBoxAdapter(child: clearDataCard(context)),
          ),
        ],
      ),
    ),
  );

  Widget clearDataCard(BuildContext context) => GestureDetector(
    onTap: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all saved scan data? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorError,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear'),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await DioHelper.post('delete', true, body: {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'All saved data has been cleared.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: colorSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorError.withAlpha(60), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colorError.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorError.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_sweep_outlined,
              color: colorError,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clear All Data',
                  style: AppTextStyles.titleSmall.copyWith(color: colorError),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Permanently delete all scan records',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: colorError, size: 20),
        ],
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.titleSmall),
          const SizedBox(height: 2),
          Text(description, style: AppTextStyles.bodySmall),
        ],
      ),
    ),
  );
}
