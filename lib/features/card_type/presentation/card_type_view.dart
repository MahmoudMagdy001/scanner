import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/router/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../extract_image/presentation/cubit/extract_image_cubit.dart';
import '../../extract_image/presentation/pages/extract_image_page.dart';
import 'cubit/card_type_cubit.dart';
import 'cubit/card_type_state.dart';

class CardTypeView extends StatelessWidget {
  const CardTypeView({super.key});

  static const List<String> _fallbackImages = [
    'assets/images/20.jpeg',
    'assets/images/25.jpeg',
    'assets/images/30.jpeg',
    'assets/images/50.jpeg',
    'assets/images/100.jpeg',
  ];

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GetIt.I<CardTypeCubit>()..getCategories(),
    child: BlocBuilder<CardTypeCubit, CardTypeState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        final cubit = CardTypeCubit.of(context);

        return Scaffold(
          backgroundColor: colorBackground,
          appBar: AppBar(
            title: const Text(
              'Select Card Type',
              style: AppTextStyles.titleMedium,
            ),
            backgroundColor: colorSurface,
            foregroundColor: colorPrimary,
            centerTitle: true,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: colorDivider),
            ),
          ),
          body: state is CardTypeLoading
              ? const Center(
                  child: CircularProgressIndicator(color: colorPrimary),
                )
              : cubit.categories.isEmpty
              ? const _EmptyState(
                  icon: Icons.dashboard_outlined,
                  message:
                      'No card types available.\nPlease check your server connection.',
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Types',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: colorTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 7,
                                mainAxisSpacing: 7,
                                childAspectRatio: 1.3,
                              ),
                          itemCount: cubit.categories.length,
                          itemBuilder: (context, index) {
                            final categories = cubit.categories;
                            final item = categories[index];
                            final fallbackImage =
                                _fallbackImages[index % _fallbackImages.length];

                            return _CategoryCard(
                              fallbackImage: fallbackImage,
                              label: item.name ?? '',
                              onTap: () {
                                MagicRouter.navigateTo(
                                  BlocProvider(
                                    create: (context) =>
                                        GetIt.I<ExtractImageCubit>()
                                          ..loadHistoryCount(),
                                    child: ExtractImagePage(
                                      scanType: item.name ?? '',
                                      categoryId: item.id!,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.fallbackImage,
    required this.label,
    required this.onTap,
  });

  final String fallbackImage;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(fallbackImage, fit: BoxFit.cover),
            // Gradient overlay for label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [colorPrimary.withAlpha(200), Colors.transparent],
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorPrimary.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: colorTextSecondary),
          ),
          const SizedBox(height: 20),
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
