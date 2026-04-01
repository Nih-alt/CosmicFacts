import 'package:flutter/material.dart';

abstract final class AppColors {
  // ═══════════════════════════════════════════
  // SHARED ACCENTS
  // ═══════════════════════════════════════════
  static const Color accentBlue      = Color(0xFF0066CC);
  static const Color accentBlueLight = Color(0xFF3B82F6);
  static const Color accentBlueDeep  = Color(0xFF1D4ED8);
  static const Color accentGreen     = Color(0xFF34D399);
  static const Color accentCyan      = Color(0xFF38BDF8);
  static const Color accentOrange    = Color(0xFFFB923C);
  static const Color starGold        = Color(0xFFFFD700);
  static const Color success         = Color(0xFF34D399);
  static const Color error           = Color(0xFFFF4D6A);

  // Legacy purple — ONLY for planet icons, timeline eras, constellation lines,
  // and select achievement badges. Do NOT use for buttons, pills, or nav.
  static const Color legacyPurple    = Color(0xFF7B5BFF);

  // ═══════════════════════════════════════════
  // DARK — MIDNIGHT BLUE
  // ═══════════════════════════════════════════
  static const Color backgroundDark  = Color(0xFF040D1A);
  static const Color surfaceDark     = Color(0xFF071428);
  static const Color cardDark        = Color(0xFF0A1E36);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF6B8CAE);
  static const Color textTertiaryDark  = Color(0xFF3A5470);

  // ═══════════════════════════════════════════
  // LIGHT — SKY BLUE
  // ═══════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFF0F6FF);
  static const Color surfaceLight    = Color(0xFFFFFFFF);
  static const Color cardLight       = Color(0xFFFFFFFF);
  static const Color textPrimaryLight  = Color(0xFF0A1628);
  static const Color textSecondaryLight = Color(0xFF5A7A9A);
  static const Color textTertiaryLight  = Color(0xFF8AAABB);

  // ═══════════════════════════════════════════
  // GRADIENTS (blue→cyan replaces old purple→cyan)
  // ═══════════════════════════════════════════
  static const Color gradientStart = Color(0xFF0066CC);
  static const Color gradientEnd   = Color(0xFF38BDF8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // ═══════════════════════════════════════════
  // THEME-AWARE HELPERS
  // ═══════════════════════════════════════════
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

  static Color textTertiary(BuildContext context) =>
      _isDark(context) ? textTertiaryDark : textTertiaryLight;

  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF0066CC).withValues(alpha: 0.18)
          : const Color(0xFF0066CC).withValues(alpha: 0.12);

  static Color glass(BuildContext context) =>
      _isDark(context) ? cardDark : Colors.white;

  static Color glassBorder(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF0066CC).withValues(alpha: 0.18)
          : const Color(0xFF0066CC).withValues(alpha: 0.12);

  static Color divider(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF0066CC).withValues(alpha: 0.12)
          : const Color(0xFF0066CC).withValues(alpha: 0.1);

  static Color searchBar(BuildContext context) =>
      _isDark(context) ? surfaceDark : Colors.white;

  // ── Pills ──
  static Color pillSelected(BuildContext context) => accentBlue;

  static Color pillUnselected(BuildContext context) =>
      _isDark(context) ? surfaceDark : const Color(0xFF0066CC).withValues(alpha: 0.08);

  static Color pillBorder(BuildContext context) =>
      const Color(0xFF0066CC).withValues(alpha: _isDark(context) ? 0.25 : 0.2);

  // ── Navigation ──
  static Color navBar(BuildContext context) =>
      _isDark(context) ? backgroundDark : Colors.white;

  static Color navBorder(BuildContext context) =>
      const Color(0xFF0066CC).withValues(alpha: _isDark(context) ? 0.12 : 0.1);

  static Color navSelected(BuildContext context) =>
      _isDark(context) ? accentBlueLight : accentBlue;

  static Color navUnselected(BuildContext context) =>
      _isDark(context) ? textTertiaryDark : textSecondaryLight;

  // ── Shimmer ──
  static Color shimmerBase(BuildContext context) =>
      _isDark(context) ? const Color(0xFF071428) : const Color(0xFFE8F0FB);

  static Color shimmerHighlight(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0D2040) : const Color(0xFFF0F6FF);

  // ── Card shadow ──
  static List<BoxShadow> cardShadow(BuildContext context) =>
      _isDark(context)
          ? const []
          : [
              BoxShadow(
                color: const Color(0xFF0066CC).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ];

  /// Colored glow shadow for topic cards.
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

  // ═══════════════════════════════════════════
  // SOURCE / AGENCY BADGES
  // ═══════════════════════════════════════════
  static Color sourceBadgeBg(String source, bool isDark) {
    switch (source.toLowerCase()) {
      case 'spacex':
        return const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.15 : 0.1);
      case 'esa':
        return const Color(0xFF34D399).withValues(alpha: isDark ? 0.15 : 0.1);
      default:
        return const Color(0xFF0066CC).withValues(alpha: isDark ? 0.15 : 0.08);
    }
  }

  static Color sourceBadgeText(String source, bool isDark) {
    switch (source.toLowerCase()) {
      case 'spacex':
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      case 'esa':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF0A7A50);
      default:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A56DB);
    }
  }
}
