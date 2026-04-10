/// Approximate Bortle dark-sky scale (1 = pristine dark, 9 = inner city)
/// for stargazing forecast purposes. Values are based on city populations
/// and well-known dark-sky locations — for educational use only.
class LightPollutionData {
  /// Returns the Bortle scale (1–9) for the nearest known location.
  static int getBortleScale(double lat, double lon) {
    double minDist = double.infinity;
    int bortle = 6; // default: bright suburban

    for (final city in _cityData) {
      final dLat = (city['lat'] as double) - lat;
      final dLon = (city['lon'] as double) - lon;
      final dist = dLat * dLat + dLon * dLon;
      if (dist < minDist) {
        minDist = dist;
        bortle = city['bortle'] as int;
      }
    }
    return bortle;
  }

  static String getBortleLabel(int bortle) {
    switch (bortle) {
      case 1:
        return 'Excellent Dark Sky';
      case 2:
        return 'Truly Dark Sky';
      case 3:
        return 'Rural Sky';
      case 4:
        return 'Rural/Suburban';
      case 5:
        return 'Suburban Sky';
      case 6:
        return 'Bright Suburban';
      case 7:
        return 'Suburban/Urban';
      case 8:
        return 'City Sky';
      case 9:
        return 'Inner City';
      default:
        return 'Suburban Sky';
    }
  }

  static String getBortleDescription(int bortle) {
    switch (bortle) {
      case 1:
      case 2:
        return 'Zodiacal light visible, thousands of stars, Milky Way detailed';
      case 3:
        return 'Milky Way visible, some light pollution on horizon';
      case 4:
        return 'Milky Way visible but not detailed, moderate light domes';
      case 5:
        return 'Milky Way faint, light pollution obvious';
      case 6:
        return 'Milky Way barely visible, only near zenith';
      case 7:
        return 'Milky Way not visible, only bright stars';
      case 8:
        return 'Only 20-30 stars visible, severe light pollution';
      case 9:
        return 'Very few stars visible through light pollution';
      default:
        return 'Moderate light pollution';
    }
  }

  // Major world cities with approximate Bortle values.
  static const List<Map<String, dynamic>> _cityData = [
    // ── India ───────────────────────────────
    {'name': 'Mumbai',     'lat': 19.076, 'lon': 72.877,  'bortle': 9},
    {'name': 'Delhi',      'lat': 28.679, 'lon': 77.069,  'bortle': 9},
    {'name': 'Bangalore',  'lat': 12.972, 'lon': 77.594,  'bortle': 8},
    {'name': 'Chennai',    'lat': 13.083, 'lon': 80.270,  'bortle': 8},
    {'name': 'Kolkata',    'lat': 22.573, 'lon': 88.364,  'bortle': 9},
    {'name': 'Hyderabad',  'lat': 17.385, 'lon': 78.487,  'bortle': 8},
    {'name': 'Pune',       'lat': 18.520, 'lon': 73.856,  'bortle': 8},
    {'name': 'Ahmedabad',  'lat': 23.023, 'lon': 72.572,  'bortle': 8},
    {'name': 'Jaipur',     'lat': 26.913, 'lon': 75.787,  'bortle': 7},
    {'name': 'Surat',      'lat': 21.170, 'lon': 72.831,  'bortle': 8},
    {'name': 'Lucknow',    'lat': 26.847, 'lon': 80.947,  'bortle': 8},
    {'name': 'Nagpur',     'lat': 21.145, 'lon': 79.088,  'bortle': 7},
    {'name': 'Indore',     'lat': 22.720, 'lon': 75.857,  'bortle': 7},
    {'name': 'Bhopal',     'lat': 23.261, 'lon': 77.402,  'bortle': 7},
    {'name': 'Patna',      'lat': 25.594, 'lon': 85.137,  'bortle': 7},
    {'name': 'Coimbatore', 'lat': 11.001, 'lon': 76.962,  'bortle': 7},
    {'name': 'Vadodara',   'lat': 22.307, 'lon': 73.181,  'bortle': 7},
    {'name': 'Kochi',      'lat':  9.931, 'lon': 76.267,  'bortle': 7},
    {'name': 'Chandigarh', 'lat': 30.735, 'lon': 76.789,  'bortle': 7},
    // Rural India / dark-sky destinations
    {'name': 'Leh',        'lat': 34.152, 'lon': 77.577,  'bortle': 2},
    {'name': 'Spiti',      'lat': 32.246, 'lon': 78.035,  'bortle': 1},
    {'name': 'Rann',       'lat': 23.733, 'lon': 69.750,  'bortle': 2},
    {'name': 'Coorg',      'lat': 12.420, 'lon': 75.739,  'bortle': 4},
    // ── USA ─────────────────────────────────
    {'name': 'New York',    'lat': 40.713, 'lon': -74.006,  'bortle': 9},
    {'name': 'Los Angeles', 'lat': 34.052, 'lon': -118.244, 'bortle': 9},
    {'name': 'Chicago',     'lat': 41.878, 'lon': -87.630,  'bortle': 9},
    {'name': 'Houston',     'lat': 29.760, 'lon': -95.370,  'bortle': 8},
    {'name': 'Phoenix',     'lat': 33.448, 'lon': -112.074, 'bortle': 8},
    // ── Europe ──────────────────────────────
    {'name': 'London', 'lat': 51.508, 'lon':  -0.128, 'bortle': 9},
    {'name': 'Paris',  'lat': 48.857, 'lon':   2.352, 'bortle': 9},
    {'name': 'Berlin', 'lat': 52.520, 'lon':  13.405, 'bortle': 8},
    {'name': 'Rome',   'lat': 41.902, 'lon':  12.496, 'bortle': 8},
    {'name': 'Madrid', 'lat': 40.416, 'lon':  -3.703, 'bortle': 8},
    // ── Asia ────────────────────────────────
    {'name': 'Tokyo',     'lat': 35.689, 'lon': 139.692, 'bortle': 9},
    {'name': 'Beijing',   'lat': 39.905, 'lon': 116.391, 'bortle': 9},
    {'name': 'Shanghai',  'lat': 31.228, 'lon': 121.474, 'bortle': 9},
    {'name': 'Singapore', 'lat':  1.352, 'lon': 103.820, 'bortle': 9},
    {'name': 'Dubai',     'lat': 25.205, 'lon':  55.271, 'bortle': 8},
    // ── Pristine dark-sky locations ─────────
    {'name': 'Sahara',  'lat':  23.412, 'lon':  25.663, 'bortle': 1},
    {'name': 'Atacama', 'lat': -22.909, 'lon': -68.201, 'bortle': 1},
    {'name': 'Outback', 'lat': -25.274, 'lon': 133.775, 'bortle': 1},
    {'name': 'Iceland', 'lat':  64.963, 'lon': -19.021, 'bortle': 2},
  ];
}
