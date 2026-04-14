import 'package:flutter/material.dart';

/// ─── Primary brand color (kept exactly as original) ───
const Color colorPrimary = Color.fromRGBO(31, 43, 70, 1); // #1F2B46 deep navy

/// ─── Accent / action color ───
const Color colorAccent = Color(0xFF36BFC6); // teal

/// ─── Background & surfaces ───
const Color colorBackground = Color(0xFFF5F6FA); // soft light-grey page bg
const Color colorSurface = Color(0xFFFFFFFF); // card / sheet surface
const Color colorSurfaceVariant = Color(0xFFEEF0F8); // subtle section bg

/// ─── Borders & dividers ───
const Color colorBorder = Color(0xFFDDE1EF);
const Color colorDivider = Color(0xFFEAEDF5);

/// ─── Text ───
const Color colorTextPrimary = Color(0xFF1F2B46); // same as brand navy
const Color colorTextSecondary = Color(0xFF6B7A99);
const Color colorTextHint = Color(0xFFADB5C8);

/// ─── Semantic ───
const Color colorError = Color(0xFFD9534F);
const Color colorSuccess = Color(0xFF2ECC71);
const Color colorWarning = Color(0xFFF0A500);

/// ─── Gradient (header / splashes) ───
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1F2B46), Color(0xFF2D4070)],
);

/// ─── Legacy aliases (kept so existing code that imports constant.dart still works) ───
Color colorSelectedBN = colorAccent;
Color colorSecondary = const Color.fromRGBO(233, 239, 255, 1);
Color colorLightGrey = const Color(0xFF707070);
BoxDecoration containerDecoration = const BoxDecoration(gradient: primaryGradient);
