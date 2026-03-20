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
  PlanetData? _p1;
  PlanetData? _p2;
  bool get _ready => _p1 != null && _p2 != null;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _topBar()),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), child: _selectors())),
            if (_ready) ...[
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: _sizeVis())),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 10), child: Text('Stats Comparison', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))))),
              SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), sliver: SliverList(delegate: SliverChildListDelegate(_rows()))),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _funFact())),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 40), child: _shareBtn())),
            ],
            if (!_ready) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 60), child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.compare_arrows_rounded, size: 48, color: AppColors.textSecondary(context).withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('Select two bodies to compare', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary(context))),
              ])))),
          ],
        ),
      ),
    );
  }

  Widget _topBar() => Padding(padding: const EdgeInsets.fromLTRB(8, 8, 20, 0), child: Row(children: [
    CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context), child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context), size: 26)),
    const SizedBox(width: 4),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Planet Comparator', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
      Text('Side-by-side celestial comparison', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))),
    ]),
  ]));

  // ── Selectors ──
  Widget _selectors() => Row(children: [
    Expanded(child: _selCard(_p1, true)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Container(width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]),
        boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.25), blurRadius: 12)]),
      child: Center(child: Text('VS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))))),
    Expanded(child: _selCard(_p2, false)),
  ]);

  Widget _selCard(PlanetData? p, bool isFirst) => GestureDetector(
    onTap: () => _pick(isFirst),
    child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _isDark ? null : AppColors.card(context),
        gradient: _isDark && p != null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [p.color.withValues(alpha: 0.1), AppColors.cardDark]) : (_isDark ? LinearGradient(colors: [AppColors.surfaceDark, AppColors.cardDark]) : null),
        border: Border.all(color: p != null ? p.color.withValues(alpha: _isDark ? 0.25 : 0.15) : AppColors.glassBorder(context)),
        boxShadow: p != null
          ? [BoxShadow(color: p.color.withValues(alpha: _isDark ? 0.08 : 0.18), blurRadius: 16, offset: const Offset(0, 4))]
          : AppColors.cardShadow(context),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: p != null
        ? [Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: p.color.withValues(alpha: 0.15),
            border: Border.all(color: p.color.withValues(alpha: 0.3), width: 2)),
            child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 22)))),
           const SizedBox(height: 8),
           Text(p.name, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
           Text(p.type, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary(context)))]
        : [Icon(CupertinoIcons.add_circled, size: 32, color: AppColors.textSecondary(context)),
           const SizedBox(height: 6),
           Text(isFirst ? 'Select Body 1' : 'Select Body 2', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context)))]),
    ),
  ).animate().fadeIn(duration: 400.ms);

  void _pick(bool isFirst) {
    showCupertinoModalPopup(context: context, builder: (ctx) => Material(color: Colors.transparent,
      child: Container(height: 420,
        decoration: BoxDecoration(color: AppColors.surface(ctx), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary(ctx).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(isFirst ? 'Select Body 1' : 'Select Body 2', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary(ctx), decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: allPlanets.length,
            itemBuilder: (context, i) { final p = allPlanets[i]; return CupertinoButton(padding: EdgeInsets.zero,
              onPressed: () { Navigator.pop(context); setState(() { if (isFirst) { _p1 = p; } else { _p2 = p; } }); },
              child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.glass(ctx), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.color.withValues(alpha: 0.15)), boxShadow: AppColors.cardShadow(ctx)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: p.color.withValues(alpha: 0.12)),
                    child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 18)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(ctx), decoration: TextDecoration.none)),
                    Text(p.type, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary(ctx), decoration: TextDecoration.none))])),
                  Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.textSecondary(ctx)),
                ])),
            ); })),
        ]),
      ),
    ));
  }

  // ── Visual Size ──
  Widget _sizeVis() {
    final p1 = _p1!; final p2 = _p2!;
    return Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
        color: _isDark ? null : AppColors.card(context),
        gradient: _isDark ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.surfaceDark, AppColors.cardDark]) : null,
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.12)),
        boxShadow: AppColors.cardShadow(context)),
      child: Column(children: [
        Text('Size Comparison', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
        const SizedBox(height: 16),
        SizedBox(height: 140, child: CustomPaint(size: const Size(double.infinity, 140),
          painter: _CompP(d1: p1.diameterKm, d2: p2.diameterKm, c1: p1.color, c2: p2.color, n1: p1.name, n2: p2.name, tc: AppColors.textPrimary(context)))),
        const SizedBox(height: 10),
        Text(_sizeTxt(p1, p2), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context))),
      ]),
    ).animate().fadeIn(duration: 500.ms);
  }

  String _sizeTxt(PlanetData a, PlanetData b) {
    final r = a.diameterKm / b.diameterKm;
    if (r > 1) return '${a.name} is ${r.toStringAsFixed(1)}x wider than ${b.name}';
    if (r < 1) return '${b.name} is ${(1 / r).toStringAsFixed(1)}x wider than ${a.name}';
    return 'Same size';
  }

  // ── Stats Rows ──
  List<Widget> _rows() {
    final p1 = _p1!; final p2 = _p2!;
    final data = <_R>[
      _R('Diameter', '${_fN(p1.diameterKm)} km', '${_fN(p2.diameterKm)} km', p1.diameterKm, p2.diameterKm),
      _R('Mass', '${p1.massEarths}\u00D7 Earth', '${p2.massEarths}\u00D7 Earth', p1.massEarths, p2.massEarths),
      _R('From Sun', '${p1.distFromSunMKm}M km', '${p2.distFromSunMKm}M km', p1.distFromSunMKm, p2.distFromSunMKm, lb: true),
      _R('Orbital Period', _fP(p1.orbitalPeriodYears), _fP(p2.orbitalPeriodYears), p1.orbitalPeriodYears, p2.orbitalPeriodYears, lb: true),
      _R('Day Length', _fD(p1.dayLengthHours), _fD(p2.dayLengthHours), p1.dayLengthHours, p2.dayLengthHours),
      _R('Gravity', '${p1.surfaceGravity} m/s\u00B2', '${p2.surfaceGravity} m/s\u00B2', p1.surfaceGravity, p2.surfaceGravity),
      _R('Avg Temp', '${p1.avgTempC}\u00B0C', '${p2.avgTempC}\u00B0C', p1.avgTempC.toDouble(), p2.avgTempC.toDouble()),
      _R('Moons', '${p1.moons}', '${p2.moons}', p1.moons.toDouble(), p2.moons.toDouble()),
      _R('Rings', p1.hasRings ? 'Yes' : 'No', p2.hasRings ? 'Yes' : 'No', p1.hasRings ? 1 : 0, p2.hasRings ? 1 : 0),
      _R('Type', p1.type, p2.type, 0, 0, nw: true),
      _R('Atmosphere', p1.atmosphere, p2.atmosphere, 0, 0, nw: true),
    ];
    return data.asMap().entries.map((e) => _row(e.value, e.key)).toList();
  }

  Widget _row(_R r, int i) {
    final lw = !r.nw && ((r.v1 > r.v2 && !r.lb) || (r.lb && r.v1 < r.v2 && r.v1 > 0));
    final rw = !r.nw && ((r.v2 > r.v1 && !r.lb) || (r.lb && r.v2 < r.v1 && r.v2 > 0));
    final even = i % 2 == 0;
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        color: even ? AppColors.card(context) : AppColors.surface(context),
        border: Border.all(color: AppColors.glassBorder(context))),
      child: Row(children: [
        if (lw) Container(width: 4, height: 4, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
        Expanded(flex: 3, child: Text(r.l, style: GoogleFonts.inter(fontSize: 12, fontWeight: lw ? FontWeight.w700 : FontWeight.w500,
          color: lw ? AppColors.success : AppColors.textPrimary(context)), textAlign: TextAlign.left)),
        Expanded(flex: 3, child: Text(r.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context)), textAlign: TextAlign.center)),
        Expanded(flex: 3, child: Text(r.r, style: GoogleFonts.inter(fontSize: 12, fontWeight: rw ? FontWeight.w700 : FontWeight.w500,
          color: rw ? AppColors.success : AppColors.textPrimary(context)), textAlign: TextAlign.right)),
        if (rw) Container(width: 4, height: 4, margin: const EdgeInsets.only(left: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
      ]),
    )).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 40 * i));
  }

  // ── Fun Fact ──
  Widget _funFact() {
    final fact = _genFact(_p1!, _p2!);
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [AppColors.accentPurple.withValues(alpha: 0.08), AppColors.accentCyan.withValues(alpha: 0.05)]),
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.12))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(CupertinoIcons.lightbulb_fill, size: 20, color: AppColors.starGold),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fun Fact', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
          const SizedBox(height: 4),
          Text(fact, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary(context), height: 1.5)),
        ])),
      ]),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  String _genFact(PlanetData a, PlanetData b) {
    final n = {a.name, b.name};
    if (n.contains('Earth') && n.contains('Jupiter')) return 'You could fit about 1,321 Earths inside Jupiter! Jupiter\'s Great Red Spot alone is bigger than Earth.';
    if (n.contains('Earth') && n.contains('Sun')) return 'About 1.3 million Earths could fit inside the Sun! The Sun contains 99.86% of all mass in our solar system.';
    if (n.contains('Mars') && n.contains('Earth')) return 'Mars has the tallest volcano \u2014 Olympus Mons is 3x Everest! But Mars is only about half Earth\'s size.';
    if (n.contains('Jupiter') && n.contains('Saturn')) return 'Both gas giants, but Saturn is so light it could float in water!';
    if (n.contains('Earth') && n.contains('Moon')) return 'The Moon is slowly drifting away from Earth at 3.8 cm per year.';
    if (n.contains('Venus') && n.contains('Earth')) return 'Venus is Earth\'s "evil twin" \u2014 similar size but 464\u00B0C surface and acid rain!';
    if (n.contains('Neptune') && n.contains('Uranus')) return 'Both ice giants, but Uranus rotates on its side at 98\u00B0! Neptune has the fastest winds at 2,100 km/h.';
    if (n.contains('Pluto')) { final o = a.name == 'Pluto' ? b : a; return 'Pluto is so small its surface area is less than Russia! ${o.name} is ${(o.diameterKm / 2377).toStringAsFixed(1)}x wider.'; }
    final big = a.diameterKm >= b.diameterKm ? a : b; final sm = a.diameterKm < b.diameterKm ? a : b;
    final vol = pow(big.diameterKm / sm.diameterKm, 3).toStringAsFixed(0);
    if (big.diameterKm > sm.diameterKm * 5) return 'You could fit about $vol ${sm.name}s inside ${big.name} by volume!';
    final gB = a.surfaceGravity >= b.surfaceGravity ? a : b; final gS = a.surfaceGravity < b.surfaceGravity ? a : b;
    return 'Gravity on ${gB.name} is ${(gB.surfaceGravity / gS.surfaceGravity).toStringAsFixed(1)}x stronger than on ${gS.name}.';
  }

  Widget _shareBtn() => SizedBox(width: double.infinity, height: 52, child: Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]),
      boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
    child: CupertinoButton(padding: EdgeInsets.zero, borderRadius: BorderRadius.circular(14),
      onPressed: () { final f = _genFact(_p1!, _p2!); SharePlus.instance.share(ShareParams(text: '${_p1!.name} vs ${_p2!.name} \u2014 $f\nCompare planets on Cosmic Facts!')); },
      child: Text('Share Comparison', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))));

  String _fN(double n) { if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M'; if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K'; return n.toStringAsFixed(0); }
  String _fP(double y) { if (y == 0) return 'N/A'; if (y < 0.1) return '${(y * 365.25).toStringAsFixed(1)} days'; if (y < 2) return '${(y * 12).toStringAsFixed(1)} months'; return '${y.toStringAsFixed(1)} years'; }
  String _fD(double h) { if (h < 48) return '${h.toStringAsFixed(1)} hours'; return '${(h / 24).toStringAsFixed(1)} Earth days'; }
}

class _R { final String label, l, r; final double v1, v2; final bool lb, nw; const _R(this.label, this.l, this.r, this.v1, this.v2, {this.lb = false, this.nw = false}); }

class _CompP extends CustomPainter {
  final double d1, d2; final Color c1, c2, tc; final String n1, n2;
  _CompP({required this.d1, required this.d2, required this.c1, required this.c2, required this.n1, required this.n2, required this.tc});
  @override
  void paint(Canvas canvas, Size size) {
    final mx = max(d1, d2); final mR = (size.height / 2 - 14).clamp(10.0, 60.0);
    final r1 = (d1 / mx * mR).clamp(3.0, mR); final r2 = (d2 / mx * mR).clamp(3.0, mR);
    final cx1 = size.width * 0.3; final cx2 = size.width * 0.7; final cy = size.height / 2 - 4;
    canvas.drawCircle(Offset(cx1, cy), r1, Paint()..shader = RadialGradient(colors: [c1, c1.withValues(alpha: 0.7)]).createShader(Rect.fromCircle(center: Offset(cx1, cy), radius: r1)));
    canvas.drawCircle(Offset(cx2, cy), r2, Paint()..shader = RadialGradient(colors: [c2, c2.withValues(alpha: 0.7)]).createShader(Rect.fromCircle(center: Offset(cx2, cy), radius: r2)));
    final t1 = TextPainter(text: TextSpan(text: n1, style: TextStyle(color: tc, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    t1.paint(canvas, Offset(cx1 - t1.width / 2, size.height - 14));
    final t2 = TextPainter(text: TextSpan(text: n2, style: TextStyle(color: tc, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    t2.paint(canvas, Offset(cx2 - t2.width / 2, size.height - 14));
  }
  @override
  bool shouldRepaint(covariant _CompP o) => o.d1 != d1 || o.d2 != d2 || o.n1 != n1 || o.n2 != n2;
}
