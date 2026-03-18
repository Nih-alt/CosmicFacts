import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/learn_content.dart';
import '../../theme/app_colors.dart';
import 'lesson_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final TopicData topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late Box _progressBox;
  bool _boxReady = false;

  TopicData get topic => widget.topic;

  static const _topicColors = <String, Color>{
    'black_holes': Color(0xFF7B5BFF),
    'galaxies': Color(0xFF00D4FF),
    'stars': Color(0xFFFFD700),
    'planets': Color(0xFF4A90D9),
    'moons': Color(0xFFB0B0C0),
    'asteroids_comets': Color(0xFFFF6B35),
    'telescopes': Color(0xFF00BFA5),
    'exploration': Color(0xFFFF9933),
    'earth': Color(0xFF00E096),
    'dark_matter': Color(0xFF5B3FBF),
    'big_bang': Color(0xFFFF4D6A),
    'exoplanets': Color(0xFFE040FB),
  };

  Color get _topicColor => _topicColors[topic.id] ?? AppColors.accentPurple;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _progressBox = await Hive.openBox('learn_progress');
    if (mounted) setState(() => _boxReady = true);
  }

  bool _isCompleted(String lessonId) {
    if (!_boxReady) return false;
    return _progressBox.get(lessonId, defaultValue: false) == true;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero area ──
          SliverToBoxAdapter(
            child: _buildHero(topPad, screenWidth),
          ),

          // ── Lesson list ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildLessonCard(index).animate().fadeIn(
                          duration: 350.ms,
                          delay: Duration(milliseconds: 60 * index),
                        ),
                childCount: topic.lessons.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════

  Widget _buildHero(double topPad, double screenWidth) {
    const heroHeight = 200.0;

    return Container(
      height: heroHeight + topPad,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _topicColor.withValues(alpha: 0.4),
            _topicColor.withValues(alpha: 0.1),
            AppColors.background(context),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Stars
          ...List.generate(15, (i) {
            final starRng = Random(i * 11 + topic.id.hashCode);
            return Positioned(
              left: starRng.nextDouble() * screenWidth,
              top: starRng.nextDouble() * (heroHeight + topPad),
              child: Container(
                width: 1.5 + starRng.nextDouble() * 2,
                height: 1.5 + starRng.nextDouble() * 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                      alpha: 0.2 + starRng.nextDouble() * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // Content
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              children: [
                Text(topic.emoji, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                Text(
                  topic.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${topic.lessons.length} lessons',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: topPad + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // LESSON CARD
  // ═══════════════════════════════════════

  Widget _buildLessonCard(int index) {
    final lesson = topic.lessons[index];
    final done = _isCompleted(lesson.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => LessonScreen(
              topic: topic,
              lessonIndex: index,
            ),
          ),
        );
        // Refresh after returning
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Row(
          children: [
            // Lesson number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.success.withValues(alpha: 0.2)
                    : _topicColor.withValues(alpha: 0.15),
                border: Border.all(
                  color: done
                      ? AppColors.success.withValues(alpha: 0.5)
                      : _topicColor.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: done
                    ? Icon(Icons.check_rounded,
                        size: 18,
                        color: AppColors.success)
                    : Text(
                        '${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _topicColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            // Reading time
            Text(
              '${lesson.readingMinutes} min',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
