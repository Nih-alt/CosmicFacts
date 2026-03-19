import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Map<String, dynamic>> _astronauts = [];
  int _astronautCount = 0;
  bool _isLoadingISS = true;
  bool _isLoadingAstronauts = true;
  bool _hasError = false;

  Timer? _issTimer;
  Timer? _astronautTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _fetchISSLocation();
    _fetchAstronauts();
    _issTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchISSLocation());
    _astronautTimer = Timer.periodic(const Duration(seconds: 60), (_) => _fetchAstronauts());
  }

  @override
  void dispose() {
    _issTimer?.cancel();
    _astronautTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchISSLocation() async {
    final data = await ApiService.getISSLocation();
    if (!mounted) return;
    if (data != null && data['message'] == 'success') {
      setState(() {
        _latitude = double.tryParse(data['iss_position']?['latitude']?.toString() ?? '');
        _longitude = double.tryParse(data['iss_position']?['longitude']?.toString() ?? '');
        _isLoadingISS = false;
        _hasError = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App bar
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
                      child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context)),
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
                    // Live indicator
                    _buildLiveIndicator(),
                  ],
                ),
              ),
            ),
          ),

          // Radar section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _isLoadingISS
                  ? _buildShimmer(320)
                  : _hasError
                      ? _buildErrorState()
                      : _buildRadarSection(),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
          ),

          // ISS Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildISSInfoCard(),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 100.ms),
          ),

          // Astronauts section
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms),
          ),

          // Astronaut list
          _isLoadingAstronauts
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildShimmer(60),
                      )),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final astronaut = _astronauts[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 4, 20, 4),
                        child: _buildAstronautCard(astronaut),
                      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 250 + index * 50))
                          .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: Duration(milliseconds: 250 + index * 50));
                    },
                    childCount: _astronauts.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

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
                color: AppColors.success.withValues(alpha: 0.5 + _pulseController.value * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3 * _pulseController.value),
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

  Widget _buildRadarSection() {
    return Column(
      children: [
        // Radar circle
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            painter: _RadarPainter(
              latitude: _latitude ?? 0,
              longitude: _longitude ?? 0,
              pulseValue: _pulseController.value,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) => const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Coordinates
        Text(
          'Latitude: ${_latitude?.toStringAsFixed(4) ?? '--'}°  |  Longitude: ${_longitude?.toStringAsFixed(4) ?? '--'}°',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(CupertinoIcons.wifi_slash, size: 48, color: AppColors.textSecondary(context)),
        const SizedBox(height: 16),
        Text(
          'Could not fetch ISS data',
          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          color: AppColors.accentPurple,
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
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildISSInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'International Space Station',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(CupertinoIcons.speedometer, 'Speed', '27,600 km/h'),
              const SizedBox(height: 12),
              _buildInfoRow(CupertinoIcons.arrow_up_circle, 'Altitude', '408 km above Earth'),
              const SizedBox(height: 12),
              _buildInfoRow(CupertinoIcons.arrow_2_circlepath, 'Orbits per day', '15.5 orbits'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentCyan),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAstronautCard(Map<String, dynamic> astronaut) {
    final name = astronaut['name']?.toString() ?? 'Unknown';
    final craft = astronaut['craft']?.toString() ?? 'Unknown';

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPurple.withValues(alpha: 0.3),
                      AppColors.accentCyan.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: const Icon(CupertinoIcons.person_fill, size: 18, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    color: craft == 'ISS' ? AppColors.accentCyan : AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
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
}

// ═══════════════════════════════════════════
// RADAR PAINTER
// ═══════════════════════════════════════════

class _RadarPainter extends CustomPainter {
  final double latitude;
  final double longitude;
  final double pulseValue;
  final bool isDark;

  _RadarPainter({
    required this.latitude,
    required this.longitude,
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0A0A2E) : const Color(0xFFE8E6F0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Border gradient
    final borderPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF7B5BFF),
          const Color(0xFF00D4FF),
          const Color(0xFF7B5BFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    // Horizontal grid lines (latitude)
    for (int i = 1; i < 6; i++) {
      final y = center.dy - radius + (radius * 2 * i / 6);
      final dx = sqrt(max(0, radius * radius - (y - center.dy) * (y - center.dy)));
      canvas.drawLine(
        Offset(center.dx - dx, y),
        Offset(center.dx + dx, y),
        gridPaint,
      );
    }

    // Vertical grid lines (longitude)
    for (int i = 1; i < 8; i++) {
      final x = center.dx - radius + (radius * 2 * i / 8);
      final dy = sqrt(max(0, radius * radius - (x - center.dx) * (x - center.dx)));
      canvas.drawLine(
        Offset(x, center.dy - dy),
        Offset(x, center.dy + dy),
        gridPaint,
      );
    }

    // Equator line
    final equatorPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      equatorPaint,
    );
    // Prime meridian
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      equatorPaint,
    );

    // ISS position dot
    // Map lat (-90 to 90) and lon (-180 to 180) to circle coords
    final issX = center.dx + (longitude / 180) * (radius - 20);
    final issY = center.dy - (latitude / 90) * (radius - 20);

    // Check if point is within the circle
    final dist = (Offset(issX, issY) - center).distance;
    if (dist < radius - 5) {
      // Pulse ring
      final pulsePaint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.4 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(issX, issY), 6 + 14 * pulseValue, pulsePaint);

      // Second pulse ring
      final pulse2Value = (pulseValue + 0.5) % 1.0;
      final pulse2Paint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.3 * (1 - pulse2Value))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(issX, issY), 6 + 14 * pulse2Value, pulse2Paint);

      // Core dot
      final dotPaint = Paint()
        ..color = AppColors.error
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(issX, issY), 6, dotPaint);

      // Inner bright core
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(issX, issY), 2.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => true;
}
