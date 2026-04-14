import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppDisabledView extends StatelessWidget {
  const AppDisabledView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Illustration / Icon ───
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // ─── Text ───
              Text(
                'Service Unavailable',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The application is currently disabled.\nPlease contact the administrator or developer to activate the service.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withAlpha(200),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // ─── Optional Contact Action (commented for now, as in original) ───
              /*
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withAlpha(40),
                  ),
                  child: Text(
                    'Contact Support',
                    style: AppTextStyles.button.copyWith(color: colorPrimary),
                  ),
                ),
                */
            ],
          ),
        ),
      ),
    ),
  );
}
