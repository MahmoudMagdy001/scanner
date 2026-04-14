import 'package:flutter/material.dart';

import '../theme/app_colors.dart' as theme;

/// ─── Legacy Bridge ───
/// This file maintains aliases to the new design system in lib/theme/
/// to ensure backward compatibility with existing code.

Color get colorPrimary => theme.colorPrimary;
Color get colorSelectedBN => theme.colorAccent;
Color get colorSecondary => const Color.fromRGBO(233, 239, 255, 1);
Color get colorLightGrey => const Color(0xFF707070);

BoxDecoration get containerDecoration => theme.containerDecoration;
