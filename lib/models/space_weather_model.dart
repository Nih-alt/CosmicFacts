// DISCLAIMER: Space weather data sourced from NOAA Space Weather
// Prediction Center (SWPC), a US government public service.
// This app is unofficial and not affiliated with NOAA.

class SpaceWeatherData {
  final DateTime timestamp;
  final double solarWindSpeed;
  final double solarWindDensity;
  final double bzValue;
  final double kpIndex;
  final String stormLevel;
  final List<SolarFlare> recentFlares;
  final List<SpaceWeatherAlert> activeAlerts;
  final List<KpForecast> kpForecast;
  final List<SolarWindPoint> windHistory;

  SpaceWeatherData({
    required this.timestamp,
    required this.solarWindSpeed,
    required this.solarWindDensity,
    required this.bzValue,
    required this.kpIndex,
    required this.stormLevel,
    required this.recentFlares,
    required this.activeAlerts,
    required this.kpForecast,
    required this.windHistory,
  });
}

class SolarFlare {
  final DateTime time;
  final String flareClass;
  final double intensity;
  final bool isSignificant;

  SolarFlare({
    required this.time,
    required this.flareClass,
    required this.intensity,
    required this.isSignificant,
  });
}

class SpaceWeatherAlert {
  final String title;
  final String message;
  final DateTime issuedAt;
  final String severity;

  SpaceWeatherAlert({
    required this.title,
    required this.message,
    required this.issuedAt,
    required this.severity,
  });
}

class KpForecast {
  final DateTime time;
  final double kp;

  KpForecast({required this.time, required this.kp});
}

class SolarWindPoint {
  final DateTime time;
  final double speed;

  SolarWindPoint({required this.time, required this.speed});
}
