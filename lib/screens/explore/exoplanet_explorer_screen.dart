// DISCLAIMER: Data sourced from NASA Exoplanet Archive public API.
// This app is unofficial and not affiliated with NASA or Caltech.
// All planet visuals are custom-painted — no copyrighted imagery.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

// ─── Accent palette ───────────────────────────────────────────
const _kAccent = Color(0xFF6C63FF);
const _kGold = Color(0xFFFFB800);
const _kGreen = Color(0xFF00E676);
const _kHot = Color(0xFFFF5252);
const _kCold = Color(0xFF448AFF);
const _kCardDark = Color(0xFF141438);
const _kBgDark = Color(0xFF0A0A1A);

// ═══════════════════════════════════════════════════════════════
// PLANET TYPE CLASSIFIER
// ═══════════════════════════════════════════════════════════════

String _getPlanetType(double? radiusEarth) {
  if (radiusEarth == null) return 'Unknown';
  if (radiusEarth < 0.8) return 'Sub-Earth';
  if (radiusEarth <= 1.25) return 'Earth-like';
  if (radiusEarth <= 2.0) return 'Super Earth';
  if (radiusEarth <= 4.0) return 'Mini Neptune';
  if (radiusEarth <= 8.0) return 'Neptune-like';
  if (radiusEarth <= 15.0) return 'Gas Giant';
  return 'Hot Jupiter';
}

Color _getPlanetColor(String type) {
  switch (type) {
    case 'Earth-like':
      return const Color(0xFF00E676);
    case 'Super Earth':
      return const Color(0xFF69F0AE);
    case 'Sub-Earth':
      return const Color(0xFFB2FF59);
    case 'Mini Neptune':
      return const Color(0xFF40C4FF);
    case 'Neptune-like':
      return const Color(0xFF448AFF);
    case 'Gas Giant':
      return const Color(0xFFFFAB40);
    case 'Hot Jupiter':
      return const Color(0xFFFF5252);
    default:
      return const Color(0xFF9E9E9E);
  }
}

bool _isInHabitableZone(double? tempK) {
  if (tempK == null) return false;
  return tempK >= 200 && tempK <= 320;
}

String _getStarType(double? teff) {
  if (teff == null) return 'Unknown';
  if (teff < 4000) return 'Red Dwarf (M-type)';
  if (teff < 5200) return 'Orange Dwarf (K-type)';
  if (teff < 6000) return 'Sun-like (G-type)';
  if (teff < 7500) return 'Hot Star (F-type)';
  return 'Very Hot Star (A/B-type)';
}

String _getMethodExplanation(String? method) {
  switch (method) {
    case 'Transit':
      return 'Planet passed in front of its star, dimming the light';
    case 'Radial Velocity':
      return 'Star wobbled due to planet\'s gravitational pull';
    case 'Direct Imaging':
      return 'Planet photographed directly \u2014 extremely rare';
    case 'Microlensing':
      return 'Planet detected by bending starlight';
    default:
      return 'Detected via $method';
  }
}

String _getDistanceContext(double? dist) {
  if (dist == null) return '';
  if (dist < 5) return 'Our cosmic backyard \u2014 closest neighbor!';
  if (dist < 50) return 'Relatively nearby in galactic terms';
  if (dist < 500) return 'Within our stellar neighborhood';
  return 'Deep in the Milky Way';
}

Color _tempColor(double? tempK) {
  if (tempK == null) return const Color(0xFF9E9E9E);
  if (tempK >= 200 && tempK <= 320) return _kGreen;
  if (tempK > 320) return _kHot;
  return _kCold;
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PLANET PAINTER — 3D sphere with lighting, texture, rings
// ═══════════════════════════════════════════════════════════════

class PlanetPainter extends CustomPainter {
  final Color planetColor;
  final double radiusEarth;
  final bool hasAtmosphere;

  const PlanetPainter({
    required this.planetColor,
    required this.radiusEarth,
    this.hasAtmosphere = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.78;

    // Step 1 — Atmosphere glow for habitable zone planets
    if (hasAtmosphere) {
      for (double i = 3; i >= 1; i--) {
        final glowPaint = Paint()
          ..color = planetColor.withValues(alpha: 0.06 * i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * i);
        canvas.drawCircle(center, radius + (6 * i), glowPaint);
      }
    }

    // Step 2 — Planet base with radial gradient (3D sphere look)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: [
          Color.lerp(planetColor, Colors.white, 0.45)!,
          planetColor,
          Color.lerp(planetColor, Colors.black, 0.55)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, spherePaint);

    // Step 3 — Surface texture lines (subtle)
    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (double dy = -radius * 0.6; dy < radius * 0.6; dy += radius * 0.22) {
      final sweepWidth = (radius * radius - dy * dy) > 0
          ? (radius * 0.9) * (1 - (dy / radius).abs() * 0.5)
          : 0.0;
      canvas.drawLine(
        Offset(center.dx - sweepWidth, center.dy + dy),
        Offset(center.dx + sweepWidth, center.dy + dy),
        texturePaint,
      );
    }

    // Step 4 — Specular highlight (top-left glint)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.5,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, highlightPaint);

    // Step 5 — Dark limb edge (shadow side)
    final limbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.5),
        radius: 0.65,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, limbPaint);

    // Step 6 — Ring system for Gas Giants and Hot Jupiters
    if (radiusEarth > 8.0) {
      // Ring shadow behind planet
      final ringShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.18;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.08),
          width: radius * 2.9,
          height: radius * 0.55,
        ),
        ringShadowPaint,
      );
      // Ring front
      final ringPaint = Paint()
        ..color = planetColor.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.14;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.9,
          height: radius * 0.52,
        ),
        ringPaint,
      );
      // Ring inner line
      final ringInnerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.4,
          height: radius * 0.44,
        ),
        ringInnerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PlanetPainter oldDelegate) =>
      oldDelegate.planetColor != planetColor ||
      oldDelegate.radiusEarth != radiusEarth ||
      oldDelegate.hasAtmosphere != hasAtmosphere;
}

// ═══════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════

class ExoplanetExplorerScreen extends StatefulWidget {
  const ExoplanetExplorerScreen({super.key});

  @override
  State<ExoplanetExplorerScreen> createState() =>
      _ExoplanetExplorerScreenState();
}

class _ExoplanetExplorerScreenState extends State<ExoplanetExplorerScreen> {
  List<Map<String, dynamic>> _allPlanets = [];
  List<Map<String, dynamic>> _filteredPlanets = [];
  bool _isLoading = true;
  String _selectedType = 'All';
  String _selectedMethod = 'All';
  String _sortBy = 'recent';
  String? _expandedPlanet;
  final TextEditingController _searchCtrl = TextEditingController();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _typeFilters = [
    'All',
    'Earth-like',
    'Super Earth',
    'Mini Neptune',
    'Neptune-like',
    'Gas Giant',
    'Hot Jupiter',
  ];

  static const _methodFilters = [
    'All',
    'Transit',
    'Radial Velocity',
    'Direct Imaging',
    'Microlensing',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlanets();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlanets() async {
    final data = await ApiService.getExoplanets();
    if (!mounted) return;
    setState(() {
      _allPlanets = data;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<Map<String, dynamic>>.from(_allPlanets);
    final q = _searchCtrl.text.toLowerCase();

    // search
    if (q.isNotEmpty) {
      list = list.where((p) {
        final name = (p['pl_name'] as String? ?? '').toLowerCase();
        final host = (p['hostname'] as String? ?? '').toLowerCase();
        return name.contains(q) || host.contains(q);
      }).toList();
    }

    // type filter
    if (_selectedType != 'All') {
      list = list.where((p) {
        final r = (p['pl_rade'] as num?)?.toDouble();
        return _getPlanetType(r) == _selectedType;
      }).toList();
    }

    // method filter
    if (_selectedMethod != 'All') {
      list = list
          .where((p) => p['discoverymethod'] == _selectedMethod)
          .toList();
    }

    // sort
    switch (_sortBy) {
      case 'earthlike':
        list.sort((a, b) {
          final ra = ((a['pl_rade'] as num?)?.toDouble() ?? 99) - 1.0;
          final rb = ((b['pl_rade'] as num?)?.toDouble() ?? 99) - 1.0;
          return ra.abs().compareTo(rb.abs());
        });
      case 'closest':
        list.sort((a, b) {
          final da = (a['sy_dist'] as num?)?.toDouble() ?? 1e9;
          final db = (b['sy_dist'] as num?)?.toDouble() ?? 1e9;
          return da.compareTo(db);
        });
      case 'largest':
        list.sort((a, b) {
          final ra = (a['pl_rade'] as num?)?.toDouble() ?? 0;
          final rb = (b['pl_rade'] as num?)?.toDouble() ?? 0;
          return rb.compareTo(ra);
        });
      case 'hottest':
        list.sort((a, b) {
          final ta = (a['pl_eqt'] as num?)?.toDouble() ?? 0;
          final tb = (b['pl_eqt'] as num?)?.toDouble() ?? 0;
          return tb.compareTo(ta);
        });
      case 'recent':
        list.sort((a, b) {
          final ya = (a['disc_year'] as num?)?.toInt() ?? 0;
          final yb = (b['disc_year'] as num?)?.toInt() ?? 0;
          return yb.compareTo(ya);
        });
    }

    if (mounted) setState(() => _filteredPlanets = list);
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? _kBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _buildTypeFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildMethodFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildHeroCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (_isLoading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_filteredPlanets.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _buildPlanetCard(_filteredPlanets[i], i),
                    childCount: _filteredPlanets.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
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
                Text('Exoplanet Explorer',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Confirmed worlds beyond our solar system',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 4),
                Text('Data: NASA Exoplanet Archive',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textTertiary(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _kAccent.withValues(alpha: 0.15),
                ),
                child: Text('5,000+ known',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kAccent)),
              ),
              const SizedBox(height: 6),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showSortSheet,
                child: Icon(CupertinoIcons.sort_down,
                    color: AppColors.textPrimary(context), size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          hintText: 'Search by planet or star name...',
          hintStyle: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textTertiary(context)),
          prefixIcon:
              Icon(Icons.search, color: AppColors.textTertiary(context)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilters();
                  },
                  child: Icon(CupertinoIcons.clear_circled_solid,
                      color: AppColors.textTertiary(context), size: 18),
                )
              : null,
          filled: true,
          fillColor: _isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER PILLS
  // ═══════════════════════════════════════════════════════════

  Widget _buildTypeFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _typeFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = _typeFilters[i];
          final selected = t == _selectedType;
          final color = t == 'All' ? _kAccent : _getPlanetColor(t);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = t);
              _applyFilters();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? color
                      : (_isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t != 'All') ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : color,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(t,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary(context))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodFilters() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _methodFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final m = _methodFilters[i];
          final selected = m == _selectedMethod;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedMethod = m);
              _applyFilters();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: selected
                    ? _kAccent.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? _kAccent
                      : (_isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                ),
              ),
              child: Text(m,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? _kAccent
                          : AppColors.textTertiary(context))),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HERO CARD — Kepler-452b
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), _kBgDark],
          ),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Planet visual
            SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: PlanetPainter(
                  planetColor: _kGreen,
                  radiusEarth: 1.63,
                  hasAtmosphere: true,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('MOST EARTH-LIKE',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: _kGold)),
                      const Spacer(),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGreen,
                          boxShadow: [
                            BoxShadow(
                              color: _kGreen.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text('HABITABLE ZONE',
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _kGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Kepler-452b',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('430 light years away',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kGold)),
                  const SizedBox(height: 4),
                  Text('385-day year \u2022 5\u00d7 Earth mass',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 2),
                  Text(
                      '\u{1F321}\u{FE0F} 265 K (-8\u00b0C) \u2014 possibly liquid water',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6))),
                  const SizedBox(height: 2),
                  Text('Discovered 2015 via Transit',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45))),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // PLANET CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildPlanetCard(Map<String, dynamic> p, int index) {
    final name = p['pl_name'] as String? ?? 'Unknown';
    final host = p['hostname'] as String? ?? '';
    final radius = (p['pl_rade'] as num?)?.toDouble();
    final tempK = (p['pl_eqt'] as num?)?.toDouble();
    final dist = (p['sy_dist'] as num?)?.toDouble();
    final type = _getPlanetType(radius);
    final color = _getPlanetColor(type);
    final habitable = _isInHabitableZone(tempK);
    final isExpanded = _expandedPlanet == name;

    // planet visual size: scale 24px (Sub-Earth) → 56px (Hot Jupiter)
    final planetDisplaySize = (radius ?? 1.0).clamp(0.3, 15.0);
    final iconSize = (24 + (planetDisplaySize / 15.0) * 32).clamp(24.0, 56.0);

    return GestureDetector(
      onTap: () =>
          setState(() => _expandedPlanet = isExpanded ? null : name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isDark ? _kCardDark : Colors.white,
          boxShadow: _isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isExpanded
                ? color.withValues(alpha: 0.35)
                : (_isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04)),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Planet visual
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Center(
                    child: CustomPaint(
                      size: Size(iconSize, iconSize),
                      painter: PlanetPainter(
                        planetColor: color,
                        radiusEarth: planetDisplaySize,
                        hasAtmosphere: habitable,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context))),
                      const SizedBox(height: 2),
                      Text(host,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary(context))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: color.withValues(alpha: 0.15),
                            ),
                            child: Text(type,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                          ),
                          if (dist != null) ...[
                            const SizedBox(width: 8),
                            Text('${dist.toStringAsFixed(1)} ly',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color:
                                        AppColors.textTertiary(context))),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (habitable)
                      Text('\u{1F33F}', style: const TextStyle(fontSize: 16)),
                    if (tempK != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${tempK.toStringAsFixed(0)} K',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _tempColor(tempK))),
                      ),
                    const SizedBox(height: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(CupertinoIcons.chevron_right,
                          size: 14,
                          color: AppColors.textTertiary(context)),
                    ),
                  ],
                ),
              ],
            ),

            // Expanded
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expandedPlanet == name
                  ? _buildPlanetDetail(p)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
        duration: 350.ms, delay: Duration(milliseconds: 35 * index));
  }

  // ═══════════════════════════════════════════════════════════
  // PLANET DETAIL (EXPANDED)
  // ═══════════════════════════════════════════════════════════

  Widget _buildPlanetDetail(Map<String, dynamic> p) {
    final radius = (p['pl_rade'] as num?)?.toDouble();
    final mass = (p['pl_bmasse'] as num?)?.toDouble();
    final period = (p['pl_orbper'] as num?)?.toDouble();
    final tempK = (p['pl_eqt'] as num?)?.toDouble();
    final dist = (p['sy_dist'] as num?)?.toDouble();
    final starTemp = (p['st_teff'] as num?)?.toDouble();
    final host = p['hostname'] as String? ?? '';
    final method = p['discoverymethod'] as String?;
    final year = (p['disc_year'] as num?)?.toInt();
    final pnum = (p['sy_pnum'] as num?)?.toInt();
    final type = _getPlanetType(radius);
    final color = _getPlanetColor(type);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. STATS ROW
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (radius != null)
                _statChip('\u{1FA90} Radius: ${radius.toStringAsFixed(2)}\u00d7 Earth'),
              if (mass != null)
                _statChip(mass > 50
                    ? '\u{2696}\u{FE0F} Mass: ${(mass / 317.8).toStringAsFixed(1)}\u00d7 Jupiter'
                    : '\u{2696}\u{FE0F} Mass: ${mass.toStringAsFixed(1)}\u00d7 Earth'),
              if (period != null)
                _statChip('\u{1F4C5} Year: ${period.toStringAsFixed(1)} days'),
              if (tempK != null)
                _statChip('\u{1F321}\u{FE0F} Temp: ${tempK.toStringAsFixed(0)} K'),
            ],
          ),
          const SizedBox(height: 16),

          // 2. SIZE COMPARISON BAR
          _buildSizeComparison(p, radius, color),
          const SizedBox(height: 16),

          // 3. STAR INFO CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border.all(
                color: _isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\u{2B50} Host Star: $host',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                const SizedBox(height: 6),
                if (starTemp != null) ...[
                  Row(
                    children: [
                      Text('${starTemp.toStringAsFixed(0)} K',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: starTemp > 6000
                                  ? const Color(0xFF40C4FF)
                                  : (starTemp < 4000
                                      ? _kHot
                                      : _kGold))),
                      const SizedBox(width: 8),
                      Text(_getStarType(starTemp),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary(context))),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (pnum != null)
                  Text('$pnum known planet${pnum == 1 ? '' : 's'} in system',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. DISCOVERY INFO
          Row(
            children: [
              if (year != null) ...[
                Icon(CupertinoIcons.search,
                    size: 13, color: AppColors.textTertiary(context)),
                const SizedBox(width: 4),
                Text('Discovered $year',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary(context))),
                const SizedBox(width: 14),
              ],
              if (method != null) ...[
                Icon(CupertinoIcons.antenna_radiowaves_left_right,
                    size: 13, color: AppColors.textTertiary(context)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('Method: $method',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context))),
                ),
              ],
            ],
          ),
          if (method != null) ...[
            const SizedBox(height: 4),
            Text(_getMethodExplanation(method),
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textTertiary(context))),
          ],
          const SizedBox(height: 14),

          // 5. HABITABLE ZONE STATUS
          _buildHabitableStatus(tempK),
          const SizedBox(height: 12),

          // 6. DISTANCE CONTEXT
          if (dist != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\u{1F4E1} ',
                    style: const TextStyle(fontSize: 13)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dist.toStringAsFixed(1)} light years away',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context))),
                      Text(_getDistanceContext(dist),
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textTertiary(context))),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xFF1E1E3F)
            : const Color(0xFFEEEEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimary(context))),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SIZE COMPARISON
  // ═══════════════════════════════════════════════════════════

  Widget _buildSizeComparison(
      Map<String, dynamic> p, double? radius, Color color) {
    final r = radius ?? 1.0;
    final name = p['pl_name'] as String? ?? '?';
    // Earth = 1, Jupiter = 11.2 in Earth radii
    const jupiterR = 11.2;
    final scale = r.clamp(0.3, jupiterR);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size Comparison',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context))),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barW = constraints.maxWidth;
              // Positions (Earth at 0, Jupiter at end)
              final earthPos = 0.0;
              final jupiterPos = barW - 40;
              final planetFraction = (scale / jupiterR).clamp(0.0, 1.0);
              final planetPos =
                  earthPos + planetFraction * (jupiterPos - earthPos);
              // Dot sizes
              const earthDot = 12.0;
              final planetDot =
                  (r / jupiterR).clamp(0.15, 1.0) * 40;
              const jupiterDot = 40.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bar track
                  Positioned(
                    top: 23,
                    left: 6,
                    right: 20,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Earth
                  Positioned(
                    top: 24 - earthDot / 2,
                    left: earthPos,
                    child: Column(
                      children: [
                        Container(
                          width: earthDot,
                          height: earthDot,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF448AFF),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text('Earth',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                color:
                                    AppColors.textTertiary(context))),
                      ],
                    ),
                  ),
                  // This planet
                  Positioned(
                    top: 24 - planetDot / 2,
                    left: planetPos - planetDot / 2 + 6,
                    child: Column(
                      children: [
                        Container(
                          width: planetDot,
                          height: planetDot,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Jupiter
                  Positioned(
                    top: 24 - jupiterDot / 2,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: jupiterDot,
                          height: jupiterDot,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFAB40)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Labels below
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Earth (1\u00d7)',
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppColors.textTertiary(context))),
            Text(name,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color)),
            Text('Jupiter (11\u00d7)',
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppColors.textTertiary(context))),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HABITABLE ZONE STATUS
  // ═══════════════════════════════════════════════════════════

  Widget _buildHabitableStatus(double? tempK) {
    final String icon;
    final String title;
    final String desc;
    final Color borderColor;

    if (_isInHabitableZone(tempK)) {
      icon = '\u{1F33F}';
      title = 'Possibly in Habitable Zone';
      desc =
          'Temperature range suggests liquid water could exist on the surface';
      borderColor = _kGreen;
    } else if (tempK != null && tempK > 320) {
      icon = '\u{1F525}';
      title = 'Too Hot for Liquid Water';
      desc = 'Surface temperature exceeds Earth\'s habitable range';
      borderColor = _kHot;
    } else {
      icon = '\u{2744}\u{FE0F}';
      title = 'Too Cold for Liquid Water';
      desc = 'Planet lies beyond the star\'s habitable zone';
      borderColor = _kCold;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: borderColor.withValues(alpha: _isDark ? 0.08 : 0.05),
        border:
            Border.all(color: borderColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon $title',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: borderColor)),
          const SizedBox(height: 4),
          Text(desc,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SHIMMER LOADING
  // ═══════════════════════════════════════════════════════════

  Widget _buildShimmer() {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Text('\u{1FA90}', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No planets match this filter',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textTertiary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SORT BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════

  void _showSortSheet() {
    final options = [
      ('earthlike', 'Most Earth-like', CupertinoIcons.globe),
      ('closest', 'Closest to us', CupertinoIcons.location),
      ('largest', 'Largest first', CupertinoIcons.arrow_up_right_circle),
      ('hottest', 'Hottest first', CupertinoIcons.flame),
      ('recent', 'Most recently discovered', CupertinoIcons.calendar),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          decoration: BoxDecoration(
            color: _isDark ? _kCardDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Sort exoplanets by',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _isDark
                          ? Colors.white
                          : const Color(0xFF0A1628))),
              const SizedBox(height: 16),
              ...options.map((o) {
                final selected = _sortBy == o.$1;
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() => _sortBy = o.$1);
                    _applyFilters();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? _kAccent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? _kAccent.withValues(alpha: 0.3)
                            : (_isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black
                                    .withValues(alpha: 0.06)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(o.$3,
                            size: 18,
                            color: selected
                                ? _kAccent
                                : (_isDark
                                    ? Colors.white
                                        .withValues(alpha: 0.5)
                                    : const Color(0xFF5A7A9A))),
                        const SizedBox(width: 12),
                        Text(o.$2,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? _kAccent
                                    : (_isDark
                                        ? Colors.white
                                        : const Color(
                                            0xFF0A1628)))),
                        const Spacer(),
                        if (selected)
                          Icon(CupertinoIcons.checkmark_alt,
                              size: 18, color: _kAccent),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
