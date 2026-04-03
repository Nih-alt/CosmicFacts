import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../data/star_catalog.dart';
import '../../data/ar_constellation_data.dart';
import '../../utils/astronomy_math.dart';

class ArSkyMapScreen extends StatefulWidget {
  const ArSkyMapScreen({super.key});

  @override
  State<ArSkyMapScreen> createState() => _ArSkyMapScreenState();
}

class _ArSkyMapScreenState extends State<ArSkyMapScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _cameraPermissionDenied = false;

  // Sensor values (smoothed)
  double _azimuth = 0.0;
  double _pitch = 0.0;
  double _roll = 0.0;

  // GPS
  double _lat = 0.0;
  double _lon = 0.0;
  bool _locationReady = false;

  // Calibration
  bool _calibrated = false;
  bool _showCalibration = true;

  // Display toggles
  bool _showConstellations = true;
  bool _showLabels = true;
  bool _showPlanets = true;

  // Tapped object info
  Map<String, dynamic>? _tappedObject;

  // Streams
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // Calibration animation
  late AnimationController _calibrationAnimController;

  @override
  void initState() {
    super.initState();
    _calibrationAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _requestPermissions();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _calibrationAnimController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Camera
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      setState(() => _cameraPermissionDenied = true);
    }

    // Location
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          );
          setState(() {
            _lat = pos.latitude;
            _lon = pos.longitude;
            _locationReady = true;
          });
        } catch (_) {
          _useFallbackLocation();
        }
      } else {
        _useFallbackLocation();
      }
    } else {
      _useFallbackLocation();
    }

    await _initCamera();
    _startSensors();
  }

  void _useFallbackLocation() {
    setState(() {
      _lat = 19.0760;
      _lon = 72.8777;
      _locationReady = true;
    });
  }

  Future<void> _initCamera() async {
    if (_cameraPermissionDenied) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  void _startSensors() {
    // Compass
    final compassSub = FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        setState(() {
          _azimuth = AstronomyMath.smoothAzimuth(
              event.heading!, _azimuth,
              alpha: 0.12);
        });
      }
    });
    if (compassSub != null) _subscriptions.add(compassSub);

    // Accelerometer for pitch/roll
    final accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      if (!mounted) return;
      final pitch = atan2(-event.x, sqrt(event.y * event.y + event.z * event.z)) *
          180 /
          pi;
      final roll = atan2(event.y, event.z) * 180 / pi;

      setState(() {
        _pitch = AstronomyMath.lowPass(pitch, _pitch, alpha: 0.15);
        _roll = AstronomyMath.lowPass(roll, _roll, alpha: 0.15);
      });
    });
    _subscriptions.add(accelSub);
  }

  void _handleTap(Offset tapPos) {
    final size = MediaQuery.of(context).size;
    final now = DateTime.now();
    const tapRadius = 30.0;

    // Check stars
    for (final star in brightStars) {
      if (star.magnitude > 3.5) continue;
      final pos = AstronomyMath.raDecToAltAz(
        ra: star.ra,
        dec: star.dec,
        lat: _lat,
        lon: _lon,
        time: now,
      );
      final screenPos = AstronomyMath.toScreenPosition(
        starAlt: pos['alt']!,
        starAz: pos['az']!,
        phoneAlt: _pitch,
        phoneAz: _azimuth,
        screenWidth: size.width,
        screenHeight: size.height,
      );
      if (screenPos == null) continue;
      if ((tapPos - screenPos).distance < tapRadius) {
        setState(() {
          _tappedObject = {
            'type': 'star',
            'name': star.name,
            'bayer': star.bayer,
            'constellation': star.constellation,
            'magnitude': star.magnitude.toStringAsFixed(2),
            'alt': pos['alt']!.toStringAsFixed(1),
            'az': pos['az']!.toStringAsFixed(1),
          };
        });
        return;
      }
    }

    // Check planets
    final planetNames = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn'];
    for (final name in planetNames) {
      final pos = AstronomyMath.planetPosition(
          planet: name, time: now, lat: _lat, lon: _lon);
      final screenPos = AstronomyMath.toScreenPosition(
        starAlt: pos['alt']!,
        starAz: pos['az']!,
        phoneAlt: _pitch,
        phoneAz: _azimuth,
        screenWidth: size.width,
        screenHeight: size.height,
      );
      if (screenPos == null) continue;
      if ((tapPos - screenPos).distance < tapRadius * 1.5) {
        setState(() {
          _tappedObject = {
            'type': 'planet',
            'name': name,
            'alt': pos['alt']!.toStringAsFixed(1),
            'az': pos['az']!.toStringAsFixed(1),
          };
        });
        return;
      }
    }

    setState(() => _tappedObject = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(),
          if (_locationReady) _buildSkyOverlay(),
          if (_showCalibration && !_calibrated) _buildCalibrationScreen(),
          if (_calibrated || !_showCalibration) ...[
            _buildTopBar(),
            _buildBottomBar(),
            if (_tappedObject != null) _buildObjectInfoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_cameraReady && _cameraController != null) {
      return SizedBox.expand(
        child: CameraPreview(_cameraController!),
      );
    }
    return SizedBox.expand(
      child: CustomPaint(
        painter: _StarfieldBackgroundPainter(),
      ),
    );
  }

  Widget _buildCalibrationScreen() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _calibrationAnimController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _calibrationAnimController.value * 2 * pi,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF6C63FF), width: 2),
                    ),
                    child: const Icon(Icons.explore,
                        color: Color(0xFF6C63FF), size: 40),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Calibrate Compass',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Move your phone in a figure-8 pattern',
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFF1A1A2E),
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _calibrated = true;
                      _showCalibration = false;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Start Exploring',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _calibrated = true;
                    _showCalibration = false;
                  }),
                  child: Text('Skip Calibration',
                      style: TextStyle(color: Colors.grey[500])),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tip: Remove phone from metal case for best accuracy',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkyOverlay() {
    return GestureDetector(
      onTapUp: (details) => _handleTap(details.localPosition),
      child: CustomPaint(
        painter: _SkyOverlayPainter(
          stars: brightStars,
          constellations: majorConstellations,
          azimuth: _azimuth,
          pitch: _pitch,
          lat: _lat,
          lon: _lon,
          time: DateTime.now(),
          showConstellations: _showConstellations,
          showLabels: _showLabels,
          showPlanets: _showPlanets,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              const Text(
                'Sky Map',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _showCalibration = true;
                  _calibrated = false;
                }),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggle(
              icon: Icons.polyline,
              label: 'Lines',
              active: _showConstellations,
              onTap: () =>
                  setState(() => _showConstellations = !_showConstellations),
            ),
            _buildToggle(
              icon: Icons.label_outline,
              label: 'Labels',
              active: _showLabels,
              onTap: () => setState(() => _showLabels = !_showLabels),
            ),
            _buildToggle(
              icon: Icons.public,
              label: 'Planets',
              active: _showPlanets,
              onTap: () => setState(() => _showPlanets = !_showPlanets),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final color = active ? const Color(0xFF6C63FF) : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildObjectInfoCard() {
    final obj = _tappedObject!;
    final isPlanet = obj['type'] == 'planet';
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlanet
                ? const Color(0xFFFFB74D).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isPlanet
                        ? const Color(0xFFFFB74D)
                        : Colors.white)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isPlanet ? Icons.public : Icons.star,
                  color: isPlanet
                      ? const Color(0xFFFFB74D)
                      : Colors.amber,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    obj['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (obj['bayer'] != null)
                    Text(obj['bayer'] as String,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  if (obj['constellation'] != null)
                    Text('Constellation: ${obj['constellation']}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  if (obj['magnitude'] != null)
                    Text('Magnitude: ${obj['magnitude']}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  Text(
                    'Alt: ${obj['alt']}° | Az: ${obj['az']}°',
                    style: const TextStyle(
                        color: Color(0xFF6C63FF), fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.close, color: Colors.white38, size: 18),
              onPressed: () => setState(() => _tappedObject = null),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SKY OVERLAY PAINTER
// ═══════════════════════════════════════════════════════

class _SkyOverlayPainter extends CustomPainter {
  final List<StarData> stars;
  final List<ARConstellationData> constellations;
  final double azimuth;
  final double pitch;
  final double lat;
  final double lon;
  final DateTime time;
  final bool showConstellations;
  final bool showLabels;
  final bool showPlanets;

  _SkyOverlayPainter({
    required this.stars,
    required this.constellations,
    required this.azimuth,
    required this.pitch,
    required this.lat,
    required this.lon,
    required this.time,
    required this.showConstellations,
    required this.showLabels,
    required this.showPlanets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = time;

    // Constellation lines (behind stars)
    if (showConstellations) {
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      for (final constellation in constellations) {
        for (final line in constellation.lines) {
          StarData? s1, s2;
          for (final s in stars) {
            if (s.name == line.star1) s1 = s;
            if (s.name == line.star2) s2 = s;
          }
          if (s1 == null || s2 == null) continue;

          final pos1 = _getStarScreenPos(s1, size, now);
          final pos2 = _getStarScreenPos(s2, size, now);

          if (pos1 != null && pos2 != null) {
            canvas.drawLine(pos1, pos2, linePaint);
          }
        }
      }
    }

    // Stars
    for (final star in stars) {
      if (star.magnitude > 4.5) continue;

      final pos = _getStarScreenPos(star, size, now);
      if (pos == null) continue;

      final starRadius =
          ((5.5 - star.magnitude) / 6.0 * 6.0 + 1.5).clamp(1.0, 8.0);
      final starColor = getStarColor(star.colorTemp);

      // Glow for bright stars
      if (star.magnitude < 1.5) {
        final glowPaint = Paint()
          ..color = starColor.withValues(alpha: 0.25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, starRadius * 2);
        canvas.drawCircle(pos, starRadius * 2.5, glowPaint);
      }

      // Star dot
      canvas.drawCircle(
        pos,
        starRadius,
        Paint()..color = starColor.withValues(alpha: 0.9),
      );

      // Cross flare for very bright stars
      if (star.magnitude < 0.5) {
        final flarePaint = Paint()
          ..color = starColor.withValues(alpha: 0.4)
          ..strokeWidth = 0.8;
        canvas.drawLine(
          Offset(pos.dx - starRadius * 3, pos.dy),
          Offset(pos.dx + starRadius * 3, pos.dy),
          flarePaint,
        );
        canvas.drawLine(
          Offset(pos.dx, pos.dy - starRadius * 3),
          Offset(pos.dx, pos.dy + starRadius * 3),
          flarePaint,
        );
      }

      // Labels
      if (showLabels && star.magnitude < 2.2) {
        _drawLabel(canvas, pos, star.name,
            color: starColor.withValues(alpha: 0.8),
            fontSize: 10.0,
            offset: Offset(starRadius + 4, -4));
      }
    }

    // Planets
    if (showPlanets) {
      final planetData = [
        {'name': 'Mercury', 'color': const Color(0xFFB0BEC5), 'size': 5.0},
        {'name': 'Venus', 'color': const Color(0xFFFFF176), 'size': 7.0},
        {'name': 'Mars', 'color': const Color(0xFFEF5350), 'size': 6.0},
        {'name': 'Jupiter', 'color': const Color(0xFFFFB74D), 'size': 9.0},
        {'name': 'Saturn', 'color': const Color(0xFFFFD54F), 'size': 8.0},
      ];

      for (final planet in planetData) {
        final pos2d = AstronomyMath.planetPosition(
          planet: planet['name'] as String,
          time: now,
          lat: lat,
          lon: lon,
        );

        final screenPos = AstronomyMath.toScreenPosition(
          starAlt: pos2d['alt']!,
          starAz: pos2d['az']!,
          phoneAlt: pitch,
          phoneAz: azimuth,
          screenWidth: size.width,
          screenHeight: size.height,
        );

        if (screenPos == null) continue;
        if (pos2d['alt']! < -5) continue;

        final pColor = planet['color'] as Color;
        final pSize = planet['size'] as double;

        // Glow
        canvas.drawCircle(
          screenPos,
          pSize * 2.0,
          Paint()
            ..color = pColor.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        // Planet circle
        canvas.drawCircle(screenPos, pSize, Paint()..color = pColor);
        // Label
        if (showLabels) {
          _drawLabel(canvas, screenPos, planet['name'] as String,
              color: pColor,
              fontSize: 11.0,
              bold: true,
              offset: Offset(pSize + 5, -4));
        }
      }
    }

    // Compass rose
    _drawCompassRose(canvas, size);

    // Horizon line
    _drawHorizonLine(canvas, size);
  }

  Offset? _getStarScreenPos(StarData star, Size size, DateTime now) {
    final pos = AstronomyMath.raDecToAltAz(
      ra: star.ra,
      dec: star.dec,
      lat: lat,
      lon: lon,
      time: now,
    );

    if (pos['alt']! < -10) return null;

    return AstronomyMath.toScreenPosition(
      starAlt: pos['alt']!,
      starAz: pos['az']!,
      phoneAlt: pitch,
      phoneAz: azimuth,
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }

  void _drawLabel(
    Canvas canvas,
    Offset pos,
    String text, {
    required Color color,
    double fontSize = 10.0,
    bool bold = false,
    Offset offset = const Offset(8, -4),
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w400,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos + offset);
  }

  void _drawCompassRose(Canvas canvas, Size size) {
    final directions = [
      {'label': 'N', 'az': 0.0, 'color': const Color(0xFFFF5252)},
      {'label': 'E', 'az': 90.0, 'color': Colors.white},
      {'label': 'S', 'az': 180.0, 'color': Colors.white},
      {'label': 'W', 'az': 270.0, 'color': Colors.white},
    ];

    for (final dir in directions) {
      double dAz = (dir['az'] as double) - azimuth;
      if (dAz > 180) dAz -= 360;
      if (dAz < -180) dAz += 360;
      if (dAz.abs() > 40) continue;

      final x = size.width / 2 + (dAz / 40.0) * size.width * 0.4;
      final label = dir['label'] as String;
      final color = dir['color'] as Color;

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 80));

      canvas.drawLine(
        Offset(x, size.height - 62),
        Offset(x, size.height - 56),
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawHorizonLine(Canvas canvas, Size size) {
    final horizonDeltaAlt = 0.0 - pitch;
    const fovV = 50.0;
    final y =
        size.height / 2 - (horizonDeltaAlt / (fovV / 2)) * size.height / 2;

    if (y < 0 || y > size.height) return;

    final paint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..strokeWidth = 0.8;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + 8, y), paint);
      x += 16;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'Horizon',
        style: TextStyle(
          color: const Color(0xFF00E676).withValues(alpha: 0.5),
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, y + 2));
  }

  @override
  bool shouldRepaint(covariant _SkyOverlayPainter old) =>
      old.azimuth != azimuth || old.pitch != pitch;
}

// ═══════════════════════════════════════════════════════
// STARFIELD BACKGROUND (when camera unavailable)
// ═══════════════════════════════════════════════════════

class _StarfieldBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0A1A),
    );
    final rng = Random(42);
    for (int i = 0; i < 200; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.5 + 0.3;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color =
              Colors.white.withValues(alpha: rng.nextDouble() * 0.5 + 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
