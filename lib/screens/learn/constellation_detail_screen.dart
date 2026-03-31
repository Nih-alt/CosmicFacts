import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/bookmark_controller.dart';
import '../../data/constellation_data.dart';
import '../../models/bookmark_model.dart';
import '../../theme/app_colors.dart';

class ConstellationDetailScreen extends StatefulWidget {
  final Constellation constellation;
  const ConstellationDetailScreen({super.key, required this.constellation});

  @override
  State<ConstellationDetailScreen> createState() =>
      _ConstellationDetailScreenState();
}

class _ConstellationDetailScreenState extends State<ConstellationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  Constellation get c => widget.constellation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 * c.starCount + 500),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: _buildStarMap(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildQuickFacts(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildMythology(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildHowToFind(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildFunFact(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildRelated(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildActionButtons(),
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
                Text(c.name,
                    style: GoogleFonts.spaceGrotesk(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text(c.meaning,
                    style: GoogleFonts.inter(fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // STAR MAP (animated, always dark)
  // ═══════════════════════════════════════

  Widget _buildStarMap() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarMapPainter(
                constellation: c,
                progress: _animCtrl.value,
              ),
              size: const Size(double.infinity, 300),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  // ═══════════════════════════════════════
  // QUICK FACTS
  // ═══════════════════════════════════════

  Widget _buildQuickFacts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Facts',
              style: GoogleFonts.spaceGrotesk(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 12),
          _factRow('Latin Name', c.latinName),
          _factRow('Meaning', c.meaning),
          _factRow('Brightest Star', '\u2B50 ${c.brightestStar}'),
          _factRow('Stars in Pattern', '${c.starCount} main stars'),
          _factRow('Best Season', c.bestSeason),
          _factRow('Hemisphere', c.hemisphere),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: Text('Difficulty',
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _difficultyColor(c.difficulty).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(c.difficulty,
                    style: GoogleFonts.inter(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _difficultyColor(c.difficulty))),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, delay: 100.ms);
  }

  Widget _factRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 13,
                    color: AppColors.textSecondary(context))),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context))),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // MYTHOLOGY
  // ═══════════════════════════════════════

  Widget _buildMythology() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark
            ? c.color.withValues(alpha: 0.06)
            : c.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.color.withValues(alpha: 0.15)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F4DC}', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Mythology',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.mythology,
              style: GoogleFonts.inter(fontSize: 15,
                  color: AppColors.textPrimary(context).withValues(alpha: 0.85),
                  height: 1.7)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, delay: 200.ms);
  }

  // ═══════════════════════════════════════
  // HOW TO FIND
  // ═══════════════════════════════════════

  Widget _buildHowToFind() {
    final tips = <String>[
      'Best viewed during ${c.bestSeason.toLowerCase()} evenings.',
      'Look toward the ${c.hemisphere.toLowerCase()} sky.',
      'Difficulty: ${c.difficulty} to find.',
    ];
    if (c.difficulty == 'Easy') {
      tips.add('One of the easiest to spot \u2014 look for its distinctive shape!');
    }
    if (c.brightestStar.isNotEmpty) {
      tips.add('Use ${c.brightestStar} as your anchor star.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F52D}', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('How to Find',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\u2022 ',
                        style: GoogleFonts.inter(fontSize: 14,
                            color: c.color, fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(t,
                          style: GoogleFonts.inter(fontSize: 14,
                              color: AppColors.textPrimary(context)
                                  .withValues(alpha: 0.85),
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.05, end: 0, delay: 300.ms);
  }

  // ═══════════════════════════════════════
  // FUN FACT
  // ═══════════════════════════════════════

  Widget _buildFunFact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            c.color.withValues(alpha: _isDark ? 0.12 : 0.08),
            AppColors.accentBlue.withValues(alpha: _isDark ? 0.08 : 0.04),
          ],
        ),
        border: Border.all(color: c.color.withValues(alpha: 0.2)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F4A1}', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Fun Fact',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 10),
          Text(c.funFact,
              style: GoogleFonts.inter(fontSize: 14,
                  color: AppColors.textPrimary(context).withValues(alpha: 0.85),
                  height: 1.6)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 400.ms);
  }

  // ═══════════════════════════════════════
  // RELATED CONSTELLATIONS
  // ═══════════════════════════════════════

  Widget _buildRelated() {
    final related = allConstellations
        .where((r) =>
            r.name != c.name &&
            (r.bestSeason == c.bestSeason || r.bestSeason == 'Year-round'))
        .take(4)
        .toList();
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nearby in the Sky',
            style: GoogleFonts.spaceGrotesk(fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context))),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: related.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final r = related[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                      builder: (_) => ConstellationDetailScreen(constellation: r)),
                ),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder(context)),
                    boxShadow: AppColors.cardShadow(context),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 56, height: 56,
                        child: CustomPaint(
                          painter: _ConstellationMiniPainterImported(r),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(r.name,
                          style: GoogleFonts.spaceGrotesk(fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(r.bestSeason,
                          style: GoogleFonts.inter(fontSize: 10,
                              color: AppColors.textSecondary(context))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  // ═══════════════════════════════════════
  // ACTION BUTTONS
  // ═══════════════════════════════════════

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _share,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.25),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.share, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Share',
                      style: GoogleFonts.inter(fontSize: 14,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _bookmark,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.glass(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder(context)),
            ),
            child: Icon(CupertinoIcons.bookmark, size: 18,
                color: AppColors.textPrimary(context)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  void _share() {
    try {
      SharePlus.instance.share(ShareParams(
        text: '\u{1F320} ${c.name} \u2014 ${c.meaning}\n\n'
            '${c.funFact}\n\n'
            'Explore more on Cosmic Facts \u{1F30C}',
      ));
    } catch (_) {}
  }

  void _bookmark() {
    final bm = BookmarkModel(
      id: 'constellation_${c.latinName}',
      type: 'glossary',
      title: '${c.name} \u2014 ${c.meaning}',
      subtitle: c.bestSeason,
      savedAt: DateTime.now(),
    );
    Get.find<BookmarkController>().toggleBookmark(bm);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark toggled!',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.surface(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
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
// ANIMATED STAR MAP PAINTER
// ═════════════════════════════════════════════

class _StarMapPainter extends CustomPainter {
  final Constellation constellation;
  final double progress; // 0.0 to 1.0

  const _StarMapPainter({required this.constellation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFF050520);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      bgPaint,
    );

    // Background stars
    final bgStarPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final seed = constellation.name.hashCode;
    for (int i = 0; i < 30; i++) {
      final x = ((seed + i * 7) % 100) / 100 * size.width;
      final y = ((seed + i * 13) % 100) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), 0.8, bgStarPaint);
    }

    final pad = 20.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final totalStars = constellation.starCount;

    // Phase: stars appear first, then lines
    final starPhaseEnd = totalStars / (totalStars + constellation.connections.length + 2);
    final linePhaseStart = starPhaseEnd * 0.5; // overlap a bit

    // Draw connections (lines)
    if (progress > linePhaseStart) {
      final lineProgress =
          ((progress - linePhaseStart) / (1.0 - linePhaseStart)).clamp(0.0, 1.0);
      final totalConns = constellation.connections.length;

      for (int i = 0; i < totalConns; i++) {
        final connProgress =
            ((lineProgress * totalConns - i)).clamp(0.0, 1.0);
        if (connProgress <= 0) continue;

        final conn = constellation.connections[i];
        final s1 = constellation.starPositions[conn[0]];
        final s2 = constellation.starPositions[conn[1]];
        final from = Offset(pad + s1[0] * w, pad + s1[1] * h);
        final to = Offset(pad + s2[0] * w, pad + s2[1] * h);
        final current = Offset.lerp(from, to, connProgress)!;

        final linePaint = Paint()
          ..color = constellation.color.withValues(alpha: 0.6 * connProgress)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;
        canvas.drawLine(from, current, linePaint);
      }
    }

    // Draw stars
    for (int i = 0; i < constellation.starPositions.length; i++) {
      final starProgress =
          ((progress * (totalStars + 2) - i)).clamp(0.0, 1.0);
      if (starProgress <= 0) continue;

      final pos = constellation.starPositions[i];
      final center = Offset(pad + pos[0] * w, pad + pos[1] * h);
      final radius = 4.0 * starProgress;

      // Glow
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15 * starProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, 8 * starProgress, glowPaint);

      // Star
      final starPaint = Paint()..color = Colors.white.withValues(alpha: starProgress);
      canvas.drawCircle(center, radius, starPaint);
    }

    // Constellation name
    if (progress > 0.8) {
      final nameOpacity = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: constellation.name,
          style: TextStyle(
            color: constellation.color.withValues(alpha: nameOpacity * 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          size.height - 28,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarMapPainter old) =>
      old.progress != progress;
}

// ═════════════════════════════════════════════
// MINI PAINTER (reuse pattern from guide screen)
// ═════════════════════════════════════════════

class _ConstellationMiniPainterImported extends CustomPainter {
  final Constellation constellation;
  const _ConstellationMiniPainterImported(this.constellation);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0A0A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ),
      bgPaint,
    );

    final pad = 6.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final linePaint = Paint()
      ..color = constellation.color.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
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

    final starPaint = Paint()..color = Colors.white;
    for (final pos in constellation.starPositions) {
      canvas.drawCircle(
        Offset(pad + pos[0] * w, pad + pos[1] * h),
        2,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationMiniPainterImported old) =>
      old.constellation.name != constellation.name;
}
