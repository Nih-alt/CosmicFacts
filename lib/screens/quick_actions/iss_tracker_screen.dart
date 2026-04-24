import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class ISSTrackerScreen extends StatefulWidget {
  const ISSTrackerScreen({super.key});

  @override
  State<ISSTrackerScreen> createState() => _ISSTrackerScreenState();
}

class _ISSTrackerScreenState extends State<ISSTrackerScreen>
    with TickerProviderStateMixin {
  double? _latitude;
  double? _longitude;
  double? _prevLatitude;
  double? _prevLongitude;
  List<Map<String, dynamic>> _astronauts = [];
  int _astronautCount = 0;
  bool _isLoadingISS = true;
  bool _isLoadingAstronauts = true;
  bool _hasError = false;

  Timer? _issTimer;
  Timer? _astronautTimer;
  late AnimationController _pulseController;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _mapController = MapController();
    _fetchISSLocation();
    _fetchAstronauts();
    _issTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchISSLocation(),
    );
    _astronautTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchAstronauts(),
    );
  }

  @override
  void dispose() {
    _issTimer?.cancel();
    _astronautTimer?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchISSLocation() async {
    final data = await ApiService.getISSLocation();
    if (!mounted) return;
    if (data != null && data['message'] == 'success') {
      final newLat = double.tryParse(
        data['iss_position']?['latitude']?.toString() ?? '',
      );
      final newLng = double.tryParse(
        data['iss_position']?['longitude']?.toString() ?? '',
      );
      setState(() {
        _prevLatitude = _latitude;
        _prevLongitude = _longitude;
        _latitude = newLat;
        _longitude = newLng;
        _isLoadingISS = false;
        _hasError = false;
      });
      _recenterMap();
    } else if (_latitude == null) {
      setState(() {
        _hasError = true;
        _isLoadingISS = false;
      });
    }
  }

  Future<void> _fetchAstronauts() async {
    final data = await ApiService.getAstronautsInSpace();
    if (!mounted) return;
    if (data != null && data['message'] == 'success') {
      setState(() {
        _astronautCount = data['number'] ?? 0;
        _astronauts = List<Map<String, dynamic>>.from(data['people'] ?? []);
        _isLoadingAstronauts = false;
      });
    } else {
      setState(() => _isLoadingAstronauts = false);
    }
  }

  void _recenterMap() {
    if (_latitude == null || _longitude == null) return;
    // camera access throws if map not yet mounted; guard with try/catch.
    try {
      final z = _mapController.camera.zoom;
      _mapController.move(LatLng(_latitude!, _longitude!), z);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.back,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'ISS Tracker',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    _buildLiveIndicator(),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _isLoadingISS && _latitude == null
                  ? _buildShimmer(mapHeight)
                  : _hasError
                      ? _buildErrorState()
                      : _buildMap(isDark, mapHeight),
            ).animate().fadeIn(duration: 500.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: _buildTelemetryStrip(),
            ).animate().fadeIn(duration: 500.ms, delay: 80.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: _buildStatGrid(),
            ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(
                  begin: 0.12,
                  end: 0,
                  duration: 500.ms,
                  delay: 150.ms,
                ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'People in Space Right Now',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  if (!_isLoadingAstronauts && _astronautCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_astronautCount people',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 220.ms).slideY(
                  begin: 0.12,
                  end: 0,
                  duration: 500.ms,
                  delay: 220.ms,
                ),
          ),

          _isLoadingAstronauts
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildShimmer(60),
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final astronaut = _astronauts[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          index == 0 ? 0 : 4,
                          20,
                          4,
                        ),
                        child: _buildAstronautCard(astronaut),
                      )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 260 + index * 40),
                          )
                          .slideX(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: Duration(milliseconds: 260 + index * 40),
                          );
                    },
                    childCount: _astronauts.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // MAP
  // ═══════════════════════════════════════════

  Widget _buildMap(bool isDark, double height) {
    final hasFix = _latitude != null && _longitude != null;
    final center = hasFix ? LatLng(_latitude!, _longitude!) : const LatLng(0, 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 2,
                minZoom: 1,
                maxZoom: 8,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.apprication.cosmic_facts',
                  maxNativeZoom: 19,
                ),
                PolylineLayer(polylines: _buildOrbitPolylines()),
                if (hasFix)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_latitude!, _longitude!),
                        width: 80,
                        height: 80,
                        child: _buildISSMarker(),
                      ),
                    ],
                  ),
              ],
            ),
            // Attribution (CartoDB ToS).
            Positioned(
              right: 6,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '© OpenStreetMap · CARTO',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildISSMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 18 + 42 * pulse,
              height: 18 + 42 * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.35 * (1 - pulse)),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.55),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ISS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // ORBIT POLYLINE (20 points, solid cyan)
  // Inclination 51.6°, period 93 min, Earth sidereal day 1436 min.
  // ═══════════════════════════════════════════

  List<Polyline> _buildOrbitPolylines() {
    if (_latitude == null || _longitude == null) return const [];
    final points = _computeOrbitPoints(_latitude!, _longitude!);
    // Split at antimeridian (>180° jump) so the line doesn't wrap across the map.
    final segments = <List<LatLng>>[];
    var current = <LatLng>[];
    for (final p in points) {
      if (current.isNotEmpty &&
          (p.longitude - current.last.longitude).abs() > 180) {
        segments.add(current);
        current = <LatLng>[];
      }
      current.add(p);
    }
    if (current.isNotEmpty) segments.add(current);

    return [
      for (final s in segments)
        if (s.length >= 2)
          Polyline(
            points: s,
            color: AppColors.accentCyan,
            strokeWidth: 2.5,
          ),
    ];
  }

  List<LatLng> _computeOrbitPoints(double lat, double lng) {
    const inclination = 51.6 * pi / 180.0;
    const orbitalPeriodMin = 93.0;
    const earthRotationMin = 1436.0;
    const totalMinutes = 30.0;
    const n = 20;

    final latRad = lat * pi / 180.0;
    final lngRad = lng * pi / 180.0;

    // Orbital argument μ₀ from current latitude (assume ascending pass).
    final sinMu0 = (sin(latRad) / sin(inclination)).clamp(-1.0, 1.0);
    final mu0 = asin(sinMu0);
    final lngOrbit0 = atan2(cos(inclination) * sin(mu0), cos(mu0));
    final ascNodeLng = lngRad - lngOrbit0;

    final out = <LatLng>[];
    for (int i = 0; i < n; i++) {
      final t = (i / (n - 1) - 0.5) * totalMinutes; // −15..+15 min
      final mu = mu0 + 2 * pi * t / orbitalPeriodMin;
      final pLat = asin(sin(inclination) * sin(mu));
      final lngOrbitT = atan2(cos(inclination) * sin(mu), cos(mu));
      var pLng = ascNodeLng + lngOrbitT - 2 * pi * t / earthRotationMin;
      // Wrap to [−π, π].
      pLng = (pLng + pi) % (2 * pi);
      if (pLng < 0) pLng += 2 * pi;
      pLng -= pi;
      out.add(LatLng(pLat * 180 / pi, pLng * 180 / pi));
    }
    return out;
  }

  // ═══════════════════════════════════════════
  // TELEMETRY STRIP (4 chips, horizontal scroll)
  // ═══════════════════════════════════════════

  Widget _buildTelemetryStrip() {
    final hasFix = _latitude != null && _longitude != null;
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _telemetryChip('⚡', 'Velocity', '27,580 km/h'),
          _telemetryChip(
            '📍',
            'Over',
            hasFix ? _positionOver(_latitude!, _longitude!) : '—',
          ),
          _telemetryChip(
            '🧭',
            'Heading',
            _heading(_prevLatitude, _prevLongitude, _latitude, _longitude),
          ),
        ],
      ),
    );
  }

  Widget _telemetryChip(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 2x2 STAT GRID
  // ═══════════════════════════════════════════

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                CupertinoIcons.speedometer,
                'Speed',
                '27,580',
                'km/h',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                CupertinoIcons.arrow_up_circle,
                'Altitude',
                '408',
                'km',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                CupertinoIcons.arrow_2_circlepath,
                'Orbits Today',
                '${_orbitsToday()}',
                'of ~15',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                CupertinoIcons.person_3_fill,
                'Crew',
                _isLoadingAstronauts ? '—' : '$_astronautCount',
                'in space',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, String unit) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.accentCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      unit,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LIVE INDICATOR (reuses _pulseController)
  // ═══════════════════════════════════════════

  Widget _buildLiveIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success
                    .withValues(alpha: 0.5 + _pulseController.value * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success
                        .withValues(alpha: 0.3 * _pulseController.value),
                    blurRadius: 6,
                    spreadRadius: 2 * _pulseController.value,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ERROR / SHIMMER
  // ═══════════════════════════════════════════

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.wifi_slash,
            size: 48,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Could not fetch ISS data',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              setState(() {
                _isLoadingISS = true;
                _hasError = false;
              });
              _fetchISSLocation();
            },
            child: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase(context),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ASTRONAUT CARD
  // ═══════════════════════════════════════════

  Widget _buildAstronautCard(Map<String, dynamic> astronaut) {
    final name = astronaut['name']?.toString() ?? 'Unknown';
    final craft = astronaut['craft']?.toString() ?? 'Unknown';
    final flag = _astronautFlag(name, craft);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.3),
                      AppColors.accentCyan.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Text(flag, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      craft,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: craft == 'ISS'
                      ? AppColors.accentCyan.withValues(alpha: 0.15)
                      : AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  craft,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: craft == 'ISS'
                        ? AppColors.accentCyan
                        : AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HELPERS (pure functions)
  // ═══════════════════════════════════════════

  String _astronautFlag(String name, String craft) {
    final c = craft.toLowerCase();
    if (c.contains('tiangong') || c.contains('shenzhou')) return '🇨🇳';

    final parts = name.trim().split(RegExp(r'\s+'));
    final last = parts.isEmpty ? '' : parts.last.toLowerCase();

    // Russian surname endings.
    const ruEnds = ['ov', 'ev', 'in', 'ko', 'sky', 'skiy', 'uk', 'chuk'];
    for (final e in ruEnds) {
      if (last.endsWith(e)) return '🇷🇺';
    }
    // Default: assume US (the majority of remaining ISS crew).
    return '🇺🇸';
  }

  String _positionOver(double lat, double lng) {
    if (lat < -60) return 'Antarctica';
    if (lat > 66 && lng > -60 && lng < 60) return 'Arctic';

    // Continental bounding boxes — coarse but readable.
    if (lat > -35 && lat < 37 && lng > -18 && lng < 51) return 'Africa';
    if (lat > 36 && lat < 71 && lng > -10 && lng < 60) return 'Europe';
    if (lat > 10 && lat < 75 && lng >= 60 && lng < 180) return 'Asia';
    if (lat > -45 && lat < -10 && lng > 110 && lng <= 180) return 'Australia';
    if (lat > 15 && lat < 75 && lng > -170 && lng < -50) return 'North America';
    if (lat > -55 && lat < 13 && lng > -82 && lng < -34) return 'South America';

    // Oceans by longitude band.
    if (lng > -80 && lng < 20) return 'Atlantic Ocean';
    if (lng >= 20 && lng < 150) return 'Indian Ocean';
    return 'Pacific Ocean';
  }

  String _heading(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return '—';
    }
    if ((lat1 - lat2).abs() < 1e-6 && (lng1 - lng2).abs() < 1e-6) return '—';
    final p1 = lat1 * pi / 180;
    final p2 = lat2 * pi / 180;
    var d = (lng2 - lng1) * pi / 180;
    if (d > pi) d -= 2 * pi;
    if (d < -pi) d += 2 * pi;
    final y = sin(d) * cos(p2);
    final x = cos(p1) * sin(p2) - sin(p1) * cos(p2) * cos(d);
    var bearing = atan2(y, x) * 180 / pi;
    bearing = (bearing + 360) % 360;
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final cardinal = dirs[((bearing + 22.5) / 45).floor() % 8];
    return '${bearing.round()}° $cardinal';
  }

  int _orbitsToday() {
    final now = DateTime.now();
    final fraction =
        (now.hour + now.minute / 60.0 + now.second / 3600.0) / 24.0;
    return (15.5 * fraction).floor();
  }
}
