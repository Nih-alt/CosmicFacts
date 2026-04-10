import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/light_pollution_data.dart';
import '../../services/weather_service.dart';

/// Stargazing visibility forecast.
///
/// Combines three signals into a single 0–100 score:
///   * Weather (40 pts) — cloud cover from Open-Meteo + humidity penalty
///   * Moon (30 pts)    — illumination % from a mathematical phase calc
///   * Light pollution (30 pts) — Bortle scale from nearest known city
class StargazingForecastScreen extends StatefulWidget {
  const StargazingForecastScreen({super.key});

  @override
  State<StargazingForecastScreen> createState() =>
      _StargazingForecastScreenState();
}

class _StargazingForecastScreenState
    extends State<StargazingForecastScreen> {
  bool _isLoading = true;
  String? _error;
  Position? _position;
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _tonightHours = [];
  int _bortleScale = 6;
  double _moonPhase = 0;
  int _overallScore = 0;

  // Score components
  int _weatherScore = 0;
  int _moonScore = 0;
  int _pollutionScore = 0;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  // ══════════════════════════════════════════
  // MOON PHASE CALCULATION
  // ══════════════════════════════════════════
  double _getMoonPhase() {
    final now = DateTime.now();
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final daysSince = now.difference(knownNewMoon).inHours / 24.0;
    const lunarCycle = 29.53058770576;
    return (daysSince % lunarCycle) / lunarCycle;
  }

  int _getMoonIllumination() {
    // 0 = new moon, 0.5 = full moon, 1 = new moon
    final phase = _moonPhase;
    final angle = phase * 2 * pi;
    return ((1 - cos(angle)) / 2 * 100).round();
  }

  String _getMoonPhaseName(double phase) {
    if (phase < 0.0625) return 'New Moon';
    if (phase < 0.1875) return 'Waxing Crescent';
    if (phase < 0.3125) return 'First Quarter';
    if (phase < 0.4375) return 'Waxing Gibbous';
    if (phase < 0.5625) return 'Full Moon';
    if (phase < 0.6875) return 'Waning Gibbous';
    if (phase < 0.8125) return 'Last Quarter';
    if (phase < 0.9375) return 'Waning Crescent';
    return 'New Moon';
  }

  // ══════════════════════════════════════════
  // SCORING ALGORITHM
  // ══════════════════════════════════════════
  void _calculateScores() {
    // 1. WEATHER SCORE (0–40 points)
    if (_tonightHours.isEmpty) {
      _weatherScore = 20; // unknown
    } else {
      final avgCloud = _tonightHours
              .map((h) => h['cloudCover'] as int)
              .reduce((a, b) => a + b) ~/
          _tonightHours.length;
      final avgHumidity = _tonightHours
              .map((h) => h['humidity'] as int)
              .reduce((a, b) => a + b) ~/
          _tonightHours.length;

      int cloudScore;
      if (avgCloud > 80) {
        cloudScore = 0;
      } else if (avgCloud > 60) {
        cloudScore = 10;
      } else if (avgCloud > 40) {
        cloudScore = 20;
      } else if (avgCloud > 20) {
        cloudScore = 30;
      } else {
        cloudScore = 40;
      }

      // Humidity penalty
      if (avgHumidity > 80) cloudScore -= 5;
      _weatherScore = cloudScore.clamp(0, 40);
    }

    // 2. MOON SCORE (0–30 points)
    final illum = _getMoonIllumination();
    if (illum <= 10) {
      _moonScore = 30;
    } else if (illum <= 25) {
      _moonScore = 25;
    } else if (illum <= 40) {
      _moonScore = 20;
    } else if (illum <= 60) {
      _moonScore = 12;
    } else if (illum <= 80) {
      _moonScore = 5;
    } else {
      _moonScore = 0;
    }

    // 3. LIGHT POLLUTION SCORE (0–30 points)
    switch (_bortleScale) {
      case 1:
        _pollutionScore = 30;
        break;
      case 2:
        _pollutionScore = 28;
        break;
      case 3:
        _pollutionScore = 24;
        break;
      case 4:
        _pollutionScore = 20;
        break;
      case 5:
        _pollutionScore = 15;
        break;
      case 6:
        _pollutionScore = 10;
        break;
      case 7:
        _pollutionScore = 6;
        break;
      case 8:
        _pollutionScore = 3;
        break;
      case 9:
        _pollutionScore = 0;
        break;
      default:
        _pollutionScore = 10;
    }

    _overallScore = _weatherScore + _moonScore + _pollutionScore;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Very Good';
    if (score >= 50) return 'Good';
    if (score >= 35) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Very Poor';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF00E676);
    if (score >= 65) return const Color(0xFF69F0AE);
    if (score >= 50) return const Color(0xFFFFEE58);
    if (score >= 35) return const Color(0xFFFFAB40);
    if (score >= 20) return const Color(0xFFFF7043);
    return const Color(0xFFFF5252);
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '🌟';
    if (score >= 65) return '✨';
    if (score >= 50) return '⭐';
    if (score >= 35) return '🌤️';
    if (score >= 20) return '☁️';
    return '⛈️';
  }

  String _getAdvice(int score) {
    if (score >= 80) {
      return 'Perfect night! Set up your telescope and prepare for an incredible show. The Milky Way should be visible from dark locations.';
    }
    if (score >= 65) {
      return 'Great conditions tonight. Bright stars, planets and most deep sky objects will be visible. Ideal for naked-eye or binocular observing.';
    }
    if (score >= 50) {
      return 'Decent night for stargazing. Stick to brighter objects — planets, the Moon, and prominent star clusters.';
    }
    if (score >= 35) {
      return 'Marginal conditions. Try observing during clearer windows. Planets and bright stars should still be visible.';
    }
    if (score >= 20) {
      return 'Challenging conditions tonight. Consider a different night. Moon or clouds will limit visibility significantly.';
    }
    return 'Not recommended tonight. Heavy clouds, bright moon, or light pollution makes stargazing very difficult.';
  }

  /// Find the clearest hour tonight (lowest cloud cover).
  Map<String, dynamic>? _getBestWindow() {
    if (_tonightHours.isEmpty) return null;
    int bestIdx = 0;
    int bestCloud = 100;
    for (int i = 0; i < _tonightHours.length; i++) {
      final cloud = _tonightHours[i]['cloudCover'] as int;
      if (cloud < bestCloud) {
        bestCloud = cloud;
        bestIdx = i;
      }
    }
    return _tonightHours[bestIdx];
  }

  /// Mumbai fallback used when location is unavailable for any reason
  /// (denied permission, GPS off, timeout, etc.). Lets the rest of the
  /// forecast still render with sensible defaults.
  static final Position _fallbackPosition = Position(
    latitude: 19.0760,
    longitude: 72.8777,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  Future<void> _loadForecast() async {
    debugPrint('STARGAZING: Starting load');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Get location permission. If denied, fall through to Mumbai
      //    fallback below — the screen still works without GPS.
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      final permissionGranted = perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever;

      // 2. Try to get the user's actual location, with fallback on failure.
      //    geolocator 11.1's public API uses desiredAccuracy + timeLimit
      //    directly (not LocationSettings), so we use low accuracy for a
      //    fast fix and pair it with an outer safety timeout.
      if (permissionGranted) {
        try {
          _position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 12),
          ).timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint('STARGAZING: Location failed: $e');
          _position = _fallbackPosition;
          debugPrint('STARGAZING: Using fallback location Mumbai');
        }
      } else {
        debugPrint('STARGAZING: Permission denied — using fallback Mumbai');
        _position = _fallbackPosition;
      }
      debugPrint(
          'STARGAZING: Location got: ${_position?.latitude}, ${_position?.longitude}');

      // 3. Get weather forecast (returns null on failure — not fatal).
      _weatherData = await WeatherService.getWeatherForecast(
        lat: _position!.latitude,
        lon: _position!.longitude,
      );
      debugPrint(
          'STARGAZING: Weather data: ${_weatherData != null ? "SUCCESS" : "FAILED"}');

      if (_weatherData != null) {
        _tonightHours = WeatherService.getTonightHours(_weatherData!);
        debugPrint(
            'STARGAZING: Tonight hours parsed: ${_tonightHours.length}');
      }

      // 4. Light pollution (offline, always works).
      _bortleScale = LightPollutionData.getBortleScale(
        _position!.latitude,
        _position!.longitude,
      );

      // 5. Moon phase (offline, always works).
      _moonPhase = _getMoonPhase();

      // 6. Calculate score.
      _calculateScores();
    } catch (e) {
      debugPrint('STARGAZING: General error: $e');
      // Don't show an error screen — fall back to offline-only signals
      // (moon phase + default Bortle suburban) so the user still sees
      // a meaningful forecast.
      _moonPhase = _getMoonPhase();
      _bortleScale = 6;
      _calculateScores();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF5F5FF),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading(isDark)
            : _error != null
                ? _buildError(isDark)
                : _buildContent(isDark),
      ),
    );
  }

  // ══════════════════════════════════════════
  // LOADING / ERROR
  // ══════════════════════════════════════════
  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing sky conditions...',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Getting your location & weather',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTopBar(isDark),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌤️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Weather data unavailable.\n'
                    'Showing forecast based on moon phase '
                    'and light pollution only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF444466),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadForecast,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // MAIN CONTENT
  // ══════════════════════════════════════════
  Widget _buildContent(bool isDark) {
    final scoreColor = _getScoreColor(_overallScore);
    final illum = _getMoonIllumination();
    final phaseName = _getMoonPhaseName(_moonPhase);
    final bestWindow = _getBestWindow();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      cacheExtent: 500,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildTopBar(isDark),
          ),
        ),

        // ── HERO SCORE CARD ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scoreColor.withValues(alpha: 0.25),
                          scoreColor.withValues(alpha: 0.08),
                          const Color(0xFF0A0A1A).withValues(alpha: 0.95),
                        ],
                      )
                    : null,
                color: isDark ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scoreColor.withValues(alpha: isDark ? 0.4 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withValues(alpha: isDark ? 0.15 : 0.12),
                    blurRadius: isDark ? 20 : 12,
                    offset: Offset(0, isDark ? 6 : 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Score circle
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: scoreColor, width: 3),
                          color: scoreColor.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_overallScore',
                              style: TextStyle(
                                color: isDark
                                    ? scoreColor
                                    : const Color(0xFF1A1A2E),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/100',
                              style: TextStyle(
                                color: isDark
                                    ? scoreColor.withValues(alpha: 0.7)
                                    : Colors.black45,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                _getScoreEmoji(_overallScore),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getScoreLabel(_overallScore),
                                style: TextStyle(
                                  color: scoreColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text(
                              "Tonight's stargazing",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                            if (bestWindow != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: scoreColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '⏰ Best: ${_formatHour(bestWindow['time'] as DateTime)}',
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Score bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _overallScore / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getAdvice(_overallScore),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF444466),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── 3 SCORE COMPONENTS ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildScoreComponent(
                    isDark: isDark,
                    emoji: '☁️',
                    label: 'Weather',
                    score: _weatherScore,
                    maxScore: 40,
                    value: _tonightHours.isEmpty
                        ? 'Unknown'
                        : '${_getAvgCloud()}% clouds',
                    color: _getScoreColor(
                        (_weatherScore / 40 * 100).round()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildScoreComponent(
                    isDark: isDark,
                    emoji: '🌙',
                    label: 'Moon',
                    score: _moonScore,
                    maxScore: 30,
                    value: '$illum% lit',
                    color: _getScoreColor(
                        (_moonScore / 30 * 100).round()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildScoreComponent(
                    isDark: isDark,
                    emoji: '💡',
                    label: 'Light',
                    score: _pollutionScore,
                    maxScore: 30,
                    value: 'Bortle $_bortleScale',
                    color: _getScoreColor(
                        (_pollutionScore / 30 * 100).round()),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── HOURLY TONIGHT ──
        if (_tonightHours.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: _sectionHeader(
                  "🌙 Tonight's Hourly Forecast", isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tonightHours.length,
                separatorBuilder: (_, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final hour = _tonightHours[index];
                  final cloud = hour['cloudCover'] as int;
                  final time = hour['time'] as DateTime;
                  final hColor = cloud < 20
                      ? const Color(0xFF00E676)
                      : cloud < 50
                          ? const Color(0xFFFFEE58)
                          : cloud < 80
                              ? const Color(0xFFFFAB40)
                              : const Color(0xFFFF5252);

                  return Container(
                    width: 68,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141438)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: hColor.withValues(alpha: 0.3)),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          _formatHour(time),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.black45,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          cloud < 10
                              ? '✨'
                              : cloud < 30
                                  ? '🌤️'
                                  : cloud < 60
                                      ? '⛅'
                                      : cloud < 85
                                          ? '☁️'
                                          : '⛈️',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          '$cloud%',
                          style: TextStyle(
                            color: hColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // ── CONDITIONS DETAIL ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: _sectionHeader('🔭 Conditions Detail', isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141438) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    isDark,
                    '☁️',
                    'Cloud Cover',
                    _tonightHours.isEmpty
                        ? 'Unknown'
                        : '${_getAvgCloud()}% average tonight',
                    _tonightHours.isEmpty
                        ? Colors.grey
                        : _getScoreColor(
                            ((_weatherScore / 40) * 100).round()),
                  ),
                  _detailDivider(isDark),
                  _buildDetailRow(
                    isDark,
                    '🌙',
                    'Moon Phase',
                    '$phaseName • $illum% illuminated',
                    _getScoreColor((_moonScore / 30 * 100).round()),
                  ),
                  _detailDivider(isDark),
                  _buildDetailRow(
                    isDark,
                    '💡',
                    'Light Pollution',
                    'Bortle $_bortleScale — '
                        '${LightPollutionData.getBortleLabel(_bortleScale)}',
                    _getScoreColor((_pollutionScore / 30 * 100).round()),
                  ),
                  _detailDivider(isDark),
                  _buildDetailRow(
                    isDark,
                    '💧',
                    'Humidity',
                    _tonightHours.isEmpty
                        ? 'Unknown'
                        : '${_getAvgHumidity()}% average',
                    _getAvgHumidity() > 80
                        ? const Color(0xFFFFAB40)
                        : const Color(0xFF00E676),
                  ),
                  if (_position != null) ...[
                    _detailDivider(isDark),
                    _buildDetailRow(
                      isDark,
                      '📍',
                      'Your Location',
                      '${_position!.latitude.toStringAsFixed(2)}°N, '
                          '${_position!.longitude.toStringAsFixed(2)}°E',
                      const Color(0xFF6C63FF),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── WHAT TO OBSERVE ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: _sectionHeader('👁️ What to Observe Tonight', isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _buildObservingGuide(isDark),
          ),
        ),

        // ── LIGHT POLLUTION TIPS ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1F5F)
                    .withValues(alpha: isDark ? 1.0 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 ${LightPollutionData.getBortleLabel(_bortleScale)}',
                    style: const TextStyle(
                      color: Color(0xFFB39DDB),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    LightPollutionData.getBortleDescription(_bortleScale),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF444466),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  if (_bortleScale > 5) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '💡 Tip: Drive 30-40 km outside your city for '
                      'significantly darker skies.',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── REFRESH BUTTON ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            child: GestureDetector(
              onTap: _loadForecast,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141438) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                          ),
                        ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh,
                        color: Color(0xFF6C63FF), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Refresh Forecast',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // SECTION HEADER (gradient bar + emoji title)
  // ══════════════════════════════════════════
  Widget _sectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
    );
  }

  // ══════════════════════════════════════════
  // TOP BAR
  // ══════════════════════════════════════════
  Widget _buildTopBar(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141438) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stargazing Forecast',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Local sky conditions tonight',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // SCORE COMPONENT CARD
  // ══════════════════════════════════════════
  Widget _buildScoreComponent({
    required bool isDark,
    required String emoji,
    required String label,
    required int score,
    required int maxScore,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141438) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score/$maxScore',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / maxScore,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // DETAIL ROW
  // ══════════════════════════════════════════
  Widget _buildDetailRow(
    bool isDark,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color:
                        isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // WHAT TO OBSERVE
  // ══════════════════════════════════════════
  Widget _buildObservingGuide(bool isDark) {
    final items = _overallScore >= 60
        ? [
            {
              'icon': '🪐',
              'title': 'Planets',
              'desc':
                  'Venus, Jupiter and Saturn are visible to naked eye',
            },
            {
              'icon': '⭐',
              'title': 'Star Clusters',
              'desc': 'Pleiades and Orion Nebula should be visible',
            },
            {
              'icon': '🌌',
              'title': 'Milky Way',
              'desc': _bortleScale <= 4
                  ? 'Milky Way band visible tonight!'
                  : 'Faint from your location — try a darker area',
            },
            {
              'icon': '☄️',
              'title': 'Meteor Shower',
              'desc':
                  'Check tonight for any active meteor showers',
            },
          ]
        : [
            {
              'icon': '🪐',
              'title': 'Bright Planets',
              'desc':
                  'Venus and Jupiter visible even through some clouds',
            },
            {
              'icon': '🌕',
              'title': 'Moon',
              'desc': _getMoonIllumination() > 50
                  ? 'Bright moon — great for lunar details'
                  : 'Moon less bright — better for stars',
            },
            {
              'icon': '⭐',
              'title': 'Brightest Stars',
              'desc':
                  'Sirius, Vega, Arcturus visible in most conditions',
            },
          ];

    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141438) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Text(item['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc']!,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.black45,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ══════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════
  int _getAvgCloud() {
    if (_tonightHours.isEmpty) return 0;
    return _tonightHours
            .map((h) => h['cloudCover'] as int)
            .reduce((a, b) => a + b) ~/
        _tonightHours.length;
  }

  int _getAvgHumidity() {
    if (_tonightHours.isEmpty) return 0;
    return _tonightHours
            .map((h) => h['humidity'] as int)
            .reduce((a, b) => a + b) ~/
        _tonightHours.length;
  }

  String _formatHour(DateTime t) {
    final h = t.hour;
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h == 0
        ? 12
        : h > 12
            ? h - 12
            : h;
    return '$hour $period';
  }
}
