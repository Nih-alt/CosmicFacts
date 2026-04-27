import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';

class TleService {
  // CelesTrak NORAD catalog numbers (public domain)
  static const Map<String, String> _catalogNumbers = {
    'ISS': '25544',
    'Hubble': '20580',
    'JWST': '50463',
  };

  /// Fetch TLE for a spacecraft.
  /// Returns Map with name, line1, line2 or fallback on failure.
  static Future<Map<String, String>?> fetchTle(String spacecraft) async {
    final catNum = _catalogNumbers[spacecraft];
    if (catNum == null) return null;

    try {
      final url = ApiEndpoints.tleByCatNum(int.parse(catNum));
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'text/plain'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final lines = response.body
            .trim()
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

        // TLE format: name line, line1, line2
        if (lines.length >= 3) {
          return {'name': lines[0], 'line1': lines[1], 'line2': lines[2]};
        }
        // Sometimes returns just line1+line2
        if (lines.length == 2) {
          return {'name': spacecraft, 'line1': lines[0], 'line2': lines[1]};
        }
      }
    } catch (e) {
      debugPrint('TLE fetch error for $spacecraft: $e');
    }

    return _getFallbackTle(spacecraft);
  }

  /// Fetch all 3 spacecraft TLEs in parallel.
  static Future<Map<String, Map<String, String>?>> fetchAllTles() async {
    final results = await Future.wait([
      fetchTle('ISS'),
      fetchTle('Hubble'),
      fetchTle('JWST'),
    ]);
    return {
      'ISS': results[0],
      'Hubble': results[1],
      'JWST': results[2],
    };
  }

  static Map<String, String>? _getFallbackTle(String spacecraft) {
    const fallbacks = {
      'ISS': {
        'name': 'ISS (ZARYA)',
        'line1':
            '1 25544U 98067A   24001.50000000  .00016717  00000-0  10270-3 0  9003',
        'line2':
            '2 25544  51.6419 208.9163 0006770  86.0169  274.1691 15.49912520 1234',
      },
      'Hubble': {
        'name': 'HST',
        'line1':
            '1 20580U 90037B   24001.50000000  .00000882  00000-0  34682-4 0  9994',
        'line2':
            '2 20580  28.4692  62.7352 0002703 221.9612 138.1199 15.09325697523124',
      },
      'JWST': {
        'name': 'JWST',
        'line1':
            '1 50463U 21130A   24001.50000000 -.00000020  00000-0  00000+0 0  9990',
        'line2':
            '2 50463  29.7856 227.3956 0005268 209.6221 150.3610  0.99969085  8301',
      },
    };
    return fallbacks[spacecraft] != null
        ? Map<String, String>.from(fallbacks[spacecraft]!)
        : null;
  }
}
