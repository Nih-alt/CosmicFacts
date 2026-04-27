import 'package:intl/intl.dart';

/// Centralized date formatting. Replaces ad-hoc `DateFormat(...)` patterns
/// scattered across the app and unifies the three independent "X ago"
/// implementations that had drifted apart.
abstract final class DateFormatUtils {
  /// "April 25, 2026" — editorial / magazine headline.
  static String editorial(DateTime date) =>
      DateFormat('MMMM d, yyyy').format(date);

  /// "Apr 25" — compact label.
  static String compact(DateTime date) => DateFormat('MMM d').format(date);

  /// "Apr 25, 2026" — short with year.
  static String shortFull(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  /// "2026-04-25" — API / ISO date format.
  static String api(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// "00:41:06 UTC" — UTC time.
  static String timeUtc(DateTime date) =>
      '${DateFormat('HH:mm:ss').format(date.toUtc())} UTC';

  /// "00:41:06" — local time.
  static String time(DateTime date) => DateFormat('HH:mm:ss').format(date);

  /// "12:41 PM" — 12-hour time.
  static String time12(DateTime date) => DateFormat('h:mm a').format(date);

  /// "STARDATE 2026.04.27" — cockpit aesthetic.
  static String stardate(DateTime date) =>
      'STARDATE ${DateFormat('yyyy.MM.dd').format(date)}';

  /// "Mon, Apr 25" — day of week + compact date.
  static String dayOfWeek(DateTime date) =>
      DateFormat('EEE, MMM d').format(date);

  /// "Sat, Apr 25, 2026" — day of week + short year date.
  static String dayOfWeekFull(DateTime date) =>
      DateFormat('EEE, MMM d, y').format(date);

  /// "Sat, Apr 25 2026 · 14:32 UTC" — verbose timestamp used by NEO close
  /// approach details. Input must already be a UTC `DateTime` if you want
  /// the UTC suffix to be accurate; this helper does NOT convert timezones.
  static String dayOfWeekTimestampUtc(DateTime date) =>
      '${DateFormat('EEE, MMM d y · HH:mm').format(date)} UTC';

  /// Relative time. Default short form: "now", "3m", "2h", "5d", "3w",
  /// "2mo", "1y". Pass [verbose] for "5 days ago" style.
  static String relative(DateTime date, {bool verbose = false}) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return verbose ? 'just now' : 'now';
    } else if (diff.inMinutes < 60) {
      final n = diff.inMinutes;
      return verbose ? '$n min ago' : '${n}m';
    } else if (diff.inHours < 24) {
      final n = diff.inHours;
      return verbose ? '$n hour${n == 1 ? "" : "s"} ago' : '${n}h';
    } else if (diff.inDays < 7) {
      final n = diff.inDays;
      return verbose ? '$n day${n == 1 ? "" : "s"} ago' : '${n}d';
    } else if (diff.inDays < 30) {
      final n = (diff.inDays / 7).floor();
      return verbose ? '$n week${n == 1 ? "" : "s"} ago' : '${n}w';
    } else if (diff.inDays < 365) {
      final n = (diff.inDays / 30).floor();
      return verbose ? '$n month${n == 1 ? "" : "s"} ago' : '${n}mo';
    } else {
      final n = (diff.inDays / 365).floor();
      return verbose ? '$n year${n == 1 ? "" : "s"} ago' : '${n}y';
    }
  }
}
