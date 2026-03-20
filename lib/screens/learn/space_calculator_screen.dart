import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/app_colors.dart';

class SpaceCalculatorScreen extends StatelessWidget {
  const SpaceCalculatorScreen({super.key});

  static const _calcs = <_CalcDef>[
    _CalcDef(Icons.scale_rounded, 'Weight on Planets', 'Your weight across the solar system', [Color(0xFF4A90D9), Color(0xFF00D4FF)]),
    _CalcDef(Icons.lightbulb_rounded, 'Light Travel Time', 'How long light takes to travel', [Color(0xFFDAA520), Color(0xFFFFD700)]),
    _CalcDef(Icons.rocket_launch_rounded, 'Escape Velocity', 'Speed to escape gravity', [Color(0xFFFF6B35), Color(0xFFFF4D6A)]),
    _CalcDef(Icons.public_rounded, 'Planet Distance', 'Distances between planets', [Color(0xFF00BFA5), Color(0xFF00E096)]),
    _CalcDef(Icons.straighten_rounded, 'Size Comparator', 'Compare celestial bodies', [Color(0xFF7B5BFF), Color(0xFF9B59B6)]),
    _CalcDef(Icons.schedule_rounded, 'Time on Planets', 'Your age on other planets', [Color(0xFF00D4FF), Color(0xFF4A90D9)]),
    _CalcDef(Icons.thermostat_rounded, 'Temp Converter', 'Space temperature converter', [Color(0xFFFF6B35), Color(0xFFFF4D6A)]),
    _CalcDef(Icons.search_rounded, 'Telescope Calc', 'Magnification & visibility', [Color(0xFF00BFA5), Color(0xFF00D4FF)]),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _topBar(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _card(ctx, i, isDark),
                  childCount: _calcs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context), size: 26)),
          const SizedBox(width: 4),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Space Calculator', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
            Text('Powered by real physics', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))),
          ])),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, int i, bool isDark) {
    final c = _calcs[i];
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => _CalculatorSheet(index: i),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? null : AppColors.cardLight,
          gradient: isDark ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.surfaceDark, AppColors.cardDark.withValues(alpha: 0.9)]) : null,
          border: Border.all(color: c.colors[0].withValues(alpha: isDark ? 0.15 : 0.1)),
          boxShadow: isDark
              ? [BoxShadow(color: c.colors[0].withValues(alpha: 0.06), blurRadius: 20, spreadRadius: 1)]
              : [BoxShadow(color: c.colors[0].withValues(alpha: 0.15), blurRadius: 18, offset: const Offset(0, 6)),
                 BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: c.colors),
                boxShadow: [BoxShadow(color: c.colors[0].withValues(alpha: 0.3), blurRadius: 10)],
              ),
              child: Icon(c.icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.glass(context),
                border: Border.all(color: AppColors.glassBorder(context))),
              child: Icon(CupertinoIcons.arrow_right, size: 12, color: AppColors.textSecondary(context)),
            ),
          ]),
          const Spacer(),
          Text(c.name, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
          const SizedBox(height: 2),
          Text(c.desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * i))
     .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms, delay: Duration(milliseconds: 50 * i));
  }
}

class _CalcDef {
  final IconData icon;
  final String name, desc;
  final List<Color> colors;
  const _CalcDef(this.icon, this.name, this.desc, this.colors);
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
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  String _selBody = 'Earth';
  String _selBody2 = 'Mars';
  String _selUnit = 'light-years';
  bool _done = false;
  String _share = '';

  static const _grav = {'Mercury': 0.38, 'Venus': 0.91, 'Earth': 1.0, 'Moon': 0.166, 'Mars': 0.38, 'Jupiter': 2.34, 'Saturn': 0.93, 'Uranus': 0.92, 'Neptune': 1.12, 'Sun': 27.9};
  static const _esc = {'Earth': 11.2, 'Moon': 2.4, 'Mars': 5.0, 'Venus': 10.4, 'Jupiter': 59.5, 'Saturn': 35.5, 'Uranus': 21.3, 'Neptune': 23.5, 'Mercury': 4.3, 'Sun': 617.5};
  static const _dist = {'Mercury': 57.9, 'Venus': 108.2, 'Earth': 149.6, 'Mars': 227.9, 'Jupiter': 778.5, 'Saturn': 1434.0, 'Uranus': 2871.0, 'Neptune': 4495.0};
  static const _sizes = {'Sun': 109.0, 'Jupiter': 11.2, 'Saturn': 9.4, 'Uranus': 4.0, 'Neptune': 3.9, 'Earth': 1.0, 'Venus': 0.95, 'Mars': 0.53, 'Mercury': 0.38, 'Moon': 0.27};
  static const _orb = {'Mercury': 0.24, 'Venus': 0.62, 'Earth': 1.0, 'Mars': 1.88, 'Jupiter': 11.86, 'Saturn': 29.46, 'Uranus': 84.01, 'Neptune': 164.8};

  @override
  void dispose() { _c1.dispose(); _c2.dispose(); super.dispose(); }

  static const _titles = ['Weight on Planets', 'Light Travel Time', 'Escape Velocity', 'Planet Distance', 'Size Comparator', 'Time on Planets', 'Temp Converter', 'Telescope Calculator'];
  static const _icons = [Icons.scale_rounded, Icons.lightbulb_rounded, Icons.rocket_launch_rounded, Icons.public_rounded, Icons.straighten_rounded, Icons.schedule_rounded, Icons.thermostat_rounded, Icons.search_rounded];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary(context).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_icons[widget.index], color: AppColors.accentPurple, size: 24),
            const SizedBox(width: 10),
            Text(_titles[widget.index], style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
          ]),
          const SizedBox(height: 20),
          Flexible(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 0, 24, 34), child: _body())),
        ]),
      ),
    );
  }

  Widget _body() {
    switch (widget.index) {
      case 0: return _weight();
      case 1: return _light();
      case 2: return _escape();
      case 3: return _distance();
      case 4: return _size();
      case 5: return _time();
      case 6: return _temp();
      case 7: return _telescope();
      default: return const SizedBox.shrink();
    }
  }

  // ── shared ──
  Widget _input(String hint, TextEditingController c, {TextInputType type = TextInputType.number}) {
    return CupertinoTextField(
      controller: c, placeholder: hint, keyboardType: type,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: AppColors.searchBar(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.glassBorder(context))),
      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
      placeholderStyle: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary(context)),
    );
  }

  Widget _btn(String label, VoidCallback onTap) => SizedBox(width: double.infinity, height: 52, child: Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]),
      boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
    child: CupertinoButton(padding: EdgeInsets.zero, borderRadius: BorderRadius.circular(14), onPressed: onTap,
      child: Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
  ));

  Widget _result(List<Widget> children) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.glass(context), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.15)),
      boxShadow: AppColors.cardShadow(context)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);

  Widget _shareBtn() => _share.isEmpty ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 14), child: SizedBox(width: double.infinity, height: 44, child: CupertinoButton(
    padding: EdgeInsets.zero, borderRadius: BorderRadius.circular(12), onPressed: () => SharePlus.instance.share(ShareParams(text: _share)),
    child: Container(alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.glassBorder(context))),
      child: Text('Share Results', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentPurple))))));

  Widget _dd(String val, List<String> items, ValueChanged<String> cb) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppColors.searchBar(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.glassBorder(context))),
    child: DropdownButton<String>(value: val, isExpanded: true, underline: const SizedBox.shrink(), dropdownColor: AppColors.surface(context),
      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary(context)),
      icon: Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.textSecondary(context)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { if (v != null) cb(v); }),
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context))));

  // ── 1. Weight ──
  Widget _weight() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Enter your weight (kg)'), _input('e.g. 70', _c1), const SizedBox(height: 18),
      _btn('Calculate', () {
        if (double.tryParse(_c1.text) == null) return;
        final buf = StringBuffer('My weight across the solar system:\n');
        for (final e in _grav.entries) {
          buf.writeln('${e.key}: ${(double.parse(_c1.text) * e.value).toStringAsFixed(1)} kg');
        }
        _share = buf.toString();
        setState(() => _done = true);
      }),
      if (_done && double.tryParse(_c1.text) != null) ...[const SizedBox(height: 18), _result([
        ..._grav.entries.map((e) { final w = double.parse(_c1.text) * e.value; final maxW = double.parse(_c1.text) * 27.9; return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.key, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
            Text('${w.toStringAsFixed(1)} kg', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: (w / maxW).clamp(0.0, 1.0), minHeight: 6, backgroundColor: AppColors.divider(context),
            valueColor: AlwaysStoppedAnimation(e.value == 27.9 ? AppColors.starGold : AppColors.accentCyan))),
        ])); }),
      ]), _shareBtn()],
    ]);
  }

  // ── 2. Light ──
  Widget _light() {
    const c = 299792.458;
    const presets = {'To Moon': 384400.0, 'To Sun': 149597870.7, 'To Mars (avg)': 225000000.0, 'To Proxima Centauri': 4.0114e+13, 'Across Milky Way': 9.461e+17};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: _input('Distance', _c1)), const SizedBox(width: 8), SizedBox(width: 120, child: _dd(_selUnit, ['km', 'AU', 'light-years'], (v) => setState(() => _selUnit = v)))]),
      const SizedBox(height: 12), _label('Quick presets'),
      Wrap(spacing: 8, runSpacing: 8, children: presets.entries.map((e) => GestureDetector(onTap: () { _c1.text = e.value.toStringAsExponential(2); setState(() { _selUnit = 'km'; _done = false; }); },
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.glass(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.glassBorder(context))),
          child: Text(e.key, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentPurple))))).toList()),
      const SizedBox(height: 18), _btn('Calculate', () { if (double.tryParse(_c1.text) == null) return; setState(() => _done = true); }),
      if (_done && double.tryParse(_c1.text) != null) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final d = double.parse(_c1.text); double km; switch (_selUnit) { case 'AU': km = d * 149597870.7; break; case 'light-years': km = d * 9.461e+12; break; default: km = d; }
        final s = km / c; final y = (s / 31557600).floor(); final dy = ((s % 31557600) / 86400).floor(); final h = ((s % 86400) / 3600).floor(); final m = ((s % 3600) / 60).floor();
        String t;
        if (y > 0) { t = '$y years, $dy days'; }
        else if (dy > 0) { t = '$dy days, $h hours'; }
        else if (h > 0) { t = '$h hours, $m min'; }
        else if (m > 0) { t = '$m min, ${(s % 60).floor()} sec'; }
        else { t = '${s.toStringAsFixed(2)} seconds'; }
        _share = 'Light takes $t to travel ${_c1.text} $_selUnit!'; return _result([_label('Light travel time'), Text(t, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accentPurple)), const SizedBox(height: 6), Text('Distance: ${km.toStringAsExponential(3)} km', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary(context)))]);
      }), _shareBtn()],
    ]);
  }

  // ── 3. Escape ──
  Widget _escape() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Select a celestial body'), _dd(_selBody, _esc.keys.toList(), (v) => setState(() { _selBody = v; _done = true; })),
      const SizedBox(height: 18), _btn('Calculate', () => setState(() => _done = true)),
      if (_done) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final v = _esc[_selBody]!; final kmh = v * 3600; final bx = (v / 1.7).toStringAsFixed(1); final sx = (v / 0.343).toStringAsFixed(0);
        _share = 'Escape velocity from $_selBody: ${v.toStringAsFixed(1)} km/s ($bx\u00D7 faster than a bullet!)';
        return _result([_label('Escape velocity from $_selBody'), Text('${v.toStringAsFixed(1)} km/s', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accentCyan)),
          Text('${kmh.toStringAsFixed(0)} km/h', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))), const SizedBox(height: 10),
          Text('v = \u221A(2GM/r)', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary(context))), const SizedBox(height: 10),
          _compRow('$bx\u00D7 faster than a bullet (1.7 km/s)'), _compRow('$sx\u00D7 faster than sound (0.343 km/s)')]);
      }), _shareBtn()],
    ]);
  }

  Widget _compRow(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    Icon(CupertinoIcons.bolt_fill, size: 14, color: AppColors.starGold), const SizedBox(width: 8),
    Expanded(child: Text(t, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary(context))))]));

  // ── 4. Distance ──
  Widget _distance() {
    final planets = _dist.keys.toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Select two planets'), _dd(_selBody, planets, (v) => setState(() { _selBody = v; _done = false; })),
      const SizedBox(height: 8), _dd(_selBody2, planets, (v) => setState(() { _selBody2 = v; _done = false; })),
      const SizedBox(height: 18), _btn('Calculate', () { if (_selBody == _selBody2) return; setState(() => _done = true); }),
      if (_done && _selBody != _selBody2) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final d1 = _dist[_selBody]!; final d2 = _dist[_selBody2]!; final mn = (d2 - d1).abs(); final mx = d1 + d2; final av = (mn + mx) / 2;
        String tt(double dm, double sp) { final h = dm * 1e6 / sp; if (h < 24) return '${h.toStringAsFixed(1)} hours'; final d = h / 24; if (d < 365) return '${d.toStringAsFixed(0)} days'; return '${(d / 365.25).toStringAsFixed(1)} years'; }
        _share = 'Distance from $_selBody to $_selBody2: ${av.toStringAsFixed(0)}M km (avg)';
        return _result([Text('$_selBody \u2194 $_selBody2', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))), const SizedBox(height: 12),
          _dr('Closest', '${mn.toStringAsFixed(1)}M km'), _dr('Farthest', '${mx.toStringAsFixed(1)}M km'), _dr('Average', '${av.toStringAsFixed(1)}M km'),
          const SizedBox(height: 12), _label('Travel time (avg distance)'),
          _dr('Car (100 km/h)', tt(av, 100)), _dr('Airplane (900 km/h)', tt(av, 900)), _dr('Rocket (40K km/h)', tt(av, 40000)), _dr('Light', tt(av, 1.079e+9))]);
      }), _shareBtn()],
    ]);
  }

  Widget _dr(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context))),
    Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)))]));

  // ── 5. Size ──
  Widget _size() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Select a celestial body'), _dd(_selBody, _sizes.keys.toList(), (v) => setState(() { _selBody = v; _done = true; })),
      const SizedBox(height: 18), _btn('Compare', () => setState(() => _done = true)),
      if (_done) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final r = _sizes[_selBody]!; _share = '$_selBody is ${r}x the diameter of Earth!';
        return _result([Text('$_selBody vs Earth', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))), const SizedBox(height: 6),
          Text(r >= 1 ? '$_selBody is ${r}x wider than Earth' : '$_selBody is ${(r * 100).toStringAsFixed(0)}% the size of Earth', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))),
          const SizedBox(height: 16), SizedBox(height: 120, child: CustomPaint(size: const Size(double.infinity, 120), painter: _SizeP(ratio: r, name: _selBody, ec: AppColors.accentCyan, bc: AppColors.accentPurple, tc: AppColors.textPrimary(context)))),
          const SizedBox(height: 12), ..._sizes.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.key, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary(context), fontWeight: e.key == _selBody ? FontWeight.w700 : FontWeight.w400)),
            Text('${e.value}x Earth', style: GoogleFonts.inter(fontSize: 13, color: e.key == _selBody ? AppColors.accentPurple : AppColors.textSecondary(context), fontWeight: e.key == _selBody ? FontWeight.w700 : FontWeight.w400))])))]);
      }), _shareBtn()],
    ]);
  }

  // ── 6. Time ──
  Widget _time() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Enter your age in Earth years'), _input('e.g. 25', _c1), const SizedBox(height: 18),
      _btn('Calculate', () {
        if (double.tryParse(_c1.text) == null) return;
        final buf = StringBuffer('My age across the solar system:\n');
        for (final e in _orb.entries) {
          buf.writeln('${e.key}: ${(double.parse(_c1.text) / e.value).toStringAsFixed(2)} years');
        }
        _share = buf.toString();
        setState(() => _done = true);
      }),
      if (_done && double.tryParse(_c1.text) != null) ...[const SizedBox(height: 18), _result([
        ..._orb.entries.map((e) { final a = double.parse(_c1.text); final pa = a / e.value; return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(e.key, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
          Text('${pa.toStringAsFixed(2)} years', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: pa > a ? AppColors.accentCyan : AppColors.accentOrange))])); }),
        const SizedBox(height: 4), Text('Faster orbits = more birthdays!', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary(context))),
      ]), _shareBtn()],
    ]);
  }

  // ── 7. Temp ──
  Widget _temp() {
    const presets = {'Absolute Zero': -273.15, 'Deep Space': -270.0, 'Pluto Surface': -229.0, 'Mars Surface': -60.0, 'Earth Avg': 15.0, 'Venus Surface': 465.0, 'Sun Surface': 5500.0};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Enter temperature in \u00B0C'), _input('e.g. 100', _c1, type: const TextInputType.numberWithOptions(signed: true, decimal: true)),
      const SizedBox(height: 12), _label('Presets'),
      Wrap(spacing: 8, runSpacing: 8, children: presets.entries.map((e) => GestureDetector(onTap: () { _c1.text = e.value.toString(); setState(() => _done = true); },
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.glass(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.glassBorder(context))),
          child: Text(e.key, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentPurple))))).toList()),
      const SizedBox(height: 18), _btn('Convert', () { if (double.tryParse(_c1.text) == null) return; setState(() => _done = true); }),
      if (_done && double.tryParse(_c1.text) != null) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final ce = double.parse(_c1.text); final f = ce * 9 / 5 + 32; final k = ce + 273.15; _share = '${ce.toStringAsFixed(1)}\u00B0C = ${f.toStringAsFixed(1)}\u00B0F = ${k.toStringAsFixed(1)} K';
        return _result([_dr('Celsius', '${ce.toStringAsFixed(1)} \u00B0C'), _dr('Fahrenheit', '${f.toStringAsFixed(1)} \u00B0F'), _dr('Kelvin', '${k.toStringAsFixed(1)} K'), const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: ((ce + 273.15) / 6000).clamp(0.0, 1.0), minHeight: 10, backgroundColor: AppColors.divider(context),
            valueColor: AlwaysStoppedAnimation(ce < 0 ? AppColors.accentCyan : (ce < 100 ? AppColors.success : AppColors.error))))]);
      }), _shareBtn()],
    ]);
  }

  // ── 8. Telescope ──
  Widget _telescope() {
    const eps = [25.0, 10.0, 4.0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Telescope aperture (mm)'), _input('e.g. 200', _c1), const SizedBox(height: 12),
      _label('Focal length (mm)'), _input('e.g. 1200', _c2), const SizedBox(height: 18),
      _btn('Calculate', () { if (double.tryParse(_c1.text) == null || double.tryParse(_c2.text) == null) return; setState(() => _done = true); }),
      if (_done && double.tryParse(_c1.text) != null && double.tryParse(_c2.text) != null) ...[const SizedBox(height: 18), Builder(builder: (_) {
        final ap = double.parse(_c1.text); final fl = double.parse(_c2.text); final lgp = (ap / 7); final lgpSq = lgp * lgp; final lm = 2.7 + 5 * (log(ap) / ln10);
        _share = 'My telescope: ${ap.toStringAsFixed(0)}mm aperture, ${fl.toStringAsFixed(0)}mm FL. Light gathering: ${lgpSq.toStringAsFixed(0)}x naked eye!';
        return _result([Text('Telescope Performance', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))), const SizedBox(height: 12),
          _label('Magnification by eyepiece:'),
          ...eps.map((ep) { final mg = fl / ep; return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${ep.toStringAsFixed(0)}mm eyepiece', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary(context))),
            Text('${mg.toStringAsFixed(0)}x', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentCyan))])); }),
          const SizedBox(height: 10), _dr('Light gathering', '${lgpSq.toStringAsFixed(0)}\u00D7 naked eye'), _dr('Limiting magnitude', lm.toStringAsFixed(1)),
          const SizedBox(height: 10), _label('What you can see:'),
          _vis('Moon craters', ap >= 50), _vis('Jupiter\'s moons', ap >= 50), _vis('Saturn\'s rings', ap >= 70), _vis('Andromeda Galaxy', ap >= 50), _vis('Nebulae detail', ap >= 150), _vis('Galaxy structure', ap >= 200), _vis('Pluto', ap >= 250)]);
      }), _shareBtn()],
    ]);
  }

  Widget _vis(String t, bool ok) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
    Icon(ok ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle, size: 16, color: ok ? AppColors.success : AppColors.error),
    const SizedBox(width: 8), Text(t, style: GoogleFonts.inter(fontSize: 13, color: ok ? AppColors.textPrimary(context) : AppColors.textSecondary(context)))]));
}

class _SizeP extends CustomPainter {
  final double ratio; final String name; final Color ec, bc, tc;
  _SizeP({required this.ratio, required this.name, required this.ec, required this.bc, required this.tc});
  @override
  void paint(Canvas canvas, Size size) {
    final maxR = size.height / 2 - 14; final eR = ratio >= 1 ? (maxR / ratio).clamp(4.0, maxR) : maxR; final bR = ratio >= 1 ? maxR : (maxR * ratio).clamp(4.0, maxR);
    canvas.drawCircle(Offset(size.width * 0.3, size.height / 2), bR, Paint()..color = bc);
    canvas.drawCircle(Offset(size.width * 0.7, size.height / 2), eR, Paint()..color = ec);
    final t1 = TextPainter(text: TextSpan(text: name, style: TextStyle(color: tc, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    t1.paint(canvas, Offset(size.width * 0.3 - t1.width / 2, size.height - 12));
    final t2 = TextPainter(text: TextSpan(text: 'Earth', style: TextStyle(color: tc, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    t2.paint(canvas, Offset(size.width * 0.7 - t2.width / 2, size.height - 12));
  }
  @override
  bool shouldRepaint(covariant _SizeP o) => o.ratio != ratio || o.name != name;
}
