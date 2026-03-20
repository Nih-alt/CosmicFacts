import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _newsBoxName = 'news_cache';
  static const String _apodBoxName = 'apod_cache';
  static const String _launchesBoxName = 'launches_cache';

  // ── News articles ──

  static Future<void> cacheNews(List<Map<String, dynamic>> articles) async {
    final box = await Hive.openBox(_newsBoxName);
    await box.put('articles', articles);
    await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns cached news if valid (within 30 minutes).
  static Future<List<Map<String, dynamic>>?> getCachedNews() async {
    final box = await Hive.openBox(_newsBoxName);
    final cachedAt = box.get('cached_at') as int?;
    if (cachedAt == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > 30 * 60 * 1000) return null; // expired

    final data = box.get('articles');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  // ── APOD ──

  static Future<void> cacheApod(Map<String, dynamic> apod) async {
    final box = await Hive.openBox(_apodBoxName);
    await box.put('apod', apod);
    await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns cached APOD if valid (within 12 hours).
  static Future<Map<String, dynamic>?> getCachedApod() async {
    final box = await Hive.openBox(_apodBoxName);
    final cachedAt = box.get('cached_at') as int?;
    if (cachedAt == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > 12 * 60 * 60 * 1000) return null; // expired after 12h

    final data = box.get('apod');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  // ── Launches ──

  static Future<void> cacheLaunches(
    String key,
    List<Map<String, dynamic>> launches,
  ) async {
    final box = await Hive.openBox(_launchesBoxName);
    await box.put(key, launches);
    await box.put('${key}_cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns cached launches if valid (within 30 minutes).
  static Future<List<Map<String, dynamic>>?> getCachedLaunches(
    String key,
  ) async {
    final box = await Hive.openBox(_launchesBoxName);
    final cachedAt = box.get('${key}_cached_at') as int?;
    if (cachedAt == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > 30 * 60 * 1000) return null; // expired

    final data = box.get(key);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }
}
