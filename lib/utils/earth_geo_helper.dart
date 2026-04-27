import 'dart:math';

/// Lightweight lat/lon → human description helpers used by the
/// "About this view" + "Cosmic Context" sections of the Earth from Space
/// screen. Bounding boxes are deliberately coarse — we only need a
/// readable label, not a true geocoder.
abstract final class EarthGeoHelper {
  /// Returns a human-readable region description for given coordinates.
  ///   "Centered over the Pacific Ocean, near the equator"
  ///   "Centered over Africa in the tropics"
  static String describeRegion(double lat, double lon) {
    if (lon > 180) lon -= 360;

    String region;
    if (lon >= -170 && lon <= -30 && lat >= -60 && lat <= 75) {
      if (lat >= 15) {
        region = 'North America';
      } else if (lat >= -10) {
        region = 'Central America';
      } else {
        region = 'South America';
      }
    } else if (lon >= -20 && lon <= 50 && lat >= -35 && lat <= 70) {
      region = lat >= 35 ? 'Europe' : 'Africa';
    } else if (lon >= 50 && lon <= 150 && lat >= -10 && lat <= 75) {
      region = 'Asia';
    } else if (lon >= 110 && lon <= 180 && lat >= -50 && lat <= 0) {
      region = 'Australia & Oceania';
    } else if (lat <= -60) {
      region = 'Antarctica';
    } else if (lon >= -180 && lon <= -100 && lat >= -50 && lat <= 50) {
      region = 'the Pacific Ocean';
    } else if (lon >= 50 && lon <= 110 && lat >= -50 && lat <= 30) {
      region = 'the Indian Ocean';
    } else if (lon >= -50 && lon <= 0 && lat >= -50 && lat <= 50) {
      region = 'the Atlantic Ocean';
    } else {
      region = 'open ocean';
    }

    final eqDistance = lat.abs();
    String suffix;
    if (eqDistance < 10) {
      suffix = ', near the equator';
    } else if (eqDistance < 30) {
      suffix = ' in the tropics';
    } else if (eqDistance < 60) {
      suffix = ' in the mid-latitudes';
    } else {
      suffix = ' near the polar region';
    }

    return 'Centered over $region$suffix';
  }

  /// Coarse description of which side of Earth is currently sunlit,
  /// based on the EPIC sub-solar longitude.
  static String describeSunlitSide(double lon) {
    if (lon > 180) lon -= 360;

    if (lon >= -30 && lon <= 60) {
      return 'Sunlit: Africa, Europe & Middle East';
    } else if (lon > 60 && lon <= 150) {
      return 'Sunlit: Asia & Western Pacific';
    } else if (lon > 150 || lon <= -150) {
      return 'Sunlit: Pacific Ocean & Oceania';
    } else if (lon > -150 && lon <= -60) {
      return 'Sunlit: Americas';
    } else {
      return 'Sunlit: Atlantic Ocean';
    }
  }

  /// Earth–Sun distance for a given date, in millions of kilometres.
  /// Simplified eccentric orbit; perihelion ~Jan 3, ±2.5M km variation.
  static double earthSunDistanceMillionKm(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final theta = 2 * pi * (dayOfYear - 3) / 365.25;
    return 149.6 - 2.5 * cos(theta);
  }

  /// Earth–Moon distance for a given date, in km. Mean 384,400 km,
  /// ±21,000 km over the lunar synodic cycle.
  static double earthMoonDistanceKm(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final theta = 2 * pi * dayOfYear / 27.3;
    return 384400 + 21000 * cos(theta);
  }
}
