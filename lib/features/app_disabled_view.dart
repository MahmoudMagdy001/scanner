import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrscanner/core/theme/app_colors.dart';
import 'package:qrscanner/core/theme/app_text_styles.dart';
import 'package:qrscanner/core/widgets/custom_button.dart';
import 'package:qrscanner/core/widgets/l10n_extension.dart';

// ponytail: premium, responsive UI for service unavailable state
class AppDisabledView extends StatelessWidget {
  const AppDisabledView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: colorBackground,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ─── Header App Title ───
                Padding(
                  padding: EdgeInsets.only(top: 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: colorPrimary.withAlpha(12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: colorPrimary, size: 24.r),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        context.l10n.appTitle,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: colorPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Main Premium Card ───
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
                  decoration: BoxDecoration(
                    color: colorSurface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: colorBorder, width: 1.2.r),
                    boxShadow: [
                      BoxShadow(color: colorPrimary.withAlpha(12), blurRadius: 30.r, offset: Offset(0, 10.h)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Graphic / Icon Ring
                      Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: const BoxDecoration(color: colorSurfaceVariant, shape: BoxShape.circle),
                        child: Center(
                          child: Container(
                            width: 84.w,
                            height: 84.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorBorder.withAlpha(180), width: 1.5.r),
                              boxShadow: [
                                BoxShadow(color: colorPrimary.withAlpha(15), blurRadius: 15.r, offset: Offset(0, 5.h)),
                              ],
                            ),
                            child: Icon(Icons.cloud_off_rounded, size: 40.r, color: colorPrimary),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Text Content
                      Text(
                        context.l10n.serviceUnavailable,
                        style: AppTextStyles.displayLarge.copyWith(fontSize: 22.sp, color: colorTextPrimary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        context.l10n.appDisabledMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorTextSecondary,
                          height: 1.6,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ─── Contact Support Action ───
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: CustomButton(
                    text: context.l10n.contactSupport,
                    heightButton: 52.h,
                    isIcon: true,
                    icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
                    onPress: () async {
                      await _showContactSupport(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _showContactSupport(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.r),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Handler
              Center(
                child: Container(
                  width: 48.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(color: colorBorder, borderRadius: BorderRadius.circular(2.r)),
                ),
              ),
              Text(
                context.l10n.supportDetails,
                style: AppTextStyles.titleLarge.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // Email Detail
              _ContactItem(
                icon: Icons.email_outlined,
                title: context.l10n.supportEmail,
                value: 'support@housingsystem.com',
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: 'support@housingsystem.com'));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Email address copied to clipboard!')));
                  }
                },
              ),
              SizedBox(height: 12.h),

              // Phone Detail
              _ContactItem(
                icon: Icons.phone_outlined,
                title: context.l10n.supportPhone,
                value: '+1 (800) 555-0199',
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: '+1 (800) 555-0199'));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Phone number copied to clipboard!')));
                  }
                },
              ),
              SizedBox(height: 24.h),

              // Close Button
              CustomButton(
                text: context.l10n.close,
                variant: ButtonVariant.outline,
                heightButton: 50.h,
                onPress: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ponytail: contact item widget for bottom sheet list
class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.icon, required this.title, required this.value, required this.onTap});

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border.all(color: colorBorder, width: 1.r),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: colorPrimary.withAlpha(10), shape: BoxShape.circle),
            child: Icon(icon, color: colorPrimary, size: 20.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall.copyWith(color: colorTextSecondary)),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(color: colorTextPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(Icons.copy_rounded, color: colorTextHint, size: 18.r),
        ],
      ),
    ),
  );
}
