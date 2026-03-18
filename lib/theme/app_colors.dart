import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Static accent colors (same in both themes) ──
  static const Color accentPurple = Color(0xFF7B5BFF);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color starGold = Color(0xFFFFD700);
  static const Color success = Color(0xFF00E096);
  static const Color error = Color(0xFFFF4D6A);

  // ── Dark-only constants (for splash, onboarding, story feed) ──
  static const Color backgroundDark = Color(0xFF05051A);
  static const Color surfaceDark = Color(0xFF0C0C2E);
  static const Color cardDark = Color(0xFF141438);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF7878AA);

  // ── Light-only constants ──
  static const Color backgroundLight = Color(0xFFF8F7FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF666680);

  // ── Gradients ──
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

  // Card borders (kept for backward compat)
  static final Color cardBorderDark = Colors.white.withValues(alpha: 0.06);
  static final Color cardBorderLight = Colors.black.withValues(alpha: 0.06);

  // ── Theme-aware helpers ──
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;

  static Color card(BuildContext context) =>
      _isDark(context) ? cardDark : cardLight;

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color glass(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white;

  static Color glassBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.1)
          : const Color(0xFFEEECF5);

  static Color divider(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFEEECF5);

  static Color shimmerBase(BuildContext context) =>
      _isDark(context) ? cardDark : const Color(0xFFEEECF5);

  static Color shimmerHighlight(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E4A) : const Color(0xFFF8F7FC);

  static Color searchBar(BuildContext context) =>
      _isDark(context) ? cardDark : Colors.white;

  static Color navBar(BuildContext context) =>
      _isDark(context) ? surfaceDark : Colors.white;

  /// Premium card shadow — purple-tinted in light, none in dark.
  static List<BoxShadow> cardShadow(BuildContext context) =>
      _isDark(context)
          ? const []
          : [
              BoxShadow(
                color: const Color(0xFF7B5BFF).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ];

  /// Colored glow shadow for topic cards in light mode.
  static List<BoxShadow> coloredShadow(BuildContext context, Color glow) =>
      _isDark(context)
          ? [
              BoxShadow(
                color: glow.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ]
          : [
              BoxShadow(
                color: glow.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ];
}
