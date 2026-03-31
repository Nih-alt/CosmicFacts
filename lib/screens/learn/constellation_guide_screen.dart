import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/constellation_data.dart';
import '../../theme/app_colors.dart';
import 'constellation_detail_screen.dart';

class ConstellationGuideScreen extends StatefulWidget {
  const ConstellationGuideScreen({super.key});

  @override
  State<ConstellationGuideScreen> createState() =>
      _ConstellationGuideScreenState();
}

class _ConstellationGuideScreenState extends State<ConstellationGuideScreen> {
  String _selectedSeason = 'All';
  String _selectedDifficulty = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();

  static const _seasons = ['All', 'Tonight', 'Winter', 'Spring', 'Summer', 'Autumn'];
  static const _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  String get _currentSeason {
    final m = DateTime.now().month;
    if (m >= 12 || m <= 2) return 'Winter';
    if (m <= 5) return 'Spring';
    if (m <= 8) return 'Summer';
    return 'Autumn';
  }

  List<Constellation> get _filtered {
    var list = allConstellations.toList();

    // Season filter
    if (_selectedSeason == 'Tonight') {
      final s = _currentSeason;
      list = list.where((c) => c.bestSeason == s || c.bestSeason == 'Year-round').toList();
    } else if (_selectedSeason != 'All') {
      list = list.where((c) => c.bestSeason == _selectedSeason || c.bestSeason == 'Year-round').toList();
    }

    // Difficulty filter
    if (_selectedDifficulty != 'All') {
      list = list.where((c) => c.difficulty == _selectedDifficulty).toList();
    }

    // Search
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.meaning.toLowerCase().contains(q) ||
          c.brightestStar.toLowerCase().contains(q) ||
          c.bestSeason.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildSeasonFilter()),
            SliverToBoxAdapter(child: _buildDifficultyFilter()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (filtered.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCard(filtered[i], i),
                    childCount: filtered.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow(context),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary(context), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Constellation Guide',
                    style: GoogleFonts.spaceGrotesk(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Navigate the night sky',
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${allConstellations.length}',
                style: GoogleFonts.spaceGrotesk(fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBlue)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.searchBar(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(CupertinoIcons.search, size: 18,
                color: AppColors.textSecondary(context)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.inter(fontSize: 14,
                    color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Search constellations...',
                  hintStyle: GoogleFonts.inter(fontSize: 14,
                      color: AppColors.textSecondary(context)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            if (_search.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _search = '');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(CupertinoIcons.xmark_circle_fill, size: 18,
                      color: AppColors.textSecondary(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════

  Widget _buildSeasonFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _seasons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = _seasons[i];
          final active = _selectedSeason == s;
          return GestureDetector(
            onTap: () => setState(() => _selectedSeason = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? _seasonColor(s)
                    : _isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: active ? null : Border.all(color: AppColors.glassBorder(context)),
                boxShadow: active
                    ? [BoxShadow(color: _seasonColor(s).withValues(alpha: 0.3),
                        blurRadius: 8, offset: const Offset(0, 2))]
                    : AppColors.cardShadow(context),
              ),
              child: Text(s,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _difficulties.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, i) {
            final d = _difficulties[i];
            final active = _selectedDifficulty == d;
            return GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? _difficultyColor(d).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active
                        ? _difficultyColor(d)
                        : AppColors.glassBorder(context),
                  ),
                ),
                child: Text(d,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                        color: active
                            ? _difficultyColor(d)
                            : AppColors.textSecondary(context))),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONSTELLATION CARD
  // ═══════════════════════════════════════

  Widget _buildCard(Constellation c, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => ConstellationDetailScreen(constellation: c)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Row(
            children: [
              // Star map preview
              SizedBox(
                width: 80, height: 80,
                child: CustomPaint(
                  painter: ConstellationMiniPainter(c),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: GoogleFonts.spaceGrotesk(fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context))),
                    Text(c.meaning,
                        style: GoogleFonts.inter(fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary(context))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6, runSpacing: 4,
                      children: [
                        _badge(c.bestSeason, _seasonColor(c.bestSeason)),
                        _badge(c.difficulty, _difficultyColor(c.difficulty)),
                        _badge(c.hemisphere, AppColors.accentCyan),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('\u2B50 ${c.brightestStar}',
                        style: GoogleFonts.inter(fontSize: 11,
                            color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right, size: 14,
                  color: AppColors.textSecondary(context)),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 30 * index))
        .slideY(begin: 0.05, end: 0, delay: Duration(milliseconds: 30 * index));
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('\u{1F52D}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No constellations found',
              style: GoogleFonts.spaceGrotesk(fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 4),
          Text('Try a different filter',
              style: GoogleFonts.inter(fontSize: 13,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════

  Color _seasonColor(String s) {
    switch (s) {
      case 'Winter': return const Color(0xFF4FC3F7);
      case 'Spring': return const Color(0xFF81C784);
      case 'Summer': return const Color(0xFFFFD54F);
      case 'Autumn': return const Color(0xFFFF8A65);
      case 'Tonight': return AppColors.accentBlue;
      case 'Year-round': return AppColors.accentCyan;
      default: return AppColors.accentBlue;
    }
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Easy': return AppColors.success;
      case 'Medium': return AppColors.accentOrange;
      case 'Hard': return AppColors.error;
      default: return AppColors.accentBlue;
    }
  }
}

// ═════════════════════════════════════════════
// MINI STAR MAP PAINTER
// ═════════════════════════════════════════════

class ConstellationMiniPainter extends CustomPainter {
  final Constellation constellation;
  const ConstellationMiniPainter(this.constellation);

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFF0A0A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      bgPaint,
    );

    final pad = 8.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    // Connections
    final linePaint = Paint()
      ..color = constellation.color.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final conn in constellation.connections) {
      final s1 = constellation.starPositions[conn[0]];
      final s2 = constellation.starPositions[conn[1]];
      canvas.drawLine(
        Offset(pad + s1[0] * w, pad + s1[1] * h),
        Offset(pad + s2[0] * w, pad + s2[1] * h),
        linePaint,
      );
    }

    // Stars
    final starPaint = Paint()..color = Colors.white;
    for (final pos in constellation.starPositions) {
      canvas.drawCircle(
        Offset(pad + pos[0] * w, pad + pos[1] * h),
        2.5,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationMiniPainter old) =>
      old.constellation.name != constellation.name;
}
