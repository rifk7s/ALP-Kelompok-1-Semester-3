import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF8A6B4F);
  static const Color primaryDark = Color(0xFF6B5240);

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFBF0); // Cream background
  static const Color surfaceAlt = Color(0xFFF9F4EC); // Alternative cream

  // Base colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Colors.grey;
  static const Color textDark = Color(0xFF505050);
  static const Color textLight = Color(0xDD000000); // black87
  static const Color textMuted = Color(0x8A000000); // black54

  // Grey variants
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFE0E0E0); // grey.shade300
  static const Color greyMedium = Color(0xFF9E9E9E); // grey.shade500
  static const Color greyDark = Color(0xFF616161); // grey.shade700

  // Input & border colors
  static const Color inputBackground = Color(0xFFF5F6F9);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEDEDED);

  // Shadow & overlay colors
  static const Color shadowLight = Color(0x1F000000); // black12
  static const Color shadowMedium = Color(0x42000000); // black26
  static const Color overlay = Color(0x8A000000); // black54

  // Accent colors
  static const Color accent = Color(0xFFFFD29A); // Light orange accent
  static const Color cardBackground = Color(0xFFFFE7C0); // Card/profile card bg
  static const Color logoPlaceholder = Color(0xFFE8DCC6); // Logo placeholder bg

  // Semantic colors
  static const Color danger = Color(0xFFD81B1B); // Logout, delete, error
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // Chat colors
  static const Color chatBubbleSent = Color(0xFFDCB285);
  static const Color chatBubbleReceived = Color(0xFFFFEDBD);
  static const Color chatInputBackground = Color(0xFFFFF1CB);
  static const Color chatInputField = Color(0xFFFFEEC5);

  // Notification colors
  static const Color notificationDivider = Color(0xFFE9DAC7);
  static const Color notificationCard = Color(0xFFFFEDE7);

  // HPP colors
  static const Color hppHeader = Color(0xFFF7C896);
  static const Color hppCard = Color(0xFFF6D7A8);

  // Misc
  static const Color cartQtyBackground = Color(0xFFF1EBE3);
  static const Color imagePlaceholder = Color(0xFFEFEFEF);

  // Primary color variants (computed)
  static Color get primaryLight => primary.withValues(alpha: 0.1);
  static Color get primaryMedium => primary.withValues(alpha: 0.25);

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
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
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
