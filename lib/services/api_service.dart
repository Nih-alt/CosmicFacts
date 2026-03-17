import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_keys.dart';
import '../models/apod_model.dart';
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
