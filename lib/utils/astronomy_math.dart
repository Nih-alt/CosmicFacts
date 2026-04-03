import 'dart:math';
import 'dart:ui';

class AstronomyMath {
  // Julian Date from DateTime
  static double julianDate(DateTime dt) {
    final utc = dt.toUtc();
    int Y = utc.year;
    int M = utc.month;
    double D = utc.day +
        utc.hour / 24.0 +
        utc.minute / 1440.0 +
        utc.second / 86400.0;

    if (M <= 2) {
      Y--;
      M += 12;
    }

    int A = (Y / 100).floor();
    int B = 2 - A + (A / 4).floor();

    return (365.25 * (Y + 4716)).floor() +
        (30.6001 * (M + 1)).floor() +
        D +
        B -
        1524.5;
  }

  // Greenwich Mean Sidereal Time in DEGREES
  static double gmst(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    double gmstDeg = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * T * T -
        T * T * T / 38710000.0;
    return gmstDeg % 360.0;
  }

  // Local Sidereal Time in DEGREES
  static double lst(double jd, double longitude) {
    return (gmst(jd) + longitude) % 360.0;
  }

  // Convert RA/Dec to Altitude/Azimuth
  static Map<String, double> raDecToAltAz({
    required double ra,
    required double dec,
    required double lat,
    required double lon,
    required DateTime time,
  }) {
    final jd = julianDate(time);
    final lstDeg = lst(jd, lon);

    double ha = (lstDeg - ra * 15.0) % 360.0;
    if (ha < 0) ha += 360.0;

    final haRad = ha * pi / 180.0;
    final decRad = dec * pi / 180.0;
    final latRad = lat * pi / 180.0;

    final sinAlt =
        sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad);
    final alt = asin(sinAlt.clamp(-1.0, 1.0)) * 180.0 / pi;

    final altRad = alt * pi / 180.0;
    double cosAz = (sin(decRad) - sin(altRad) * sin(latRad)) /
        (cos(altRad) * cos(latRad));
    cosAz = cosAz.clamp(-1.0, 1.0);
    double az = acos(cosAz) * 180.0 / pi;
    if (sin(haRad) > 0) az = 360.0 - az;

    return {'alt': alt, 'az': az};
  }

  // Planet position — simplified VSOP (accurate ~1 degree)
  static Map<String, double> planetPosition({
    required String planet,
    required DateTime time,
    required double lat,
    required double lon,
  }) {
    final jd = julianDate(time);
    final T = (jd - 2451545.0) / 36525.0;

    final planets = {
      'Mercury': {
        'L0': 252.2503,
        'dL': 149472.6741,
        'M0': 174.7948,
        'dM': 149472.5153,
        'e': 0.2056
      },
      'Venus': {
        'L0': 181.9798,
        'dL': 58517.8156,
        'M0': 50.4161,
        'dM': 58517.8039,
        'e': 0.0068
      },
      'Mars': {
        'L0': 355.4330,
        'dL': 19140.2993,
        'M0': 19.3730,
        'dM': 19140.3023,
        'e': 0.0934
      },
      'Jupiter': {
        'L0': 34.3515,
        'dL': 3034.9057,
        'M0': 20.9206,
        'dM': 3034.7684,
        'e': 0.0484
      },
      'Saturn': {
        'L0': 50.0774,
        'dL': 1222.1138,
        'M0': 317.8107,
        'dM': 1222.0698,
        'e': 0.0542
      },
    };

    final p = planets[planet];
    if (p == null) return {'alt': -90.0, 'az': 0.0};

    double M = (p['M0']! + p['dM']! * T / 36525) % 360.0;
    if (M < 0) M += 360.0;
    final mRad = M * pi / 180.0;

    final eoc = (2 * p['e']! - p['e']! * p['e']! * p['e']! / 4) * sin(mRad) +
        5.0 / 4.0 * p['e']! * p['e']! * sin(2 * mRad);

    double L =
        (p['L0']! + p['dL']! * T / 36525 + eoc * 180 / pi) % 360.0;
    if (L < 0) L += 360.0;

    final eps = (23.439 - 0.013 * T) * pi / 180.0;
    final lRad = L * pi / 180.0;

    final ra = atan2(cos(eps) * sin(lRad), cos(lRad));
    final dec = asin(sin(eps) * sin(lRad));

    final raHours = ((ra * 180 / pi) % 360 + 360) % 360 / 15.0;
    final decDeg = dec * 180 / pi;

    return raDecToAltAz(
      ra: raHours,
      dec: decDeg,
      lat: lat,
      lon: lon,
      time: time,
    );
  }

  // Screen position from alt/az difference to phone pointing direction
  static Offset? toScreenPosition({
    required double starAlt,
    required double starAz,
    required double phoneAlt,
    required double phoneAz,
    required double screenWidth,
    required double screenHeight,
    double fovH = 65.0,
    double fovV = 50.0,
  }) {
    double dAz = starAz - phoneAz;
    if (dAz > 180) dAz -= 360;
    if (dAz < -180) dAz += 360;
    double dAlt = starAlt - phoneAlt;

    if (dAz.abs() > fovH / 2 + 10) return null;
    if (dAlt.abs() > fovV / 2 + 10) return null;

    final x = screenWidth / 2 + (dAz / (fovH / 2)) * screenWidth / 2;
    final y = screenHeight / 2 - (dAlt / (fovV / 2)) * screenHeight / 2;

    return Offset(x, y);
  }

  // Low-pass filter for sensor smoothing
  static double lowPass(double current, double previous,
      {double alpha = 0.15}) {
    return previous + alpha * (current - previous);
  }

  // Smooth azimuth handling (wrap-around safe)
  static double smoothAzimuth(double current, double previous,
      {double alpha = 0.15}) {
    double diff = current - previous;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    double result = previous + alpha * diff;
    return (result + 360) % 360;
  }
}
