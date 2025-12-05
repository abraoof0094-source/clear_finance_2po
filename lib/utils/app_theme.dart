import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Centralized color palette
class AppColors {
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color primary = Color(0xFF3B82F6);
  static const Color cardBorder = Color.fromRGBO(255, 255, 255, 0.05);
  static const Color white = Colors.white;
}

// 2. Centralized border radius values
class AppBorderRadius {
  static final BorderRadius card = BorderRadius.circular(24);
  static final BorderRadius fab = BorderRadius.circular(18);
}

// 3. Theme builder class
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Use the color constants for better consistency
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // Define a ColorScheme for better Material 3 component compatibility
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.card,
        onPrimary: AppColors.white,
        onSurface: AppColors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),

      // CORRECTED: Use CardThemeData instead of CardTheme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.card,
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.fab,
        ),
      ),
    );
  }
}
