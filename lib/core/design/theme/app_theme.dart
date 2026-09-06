import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColor.background,

    colorScheme: const ColorScheme.light(
      primary: AppColor.primary,
      secondary: AppColor.secondary,
      surface: AppColor.surface,
      onSurface: AppColor.textPrimary,
    ),

    cardColor: AppColor.surface,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.background,
      foregroundColor: AppColor.textPrimary,
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColor.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: AppColor.primary,
      secondary: AppColor.secondary,
      surface: AppColor.darkSurface,
      onSurface: Colors.white,
    ),

    cardColor: AppColor.darkCard,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}