import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/orbital_mechanics_controller.dart';
import '../../data/celestial_bodies.dart';
import '../../widgets/orbital_animations.dart';

/// Mission-Control-styled orbital mechanics calculator with four
/// interactive tabs: orbital period, escape velocity, Hohmann transfer,
/// and special-relativity time dilation.
class OrbitalMechanicsScreen extends StatefulWidget {
  const OrbitalMechanicsScreen({super.key});

  @override
  State<OrbitalMechanicsScreen> createState() =>
      _OrbitalMechanicsScreenState();
}

class _OrbitalMechanicsScreenState extends State<OrbitalMechanicsScreen>
    with TickerProviderStateMixin {
  late final OrbitalMechanicsController _ctrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _escapeCtrl;
  late final AnimationController _hohmannCtrl;
  late final AnimationController _clockCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<OrbitalMechanicsController>();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _escapeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _hohmannCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _clockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _escapeCtrl.dispose();
    _hohmannCtrl.dispose();
    _clockCtrl.dispose();
    super.dispose();
  }

  // ── theme helpers ───────────────────────────────────────────
  Color _bg(bool isDark) =>
      isDark ? const Color(0xFF030310) : const Color(0xFFF5F7FB);
  Color _panel(bool isDark) =>
      isDark ? const Color(0xFF080820) : Colors.white;
  Color _primary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF0A1628);
  Color _secondary(bool isDark) =>
      isDark ? const Color(0xFF7A8AB8) : const Color(0xFF5B6B85);
  Color _accent(bool isDark) =>
      isDark ? const Color(0xFF00E5FF) : const Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _bg(isDark),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(isDark),
            _buildTabBar(isDark),
            Expanded(
              child: Obx(() {
                switch (_ctrl.selectedTab.value) {
                  case 0:
                    return _OrbitTab(
                      ctrl: _ctrl,
                      anim: _orbitCtrl,
                      isDark: isDark,
                      panelBg: _panel(isDark),
                      accent: _accent(isDark),
                      primary: _primary(isDark),
                      secondary: _secondary(isDark),
                    );
                  case 1:
                    return _EscapeTab(
                      ctrl: _ctrl,
                      anim: _escapeCtrl,
                      isDark: isDark,
                      panelBg: _panel(isDark),
                      accent: _accent(isDark),
                      primary: _primary(isDark),
                      secondary: _secondary(isDark),
                    );
                  case 2:
                    return _HohmannTab(
                      ctrl: _ctrl,
                      anim: _hohmannCtrl,
                      isDark: isDark,
                      panelBg: _panel(isDark),
                      accent: _accent(isDark),
                      primary: _primary(isDark),
                      secondary: _secondary(isDark),
                    );
                  case 3:
                  default:
                    return _DilationTab(
                      ctrl: _ctrl,
                      anim: _clockCtrl,
                      isDark: isDark,
                      panelBg: _panel(isDark),
                      accent: _accent(isDark),
                      primary: _primary(isDark),
                      secondary: _secondary(isDark),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar(bool isDark) {
    final accent = _accent(isDark);
    final secondary = _secondary(isDark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      child: Row(
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
                  'ORBITAL MECHANICS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'INTERACTIVE CALCULATIONS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final showing = _ctrl.showFormula.value;
            return GestureDetector(
              onTap: _ctrl.toggleFormula,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: showing
                      ? accent.withValues(alpha: 0.16)
                      : Colors.transparent,
                  border: Border.all(
                    color: accent.withValues(alpha: showing ? 0.7 : 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showing
                          ? Icons.visibility
                          : Icons.visibility_off_outlined,
                      size: 14,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FORMULAS',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isDark) {
    final accent = _accent(isDark);
    final secondary = _secondary(isDark);
    final tabs = const [
      ('🛰️', 'ORBIT'),
      ('🚀', 'ESCAPE'),
      ('🌌', 'TRANSFER'),
      ('⚡', 'DILATION'),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.20), width: 0.5),
        ),
      ),
      height: 56,
      child: Obx(() {
        final selected = _ctrl.selectedTab.value;
        return Row(
          children: List.generate(tabs.length, (i) {
            final active = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => _ctrl.changeTab(i),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabs[i].$1,
                            style: TextStyle(
                              fontSize: 16,
                              shadows: active
                                  ? [
                                      Shadow(
                                        color: accent.withValues(alpha: 0.7),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tabs[i].$2,
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: active ? accent : secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (active)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: accent,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED STYLE — panels, dropdowns, sliders
// ═══════════════════════════════════════════════════════════════════

/// Cockpit panel with HUD ┌ ┐ └ ┘ corner brackets.
class _Panel extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.isDark,
    required this.accent,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF050514) : const Color(0xFFF8FAFF);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          ..._corners(accent),
        ],
      ),
    );
  }

  static List<Widget> _corners(Color c) {
    Widget corner({
      required bool top,
      required bool left,
    }) {
      return Positioned(
        top: top ? 0 : null,
        bottom: top ? null : 0,
        left: left ? 0 : null,
        right: left ? null : 0,
        child: SizedBox(
          width: 8,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: top ? BorderSide(color: c, width: 2) : BorderSide.none,
                bottom:
                    top ? BorderSide.none : BorderSide(color: c, width: 2),
                left: left ? BorderSide(color: c, width: 2) : BorderSide.none,
                right:
                    left ? BorderSide.none : BorderSide(color: c, width: 2),
              ),
            ),
          ),
        ),
      );
    }

    return [
      corner(top: true, left: true),
      corner(top: true, left: false),
      corner(top: false, left: true),
      corner(top: false, left: false),
    ];
  }
}

/// Section header with the small "UNIVERSE-AGE-style" label.
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: color,
      ),
    );
  }
}

/// A small bordered dropdown styled like a HUD selector.
class _BodyDropdown extends StatelessWidget {
  final List<CelestialBody> options;
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final bool isDark;
  final Color accent;
  final Color secondary;

  const _BodyDropdown({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.isDark,
    required this.accent,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF080820) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label, secondary),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: accent.withValues(alpha: 0.4), width: 0.7),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(Icons.keyboard_arrow_down, color: accent, size: 18),
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.6,
              ),
              items: options
                  .map(
                    (b) => DropdownMenuItem<String>(
                      value: b.name,
                      child: Row(
                        children: [
                          Text(b.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(b.name.toUpperCase()),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final Color accent;
  final Color secondary;

  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.accent,
    required this.secondary,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionLabel(label, secondary),
            const Spacer(),
            Text(
              valueLabel,
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accent,
            inactiveTrackColor: accent.withValues(alpha: 0.20),
            thumbColor: accent,
            trackHeight: 2,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          children: [
            Text(
              _short(min),
              style: GoogleFonts.spaceMono(fontSize: 9, color: secondary),
            ),
            const Spacer(),
            Text(
              _short(max),
              style: GoogleFonts.spaceMono(fontSize: 9, color: secondary),
            ),
          ],
        ),
      ],
    );
  }

  static String _short(double v) {
    if (v >= 1000) return NumberFormat('#,###').format(v);
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}

class _ResultCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color secondary;
  const _ResultCell({
    required this.label,
    required this.value,
    required this.accent,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(label, secondary),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _FormulaPanel extends StatelessWidget {
  final String title;
  final List<String> formulas;
  final Map<String, String> definitions;
  final bool isDark;
  final Color accent;
  final Color secondary;

  const _FormulaPanel({
    required this.title,
    required this.formulas,
    required this.definitions,
    required this.isDark,
    required this.accent,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF000010) : const Color(0xFFF0F4FF);
    final mathColor =
        isDark ? const Color(0xFFA8FFB6) : const Color(0xFF1E3A8A);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          for (final f in formulas)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SelectableText(
                f,
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: mathColor,
                  height: 1.4,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'WHERE:',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: secondary,
            ),
          ),
          const SizedBox(height: 4),
          for (final entry in definitions.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '  ${entry.key} = ${entry.value}',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: secondary,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  final String text;
  final Color secondary;
  const _Explanation(this.text, this.secondary);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.6,
          letterSpacing: 0.3,
          color: secondary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 0 — ORBITAL PERIOD & VELOCITY
// ═══════════════════════════════════════════════════════════════════
class _OrbitTab extends StatelessWidget {
  final OrbitalMechanicsController ctrl;
  final AnimationController anim;
  final bool isDark;
  final Color panelBg;
  final Color accent;
  final Color primary;
  final Color secondary;

  const _OrbitTab({
    required this.ctrl,
    required this.anim,
    required this.isDark,
    required this.panelBg,
    required this.accent,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // INPUT
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => _BodyDropdown(
                      options: CelestialBody.orbitable,
                      value: ctrl.centralBody.value,
                      onChanged: (v) => ctrl.centralBody.value = v,
                      label: 'CENTRAL BODY',
                      isDark: isDark,
                      accent: accent,
                      secondary: secondary,
                    )),
                const SizedBox(height: 14),
                Obx(() => _LabeledSlider(
                      label: 'ALTITUDE (KM)',
                      valueLabel:
                          NumberFormat('#,###').format(ctrl.altitudeKm.value.round()),
                      value: ctrl.altitudeKm.value,
                      min: 100,
                      max: 50000,
                      divisions: 499,
                      onChanged: (v) => ctrl.altitudeKm.value = v,
                      accent: accent,
                      secondary: secondary,
                    )),
                const SizedBox(height: 6),
                Obx(() {
                  final body = CelestialBody.byName(ctrl.centralBody.value);
                  return Text(
                    'PLANET RADIUS: ${NumberFormat('#,###').format(body.radius.round())} KM',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      color: secondary,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // VISUALIZATION
          _Panel(
            isDark: isDark,
            accent: accent,
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 200,
              child: Obx(() {
                final body = CelestialBody.byName(ctrl.centralBody.value);
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, _) => CustomPaint(
                    painter: OrbitVisualPainter(
                      altitudeKm: ctrl.altitudeKm.value,
                      bodyRadiusKm: body.radius,
                      bodyColor: body.color,
                      satelliteAngle: anim.value * 2 * pi,
                      isDark: isDark,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          // RESULT
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Obx(() {
              final periodS = ctrl.orbitalPeriodSeconds;
              final v = ctrl.orbitalVelocityKmS;
              final orbits = ctrl.orbitsPerDay;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ResultCell(
                      label: 'PERIOD',
                      value: _fmtPeriod(periodS),
                      accent: accent,
                      secondary: secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultCell(
                      label: 'VELOCITY',
                      value: '${v.toStringAsFixed(3)} KM/S',
                      accent: accent,
                      secondary: secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultCell(
                      label: 'ORBITS/DAY',
                      value: orbits.toStringAsFixed(1),
                      accent: accent,
                      secondary: secondary,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          // FORMULA
          Obx(() {
            if (!ctrl.showFormula.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FormulaPanel(
                title: "KEPLER'S THIRD LAW",
                formulas: const [
                  'T = 2π × √(r³ / GM)',
                  'v = √(GM / r)',
                ],
                definitions: const {
                  'T': 'orbital period (s)',
                  'r': 'orbital radius from center (km)',
                  'GM (μ)': 'gravitational parameter (km³/s²)',
                  'v': 'orbital velocity (km/s)',
                },
                isDark: isDark,
                accent: accent,
                secondary: secondary,
              ),
            );
          }),
          // EXPLANATION
          _Explanation(
            "An object in orbit balances gravitational pull with forward motion. "
            "Higher altitude = slower orbit but longer period. The ISS at 408 km "
            "completes one orbit every ~93 minutes. Geostationary satellites at "
            "35,786 km match Earth's rotation period.",
            secondary,
          ),
        ],
      ),
    );
  }

  /// Format seconds as HH:MM:SS for periods under 24 h, otherwise days.
  static String _fmtPeriod(double seconds) {
    if (seconds < 86400) {
      final h = (seconds / 3600).floor();
      final m = ((seconds % 3600) / 60).floor();
      final s = (seconds % 60).floor();
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    final days = seconds / 86400;
    return '${days.toStringAsFixed(2)} D';
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 1 — ESCAPE VELOCITY
// ═══════════════════════════════════════════════════════════════════
class _EscapeTab extends StatelessWidget {
  final OrbitalMechanicsController ctrl;
  final AnimationController anim;
  final bool isDark;
  final Color panelBg;
  final Color accent;
  final Color primary;
  final Color secondary;

  const _EscapeTab({
    required this.ctrl,
    required this.anim,
    required this.isDark,
    required this.panelBg,
    required this.accent,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // INPUT
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => _BodyDropdown(
                      options: CelestialBody.escapable,
                      value: ctrl.escapeBody.value,
                      onChanged: (v) => ctrl.escapeBody.value = v,
                      label: 'BODY',
                      isDark: isDark,
                      accent: accent,
                      secondary: secondary,
                    )),
                const SizedBox(height: 12),
                Obx(() {
                  final b = CelestialBody.byName(ctrl.escapeBody.value);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _kv('MASS', '${b.mass.toStringAsExponential(3)} KG',
                          secondary, primary),
                      _kv('RADIUS',
                          '${NumberFormat('#,###').format(b.radius.round())} KM',
                          secondary, primary),
                      _kv('SURFACE g',
                          '${b.surfaceGravity.toStringAsFixed(2)} M/S²',
                          secondary, primary),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // VISUALIZATION
          _Panel(
            isDark: isDark,
            accent: accent,
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 200,
              child: Obx(() {
                final body = CelestialBody.byName(ctrl.escapeBody.value);
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, _) => CustomPaint(
                    painter: EscapeTrajectoryPainter(
                      bodyColor: body.color,
                      escapeKmS: ctrl.escapeVelocityKmS,
                      isDark: isDark,
                      progress: anim.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          // RESULT
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Obx(() {
              final v = ctrl.escapeVelocityKmS;
              final kmh = v * 3600;
              const machSpeed = 0.343; // km/s, sea-level on Earth
              final mach = (v / machSpeed);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultCell(
                    label: 'ESCAPE VELOCITY',
                    value: '${v.toStringAsFixed(3)} KM/S',
                    accent: accent,
                    secondary: secondary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCell(
                          label: 'KM/H',
                          value: NumberFormat('#,###').format(kmh.round()),
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultCell(
                          label: 'MACH (vs EARTH ATM)',
                          value: '${mach.toStringAsFixed(1)}× SOUND',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (!ctrl.showFormula.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FormulaPanel(
                title: 'ESCAPE VELOCITY',
                formulas: const ['v_esc = √(2GM / r)'],
                definitions: const {
                  'G': 'gravitational constant',
                  'M': 'mass of body (kg)',
                  'r': 'distance from center (km)',
                },
                isDark: isDark,
                accent: accent,
                secondary: secondary,
              ),
            );
          }),
          _Explanation(
            "Escape velocity is the minimum speed needed to escape a body's "
            "gravitational pull without further propulsion. Earth's is "
            "11.2 km/s — that's why rockets need so much fuel. The Moon's "
            "is only 2.4 km/s, which is why Apollo missions could lift off "
            "with smaller engines.",
            secondary,
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color secColor, Color valColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(k, secColor),
        const SizedBox(height: 2),
        Text(
          v,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valColor,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 2 — HOHMANN TRANSFER
// ═══════════════════════════════════════════════════════════════════
class _HohmannTab extends StatelessWidget {
  final OrbitalMechanicsController ctrl;
  final AnimationController anim;
  final bool isDark;
  final Color panelBg;
  final Color accent;
  final Color primary;
  final Color secondary;

  const _HohmannTab({
    required this.ctrl,
    required this.anim,
    required this.isDark,
    required this.panelBg,
    required this.accent,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(() => _BodyDropdown(
                            options: CelestialBody.heliocentric,
                            value: ctrl.fromPlanet.value,
                            onChanged: (v) => ctrl.fromPlanet.value = v,
                            label: 'FROM',
                            isDark: isDark,
                            accent: accent,
                            secondary: secondary,
                          )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => _BodyDropdown(
                            options: CelestialBody.heliocentric,
                            value: ctrl.toPlanet.value,
                            onChanged: (v) => ctrl.toPlanet.value = v,
                            label: 'TO',
                            isDark: isDark,
                            accent: accent,
                            secondary: secondary,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final same = ctrl.fromPlanet.value == ctrl.toPlanet.value;
                  if (!same) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: const Color(0xFFFB923C)),
                        const SizedBox(width: 6),
                        Text(
                          'FROM AND TO MUST DIFFER',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: const Color(0xFFFB923C),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            isDark: isDark,
            accent: accent,
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 220,
              child: Obx(() {
                final from = CelestialBody.byName(ctrl.fromPlanet.value);
                final to = CelestialBody.byName(ctrl.toPlanet.value);
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, _) => CustomPaint(
                    painter: HohmannPainter(
                      r1Au: from.semiMajorAxis,
                      r2Au: to.semiMajorAxis,
                      fromColor: from.color,
                      toColor: to.color,
                      progress: anim.value,
                      isDark: isDark,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Obx(() {
              final r = ctrl.hohmannResults;
              final dv1 = r['deltaV1']!;
              final dv2 = r['deltaV2']!;
              final total = r['totalDeltaV']!;
              final days = r['transferDays']!;
              final timeStr = days > 365
                  ? '${(days / 365.25).toStringAsFixed(2)} YR'
                  : '${days.toStringAsFixed(0)} D';
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCell(
                          label: 'Δv₁ DEPARTURE',
                          value: '${dv1.toStringAsFixed(3)} KM/S',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultCell(
                          label: 'Δv₂ ARRIVAL',
                          value: '${dv2.toStringAsFixed(3)} KM/S',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCell(
                          label: 'TOTAL Δv',
                          value: '${total.toStringAsFixed(3)} KM/S',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultCell(
                          label: 'TRANSFER TIME',
                          value: timeStr,
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (!ctrl.showFormula.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FormulaPanel(
                title: 'HOHMANN TRANSFER',
                formulas: const [
                  'Δv₁ = √(GMs × (2/r₁ − 1/a)) − √(GMs / r₁)',
                  'Δv₂ = √(GMs / r₂) − √(GMs × (2/r₂ − 1/a))',
                  'T_transfer = π × √(a³ / GMs)',
                ],
                definitions: const {
                  'r₁': 'source orbit radius',
                  'r₂': 'destination orbit radius',
                  'a': '(r₁ + r₂) / 2',
                  'GMs': "Sun's gravitational parameter (km³/s²)",
                },
                isDark: isDark,
                accent: accent,
                secondary: secondary,
              ),
            );
          }),
          _Explanation(
            "A Hohmann transfer is the most fuel-efficient way to move "
            "between two circular orbits. Two engine burns are required: "
            "one to leave the source orbit, one to circularize at the "
            "destination. Real Mars missions take ~9 months. The famous "
            "'launch window' to Mars opens every 26 months when the planets align.",
            secondary,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 3 — TIME DILATION
// ═══════════════════════════════════════════════════════════════════
class _DilationTab extends StatelessWidget {
  final OrbitalMechanicsController ctrl;
  final AnimationController anim;
  final bool isDark;
  final Color panelBg;
  final Color accent;
  final Color primary;
  final Color secondary;

  const _DilationTab({
    required this.ctrl,
    required this.anim,
    required this.isDark,
    required this.panelBg,
    required this.accent,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final pct = ctrl.speedFraction.value * 100;
                  return _LabeledSlider(
                    label: 'SPEED (% of c)',
                    valueLabel:
                        '${pct.toStringAsFixed(1)}% OF LIGHT SPEED',
                    value: ctrl.speedFraction.value,
                    min: 0.0,
                    max: 0.999,
                    divisions: 999,
                    onChanged: (v) => ctrl.speedFraction.value = v,
                    accent: accent,
                    secondary: secondary,
                  );
                }),
                const SizedBox(height: 12),
                Obx(() => _LabeledSlider(
                      label: 'REST TIME (YEARS)',
                      valueLabel:
                          '${ctrl.restTimeYears.value.toStringAsFixed(1)} YEARS',
                      value: ctrl.restTimeYears.value,
                      min: 0.1,
                      max: 100,
                      divisions: 999,
                      onChanged: (v) => ctrl.restTimeYears.value = v,
                      accent: accent,
                      secondary: secondary,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            isDark: isDark,
            accent: accent,
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 160,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final gamma = ctrl.lorentzFactor;
                      return AnimatedBuilder(
                        animation: anim,
                        builder: (_, _) {
                          final restAngle = anim.value * 2 * pi;
                          final travelAngle = anim.value * 2 * pi / gamma;
                          return CustomPaint(
                            painter: DualClockPainter(
                              restAngle: restAngle,
                              travelAngle: travelAngle,
                              isDark: isDark,
                            ),
                            child: const SizedBox.expand(),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'STATIONARY',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: secondary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'TRAVELER',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            isDark: isDark,
            accent: accent,
            child: Obx(() {
              final gamma = ctrl.lorentzFactor;
              final dilated = ctrl.dilatedTimeYears;
              final rest = ctrl.restTimeYears.value;
              final ageDiff = ctrl.ageDifferenceYears;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCell(
                          label: 'LORENTZ γ',
                          value: gamma.toStringAsFixed(3),
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultCell(
                          label: 'TRAVELER TIME',
                          value: '${rest.toStringAsFixed(2)} YR',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCell(
                          label: 'EARTH TIME',
                          value: '${dilated.toStringAsFixed(2)} YR',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultCell(
                          label: 'YOUNGER BY',
                          value: '${ageDiff.toStringAsFixed(2)} YR',
                          accent: accent,
                          secondary: secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (!ctrl.showFormula.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FormulaPanel(
                title: 'SPECIAL RELATIVITY — TIME DILATION',
                formulas: const [
                  'γ = 1 / √(1 − v²/c²)',
                  "Δt' = Δt × γ",
                ],
                definitions: const {
                  'γ': 'Lorentz factor (always ≥ 1)',
                  'v': 'velocity (km/s)',
                  'c': '299,792.458 km/s (speed of light)',
                  'Δt': "proper time (traveler's clock)",
                  "Δt'": 'time elapsed for stationary observer',
                },
                isDark: isDark,
                accent: accent,
                secondary: secondary,
              ),
            );
          }),
          _Explanation(
            "At extreme speeds, time literally slows down for the traveler "
            "relative to a stationary observer (Einstein's special "
            "relativity, 1905). At 99.9% of light speed, 1 year for the "
            "traveler ≈ 22.4 years on Earth. This is why interstellar "
            "travel could theoretically allow humans to traverse galactic "
            "distances within a lifetime — but everyone they knew on Earth "
            "would have aged centuries by their return.",
            secondary,
          ),
        ],
      ),
    );
  }
}
