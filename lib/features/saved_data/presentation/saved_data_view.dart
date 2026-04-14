import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../component/saved_data_card.dart';
import 'cubit/saved_data_cubit.dart';
import 'cubit/saved_data_state.dart';

class SavedDataView extends StatelessWidget {
  const SavedDataView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GetIt.I<SavedDataCubit>()..loadScans(),
    child: Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text('Saved Scans', style: AppTextStyles.titleMedium),
        backgroundColor: colorSurface,
        foregroundColor: colorPrimary,
        centerTitle: true,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: colorDivider),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SavedDataCubit, SavedDataState>(
          builder: (context, state) {
            final cubit = SavedDataCubit.of(context);
            final scans = cubit.scans;

            if (state is SavedDataLoading ||
                (state is SavedDataInitial && scans.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(color: colorPrimary),
              );
            }

            if (state is SavedDataError) {
              return const _EmptyOrErrorState(
                icon: Icons.cloud_off_outlined,
                title: 'Connection Error',
                message: 'Unable to load saved scans.\nPlease try again later.',
                isError: true,
              );
            }

            if (scans.isEmpty) {
              return const _EmptyOrErrorState(
                icon: Icons.inbox_outlined,
                title: 'No Scans Yet',
                message:
                    "You don't have any saved scans yet.\nStart scanning a card!",
              );
            }

            return Column(
              children: [
                // ─── Stats Bar ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorBorder, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorPrimary.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.list_alt_rounded,
                                size: 16,
                                color: colorPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${scans.length} Records',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _ActionChip(
                              label: 'Excel',
                              icon: Icons.table_chart_outlined,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _ActionChip(
                              label: 'Email',
                              icon: Icons.email_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Search ───
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: CustomTextField(
                    hint: 'Search by PIN or serial…',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                  ),
                ),

                // ─── List ───
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: scans.length,
                    itemBuilder: (context, index) =>
                        SavedDataCard(savedData: scans[index]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _EmptyOrErrorState extends StatelessWidget {
  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color color = isError ? colorError : colorTextSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(color: colorTextPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
