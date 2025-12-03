import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8A6B4F);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(
    0xFFFFFBF0,
  ); // Cream background for main screens
  static const Color surfaceAlt = Color(
    0xFFF9F4EC,
  ); // Alternative cream background
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Colors.grey;
  static const Color inputBackground = Color(0xFFF5F6F9);
  static const Color white = Colors.white;
  static const Color accent = Color(0xFFFFD29A); // Light orange accent

  // Primary color variants
  static Color get primaryLight => primary.withValues(alpha: 0.1);
  static Color get primaryMedium => primary.withValues(alpha: 0.25);
  static Color get primaryDark => const Color(0xFF6B5240);

  // For shadows and overlays
  static Color get primaryShadow => primary.withValues(alpha: 0.08);
  static Color get primaryShadowMedium => primary.withValues(alpha: 0.25);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      useMaterial3: true,
      fontFamily: 'Poppins', // Assuming Poppins or similar sans-serif
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white, // Or inputBackground if intended
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
