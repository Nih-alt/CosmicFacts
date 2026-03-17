import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color backgroundDark = Color(0xFF05051A);
  static const Color backgroundLight = Color(0xFFF0F0FA);

  // Surfaces
  static const Color surfaceDark = Color(0xFF0C0C2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Cards
  static const Color cardDark = Color(0xFF141438);
  static const Color cardLight = Color(0xFFF0F0F8);

  // Accents
  static const Color accentPurple = Color(0xFF7B5BFF);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentOrange = Color(0xFFFF6B35);

  // Special
  static const Color starGold = Color(0xFFFFD700);
  static const Color success = Color(0xFF00E096);
  static const Color error = Color(0xFFFF4D6A);

  // Text — Dark theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF7878AA);

  // Text — Light theme
  static const Color textPrimaryLight = Color(0xFF05051A);
  static const Color textSecondaryLight = Color(0xFF666680);

  // Gradient
  static const Color gradientStart = Color(0xFF7B5BFF);
  static const Color gradientEnd = Color(0xFF00D4FF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Card borders
  static final Color cardBorderDark = Colors.white.withValues(alpha: 0.06);
  static final Color cardBorderLight = Colors.black.withValues(alpha: 0.06);
}
