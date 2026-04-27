import 'dart:math' as math;
import 'package:intl/intl.dart';

/// Centralized number formatting. Replaces scattered `NumberFormat('#,###')`
/// constructions and the local `_fmt` / `intComma` / `kmh` helpers.
abstract final class NumberFormatUtils {
  static final NumberFormat _commas = NumberFormat('#,###');

  /// "27,556" — comma-separated integer.
  static String commas(num value) => _commas.format(value);

  /// "27,556.42" — comma-separated with decimals.
  static String commasDecimal(num value, {int decimals = 2}) =>
      NumberFormat('#,##0.${'0' * decimals}').format(value);

  /// "384,400 km" or "1.50M km" — distance with units.
  /// Switches to "M km" suffix above 1,000,000 km.
  static String distance(num km) {
    if (km.abs() >= 1000000) {
      return '${(km / 1000000).toStringAsFixed(2)}M km';
    } else if (km.abs() >= 1000) {
      return '${commas(km.toInt())} km';
    } else {
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// "93B" / "1.2M" / "5.8K" — compact big-number abbreviation.
  static String compactBig(num value, {int decimals = 1}) {
    final abs = value.abs();
    if (abs >= 1e12) return '${(value / 1e12).toStringAsFixed(decimals)}T';
    if (abs >= 1e9) return '${(value / 1e9).toStringAsFixed(decimals)}B';
    if (abs >= 1e6) return '${(value / 1e6).toStringAsFixed(decimals)}M';
    if (abs >= 1e3) return '${(value / 1e3).toStringAsFixed(decimals)}K';
    return value.toStringAsFixed(0);
  }

  /// "27,556 km/h" — velocity with units.
  static String velocity(num kmh) => '${commas(kmh.round())} km/h';

  /// "4.3508 × 10¹⁷" — scientific notation with Unicode superscripts.
  static String scientific(num value, {int decimals = 4}) {
    if (value == 0) return '0';
    final exponent = (math.log(value.abs()) / math.ln10).floor();
    final mantissa = value / math.pow(10, exponent);
    const superscriptDigits = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
    final expStr = exponent.toString().split('').map((c) {
      if (c == '-') return '⁻';
      return superscriptDigits[int.parse(c)];
    }).join();
    return '${mantissa.toStringAsFixed(decimals)} × 10$expStr';
  }

  /// "87.3%" — percentage from a 0..1 fraction.
  static String percent(double fraction, {int decimals = 1}) =>
      '${(fraction * 100).toStringAsFixed(decimals)}%';

  /// "1.5B years" / "23 days" — duration in human terms.
  static String yearsCompact(num years) {
    if (years.abs() >= 1e9) return '${compactBig(years)} years';
    if (years.abs() >= 1) return '${years.toStringAsFixed(1)} years';
    final days = (years * 365).round();
    return '$days days';
  }
}
