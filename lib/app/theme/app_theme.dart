import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';

abstract final class AppTheme {
  static const _lightScheme = ColorScheme.light(
    primary: Color(0xFF263BFA),
    onPrimary: Colors.white,
    secondary: Color(0xFF238A50),
    onSecondary: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111114),
    error: Color(0xFFD92D3A),
    onError: Colors.white,
    outline: Color(0xFFE5E5E9),
    outlineVariant: Color(0xFFE5E5E9),
    shadow: Color(0xFF000000),
  );

  static const _darkScheme = ColorScheme.dark(
    primary: Color(0xFF263BFA),
    onPrimary: Colors.white,
    secondary: Color(0xFF62D891),
    onSecondary: Color(0xFF092315),
    surface: Color(0xFF1D1E24),
    onSurface: Color(0xFFF2F2F5),
    error: Color(0xFFFF7C84),
    onError: Color(0xFF3D080D),
    outline: Color(0xFF777984),
    outlineVariant: Color(0xFF393A42),
    shadow: Color(0xFF000000),
  );

  static ThemeData get light =>
      _build(_lightScheme, AppColors.light, AppShadows.light, Brightness.light);
  static ThemeData get dark =>
      _build(_darkScheme, AppColors.dark, AppShadows.dark, Brightness.dark);

  static ThemeData _build(ColorScheme colors, AppColors appColors,
      AppShadows appShadows, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = Typography.material2021().black.apply(
          bodyColor: colors.onSurface,
          displayColor: colors.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      extensions: [appColors, appShadows],
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121318) : const Color(0xFFF8F8F8),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge
            ?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.15),
        headlineMedium: textTheme.headlineMedium
            ?.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
        titleLarge: textTheme.titleLarge
            ?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium
            ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
        bodyMedium: textTheme.bodyMedium?.copyWith(
            color: appColors.secondaryText, fontSize: 14, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF121318) : const Color(0xFFF8F8F8),
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.onSurface,
          foregroundColor: colors.surface,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
