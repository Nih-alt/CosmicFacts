import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_keys.dart';
import '../models/apod_model.dart';
import '../models/launch_model.dart';
import '../models/nasa_image.dart';
import '../models/space_article.dart';

class ApiService {
  static const String _newsBaseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const String _nasaBaseUrl = 'https://api.nasa.gov';
  static const String _nasaImagesUrl = 'https://images-api.nasa.gov';

  /// HTTP GET with automatic retry (2 attempts, 8s timeout).
  static Future<http.Response?> _getWithRetry(String url) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) return response;
      } catch (_) {
        if (attempt == 1) return null;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return null;
  }

  /// Fetch space news articles from Spaceflight News API.
  static Future<List<SpaceArticle>?> getSpaceNews({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    final encoded = searchQuery != null && searchQuery.isNotEmpty
        ? Uri.encodeComponent(searchQuery)
        : null;
    final url = encoded != null
        ? '$_newsBaseUrl/articles/?limit=$limit&offset=$offset&search=$encoded'
        : '$_newsBaseUrl/articles/?limit=$limit&offset=$offset';
    final response = await _getWithRetry(url);
    if (response == null) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((e) => SpaceArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Fetch news filtered by category/agency search term.
  static Future<List<SpaceArticle>?> getNewsByCategory(
    String category, {
    int offset = 0,
    int limit = 20,
  }) async {
    String url;
    if (category == 'All') {
      url = '$_newsBaseUrl/articles/?limit=$limit&offset=$offset';
    } else {
      final encoded = Uri.encodeComponent(category);
      url = '$_newsBaseUrl/articles/?search=$encoded&limit=$limit&offset=$offset';
    }
    final response = await _getWithRetry(url);
    if (response == null) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((e) => SpaceArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Fetch NASA Astronomy Picture of the Day.
  static Future<ApodModel?> getApod() async {
    final response = await _getWithRetry(
      '$_nasaBaseUrl/planetary/apod?api_key=${ApiKeys.nasaApiKey}',
    );
    if (response == null) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ApodModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Search NASA Image & Video Library.
  static Future<List<NasaImage>> searchNasaImages({
    String query = 'space',
    int page = 1,
  }) async {
    final encoded = Uri.encodeComponent(query);
    final response = await _getWithRetry(
      '$_nasaImagesUrl/search?q=$encoded&media_type=image&page=$page&page_size=30',
    );
    if (response == null) return [];

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final collection = body['collection'] as Map<String, dynamic>;
      final items = collection['items'] as List<dynamic>;

      final results = <NasaImage>[];
      for (final item in items) {
        final dataList = item['data'] as List<dynamic>?;
        final linksList = item['links'] as List<dynamic>?;
        if (dataList == null || dataList.isEmpty) continue;

        final meta = dataList[0] as Map<String, dynamic>;
        final links = linksList ?? [];

        // Grid uses ~thumb.jpg (always exists, fast); detail hero upgrades to ~large.jpg.
        final mediumUrl = _buildImageUrl(links, quality: 'thumb');
        final largeUrl  = _buildImageUrl(links, quality: 'large');

        if (mediumUrl.isEmpty) continue;
        results.add(NasaImage.fromJson(meta, mediumUrl, largeUrl: largeUrl));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  /// Returns the NASA CDN URL at the requested quality tier.
  /// NASA CDN suffixes that EXIST: ~thumb.jpg (~100–300px, always exists) | ~large.jpg (~1800px, usually exists)
  /// NOTE: ~medium.jpg does NOT exist on NASA CDN — never request it.
  static String _buildImageUrl(List<dynamic> links, {String quality = 'medium'}) {
    for (final link in links) {
      final rel  = link['rel']  as String? ?? '';
      final href = link['href'] as String? ?? '';
      if (rel == 'preview' && href.isNotEmpty) {
        if (quality == 'large') {
          return href
              .replaceAll('~thumb.jpg', '~large.jpg')
              .replaceAll('~small.jpg', '~large.jpg');
        }
        // 'medium' and 'thumb' both return the original ~thumb.jpg — it always exists
        return href;
      }
    }
    // Fallback: first available link
    if (links.isNotEmpty) {
      final href = links.first['href'] as String? ?? '';
      if (quality == 'large') {
        return href
            .replaceAll('~thumb.jpg', '~large.jpg')
            .replaceAll('~small.jpg', '~large.jpg');
      }
      return href;
    }
    return '';
  }

  /// Fetch upcoming launches: SpaceX v5 query → SNAPI → hardcoded fallback.
  static Future<List<LaunchModel>> getUpcomingLaunches({
    int limit = 15,
  }) async {
    // Method 1: SpaceX v5 query API with date filter
    try {
      final response = await http
          .post(
            Uri.parse('https://api.spacexdata.com/v5/launches/query'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': {
                'date_utc': {
                  '\$gte': DateTime.now().toUtc().toIso8601String(),
                },
              },
              'options': {
                'limit': limit,
                'sort': {'date_utc': 'asc'},
              },
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['docs'] as List<dynamic>? ?? [];
        if (docs.isNotEmpty) {
          return docs
              .map((e) => _parseSpaceXLaunch(
                  e as Map<String, dynamic>,
                  isUpcoming: true))
              .toList();
        }
      }
    } catch (_) {}

    // Method 2: Spaceflight News API
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final response = await _getWithRetry(
        '$_newsBaseUrl/launches/?limit=$limit&ordering=net&net__gte=$now',
      );
      if (response != null) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          return results
              .map((e) =>
                  LaunchModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}

    // Method 3: Hardcoded realistic upcoming launches
    return _getHardcodedUpcoming();
  }

  /// Fetch past launches: SpaceX v5 query → SNAPI fallback.
  static Future<List<LaunchModel>> getPastLaunches({
    int limit = 15,
  }) async {
    // Method 1: SpaceX v5 query API
    try {
      final response = await http
          .post(
            Uri.parse('https://api.spacexdata.com/v5/launches/query'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': {
                'date_utc': {
                  '\$lte': DateTime.now().toUtc().toIso8601String(),
                },
                'success': {'\$ne': null},
              },
              'options': {
                'limit': limit,
                'sort': {'date_utc': 'desc'},
              },
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['docs'] as List<dynamic>? ?? [];
        if (docs.isNotEmpty) {
          return docs
              .map((e) => _parseSpaceXLaunch(
                  e as Map<String, dynamic>,
                  isUpcoming: false))
              .toList();
        }
      }
    } catch (_) {}

    // Method 2: Spaceflight News API
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final response = await _getWithRetry(
        '$_newsBaseUrl/launches/?limit=$limit&ordering=-net&net__lte=$now',
      );
      if (response != null) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          return results
              .map((e) =>
                  LaunchModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Parse a SpaceX v5 launch document (includes video links).
  static LaunchModel _parseSpaceXLaunch(
    Map<String, dynamic> e, {
    required bool isUpcoming,
  }) {
    final name = e['name']?.toString() ?? 'Unknown Launch';
    final date =
        DateTime.tryParse(e['date_utc']?.toString() ?? '') ?? DateTime.now();
    final hasPipe = name.contains('|');
    final rocketName =
        hasPipe ? name.split('|').first.trim() : 'Falcon 9';
    final missionName =
        hasPipe ? name.split('|').last.trim() : name;

    // Infer provider from rocket name
    String provider = 'SpaceX';
    if (rocketName.contains('GSLV') || rocketName.contains('PSLV')) {
      provider = 'ISRO';
    } else if (rocketName.contains('SLS') || rocketName.contains('Atlas')) {
      provider = 'NASA';
    } else if (rocketName.contains('Ariane')) {
      provider = 'Arianespace';
    }

    // Extract video URL from SpaceX links
    final links = e['links'] as Map<String, dynamic>?;
    String videoUrl = '';
    if (links != null) {
      videoUrl = links['webcast']?.toString() ??
          links['youtube_id']?.toString() ??
          '';
    }

    return LaunchModel(
      id: e['id']?.toString() ?? '',
      name: name,
      status: isUpcoming
          ? 'Upcoming'
          : (e['success'] == true
              ? 'Success'
              : e['success'] == false
                  ? 'Failure'
                  : 'Unknown'),
      launchDate: date,
      provider: provider,
      rocketName: rocketName,
      missionName: missionName,
      padLocation: 'Cape Canaveral, FL',
      imageUrl: links?['patch']?['small']?.toString() ?? '',
      videoUrl: videoUrl,
    );
  }

  /// Hardcoded realistic upcoming launches as last-resort fallback.
  static List<LaunchModel> _getHardcodedUpcoming() {
    final now = DateTime.now();
    return [
      LaunchModel(id: 'f1', name: 'Falcon 9 | Starlink Group 15-1', status: 'Upcoming', launchDate: now.add(const Duration(days: 3)), provider: 'SpaceX', rocketName: 'Falcon 9', missionName: 'Starlink Group 15-1', padLocation: 'Cape Canaveral, FL', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f2', name: 'Falcon Heavy | GOES-U', status: 'Upcoming', launchDate: now.add(const Duration(days: 8)), provider: 'SpaceX', rocketName: 'Falcon Heavy', missionName: 'GOES-U', padLocation: 'Kennedy Space Center', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f3', name: 'GSLV Mk III | Gaganyaan Uncrewed', status: 'Upcoming', launchDate: now.add(const Duration(days: 15)), provider: 'ISRO', rocketName: 'GSLV Mk III', missionName: 'Gaganyaan Uncrewed', padLocation: 'Sriharikota, India', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f4', name: 'New Glenn | Blue Ring', status: 'Upcoming', launchDate: now.add(const Duration(days: 20)), provider: 'Blue Origin', rocketName: 'New Glenn', missionName: 'Blue Ring', padLocation: 'Cape Canaveral, FL', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f5', name: 'Ariane 6 | Galileo L13', status: 'Upcoming', launchDate: now.add(const Duration(days: 30)), provider: 'Arianespace', rocketName: 'Ariane 6', missionName: 'Galileo L13', padLocation: 'Kourou, French Guiana', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f6', name: 'SLS | Artemis III', status: 'Upcoming', launchDate: now.add(const Duration(days: 45)), provider: 'NASA', rocketName: 'SLS', missionName: 'Artemis III', padLocation: 'Kennedy Space Center', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f7', name: 'Starship | Mars Cargo Test', status: 'Upcoming', launchDate: now.add(const Duration(days: 60)), provider: 'SpaceX', rocketName: 'Starship', missionName: 'Mars Cargo Test', padLocation: 'Boca Chica, TX', imageUrl: '', videoUrl: ''),
      LaunchModel(id: 'f8', name: 'PSLV | Aditya-L2', status: 'Upcoming', launchDate: now.add(const Duration(days: 90)), provider: 'ISRO', rocketName: 'PSLV', missionName: 'Aditya-L2', padLocation: 'Sriharikota, India', imageUrl: '', videoUrl: ''),
    ];
  }

  /// Fetch current ISS location.
  static Future<Map<String, dynamic>?> getISSLocation() async {
    final response =
        await _getWithRetry('http://api.open-notify.org/iss-now.json');
    if (response == null) return null;
    return jsonDecode(response.body);
  }

  /// Fetch astronauts currently in space.
  static Future<Map<String, dynamic>?> getAstronautsInSpace() async {
    final response =
        await _getWithRetry('http://api.open-notify.org/astros.json');
    if (response == null) return null;
    return jsonDecode(response.body);
  }

  /// Fetch near-Earth asteroids for today from NASA NEO API.
  static Future<List<Map<String, dynamic>>> getNearEarthAsteroids() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final url =
        '$_nasaBaseUrl/neo/rest/v1/feed?start_date=$today&end_date=$today&api_key=${ApiKeys.nasaApiKey}';
    final response = await _getWithRetry(url);
    if (response == null) return [];
    final data = jsonDecode(response.body);
    final dateKey = data['near_earth_objects']?.keys?.first;
    if (dateKey == null) return [];
    return List<Map<String, dynamic>>.from(
        data['near_earth_objects'][dateKey] ?? []);
  }

  // ── NASA EPIC (Earth from Space) ──
  // Uses direct EPIC endpoint (epic.gsfc.nasa.gov) — no API key needed,
  // more reliable than the api.nasa.gov proxy.
  static const String _epicBaseUrl = 'https://epic.gsfc.nasa.gov';

  /// Fetch available EPIC image dates (most recent first).
  static Future<List<String>> getEpicAvailableDates() async {
    final url = '$_epicBaseUrl/api/natural/all';
    debugPrint('EPIC: Fetching available dates: $url');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      debugPrint('EPIC: Available dates status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final dates = data
              .map((e) =>
                  (e as Map<String, dynamic>)['date']?.toString() ?? '')
              .where((d) => d.isNotEmpty)
              .toList();
          debugPrint('EPIC: Dates found: ${dates.length}');
          return dates;
        }
      }
    } catch (e) {
      debugPrint('EPIC: Available dates error: $e');
    }
    return [];
  }

  /// Fetch EPIC images for a specific date.
  static Future<List<Map<String, dynamic>>> getEpicImages({
    String? date,
  }) async {
    final url = date != null
        ? '$_epicBaseUrl/api/natural/date/$date'
        : '$_epicBaseUrl/api/natural';
    debugPrint('EPIC: Fetching images: $url');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      debugPrint('EPIC: Images status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          debugPrint('EPIC: Images found: ${data.length}');
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('EPIC: Images error: $e');
    }
    return [];
  }

  /// Build URL for a NASA EPIC image (thumbnail or full resolution).
  /// Uses direct EPIC archive — no API key needed.
  static String getEpicImageUrl(
    String date,
    String imageName, {
    bool thumbnail = true,
  }) {
    final parts = date.split('-');
    final type = thumbnail ? 'thumbs' : 'png';
    final ext = thumbnail ? 'jpg' : 'png';
    return '$_epicBaseUrl/archive/natural/${parts[0]}/${parts[1]}/${parts[2]}/$type/$imageName.$ext';
  }

  /// Get trending/curated NASA images.
  static Future<List<NasaImage>> getTrendingImages({int page = 1}) async {
    const queries = [
      'galaxy', 'nebula', 'jupiter', 'mars', 'earth from space',
      'astronaut', 'rocket launch', 'saturn rings', 'milky way',
      'supernova', 'hubble deep field', 'james webb', 'moon surface',
      'international space station', 'black hole',
    ];
    final query = queries[(page - 1) % queries.length];
    final apiPage = ((page - 1) ~/ queries.length) + 1;
    return searchNasaImages(query: query, page: apiPage);
  }
}
