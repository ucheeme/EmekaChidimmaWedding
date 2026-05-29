import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.roseGold,
      brightness: Brightness.light,
      primary: AppColors.deepWine,
      onPrimary: Colors.white,
      secondary: AppColors.roseGold,
      onSecondary: AppColors.deepWine,
      tertiary: AppColors.olive,
      onTertiary: Colors.white,
      error: AppColors.wine,
      surface: AppColors.blush,
      onSurface: AppColors.deepWine,
    );

    final displayFont = GoogleFonts.cormorantGaramondTextTheme();
    final bodyFont = GoogleFonts.latoTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.blush,
      textTheme: displayFont.copyWith(
        headlineMedium: displayFont.headlineMedium?.copyWith(
          color: AppColors.deepWine,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: bodyFont.bodyLarge?.copyWith(color: AppColors.deepWine),
        bodyMedium: bodyFont.bodyMedium?.copyWith(
          color: AppColors.deepWine.withValues(alpha: 0.88),
        ),
        bodySmall: bodyFont.bodySmall?.copyWith(
          color: AppColors.deepWine.withValues(alpha: 0.65),
        ),
        labelLarge: bodyFont.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.deepWine,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.deepWine,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.deepWine,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.ivory.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.roseGold.withValues(alpha: 0.35),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.roseGold.withValues(alpha: 0.45),
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.roseGold,
          foregroundColor: AppColors.deepWine,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepWine,
          side: const BorderSide(color: AppColors.roseGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ivory.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.roseGold.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.roseGold, width: 1.5),
        ),
      ),
    );
  }
}
