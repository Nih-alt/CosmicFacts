import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  // ──────────────────────────────────────────────
  // DARK THEME — MIDNIGHT BLUE
  // ──────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.accentBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentGreen,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTextStyles.headingMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF0066CC).withValues(alpha: 0.18),
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: const WidgetStatePropertyAll(AppColors.accentBlue),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.accentBlueLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Cupertino overrides
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.accentBlue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        barBackgroundColor: AppColors.backgroundDark,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: const Color(0xFF0066CC).withValues(alpha: 0.12),
        thickness: 1,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      ),

      useMaterial3: true,
    );
  }

  // ──────────────────────────────────────────────
  // LIGHT THEME — SKY BLUE
  // ──────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.accentBlue,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentBlue,
        secondary: Color(0xFF0A7A50),
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: AppTextStyles.headingMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),

      // Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: const Color(0xFF0066CC).withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF0066CC).withValues(alpha: 0.12),
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: const WidgetStatePropertyAll(AppColors.accentBlue),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Cupertino overrides
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.accentBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        barBackgroundColor: Colors.white,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: const Color(0xFF0066CC).withValues(alpha: 0.1),
        thickness: 1,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),

      useMaterial3: true,
    );
  }
}
