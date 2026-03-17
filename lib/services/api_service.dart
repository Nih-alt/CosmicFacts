import 'dart:convert';

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
  }) async {
    final response = await _getWithRetry(
      '$_newsBaseUrl/articles/?limit=$limit&offset=$offset',
    );
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
        String thumbUrl = '';
        if (linksList != null) {
          for (final link in linksList) {
            if (link['rel'] == 'preview') {
              thumbUrl = link['href'] as String? ?? '';
              break;
            }
          }
        }

        if (thumbUrl.isEmpty) continue;
        results.add(NasaImage.fromJson(meta, thumbUrl));
      }
      return results;
    } catch (_) {
      return [];
    }
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

  /// Find a YouTube video ID for a launch (4-layer fallback).
  static Future<String?> findLaunchVideo(LaunchModel launch) async {
    // Priority 1: Video URL already in model from API
    if (launch.videoUrl.isNotEmpty) {
      final id = _extractYouTubeId(launch.videoUrl);
      if (id != null) return id;
    }

    final mission = launch.missionName.isNotEmpty
        ? launch.missionName
        : launch.name;

    // Priority 2: Piped API (reliable free YouTube proxy)
    try {
      final query = Uri.encodeComponent(
          '${launch.provider} $mission official launch');
      final response = await http
          .get(Uri.parse(
              'https://pipedapi.kavin.rocks/search?q=$query&filter=videos'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        if (items.isNotEmpty) {
          final url =
              (items[0] as Map<String, dynamic>)['url']?.toString() ?? '';
          if (url.contains('watch?v=')) {
            return url.split('watch?v=').last.split('&').first;
          }
        }
      }
    } catch (_) {}

    // Priority 3: Invidious (backup)
    try {
      final query = Uri.encodeComponent(
          '${launch.provider} $mission launch');
      final response = await http
          .get(Uri.parse(
              'https://vid.puffyan.us/api/v1/search?q=$query&type=video'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List<dynamic>;
        if (results.isNotEmpty) {
          final videoId =
              (results[0] as Map<String, dynamic>)['videoId']?.toString();
          if (videoId != null && videoId.isNotEmpty) return videoId;
        }
      }
    } catch (_) {}

    // Priority 4: Provider fallback videos
    return _getProviderFallbackVideo(
      launch.provider,
      launch.launchDate.isAfter(DateTime.now()),
    );
  }

  static String? _getProviderFallbackVideo(
      String provider, bool isUpcoming) {
    final p = provider.toLowerCase();
    if (isUpcoming) {
      if (p.contains('spacex')) return 'ODY6JWzS8WU';
      if (p.contains('nasa')) return '21X5lGlDOfg';
      if (p.contains('isro')) return 'kHwMCtwfCBg';
      return '21X5lGlDOfg';
    } else {
      if (p.contains('spacex')) return 'pJspOORoAZE';
      if (p.contains('nasa')) return 'pDhm4cslPWI';
      if (p.contains('isro')) return 'kHwMCtwfCBg';
      return 'pDhm4cslPWI';
    }
  }

  static String? _extractYouTubeId(String url) {
    // Already an 11-char ID
    if (url.length == 11 && !url.contains('/')) return url;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // youtu.be/VIDEO_ID
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    // youtube.com/watch?v=VIDEO_ID
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }

    return null;
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
