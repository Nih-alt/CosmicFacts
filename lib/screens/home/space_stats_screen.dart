import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/space_stats_controller.dart';
import '../../widgets/cockpit_painters.dart';

/// NASA Mission Control cockpit dashboard for live space statistics.
class SpaceStatsScreen extends StatefulWidget {
  const SpaceStatsScreen({super.key});

  @override
  State<SpaceStatsScreen> createState() => _SpaceStatsScreenState();
}

class _SpaceStatsScreenState extends State<SpaceStatsScreen>
    with TickerProviderStateMixin {
  late final SpaceStatsController _ctrl;
  late final AnimationController _radarCtrl;
  late final AnimationController _tickerCtrl;

  static const _fmt = _Fmt();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(SpaceStatsController(), permanent: true);
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _tickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _tickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _bg(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(isDark),
              const SizedBox(height: 12),
              _buildTickerBar(isDark),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildUniverseAgePanel(isDark),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildIssTelemetryPanel(isDark),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildInstrumentCluster(isDark),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildStatusLegend(isDark),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildConsoleLog(isDark),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // A) TOP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBar(bool isDark) {
    final accent = cockpitAccent(isDark);
    final live = cockpitLive(isDark);
    final secondary = _secondary(isDark);
    final stardate = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: _primary(isDark),
            ),
            splashRadius: 22,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MISSION CONTROL',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'STARDATE $stardate',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          _PulsingDot(color: live)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 900.ms)
              .then()
              .fadeOut(duration: 900.ms),
          const SizedBox(width: 6),
          Text(
            'ONLINE',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: live,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // B) SCROLLING TICKER BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTickerBar(bool isDark) {
    final accent = cockpitAccent(isDark);
    final tickerBg = isDark
        ? const Color(0xFF02020A)
        : const Color(0xFFE8EEFB);
    final borderColor = accent.withValues(alpha: 0.25);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: tickerBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.5),
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: ClipRect(
        child: Obx(() {
          final text = _buildTickerText();
          return AnimatedBuilder(
            animation: _tickerCtrl,
            builder: (_, _) {
              return _MarqueeText(
                text: text,
                progress: _tickerCtrl.value,
                color: accent,
              );
            },
          );
        }),
      ),
    );
  }

  String _buildTickerText() {
    final v = _fmt.kmh(_ctrl.issVelocity.value);
    final a = _fmt.km(_ctrl.issAltitude.value);
    final exo = _fmt.intComma(_ctrl.exoplanetCount.value);
    final crew = _ctrl.peopleInSpace.value;
    final neo = _ctrl.asteroidsToday.value;
    final moon = _fmt.intComma(_ctrl.moonDistanceKm.value.round());
    final sun = _ctrl.sunDistanceMillionKm.value.toStringAsFixed(2);
    final lat = _ctrl.issLat.value.toStringAsFixed(2);
    final lon = _ctrl.issLon.value.toStringAsFixed(2);
    return '   ▸ ISS VEL: $v   '
        '▸ ALT: $a   '
        '▸ LAT/LON: $lat / $lon   '
        '▸ EXOPLANETS: $exo   '
        '▸ CREW: $crew   '
        '▸ NEO: $neo TRACKED   '
        '▸ MOON: $moon KM   '
        '▸ SUN: $sun MIL KM   ';
  }

  // ═══════════════════════════════════════════════════════════════
  // C) UNIVERSE AGE HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUniverseAgePanel(bool isDark) {
    final accent = cockpitAccent(isDark);
    final live = cockpitLive(isDark);
    final secondary = _secondary(isDark);
    return _CockpitPanel(
      isDark: isDark,
      accent: accent,
      height: 180,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'UNIVERSE AGE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: secondary,
                  ),
                ),
                const Spacer(),
                _PulsingDot(color: live)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 800.ms)
                    .then()
                    .fadeOut(duration: 800.ms),
                const SizedBox(width: 6),
                Text(
                  'REAL-TIME',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: live,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Obx(() {
                final age = _ctrl.universeAgeSeconds.value;
                // Compact scientific format: 4.3508 × 10¹⁷ fits one line.
                final exponent = (log(age) / ln10).floor();
                final mantissa = age / pow(10, exponent);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.spaceMono(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _primary(isDark),
                          letterSpacing: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        children: [
                          TextSpan(text: mantissa.toStringAsFixed(4)),
                          const TextSpan(
                            text: ' × 10',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextSpan(
                            text: '$exponent',
                            style: TextStyle(
                              fontSize: 20,
                              color: accent,
                              fontFeatures: const [
                                FontFeature.superscripts(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      NumberFormat('#,###').format(age.toInt()),
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: secondary,
                        letterSpacing: 0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'SECONDS SINCE BIG BANG',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: secondary,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // D) ISS LIVE TELEMETRY PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildIssTelemetryPanel(bool isDark) {
    final accent = cockpitAccent(isDark);
    final live = cockpitLive(isDark);
    final secondary = _secondary(isDark);

    return _CockpitPanel(
      isDark: isDark,
      accent: accent,
      height: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ISS — INTERNATIONAL SPACE STATION',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() => _LiveBadge(
                      isLive: _ctrl.issLive.value,
                      isDark: isDark,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Speedometer
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return CustomPaint(
                              painter: SpeedometerPainter(
                                value: _ctrl.issVelocity.value,
                                maxValue: 30000,
                                isDark: isDark,
                              ),
                              child: const SizedBox.expand(),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              '${_fmt.intComma(_ctrl.issVelocity.value.round())} KM/H',
                              style: GoogleFonts.spaceMono(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _primary(isDark),
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            )),
                        Text(
                          'ORBITAL VELOCITY',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            letterSpacing: 1.2,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Altimeter
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return CustomPaint(
                              painter: AltimeterBarPainter(
                                altitudeKm: _ctrl.issAltitude.value,
                                isDark: isDark,
                              ),
                              child: const SizedBox.expand(),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              '${_ctrl.issAltitude.value.toStringAsFixed(0)} KM',
                              style: GoogleFonts.spaceMono(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _primary(isDark),
                              ),
                            )),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'LAT ${_ctrl.issLat.value.toStringAsFixed(2)}°',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                    color: secondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LON ${_ctrl.issLon.value.toStringAsFixed(2)}°',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                    color: secondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Text(
                          'ALTITUDE',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            letterSpacing: 1.2,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              color: live.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // E) INSTRUMENT CLUSTER (2-col grid)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInstrumentCluster(bool isDark) {
    final live = cockpitLive(isDark);

    final tiles = <Widget>[
      // 1. People in Space
      Obx(() => _InstrumentTile(
            isDark: isDark,
            accent: live,
            label: 'CREW IN ORBIT',
            valueText: '${_ctrl.peopleInSpace.value}',
            badge: 'LIVE',
            badgeColor: live,
            isLive: _ctrl.peopleLive.value,
            icon: Icons.person_pin_circle_outlined,
          )),

      // 2. Asteroids Today + Radar
      Obx(() => _InstrumentTile(
            isDark: isDark,
            accent: const Color(0xFFFB923C),
            label: 'NEO TRACKED',
            valueText: '${_ctrl.asteroidsToday.value}',
            badge: 'LIVE',
            badgeColor: live,
            isLive: _ctrl.asteroidsLive.value,
            customLeading: SizedBox(
              width: 56,
              height: 56,
              child: AnimatedBuilder(
                animation: _radarCtrl,
                builder: (_, _) => CustomPaint(
                  painter: RadarSweepPainter(
                    sweepAngle: _radarCtrl.value * 2 * pi,
                    blipCount:
                        _ctrl.asteroidsToday.value.clamp(0, 14),
                    isDark: isDark,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          )),

      // 3. Exoplanets
      Obx(() => _InstrumentTile(
            isDark: isDark,
            accent: const Color(0xFFA78BFA),
            label: 'CONFIRMED EXOPLANETS',
            valueText: _fmt.intComma(_ctrl.exoplanetCount.value),
            badge: 'NASA ARCHIVE',
            badgeColor: const Color(0xFFA78BFA),
            isLive: _ctrl.exoLive.value,
            icon: Icons.travel_explore,
          )),

      // 4. Moon Distance
      Obx(() => _InstrumentTile(
            isDark: isDark,
            accent: const Color(0xFFB8C1D6),
            label: 'LUNAR RANGE (KM)',
            valueText: _fmt.intComma(_ctrl.moonDistanceKm.value.round()),
            badge: 'CALC',
            badgeColor: const Color(0xFFFCD34D),
            isLive: false,
            icon: Icons.brightness_2,
          )),

      // 5. Sun Distance
      Obx(() => _InstrumentTile(
            isDark: isDark,
            accent: const Color(0xFFFCD34D),
            label: 'SOLAR RANGE (M KM)',
            valueText:
                _ctrl.sunDistanceMillionKm.value.toStringAsFixed(2),
            badge: 'CALC',
            badgeColor: const Color(0xFFFCD34D),
            isLive: false,
            icon: Icons.wb_sunny_outlined,
          )),

      // 6. Observable Universe
      _InstrumentTile(
        isDark: isDark,
        accent: const Color(0xFF8B5CF6),
        label: 'LIGHT-YEARS DIAMETER',
        valueText: '93B',
        badge: 'FIXED',
        badgeColor: const Color(0xFFB8C1D6),
        isLive: false,
        icon: Icons.public,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      children: List.generate(tiles.length, (i) {
        return tiles[i]
            .animate()
            .fadeIn(
              duration: 350.ms,
              delay: Duration(milliseconds: 60 * i),
            )
            .slideY(begin: 0.06, end: 0);
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // F) STATUS LEGEND
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatusLegend(bool isDark) {
    final secondary = _secondary(isDark);
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _legendChip(const Color(0xFF22C55E), 'LIVE', secondary, isDark),
        _legendChip(const Color(0xFFFCD34D), 'CALC', secondary, isDark),
        _legendChip(const Color(0xFFB8C1D6), 'FIXED', secondary, isDark),
      ],
    );
  }

  Widget _legendChip(Color dotColor, String label, Color secondary, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF080820)
            : Colors.white,
        border: Border.all(
          color: cockpitAccent(isDark).withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // G) CONSOLE LOG
  // ═══════════════════════════════════════════════════════════════
  Widget _buildConsoleLog(bool isDark) {
    final accent = cockpitAccent(isDark);
    final live = cockpitLive(isDark);
    final logBg = isDark ? const Color(0xFF000010) : const Color(0xFFF0F4FF);
    final logColor = isDark ? const Color(0xFFA8FFB6) : const Color(0xFF1E3A8A);

    const lines = [
      '[14:32:01] RUN_TO_MOON: 9.3 YEARS @ 10 KM/H',
      '[14:32:02] FLIGHT_TO_SUN: 17 YEARS @ 900 KM/H',
      '[14:32:03] DRIVE_TO_MARS: 228 YEARS @ 100 KM/H',
      '[14:32:04] LIGHT_TO_PROXIMA: 4.24 YEARS',
      '[14:32:05] STARS_VS_GRAINS: 10× MORE STARS',
    ];

    return Container(
      decoration: BoxDecoration(
        color: logBg,
        border: Border(left: BorderSide(color: live, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '▸ TRANSMISSION LOG',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '> $l',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: logColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── theme helpers ──
  Color _bg(bool isDark) =>
      isDark ? const Color(0xFF030310) : const Color(0xFFF5F7FB);
  Color _primary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF0A1628);
  Color _secondary(bool isDark) =>
      isDark ? const Color(0xFF7A8AB8) : const Color(0xFF5B6B85);
}

// ═══════════════════════════════════════════════════════════════════
// Reusable building blocks
// ═══════════════════════════════════════════════════════════════════

/// Panel with HUD corner brackets ┌ ┐ └ ┘.
class _CockpitPanel extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final double? height;
  final Widget child;

  const _CockpitPanel({
    required this.isDark,
    required this.accent,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF050514) : const Color(0xFFF8FAFF),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(top: 0, left: 0, child: _Corner(accent, _CornerPos.tl)),
          Positioned(top: 0, right: 0, child: _Corner(accent, _CornerPos.tr)),
          Positioned(
              bottom: 0, left: 0, child: _Corner(accent, _CornerPos.bl)),
          Positioned(
              bottom: 0, right: 0, child: _Corner(accent, _CornerPos.br)),
        ],
      ),
    );
  }
}

enum _CornerPos { tl, tr, bl, br }

class _Corner extends StatelessWidget {
  final Color color;
  final _CornerPos pos;
  const _Corner(this.color, this.pos);

  @override
  Widget build(BuildContext context) {
    const len = 10.0;
    final c = color;
    final top = (pos == _CornerPos.tl || pos == _CornerPos.tr)
        ? BorderSide(color: c, width: 2)
        : BorderSide.none;
    final bottom = (pos == _CornerPos.bl || pos == _CornerPos.br)
        ? BorderSide(color: c, width: 2)
        : BorderSide.none;
    final left = (pos == _CornerPos.tl || pos == _CornerPos.bl)
        ? BorderSide(color: c, width: 2)
        : BorderSide.none;
    final right = (pos == _CornerPos.tr || pos == _CornerPos.br)
        ? BorderSide(color: c, width: 2)
        : BorderSide.none;
    return SizedBox(
      width: len,
      height: len,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: top, bottom: bottom, left: left, right: right),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLive;
  final bool isDark;
  const _LiveBadge({required this.isLive, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final live = cockpitLive(isDark);
    final dim = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);
    final color = isLive ? live : dim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: color),
          const SizedBox(width: 4),
          Text(
            isLive ? 'LIVE' : 'CACHED',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstrumentTile extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String label;
  final String valueText;
  final String badge;
  final Color badgeColor;
  final bool isLive;
  final IconData? icon;
  final Widget? customLeading;

  const _InstrumentTile({
    required this.isDark,
    required this.accent,
    required this.label,
    required this.valueText,
    required this.badge,
    required this.badgeColor,
    required this.isLive,
    this.icon,
    this.customLeading,
  });

  @override
  Widget build(BuildContext context) {
    final secondary =
        isDark ? const Color(0xFF7A8AB8) : const Color(0xFF5B6B85);
    return _CockpitPanel(
      isDark: isDark,
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (customLeading != null)
                  customLeading!
                else if (icon != null)
                  Icon(icon, size: 16, color: accent),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.spaceMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valueText,
                maxLines: 1,
                style: GoogleFonts.spaceMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                letterSpacing: 1.1,
                color: secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isLive)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulsingDot(color: cockpitLive(isDark))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 700.ms)
                          .then()
                          .fadeOut(duration: 700.ms),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'STREAMING',
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            letterSpacing: 1.0,
                            color: cockpitLive(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
}

/// Marquee-style continuously scrolling text driven by an external [progress]
/// (0..1, looped). Renders the text twice so the seam is invisible.
class _MarqueeText extends StatelessWidget {
  final String text;
  final double progress;
  final Color color;

  const _MarqueeText({
    required this.text,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.spaceMono(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute string width.
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final stringWidth = tp.width;
        // Total scroll cycle = string width + viewport width so it always
        // exits cleanly.
        final cycle = stringWidth + constraints.maxWidth;
        final dx = -progress * cycle;

        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Row(
                children: [
                  Text(text, style: style, maxLines: 1),
                  SizedBox(width: constraints.maxWidth),
                  Text(text, style: style, maxLines: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Fmt {
  const _Fmt();
  String intComma(int n) => NumberFormat('#,###').format(n);
  String kmh(double v) => '${NumberFormat('#,###').format(v.round())} KM/H';
  String km(double v) => '${v.toStringAsFixed(0)} KM';
}
