import 'package:flutter/material.dart';

/// Provider-specific brand colors and logo emoji used by the Launches
/// screens for accent borders, emojis in front of provider names, and
/// gradient borders on countdown boxes.
class LaunchBranding {
  static Color providerColor(String provider) {
    final p = provider.toLowerCase();
    if (p.contains('spacex')) return const Color(0xFF005288);
    if (p.contains('nasa')) return const Color(0xFFE03C31);
    if (p.contains('isro') || p.contains('indian space')) {
      return const Color(0xFFFF6B35);
    }
    if (p.contains('blue origin')) return const Color(0xFF0033A0);
    if (p.contains('ariane')) return const Color(0xFF003DA5);
    if (p.contains('ula') || p.contains('united launch')) {
      return const Color(0xFF002855);
    }
    if (p.contains('rocket lab')) return const Color(0xFF000000);
    return const Color(0xFF0066CC);
  }

  /// Variant that stays visible on dark backgrounds — for providers whose
  /// brand color is near-black or very dark navy.
  static Color providerColorOnDark(String provider) {
    final base = providerColor(provider);
    final p = provider.toLowerCase();
    if (p.contains('rocket lab')) return const Color(0xFFE5E5E5);
    if (p.contains('ula') || p.contains('united launch')) {
      return const Color(0xFF5A7AB0);
    }
    return base;
  }

  static String providerEmoji(String provider) {
    final p = provider.toLowerCase();
    if (p.contains('spacex')) return '\u{1F680}';
    if (p.contains('nasa')) return '\u{1F6F8}';
    if (p.contains('isro') || p.contains('indian space')) {
      return '\u{1F1EE}\u{1F1F3}';
    }
    if (p.contains('blue origin')) return '\u{1F535}';
    if (p.contains('ariane')) return '\u{1F1EA}\u{1F1FA}';
    if (p.contains('ula') || p.contains('united launch')) return '⭐';
    if (p.contains('rocket lab')) return '\u{1F680}';
    return '\u{1F680}';
  }

  /// Status value color for detail screen — bolds + colors the status
  /// string (Go / Success → green-cyan family, Failure → red, TBD → amber).
  static Color statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('success')) return const Color(0xFF00E096);
    if (s.contains('failure') || s.contains('failed')) {
      return const Color(0xFFFF4D6A);
    }
    if (s.contains('go') || s.contains('upcoming')) {
      return const Color(0xFF38BDF8);
    }
    if (s.contains('tbd') || s.contains('hold') || s.contains('tbc')) {
      return const Color(0xFFFB923C);
    }
    if (s.contains('partial')) return const Color(0xFFFB923C);
    return const Color(0xFF6B8CAE);
  }
}
