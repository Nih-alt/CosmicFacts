import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/learn_content.dart';
import '../../theme/app_colors.dart';
import 'topic_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Box _progressBox;
  bool _boxReady = false;

  static const _topicGlowColors = <Color>[
    Color(0xFF7B5BFF), // Black Holes — purple
    Color(0xFF00D4FF), // Galaxies — cyan
    Color(0xFFFFD700), // Stars — gold
    Color(0xFF4A90D9), // Planets — blue
    Color(0xFFB0B0C0), // Moons — silver
    Color(0xFFFF6B35), // Asteroids — orange
    Color(0xFF00BFA5), // Telescopes — teal
    Color(0xFFFF9933), // Space Exploration — saffron
    Color(0xFF00E096), // Earth — green
    Color(0xFF5B3FBF), // Dark Matter — deep purple
    Color(0xFFFF4D6A), // Big Bang — red
    Color(0xFFE040FB), // Exoplanets — pink
  ];

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _progressBox = await Hive.openBox('learn_progress');
    if (mounted) setState(() => _boxReady = true);
  }

  int _completedCount(TopicData topic) {
    if (!_boxReady) return 0;
    int count = 0;
    for (final lesson in topic.lessons) {
      if (_progressBox.get(lesson.id, defaultValue: false) == true) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ──
            SliverToBoxAdapter(child: _buildTopBar()),

            // ── Featured hero ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: _buildFeaturedCard(),
              ),
            ),

            // ── Section header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text(
                  'Topics',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ── Topics grid ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final topic = allTopics[index];
                    final glow = _topicGlowColors[index];
                    return _buildTopicCard(topic, glow, index);
                  },
                  childCount: allTopics.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deep dive into the cosmos',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: const Text('Bookmarks'),
                  content: const Text(
                      'Bookmarked lessons coming in a future update!'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // FEATURED CARD
  // ═══════════════════════════════════════

  Widget _buildFeaturedCard() {
    final blackHoles = allTopics[0];

    return GestureDetector(
      onTap: () => _openTopic(blackHoles),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A1060),
              const Color(0xFF0A0A30),
              AppColors.accentCyan.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            // Star dots
            ...List.generate(12, (i) {
              final rng = Random(i * 13);
              return Positioned(
                left: rng.nextDouble() * 360,
                top: rng.nextDouble() * 180,
                child: Container(
                  width: 1.5 + rng.nextDouble() * 1.5,
                  height: 1.5 + rng.nextDouble() * 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.2 + rng.nextDouble() * 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    blackHoles.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    blackHoles.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blackHoles.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'Start Learning \u2192',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════
  // TOPIC CARD
  // ═══════════════════════════════════════

  Widget _buildTopicCard(TopicData topic, Color glow, int index) {
    final completed = _completedCount(topic);
    final total = topic.lessons.length;
    final progress = total > 0 ? completed / total : 0.0;

    return GestureDetector(
      onTap: () => _openTopic(topic),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic.emoji, style: const TextStyle(fontSize: 36)),
              const Spacer(),
              Text(
                topic.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (completed > 0) ...[
                Text(
                  '$completed/$total completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(glow),
                  ),
                ),
              ] else
                Text(
                  '${topic.lessons.length} lessons',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 80 * index))
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 80 * index),
        );
  }

  // ═══════════════════════════════════════

  void _openTopic(TopicData topic) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
    );
    // Refresh progress when returning
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }
}
