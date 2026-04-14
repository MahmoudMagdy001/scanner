import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colorPrimary,
      onPrimary: colorSurface,
      primaryContainer: Color(0xFFD8DFEE),
      onPrimaryContainer: colorPrimary,
      secondary: colorAccent,
      onSecondary: colorSurface,
      secondaryContainer: Color(0xFFD0F4F5),
      onSecondaryContainer: Color(0xFF006064),
      tertiary: colorAccent,
      onTertiary: colorSurface,
      error: colorError,
      onError: colorSurface,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: colorError,
      surface: colorSurface,
      onSurface: colorTextPrimary,
      onSurfaceVariant: colorTextSecondary,
      outline: colorBorder,
      outlineVariant: colorDivider,
      shadow: Color(0x1A1F2B46),
      inverseSurface: colorPrimary,
      onInverseSurface: colorSurface,
      surfaceTint: Color(0x0A36BFC6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Tajwal',
      scaffoldBackgroundColor: colorBackground,

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: colorSurface,
        foregroundColor: colorTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withAlpha(25),
        centerTitle: true,
        iconTheme: const IconThemeData(color: colorPrimary),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: colorTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: colorBackground,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        shape: const Border(bottom: BorderSide(color: colorDivider)),
      ),

      // ─── Cards ───
      cardTheme: CardThemeData(
        color: colorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorBorder.withAlpha(120)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        shadowColor: colorPrimary.withAlpha(25),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: colorSurface,
          disabledBackgroundColor: colorBorder,
          disabledForegroundColor: colorTextHint,
          elevation: 0,
          shadowColor: colorPrimary.withAlpha(60),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorPrimary,
          side: const BorderSide(color: colorPrimary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.button.copyWith(color: colorPrimary),
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorAccent,
          textStyle: AppTextStyles.labelMedium.copyWith(color: colorAccent),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ─── Input / TextField ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorSurface,
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorTextSecondary,
        ),
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorPrimary,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorError, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorError, width: 1.8),
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: colorError),
        prefixIconColor: colorTextSecondary,
        suffixIconColor: colorTextSecondary,
      ),

      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ─── Divider ───
      dividerTheme: const DividerThemeData(
        color: colorDivider,
        thickness: 1,
        space: 1,
      ),

      // ─── Progress Indicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: colorPrimary,
        linearTrackColor: colorBorder,
      ),

      // ─── Icon ───
      iconTheme: const IconThemeData(color: colorTextSecondary, size: 22),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: colorSurfaceVariant,
        labelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: colorBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ─── List Tile ───
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: colorPrimary,
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodyMedium,
      ),

      // ─── Page Transitions ───
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
