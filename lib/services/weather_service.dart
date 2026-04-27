import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';

/// Weather service backed by Open-Meteo (open data, no API key required).
///
/// Used by the Stargazing Forecast tool to compute tonight's cloud cover,
/// humidity, and temperature for the user's current location.
class WeatherService {
  /// Fetches a 3-day forecast for the given coordinates.
  /// Returns the raw decoded JSON, or `null` on any failure.
  static Future<Map<String, dynamic>?> getWeatherForecast({
    required double lat,
    required double lon,
  }) async {
    final url = '${ApiEndpoints.openMeteo}'
        '?latitude=$lat&longitude=$lon'
        '&hourly=cloudcover,relativehumidity_2m,temperature_2m'
        '&daily=weathercode,windspeed_10m_max'
        '&forecast_days=3'
        '&timezone=auto';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Weather API status: ${response.statusCode}');
    } catch (e) {
      debugPrint('Weather API error: $e');
      // Return null — screen will fall back to offline-only signals
      // (moon phase + light pollution still work without weather data).
    }
    return null;
  }

  /// Filters the hourly forecast to "tonight" — 19:00 today through 05:00
  /// tomorrow — and returns a list of hour records.
  static List<Map<String, dynamic>> getTonightHours(
      Map<String, dynamic> data) {
    try {
      final hourly = data['hourly'] as Map<String, dynamic>;
      final hourlyTimes = List<String>.from(hourly['time'] as List);
      final cloudCover = List<int>.from(
          (hourly['cloudcover'] as List).map((e) => (e as num).round()));
      final humidity = List<int>.from(
          (hourly['relativehumidity_2m'] as List)
              .map((e) => (e as num).round()));
      final temperature = List<double>.from(
          (hourly['temperature_2m'] as List)
              .map((e) => (e as num).toDouble()));

      final now = DateTime.now();
      final tonight = <Map<String, dynamic>>[];

      for (int i = 0; i < hourlyTimes.length; i++) {
        final t = DateTime.parse(hourlyTimes[i]);
        // Tonight = 19:00 today through 05:00 tomorrow.
        final isTonight = (t.day == now.day &&
                t.month == now.month &&
                t.year == now.year &&
                t.hour >= 19) ||
            (t.day == now.day + 1 && t.hour <= 5);
        if (isTonight) {
          tonight.add({
            'time': t,
            'cloudCover': cloudCover[i],
            'humidity': humidity[i],
            'temperature': temperature[i],
          });
        }
      }
      return tonight;
    } catch (e) {
      debugPrint('Weather parse error: $e');
      return [];
    }
  }
}
