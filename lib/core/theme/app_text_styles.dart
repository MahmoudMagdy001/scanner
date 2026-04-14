import 'package:flutter/material.dart';

import 'app_colors.dart';

const String _font = 'Tajwal';

class AppTextStyles {
  AppTextStyles._();

  // ─── Display ───
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: colorTextPrimary,
    height: 1.3,
  );

  // ─── Titles ───
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: colorTextPrimary,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: colorTextPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: colorTextPrimary,
    height: 1.4,
  );

  // ─── Body ───
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: colorTextPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: colorTextSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: colorTextSecondary,
    height: 1.4,
  );

  // ─── Labels / UI ───
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: colorSurface,
    letterSpacing: 0.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: colorTextSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: colorTextHint,
    letterSpacing: 0.2,
  );

  // ─── Button ───
  static const TextStyle button = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: colorSurface,
    letterSpacing: 0.2,
  );

  // ─── Input ───
  static const TextStyle inputText = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: colorTextPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: colorTextHint,
  );
}
