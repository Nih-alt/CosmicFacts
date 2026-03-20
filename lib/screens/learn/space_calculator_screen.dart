import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/app_colors.dart';

class SpaceCalculatorScreen extends StatelessWidget {
  const SpaceCalculatorScreen({super.key});

  static const _calculators = [
    _CalcInfo('\u2696\uFE0F', 'Weight on Planets', 'Your weight across the solar system'),
    _CalcInfo('\u{1F4A1}', 'Light Travel Time', 'How long light takes to travel'),
    _CalcInfo('\u{1F680}', 'Escape Velocity', 'Speed to escape a body\u2019s gravity'),
    _CalcInfo('\u{1F30D}', 'Planet Distance', 'Distances between planets'),
    _CalcInfo('\u{1F4CF}', 'Size Comparator', 'Compare sizes of celestial bodies'),
    _CalcInfo('\u{1F550}', 'Time on Planets', 'Your age on other planets'),
    _CalcInfo('\u{1F321}\uFE0F', 'Temp Converter', 'Space temperature converter'),
    _CalcInfo('\u{1F52D}', 'Telescope Calc', 'Magnification & visibility'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildCard(ctx, i),
                  childCount: _calculators.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context), size: 26),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Space Calculator',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Tools for space math',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final c = _calculators[index];
    final glows = [
      AppColors.accentPurple, AppColors.starGold, AppColors.accentCyan,
      AppColors.accentOrange, AppColors.success, AppColors.accentPurple,
      AppColors.error, AppColors.accentCyan,
    ];
    final glow = glows[index];

    return GestureDetector(
      onTap: () => _openCalculator(context, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: glow.withValues(alpha: 0.2)),
          boxShadow: AppColors.coloredShadow(context, glow),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            Text(c.name,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(c.desc,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary(context)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  void _openCalculator(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CalculatorSheet(index: index),
    );
  }
}

class _CalcInfo {
  final String emoji, name, desc;
  const _CalcInfo(this.emoji, this.name, this.desc);
}

// ═══════════════════════════════════════════════════
// CALCULATOR BOTTOM SHEET
// ═══════════════════════════════════════════════════

class _CalculatorSheet extends StatefulWidget {
  final int index;
  const _CalculatorSheet({required this.index});

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  final _inputCtrl = TextEditingController();
  final _inputCtrl2 = TextEditingController();
  String _selectedBody = 'Earth';
  String _selectedBody2 = 'Mars';
  String _selectedUnit = 'light-years';
  bool _calculated = false;
  String _shareText = '';

  // ── Gravity multipliers ──
  static const _gravities = {
    'Mercury \u263F': 0.38, 'Venus \u2640': 0.91, 'Earth \u{1F30D}': 1.0,
    'Moon \u{1F319}': 0.166, 'Mars \u2642': 0.38, 'Jupiter \u2643': 2.34,
    'Saturn \u2644': 0.93, 'Uranus \u26E2': 0.92, 'Neptune \u2646': 1.12,
    'Sun \u2600\uFE0F': 27.9,
  };

  // ── Escape velocities (km/s) ──
  static const _escapeVelocities = {
    'Earth': 11.2, 'Moon': 2.4, 'Mars': 5.0, 'Venus': 10.4,
    'Jupiter': 59.5, 'Saturn': 35.5, 'Uranus': 21.3, 'Neptune': 23.5,
    'Mercury': 4.3, 'Sun': 617.5,
  };

  // ── Average distances from Sun (million km) ──
  static const _distFromSun = {
    'Mercury': 57.9, 'Venus': 108.2, 'Earth': 149.6, 'Mars': 227.9,
    'Jupiter': 778.5, 'Saturn': 1434.0, 'Uranus': 2871.0, 'Neptune': 4495.0,
  };

  // ── Planet radii relative to Earth ──
  static const _sizeRatios = {
    'Sun': 109.0, 'Jupiter': 11.2, 'Saturn': 9.4, 'Uranus': 4.0,
    'Neptune': 3.9, 'Earth': 1.0, 'Venus': 0.95, 'Mars': 0.53,
    'Mercury': 0.38, 'Moon': 0.27,
  };

  // ── Orbital periods in Earth years ──
  static const _orbitalPeriods = {
    'Mercury': 0.24, 'Venus': 0.62, 'Earth': 1.0, 'Mars': 1.88,
    'Jupiter': 11.86, 'Saturn': 29.46, 'Uranus': 84.01, 'Neptune': 164.8,
  };

  @override
  void dispose() {
    _inputCtrl.dispose();
    _inputCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      '\u2696\uFE0F Weight on Planets',
      '\u{1F4A1} Light Travel Time',
      '\u{1F680} Escape Velocity',
      '\u{1F30D} Planet Distance',
      '\u{1F4CF} Size Comparator',
      '\u{1F550} Time on Planets',
      '\u{1F321}\uFE0F Temp Converter',
      '\u{1F52D} Telescope Calculator',
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(titles[widget.index],
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                    decoration: TextDecoration.none)),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: _buildCalculatorBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorBody() {
    switch (widget.index) {
      case 0: return _buildWeightCalc();
      case 1: return _buildLightCalc();
      case 2: return _buildEscapeCalc();
      case 3: return _buildDistanceCalc();
      case 4: return _buildSizeCalc();
      case 5: return _buildTimeCalc();
      case 6: return _buildTempCalc();
      case 7: return _buildTelescopeCalc();
      default: return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════

  Widget _inputField(String hint, TextEditingController ctrl, {TextInputType type = TextInputType.number}) {
    return CupertinoTextField(
      controller: ctrl,
      placeholder: hint,
      keyboardType: type,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.searchBar(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      style: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textPrimary(context)),
      placeholderStyle: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textSecondary(context)),
    );
  }

  Widget _calcButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(12),
        onPressed: onTap,
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _resultCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _shareButton() {
    if (_shareText.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(12),
          onPressed: () => SharePlus.instance.share(ShareParams(text: _shareText)),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder(context)),
            ),
            child: Text('Share Results',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPurple)),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.searchBar(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface(context),
        style: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textPrimary(context)),
        icon: Icon(CupertinoIcons.chevron_down,
            size: 16, color: AppColors.textSecondary(context)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }

  // ═══════════════════════════════════════
  // 1. WEIGHT ON PLANETS
  // ═══════════════════════════════════════

  Widget _buildWeightCalc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your weight (kg)',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _inputField('e.g. 70', _inputCtrl),
        const SizedBox(height: 16),
        _calcButton('Calculate', () {
          final w = double.tryParse(_inputCtrl.text);
          if (w == null || w <= 0) return;
          final buf = StringBuffer('My weight across the solar system:\n');
          for (final e in _gravities.entries) {
            buf.writeln('${e.key}: ${(w * e.value).toStringAsFixed(1)} kg');
          }
          _shareText = buf.toString();
          setState(() => _calculated = true);
        }),
        if (_calculated && double.tryParse(_inputCtrl.text) != null) ...[
          const SizedBox(height: 16),
          _resultCard([
            ..._gravities.entries.map((e) {
              final w = double.parse(_inputCtrl.text) * e.value;
              final maxW = double.parse(_inputCtrl.text) * 27.9;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context))),
                        Text('${w.toStringAsFixed(1)} kg',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentPurple)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (w / maxW).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.divider(context),
                        valueColor: AlwaysStoppedAnimation(
                            e.value == 27.9 ? AppColors.starGold : AppColors.accentCyan),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ]),
          _shareButton(),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════
  // 2. LIGHT TRAVEL TIME
  // ═══════════════════════════════════════

  Widget _buildLightCalc() {
    const c = 299792.458; // km/s
    const presets = {
      'To Moon': 384400.0,
      'To Sun': 149597870.7,
      'To Mars (avg)': 225000000.0,
      'To Proxima Centauri': 4.0114e+13,
      'Across Milky Way': 9.461e+17,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _inputField('Distance', _inputCtrl)),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: _dropdown(_selectedUnit, ['km', 'AU', 'light-years'], (v) {
                setState(() => _selectedUnit = v);
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Quick presets',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: presets.entries.map((e) => GestureDetector(
            onTap: () {
              _inputCtrl.text = e.value.toStringAsExponential(2);
              setState(() { _selectedUnit = 'km'; _calculated = false; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Text(e.key,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPurple)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _calcButton('Calculate', () {
          final d = double.tryParse(_inputCtrl.text);
          if (d == null || d <= 0) return;
          setState(() => _calculated = true);
        }),
        if (_calculated && double.tryParse(_inputCtrl.text) != null) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final d = double.parse(_inputCtrl.text);
            double km;
            switch (_selectedUnit) {
              case 'AU': km = d * 149597870.7; break;
              case 'light-years': km = d * 9.461e+12; break;
              default: km = d;
            }
            final seconds = km / c;
            final years = (seconds / 31557600).floor();
            final days = ((seconds % 31557600) / 86400).floor();
            final hours = ((seconds % 86400) / 3600).floor();
            final mins = ((seconds % 3600) / 60).floor();
            final secs = (seconds % 60).floor();

            String timeStr;
            if (years > 0) {
              timeStr = '$years years, $days days';
            } else if (days > 0) {
              timeStr = '$days days, $hours hours';
            } else if (hours > 0) {
              timeStr = '$hours hours, $mins minutes';
            } else if (mins > 0) {
              timeStr = '$mins minutes, $secs seconds';
            } else {
              timeStr = '${seconds.toStringAsFixed(2)} seconds';
            }

            _shareText = 'Light takes $timeStr to travel ${_inputCtrl.text} $_selectedUnit! \u{1F4A1}';

            return _resultCard([
              Text('Light travel time',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              Text(timeStr,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPurple)),
              const SizedBox(height: 8),
              Text('Distance: ${km.toStringAsExponential(3)} km',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary(context))),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════
  // 3. ESCAPE VELOCITY
  // ═══════════════════════════════════════

  Widget _buildEscapeCalc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a celestial body',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _dropdown(_selectedBody, _escapeVelocities.keys.toList(), (v) {
          setState(() { _selectedBody = v; _calculated = true; });
        }),
        const SizedBox(height: 16),
        _calcButton('Calculate', () => setState(() => _calculated = true)),
        if (_calculated) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final v = _escapeVelocities[_selectedBody]!;
            final kmh = v * 3600;
            final bulletX = (v / 1.7).toStringAsFixed(1);
            final soundX = (v / 0.343).toStringAsFixed(0);
            _shareText = 'Escape velocity from $_selectedBody: ${v.toStringAsFixed(1)} km/s ($bulletX\u00D7 faster than a bullet!) \u{1F680}';

            return _resultCard([
              Text('Escape velocity from $_selectedBody',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              Text('${v.toStringAsFixed(1)} km/s',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentCyan)),
              Text('${kmh.toStringAsFixed(0)} km/h',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary(context))),
              const SizedBox(height: 12),
              Text('v = \u221A(2GM/r)',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary(context))),
              const SizedBox(height: 12),
              _comparisonRow('$bulletX\u00D7 faster than a bullet (1.7 km/s)'),
              _comparisonRow('$soundX\u00D7 faster than sound (0.343 km/s)'),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  Widget _comparisonRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(CupertinoIcons.bolt_fill,
              size: 14, color: AppColors.starGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary(context))),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 4. PLANET DISTANCE
  // ═══════════════════════════════════════

  Widget _buildDistanceCalc() {
    final planets = _distFromSun.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select two planets',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _dropdown(_selectedBody, planets, (v) {
          setState(() { _selectedBody = v; _calculated = false; });
        }),
        const SizedBox(height: 8),
        _dropdown(_selectedBody2, planets, (v) {
          setState(() { _selectedBody2 = v; _calculated = false; });
        }),
        const SizedBox(height: 16),
        _calcButton('Calculate', () {
          if (_selectedBody == _selectedBody2) return;
          setState(() => _calculated = true);
        }),
        if (_calculated && _selectedBody != _selectedBody2) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final d1 = _distFromSun[_selectedBody]!;
            final d2 = _distFromSun[_selectedBody2]!;
            final minDist = (d2 - d1).abs();
            final maxDist = d1 + d2;
            final avgDist = (minDist + maxDist) / 2;

            String travelTime(double distMkm, double speedKmh) {
              final hours = distMkm * 1e6 / speedKmh;
              if (hours < 24) return '${hours.toStringAsFixed(1)} hours';
              final days = hours / 24;
              if (days < 365) return '${days.toStringAsFixed(0)} days';
              final years = days / 365.25;
              return '${years.toStringAsFixed(1)} years';
            }

            _shareText = 'Distance from $_selectedBody to $_selectedBody2: ${avgDist.toStringAsFixed(0)}M km (avg) \u{1F30D}';

            return _resultCard([
              Text('$_selectedBody \u2194 $_selectedBody2',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              const SizedBox(height: 12),
              _distRow('Closest approach', '${minDist.toStringAsFixed(1)}M km'),
              _distRow('Farthest apart', '${maxDist.toStringAsFixed(1)}M km'),
              _distRow('Average', '${avgDist.toStringAsFixed(1)}M km'),
              const SizedBox(height: 12),
              Text('Travel time (avg distance)',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              _distRow('\u{1F697} Car (100 km/h)', travelTime(avgDist, 100)),
              _distRow('\u2708\uFE0F Airplane (900 km/h)', travelTime(avgDist, 900)),
              _distRow('\u{1F680} Rocket (40,000 km/h)', travelTime(avgDist, 40000)),
              _distRow('\u{1F4A1} Light', travelTime(avgDist, 1.079e+9)),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  Widget _distRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary(context))),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 5. SIZE COMPARATOR
  // ═══════════════════════════════════════

  Widget _buildSizeCalc() {
    final bodies = _sizeRatios.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a celestial body',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _dropdown(_selectedBody, bodies, (v) {
          setState(() { _selectedBody = v; _calculated = true; });
        }),
        const SizedBox(height: 16),
        _calcButton('Compare', () => setState(() => _calculated = true)),
        if (_calculated) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final ratio = _sizeRatios[_selectedBody]!;
            _shareText = '$_selectedBody is ${ratio}x the diameter of Earth! \u{1F4CF}';

            return _resultCard([
              Text('$_selectedBody vs Earth',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              const SizedBox(height: 8),
              Text(ratio >= 1
                  ? '$_selectedBody is ${ratio}x wider than Earth'
                  : '$_selectedBody is ${(ratio * 100).toStringAsFixed(0)}% the size of Earth',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary(context))),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _SizeCompPainter(
                    ratio: ratio,
                    bodyName: _selectedBody,
                    earthColor: AppColors.accentCyan,
                    bodyColor: AppColors.accentPurple,
                    textColor: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('All bodies in the solar system:',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              ..._sizeRatios.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textPrimary(context),
                            fontWeight: e.key == _selectedBody
                                ? FontWeight.w700
                                : FontWeight.w400)),
                    Text('${e.value}x Earth',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: e.key == _selectedBody
                                ? AppColors.accentPurple
                                : AppColors.textSecondary(context),
                            fontWeight: e.key == _selectedBody
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ],
                ),
              )),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════
  // 6. TIME ON PLANETS
  // ═══════════════════════════════════════

  Widget _buildTimeCalc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your age in Earth years',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _inputField('e.g. 25', _inputCtrl),
        const SizedBox(height: 16),
        _calcButton('Calculate', () {
          final age = double.tryParse(_inputCtrl.text);
          if (age == null || age <= 0) return;
          final buf = StringBuffer('My age across the solar system:\n');
          for (final e in _orbitalPeriods.entries) {
            buf.writeln('${e.key}: ${(age / e.value).toStringAsFixed(2)} years');
          }
          _shareText = buf.toString();
          setState(() => _calculated = true);
        }),
        if (_calculated && double.tryParse(_inputCtrl.text) != null) ...[
          const SizedBox(height: 16),
          _resultCard([
            ..._orbitalPeriods.entries.map((e) {
              final age = double.parse(_inputCtrl.text);
              final planetAge = age / e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context))),
                    Text('${planetAge.toStringAsFixed(2)} years old',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: planetAge > age
                                ? AppColors.accentCyan
                                : AppColors.accentOrange)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Text('Faster orbits = more birthdays!',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary(context))),
          ]),
          _shareButton(),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════
  // 7. TEMPERATURE CONVERTER
  // ═══════════════════════════════════════

  Widget _buildTempCalc() {
    const presets = {
      'Absolute Zero': -273.15,
      'Deep Space': -270.0,
      'Pluto Surface': -229.0,
      'Mars Surface': -60.0,
      'Earth Average': 15.0,
      'Venus Surface': 465.0,
      'Sun Surface': 5500.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter temperature in \u00B0C',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _inputField('e.g. 100', _inputCtrl, type: const TextInputType.numberWithOptions(signed: true, decimal: true)),
        const SizedBox(height: 12),
        Text('Presets',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: presets.entries.map((e) => GestureDetector(
            onTap: () {
              _inputCtrl.text = e.value.toString();
              setState(() => _calculated = true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Text(e.key,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPurple)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _calcButton('Convert', () {
          if (double.tryParse(_inputCtrl.text) == null) return;
          setState(() => _calculated = true);
        }),
        if (_calculated && double.tryParse(_inputCtrl.text) != null) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final c = double.parse(_inputCtrl.text);
            final f = c * 9 / 5 + 32;
            final k = c + 273.15;
            _shareText = '${c.toStringAsFixed(1)}\u00B0C = ${f.toStringAsFixed(1)}\u00B0F = ${k.toStringAsFixed(1)} K';

            return _resultCard([
              _tempRow('Celsius', '${c.toStringAsFixed(1)} \u00B0C'),
              _tempRow('Fahrenheit', '${f.toStringAsFixed(1)} \u00B0F'),
              _tempRow('Kelvin', '${k.toStringAsFixed(1)} K'),
              const SizedBox(height: 12),
              // Visual thermometer
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((c + 273.15) / 6000).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: AppColors.divider(context),
                  valueColor: AlwaysStoppedAnimation(
                      c < 0 ? AppColors.accentCyan : (c < 100 ? AppColors.success : AppColors.error)),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('-273\u00B0C',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.textSecondary(context))),
                  Text('5727\u00B0C',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.textSecondary(context))),
                ],
              ),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  Widget _tempRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary(context))),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 8. TELESCOPE CALCULATOR
  // ═══════════════════════════════════════

  Widget _buildTelescopeCalc() {
    const eyepieces = [25.0, 10.0, 4.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Telescope aperture (mm)',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _inputField('e.g. 200', _inputCtrl),
        const SizedBox(height: 12),
        Text('Focal length (mm)',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        _inputField('e.g. 1200', _inputCtrl2),
        const SizedBox(height: 16),
        _calcButton('Calculate', () {
          final ap = double.tryParse(_inputCtrl.text);
          final fl = double.tryParse(_inputCtrl2.text);
          if (ap == null || fl == null || ap <= 0 || fl <= 0) return;
          setState(() => _calculated = true);
        }),
        if (_calculated &&
            double.tryParse(_inputCtrl.text) != null &&
            double.tryParse(_inputCtrl2.text) != null) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final aperture = double.parse(_inputCtrl.text);
            final focalLength = double.parse(_inputCtrl2.text);
            final lgp = (aperture / 7).toDouble(); // vs 7mm human pupil
            final lgpSq = lgp * lgp;
            final limitMag = 2.7 + 5 * (log(aperture) / ln10);

            _shareText = 'My telescope: ${aperture.toStringAsFixed(0)}mm aperture, '
                '${focalLength.toStringAsFixed(0)}mm FL. '
                'Light gathering: ${lgpSq.toStringAsFixed(0)}x naked eye! \u{1F52D}';

            return _resultCard([
              Text('Telescope Performance',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              const SizedBox(height: 12),
              Text('Magnification by eyepiece:',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              ...eyepieces.map((ep) {
                final mag = focalLength / ep;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${ep.toStringAsFixed(0)}mm eyepiece',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textPrimary(context))),
                      Text('${mag.toStringAsFixed(0)}x',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentCyan)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              _distRow('Light gathering power', '${lgpSq.toStringAsFixed(0)}\u00D7 naked eye'),
              _distRow('Limiting magnitude', limitMag.toStringAsFixed(1)),
              const SizedBox(height: 12),
              Text('What you can see:',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              _canSee('Moon craters', aperture >= 50),
              _canSee('Jupiter\'s moons', aperture >= 50),
              _canSee('Saturn\'s rings', aperture >= 70),
              _canSee('Andromeda Galaxy', aperture >= 50),
              _canSee('Nebulae detail', aperture >= 150),
              _canSee('Galaxy structure', aperture >= 200),
              _canSee('Pluto', aperture >= 250),
            ]);
          }),
          _shareButton(),
        ],
      ],
    );
  }

  Widget _canSee(String target, bool visible) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            visible ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle,
            size: 16,
            color: visible ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(target,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: visible
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SIZE COMPARISON PAINTER
// ═══════════════════════════════════════════════════

class _SizeCompPainter extends CustomPainter {
  final double ratio;
  final String bodyName;
  final Color earthColor;
  final Color bodyColor;
  final Color textColor;

  _SizeCompPainter({
    required this.ratio,
    required this.bodyName,
    required this.earthColor,
    required this.bodyColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = size.height / 2 - 10;
    final earthR = ratio >= 1
        ? (maxRadius / ratio).clamp(4.0, maxRadius)
        : maxRadius;
    final bodyR = ratio >= 1
        ? maxRadius
        : (maxRadius * ratio).clamp(4.0, maxRadius);

    final earthPaint = Paint()..color = earthColor;
    final bodyPaint = Paint()..color = bodyColor;

    // Draw body on left
    final bodyCenter = Offset(size.width * 0.3, size.height / 2);
    canvas.drawCircle(bodyCenter, bodyR, bodyPaint);

    // Draw Earth on right
    final earthCenter = Offset(size.width * 0.7, size.height / 2);
    canvas.drawCircle(earthCenter, earthR, earthPaint);

    // Labels
    final bodyTp = TextPainter(
      text: TextSpan(text: bodyName, style: TextStyle(color: textColor, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    bodyTp.paint(canvas, Offset(bodyCenter.dx - bodyTp.width / 2, size.height - 12));

    final earthTp = TextPainter(
      text: TextSpan(text: 'Earth', style: TextStyle(color: textColor, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    earthTp.paint(canvas, Offset(earthCenter.dx - earthTp.width / 2, size.height - 12));
  }

  @override
  bool shouldRepaint(covariant _SizeCompPainter old) =>
      old.ratio != ratio || old.bodyName != bodyName;
}
