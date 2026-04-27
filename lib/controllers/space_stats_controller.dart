import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../constants/api_keys.dart';
import '../services/api_service.dart';

/// Mission Control reactive state for the Space Statistics dashboard.
///
/// Live: ISS telemetry, people in space, NEO count today, exoplanet total.
/// Calculated: Moon distance (synodic-month phase), Earth–Sun distance.
/// Ticker: universe age in seconds since Big Bang, advancing at 50ms.
class SpaceStatsController extends GetxController {
  // ── LIVE ──
  final issVelocity = 27600.0.obs;
  final issAltitude = 408.0.obs;
  final issLat = 0.0.obs;
  final issLon = 0.0.obs;
  final peopleInSpace = 0.obs;
  final asteroidsToday = 0.obs;
  final exoplanetCount = 5800.obs;

  // ── CALCULATED ──
  final moonDistanceKm = 384400.0.obs;
  final sunDistanceMillionKm = 149.6.obs;

  // ── TICKER ──
  final universeAgeSeconds = 0.0.obs;

  // ── STATUS FLAGS ──
  final issLive = false.obs;
  final exoLive = false.obs;
  final peopleLive = false.obs;
  final asteroidsLive = false.obs;

  Timer? _ageTicker;
  Timer? _issRefresh;

  static const _statsBox = 'settings';
  static const _kPeople = 'stats_people_cache';
  static const _kAsteroids = 'stats_asteroids_cache';
  static const _kExoCount = 'stats_exo_cache';

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    _startAgeTicker();
    _calcMoonSun();
    _refreshAll();
    _issRefresh =
        Timer.periodic(const Duration(seconds: 15), (_) => _refreshISS());
  }

  void _loadFromCache() {
    try {
      if (!Hive.isBoxOpen(_statsBox)) return;
      final box = Hive.box(_statsBox);
      final p = box.get(_kPeople);
      final a = box.get(_kAsteroids);
      final e = box.get(_kExoCount);
      if (p is int) peopleInSpace.value = p;
      if (a is int) asteroidsToday.value = a;
      if (e is int) exoplanetCount.value = e;
    } catch (_) {}
  }

  Future<void> _persist(String key, int value) async {
    try {
      if (!Hive.isBoxOpen(_statsBox)) return;
      await Hive.box(_statsBox).put(key, value);
    } catch (_) {}
  }

  void _startAgeTicker() {
    // 13.787 billion years × 365.25 days × 86400 s ≈ 4.35e17 seconds.
    final baseSeconds = 13.787e9 * 365.25 * 24 * 3600;
    final start = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _ageTicker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final elapsed =
          (DateTime.now().millisecondsSinceEpoch / 1000.0) - start;
      universeAgeSeconds.value = baseSeconds + elapsed;
    });
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _refreshISS(),
      _refreshPeople(),
      _refreshAsteroids(),
      _refreshExoplanets(),
    ]);
  }

  Future<void> _refreshISS() async {
    final t = await ApiService.getISSLiveTelemetry();
    issVelocity.value = t['velocity'] ?? issVelocity.value;
    issAltitude.value = t['altitude'] ?? issAltitude.value;
    issLat.value = t['latitude'] ?? issLat.value;
    issLon.value = t['longitude'] ?? issLon.value;
    issLive.value = true;
  }

  Future<void> _refreshExoplanets() async {
    final c = await ApiService.getExoplanetCount();
    exoplanetCount.value = c;
    exoLive.value = c != 5800;
    if (c != 5800) await _persist(_kExoCount, c);
  }

  Future<void> _refreshPeople() async {
    try {
      final resp = await http
          .get(Uri.parse('http://api.open-notify.org/astros.json'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final n = data['number'];
        if (n is int) {
          peopleInSpace.value = n;
          peopleLive.value = true;
          await _persist(_kPeople, n);
        }
      }
    } catch (e) {
      debugPrint('People in space error: $e');
    }
  }

  Future<void> _refreshAsteroids() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final url = 'https://api.nasa.gov/neo/rest/v1/feed'
          '?start_date=$today&end_date=$today&api_key=${ApiKeys.nasaApiKey}';
      final resp =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final count = data['element_count'];
        if (count is int) {
          asteroidsToday.value = count;
          asteroidsLive.value = true;
          await _persist(_kAsteroids, count);
        }
      }
    } catch (e) {
      debugPrint('Asteroids error: $e');
    }
  }

  void _calcMoonSun() {
    // Moon: ~384,400 km mean ± 25,100 km variation across the synodic month.
    const synodicMonth = 29.53059;
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final daysSince =
        DateTime.now().difference(knownNewMoon).inHours / 24.0;
    final phase = (daysSince % synodicMonth) / synodicMonth;
    moonDistanceKm.value = 384400.0 + 25100.0 * cos(phase * 2 * pi);

    // Earth–Sun: 149.598M km mean, perihelion Jan 3 ≈ 147.1M, aphelion Jul 4.
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    sunDistanceMillionKm.value =
        149.598 + 2.5 * cos((dayOfYear - 3) * 2 * pi / 365.25);
  }

  /// Manual pull-to-refresh hook (not yet wired to UI).
  Future<void> refreshNow() async {
    _calcMoonSun();
    await _refreshAll();
  }

  @override
  void onClose() {
    _ageTicker?.cancel();
    _issRefresh?.cancel();
    super.onClose();
  }
}
