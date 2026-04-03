// DISCLAIMER: Space weather data sourced from NOAA Space Weather
// Prediction Center (SWPC), a US government public service.
// This app is unofficial and not affiliated with NOAA.

import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/space_weather_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

// ─── Palette ──────────────────────────────────────────────────
const _kAccent = Color(0xFF6C63FF);
const _kCardDark = Color(0xFF141438);
const _kBgDark = Color(0xFF0A0A1A);

Color _stormColor(double kp) {
  if (kp < 3) return const Color(0xFF00E676);
  if (kp < 4) return const Color(0xFFFFEE58);
  if (kp < 5) return const Color(0xFFFFAB40);
  if (kp < 6) return const Color(0xFFFF7043);
  if (kp < 7) return const Color(0xFFFF5252);
  if (kp < 8) return const Color(0xFFE040FB);
  if (kp < 9) return const Color(0xFFD500F9);
  return const Color(0xFFFF1744);
}

Color _flareColor(String c) {
  switch (c) {
    case 'X':
      return const Color(0xFFFF5252);
    case 'M':
      return const Color(0xFFFFAB40);
    case 'C':
      return const Color(0xFFFFEE58);
    default:
      return const Color(0xFF00E676);
  }
}

// ═══════════════════════════════════════════════════════════════
// KP GAUGE PAINTER
// ═══════════════════════════════════════════════════════════════

class _KpGaugePainter extends CustomPainter {
  final double kpValue;
  final Color color;

  const _KpGaugePainter({required this.kpValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.width * 0.42;
    const startAngle = pi * 0.75;
    const sweepTotal = pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Fill
    final sweep = (kpValue / 9.0).clamp(0.0, 1.0) * sweepTotal;
    if (sweep > 0) {
      final fillPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepTotal,
          colors: const [
            Color(0xFF00E676),
            Color(0xFFFFEE58),
            Color(0xFFFFAB40),
            Color(0xFFFF5252),
            Color(0xFFE040FB),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        fillPaint,
      );
    }

    // Ticks
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 9; i++) {
      final a = startAngle + (i / 9.0) * sweepTotal;
      canvas.drawLine(
        Offset(center.dx + (radius - 18) * cos(a),
            center.dy + (radius - 18) * sin(a)),
        Offset(center.dx + (radius - 8) * cos(a),
            center.dy + (radius - 8) * sin(a)),
        tickPaint,
      );
    }

    // Needle
    final needleA = startAngle + (kpValue / 9.0).clamp(0.0, 1.0) * sweepTotal;
    final tip = Offset(center.dx + (radius - 22) * cos(needleA),
        center.dy + (radius - 22) * sin(needleA));
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 7, Paint()..color = color);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Value text
    final tp = TextPainter(
      text: TextSpan(
        text: kpValue.toStringAsFixed(1),
        style: const TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2 - 8));
  }

  @override
  bool shouldRepaint(covariant _KpGaugePainter old) =>
      old.kpValue != kpValue;
}

// ═══════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════

class SpaceWeatherScreen extends StatefulWidget {
  const SpaceWeatherScreen({super.key});

  @override
  State<SpaceWeatherScreen> createState() => _SpaceWeatherScreenState();
}

class _SpaceWeatherScreenState extends State<SpaceWeatherScreen>
    with SingleTickerProviderStateMixin {
  SpaceWeatherData? _data;
  bool _isLoading = true;
  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  late AnimationController _pulseCtrl;
  bool _eduExpanded = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadData();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isLoading) setState(() => _isLoading = true);
    final d = await ApiService.getSpaceWeather();
    if (!mounted) return;
    setState(() {
      _data = d;
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  String _ago(DateTime dt) {
    final m = DateTime.now().difference(dt).inMinutes;
    if (m < 1) return 'just now';
    if (m == 1) return '1 min ago';
    return '$m min ago';
  }

  String _flareAgo(DateTime dt) {
    final h = DateTime.now().difference(dt).inHours;
    if (h < 1) return '< 1h ago';
    return '${h}h ago';
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? _kBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: _isLoading && _data == null
            ? _buildLoading()
            : _data == null
                ? _buildLoading()
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final sc = _stormColor(_data!.kpIndex);
    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildHeroCard(sc)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildStatsGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildWindChart()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildKpForecast()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildFlares()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildAlerts()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildEduFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.back,
                  color: AppColors.textPrimary(context), size: 26),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Space Weather',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Live solar & geomagnetic conditions',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 2),
                Text('Data: NOAA SWPC',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textTertiary(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Live badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, _) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          const Color(0xFF00E676).withValues(alpha: 0.3),
                          const Color(0xFF00E676),
                          _pulseCtrl.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676)
                                .withValues(alpha: 0.5 * _pulseCtrl.value),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('LIVE',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00E676))),
                ],
              ),
              if (_lastUpdated != null) ...[
                const SizedBox(height: 4),
                Text('Updated ${_ago(_lastUpdated!)}',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiary(context))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HERO — STORM STATUS + KP GAUGE
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroCard(Color sc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sc.withValues(alpha: 0.25), _kBgDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sc.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            height: 130,
            child: CustomPaint(
              painter:
                  _KpGaugePainter(kpValue: _data!.kpIndex, color: sc),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kp Index',
                    style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(_data!.stormLevel,
                    style: GoogleFonts.spaceGrotesk(
                        color: sc,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMiniStat(
                  'Bz (IMF)',
                  '${_data!.bzValue.toStringAsFixed(1)} nT',
                  _data!.bzValue < -5
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF00E676),
                  _data!.bzValue < -5
                      ? '\u{26A0}\u{FE0F} Southward \u2014 storm risk'
                      : '\u{2705} Northward \u2014 stable',
                ),
                if (_data!.kpIndex >= 5) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF00E676)
                              .withValues(alpha: 0.4)),
                    ),
                    child: Text('\u{1F30C} Aurora possible!',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF00E676),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMiniStat(
      String label, String value, Color color, String note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label: ',
                style: GoogleFonts.inter(
                    color: Colors.white38, fontSize: 11)),
            Text(value,
                style: GoogleFonts.inter(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(note,
            style:
                GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LIVE STATS 2x2 GRID
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsGrid() {
    final d = _data!;
    final windC = d.solarWindSpeed > 600
        ? const Color(0xFFFFAB40)
        : d.solarWindSpeed > 450
            ? const Color(0xFFFFEE58)
            : const Color(0xFF00E676);
    final densC = d.solarWindDensity > 15
        ? const Color(0xFFFFAB40)
        : const Color(0xFF00E676);
    final bzC = d.bzValue < -10
        ? const Color(0xFFFF5252)
        : d.bzValue < -5
            ? const Color(0xFFFFAB40)
            : const Color(0xFF00E676);
    final flareC = d.recentFlares.isEmpty
        ? const Color(0xFF00E676)
        : _flareColor(d.recentFlares.first.flareClass);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _statCard(
                      '\u{1F32C}\u{FE0F}',
                      'Solar Wind',
                      '${d.solarWindSpeed.toInt()} km/s',
                      d.solarWindSpeed > 600 ? 'Fast stream!' : 'Normal',
                      windC)),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      '\u{1F4AB}',
                      'Particle Density',
                      '${d.solarWindDensity.toStringAsFixed(1)} p/cm\u00b3',
                      d.solarWindDensity > 15 ? 'Elevated' : 'Normal',
                      densC)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _statCard(
                      '\u{1F9F2}',
                      'Bz Field',
                      '${d.bzValue.toStringAsFixed(1)} nT',
                      d.bzValue < 0 ? 'Southward' : 'Northward',
                      bzC)),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      '\u{2600}\u{FE0F}',
                      'Solar Activity',
                      d.recentFlares.isEmpty
                          ? 'Quiet'
                          : '${d.recentFlares.first.flareClass}-class',
                      'Latest flare',
                      flareC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String label, String value,
      String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark ? _kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon $label',
              style: GoogleFonts.inter(
                  color: _isDark ? Colors.white54 : Colors.black45,
                  fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: GoogleFonts.inter(
                  color: _isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SOLAR WIND LINE CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildWindChart() {
    if (_data!.windHistory.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDark ? _kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solar Wind Speed \u2014 Last 7 Days',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: GoogleFonts.inter(
                                color: _isDark
                                    ? Colors.white38
                                    : Colors.black38,
                                fontSize: 9)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            (_data!.windHistory.length / 6).ceilToDouble(),
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 &&
                              idx < _data!.windHistory.length) {
                            final dt = _data!.windHistory[idx].time;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${dt.day}/${dt.month}',
                                  style: GoogleFonts.inter(
                                      color: _isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      fontSize: 9)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _data!.windHistory
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.speed))
                          .toList(),
                      isCurved: true,
                      color: _kAccent,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            _kAccent.withValues(alpha: 0.3),
                            _kAccent.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // KP FORECAST BAR CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildKpForecast() {
    if (_data!.kpForecast.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDark ? _kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Geomagnetic Forecast',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 9,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Now',
                                  style: GoogleFonts.inter(
                                      color: _isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      fontSize: 9)),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('+${idx * 3}h',
                                style: GoogleFonts.inter(
                                    color: _isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 9)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 3,
                        getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: GoogleFonts.inter(
                                color: _isDark
                                    ? Colors.white38
                                    : Colors.black38,
                                fontSize: 9)),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 5,
                        color:
                            const Color(0xFFFF5252).withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          labelResolver: (_) => 'Storm',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF5252),
                              fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  barGroups: _data!.kpForecast
                      .asMap()
                      .entries
                      .map((e) {
                    final kp = e.value.kp;
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(
                        toY: kp,
                        color: _stormColor(kp),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 9,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SOLAR FLARES
  // ═══════════════════════════════════════════════════════════

  Widget _buildFlares() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Solar Flares',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 12),
          if (_data!.recentFlares.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No significant flares detected',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textTertiary(context))),
              ),
            )
          else
            ..._data!.recentFlares.map(_buildFlareCard),
        ],
      ),
    );
  }

  Widget _buildFlareCard(SolarFlare f) {
    final c = _flareColor(f.flareClass);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark ? _kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(f.flareClass,
                  style: GoogleFonts.spaceGrotesk(
                      color: c,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class ${f.flareClass} Solar Flare',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text(_flareAgo(f.time),
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiary(context))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
                f.flareClass == 'X'
                    ? 'Major'
                    : f.flareClass == 'M'
                        ? 'Moderate'
                        : 'Minor',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: c)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ALERTS
  // ═══════════════════════════════════════════════════════════

  Widget _buildAlerts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active NOAA Alerts',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 12),
          if (_data!.activeAlerts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF00E676).withValues(alpha: 0.08),
                border: Border.all(
                    color:
                        const Color(0xFF00E676).withValues(alpha: 0.3)),
              ),
              child: Text('\u{2705} No active space weather alerts',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF00E676))),
            )
          else
            ..._data!.activeAlerts.map(_buildAlertCard),
        ],
      ),
    );
  }

  Widget _buildAlertCard(SpaceWeatherAlert a) {
    final Color borderC;
    final IconData icon;
    switch (a.severity) {
      case 'Alert':
        borderC = const Color(0xFFFF5252);
        icon = Icons.warning_amber_rounded;
      case 'Warning':
        borderC = const Color(0xFFFFAB40);
        icon = Icons.error_outline;
      default:
        borderC = const Color(0xFFFFEE58);
        icon = Icons.info_outline;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark ? _kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: borderC),
              const SizedBox(width: 8),
              Expanded(
                child: Text(a.title,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borderC.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(a.severity,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: borderC)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 6),
          Text('Issued: ${_ago(a.issuedAt)}',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EDUCATIONAL FOOTER
  // ═══════════════════════════════════════════════════════════

  Widget _buildEduFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => setState(() => _eduExpanded = !_eduExpanded),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isDark ? _kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _kAccent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('\u{2753}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('What is space weather?',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context))),
                  ),
                  Icon(
                    _eduExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: AppColors.textTertiary(context),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: _eduExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Space weather refers to conditions on the Sun '
                          'and in space that can affect Earth\'s technology '
                          'and magnetosphere. Solar flares, coronal mass '
                          'ejections (CMEs), and solar wind can disrupt '
                          'satellites, GPS, radio communications, and power '
                          'grids. The Kp index measures geomagnetic '
                          'disturbance on a 0\u20139 scale.',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textSecondary(context)),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOADING
  // ═══════════════════════════════════════════════════════════

  Widget _buildLoading() {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 60),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                child: Container(
                  height: i == 0 ? 160 : 90,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
