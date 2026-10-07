import 'package:flutter/material.dart';

/// ألوان التطبيق المركزية — يُرجع دائماً من هنا ولا تُكتب مباشرة في الـ Widgets
abstract final class AppColors {
  static const primary = Color(0xFFD97757);
  static const primaryDark = Color(0xFFB85C3E);
  static const primaryLight = Color(0xFFF3C5B5);

  static const surface = Color(0xFFF7F4EF);
  static const card = Colors.white;

  static const textDark = Color(0xFF292524);
  static const textMid = Color(0xFF78716C);
  static const textLight = Color(0xFFB8B0A8);

  static const booked = Color(0xFF6B8E72);
  static const partial = Color(0xFFD59A3A);
  static const available = Color(0xFFE7E2DC);

  static const error = Color(0xFFC65D5D);
}

/// ثيم التطبيق الرئيسي
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: AppColors.surface,
  ),
  scaffoldBackgroundColor: AppColors.surface,
  fontFamily: 'Arial',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: AppColors.card,
    indicatorColor: AppColors.primaryLight,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(22)),
    ),
  ),
);
