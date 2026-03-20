import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/planet_data.dart';
import '../../theme/app_colors.dart';

class PlanetComparatorScreen extends StatefulWidget {
  const PlanetComparatorScreen({super.key});

  @override
  State<PlanetComparatorScreen> createState() => _PlanetComparatorScreenState();
}

class _PlanetComparatorScreenState extends State<PlanetComparatorScreen> {
  PlanetData? _planet1;
  PlanetData? _planet2;

  bool get _bothSelected => _planet1 != null && _planet2 != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: _buildSelectors(),
              ),
            ),
            if (_bothSelected) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildVisualComparison(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text('Stats Comparison',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context))),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                      _buildComparisonRows()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _buildFunFact(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: _buildShareButton(),
                ),
              ),
            ],
            if (!_bothSelected)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: Center(
                    child: Text('Select two bodies to compare',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary(context))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════

  Widget _buildTopBar() {
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
          Text('Planet Comparator',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // SELECTOR CARDS
  // ═══════════════════════════════════════

  Widget _buildSelectors() {
    return Row(
      children: [
        Expanded(child: _selectorCard(_planet1, true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text('VS',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentPurple)),
          ),
        ),
        Expanded(child: _selectorCard(_planet2, false)),
      ],
    );
  }

  Widget _selectorCard(PlanetData? planet, bool isFirst) {
    return GestureDetector(
      onTap: () => _showPicker(isFirst),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: planet != null
                ? planet.color.withValues(alpha: 0.4)
                : AppColors.glassBorder(context),
          ),
          boxShadow: planet != null
              ? AppColors.coloredShadow(context, planet.color)
              : AppColors.cardShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (planet != null) ...[
              Text(planet.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(planet.name,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              Text(planet.type,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary(context))),
            ] else ...[
              Icon(CupertinoIcons.add_circled,
                  size: 32, color: AppColors.textSecondary(context)),
              const SizedBox(height: 6),
              Text(isFirst ? 'Planet 1' : 'Planet 2',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary(context))),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showPicker(bool isFirst) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            color: AppColors.surface(ctx),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(ctx).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(isFirst ? 'Select Planet 1' : 'Select Planet 2',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(ctx),
                      decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: allPlanets.length,
                  itemBuilder: (context, i) {
                    final p = allPlanets[i];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isFirst) {
                            _planet1 = p;
                          } else {
                            _planet2 = p;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.glass(ctx),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.glassBorder(ctx)),
                          boxShadow: AppColors.cardShadow(ctx),
                        ),
                        child: Row(
                          children: [
                            Text(p.emoji,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(ctx),
                                          decoration: TextDecoration.none)),
                                  Text(p.type,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.textSecondary(ctx),
                                          decoration: TextDecoration.none)),
                                ],
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_right,
                                size: 14,
                                color: AppColors.textSecondary(ctx)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // VISUAL SIZE COMPARISON
  // ═══════════════════════════════════════

  Widget _buildVisualComparison() {
    final p1 = _planet1!;
    final p2 = _planet2!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        children: [
          Text('Size Comparison',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _CompPainter(
                d1: p1.diameterKm,
                d2: p2.diameterKm,
                c1: p1.color,
                c2: p2.color,
                n1: p1.name,
                n2: p2.name,
                textColor: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sizeCompText(p1, p2),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  String _sizeCompText(PlanetData p1, PlanetData p2) {
    final ratio = p1.diameterKm / p2.diameterKm;
    if (ratio > 1) {
      return '${p1.name} is ${ratio.toStringAsFixed(1)}x wider than ${p2.name}';
    } else if (ratio < 1) {
      return '${p2.name} is ${(1 / ratio).toStringAsFixed(1)}x wider than ${p1.name}';
    }
    return '${p1.name} and ${p2.name} are the same size';
  }

  // ═══════════════════════════════════════
  // COMPARISON ROWS
  // ═══════════════════════════════════════

  List<Widget> _buildComparisonRows() {
    final p1 = _planet1!;
    final p2 = _planet2!;

    final rows = <_CompRow>[
      _CompRow('Diameter', '${_fmtNum(p1.diameterKm)} km', '${_fmtNum(p2.diameterKm)} km',
          p1.diameterKm, p2.diameterKm),
      _CompRow('Mass', '${p1.massEarths} \u00D7 Earth', '${p2.massEarths} \u00D7 Earth',
          p1.massEarths, p2.massEarths),
      _CompRow('From Sun', '${p1.distFromSunMKm}M km', '${p2.distFromSunMKm}M km',
          p1.distFromSunMKm, p2.distFromSunMKm, lowerBetter: true),
      _CompRow('Orbital Period', _fmtPeriod(p1.orbitalPeriodYears), _fmtPeriod(p2.orbitalPeriodYears),
          p1.orbitalPeriodYears, p2.orbitalPeriodYears, lowerBetter: true),
      _CompRow('Day Length', _fmtDay(p1.dayLengthHours), _fmtDay(p2.dayLengthHours),
          p1.dayLengthHours, p2.dayLengthHours),
      _CompRow('Gravity', '${p1.surfaceGravity} m/s\u00B2', '${p2.surfaceGravity} m/s\u00B2',
          p1.surfaceGravity, p2.surfaceGravity),
      _CompRow('Avg Temp', '${p1.avgTempC}\u00B0C', '${p2.avgTempC}\u00B0C',
          p1.avgTempC.toDouble(), p2.avgTempC.toDouble()),
      _CompRow('Moons', '${p1.moons}', '${p2.moons}',
          p1.moons.toDouble(), p2.moons.toDouble()),
      _CompRow('Rings', p1.hasRings ? 'Yes' : 'No', p2.hasRings ? 'Yes' : 'No',
          p1.hasRings ? 1 : 0, p2.hasRings ? 1 : 0),
      _CompRow('Type', p1.type, p2.type, 0, 0, noWinner: true),
      _CompRow('Atmosphere', p1.atmosphere, p2.atmosphere, 0, 0, noWinner: true),
    ];

    return rows.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;
      return _buildRow(r, i);
    }).toList();
  }

  Widget _buildRow(_CompRow r, int index) {
    final leftWins = !r.noWinner && r.v1 > r.v2 && !(r.lowerBetter);
    final rightWins = !r.noWinner && r.v2 > r.v1 && !(r.lowerBetter);
    final leftWinsLower = !r.noWinner && r.lowerBetter && r.v1 < r.v2 && r.v1 > 0;
    final rightWinsLower = !r.noWinner && r.lowerBetter && r.v2 < r.v1 && r.v2 > 0;

    final leftHighlight = leftWins || leftWinsLower;
    final rightHighlight = rightWins || rightWinsLower;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(r.left,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: leftHighlight ? FontWeight.w700 : FontWeight.w500,
                      color: leftHighlight
                          ? AppColors.success
                          : AppColors.textPrimary(context)),
                  textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(r.label,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context)),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(r.right,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: rightHighlight ? FontWeight.w700 : FontWeight.w500,
                      color: rightHighlight
                          ? AppColors.success
                          : AppColors.textPrimary(context)),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
        duration: 300.ms, delay: Duration(milliseconds: 40 * index));
  }

  // ═══════════════════════════════════════
  // FUN FACT
  // ═══════════════════════════════════════

  Widget _buildFunFact() {
    final p1 = _planet1!;
    final p2 = _planet2!;
    final fact = _generateFunFact(p1, p2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u{1F4A1}', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fun Fact',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPurple)),
                const SizedBox(height: 4),
                Text(fact,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary(context),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  String _generateFunFact(PlanetData p1, PlanetData p2) {
    final big = p1.diameterKm >= p2.diameterKm ? p1 : p2;
    final small = p1.diameterKm < p2.diameterKm ? p1 : p2;
    final volRatio = pow(big.diameterKm / small.diameterKm, 3).toStringAsFixed(0);

    // Special pairs
    final names = {p1.name, p2.name};
    if (names.contains('Earth') && names.contains('Jupiter')) {
      return 'You could fit about 1,321 Earths inside Jupiter! Jupiter\'s Great Red Spot alone is bigger than Earth.';
    }
    if (names.contains('Earth') && names.contains('Sun')) {
      return 'About 1.3 million Earths could fit inside the Sun! The Sun contains 99.86% of all mass in our solar system.';
    }
    if (names.contains('Mars') && names.contains('Earth')) {
      return 'Mars has the tallest volcano in the solar system \u2014 Olympus Mons is 3x the height of Everest! But Mars is only about half Earth\'s size.';
    }
    if (names.contains('Jupiter') && names.contains('Saturn')) {
      return 'Jupiter and Saturn are both gas giants, but Saturn is so light it could float in water! Its density is only 0.687 g/cm\u00B3.';
    }
    if (names.contains('Earth') && names.contains('Moon')) {
      return 'The Moon is slowly drifting away from Earth at 3.8 cm per year. In the distant past, it was much closer and days were shorter!';
    }
    if (names.contains('Venus') && names.contains('Earth')) {
      return 'Venus is Earth\'s "evil twin" \u2014 similar in size but with a surface hot enough to melt lead (464\u00B0C) and acid rain!';
    }
    if (names.contains('Neptune') && names.contains('Uranus')) {
      return 'Both ice giants, but Uranus rotates on its side at 98\u00B0! Neptune has the fastest winds in the solar system at over 2,100 km/h.';
    }
    if (names.contains('Pluto')) {
      final other = p1.name == 'Pluto' ? p2 : p1;
      return 'Pluto is so small that its surface area is less than Russia! It was reclassified as a dwarf planet in 2006. ${other.name} is ${(other.diameterKm / 2377).toStringAsFixed(1)}x wider.';
    }

    // Generic
    if (big.diameterKm > small.diameterKm * 5) {
      return 'You could fit about $volRatio ${small.name}s inside ${big.name} by volume! ${big.name} is truly massive in comparison.';
    }
    final gravBig = p1.surfaceGravity >= p2.surfaceGravity ? p1 : p2;
    final gravSmall = p1.surfaceGravity < p2.surfaceGravity ? p1 : p2;
    final gravRatio = (gravBig.surfaceGravity / gravSmall.surfaceGravity).toStringAsFixed(1);
    return 'Gravity on ${gravBig.name} is ${gravRatio}x stronger than on ${gravSmall.name}. A 70 kg person would weigh ${(70 * gravBig.surfaceGravity / 9.8).toStringAsFixed(0)} kg on ${gravBig.name}!';
  }

  // ═══════════════════════════════════════
  // SHARE
  // ═══════════════════════════════════════

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(14),
        onPressed: () {
          final p1 = _planet1!;
          final p2 = _planet2!;
          final fact = _generateFunFact(p1, p2);
          SharePlus.instance.share(ShareParams(
            text: '\u{1FA90} ${p1.name} vs ${p2.name} \u2014 $fact\n\nCompare planets on Cosmic Facts! \u{1F30C}',
          ));
        },
        child: Text('Share Comparison',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════

  String _fmtNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  String _fmtPeriod(double years) {
    if (years == 0) return 'N/A';
    if (years < 0.1) return '${(years * 365.25).toStringAsFixed(1)} days';
    if (years < 2) return '${(years * 12).toStringAsFixed(1)} months';
    return '${years.toStringAsFixed(1)} years';
  }

  String _fmtDay(double hours) {
    if (hours < 48) return '${hours.toStringAsFixed(1)} hours';
    return '${(hours / 24).toStringAsFixed(1)} Earth days';
  }
}

// ═══════════════════════════════════════
// COMPARISON ROW DATA
// ═══════════════════════════════════════

class _CompRow {
  final String label;
  final String left;
  final String right;
  final double v1;
  final double v2;
  final bool lowerBetter;
  final bool noWinner;

  const _CompRow(this.label, this.left, this.right, this.v1, this.v2,
      {this.lowerBetter = false, this.noWinner = false});
}

// ═══════════════════════════════════════
// SIZE COMPARISON PAINTER
// ═══════════════════════════════════════

class _CompPainter extends CustomPainter {
  final double d1, d2;
  final Color c1, c2;
  final String n1, n2;
  final Color textColor;

  _CompPainter({
    required this.d1, required this.d2,
    required this.c1, required this.c2,
    required this.n1, required this.n2,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxD = max(d1, d2);
    final maxR = (size.height / 2 - 14).clamp(10.0, 60.0);

    final r1 = (d1 / maxD * maxR).clamp(3.0, maxR);
    final r2 = (d2 / maxD * maxR).clamp(3.0, maxR);

    final cx1 = size.width * 0.3;
    final cx2 = size.width * 0.7;
    final cy = size.height / 2 - 4;

    canvas.drawCircle(Offset(cx1, cy), r1, Paint()..color = c1);
    canvas.drawCircle(Offset(cx2, cy), r2, Paint()..color = c2);

    final tp1 = TextPainter(
      text: TextSpan(text: n1, style: TextStyle(color: textColor, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, Offset(cx1 - tp1.width / 2, size.height - 14));

    final tp2 = TextPainter(
      text: TextSpan(text: n2, style: TextStyle(color: textColor, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(cx2 - tp2.width / 2, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant _CompPainter old) =>
      old.d1 != d1 || old.d2 != d2 || old.n1 != n1 || old.n2 != n2;
}
