import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/learn_content.dart';
import '../../theme/app_colors.dart';

class LessonScreen extends StatefulWidget {
  final TopicData topic;
  final int lessonIndex;

  const LessonScreen({
    super.key,
    required this.topic,
    required this.lessonIndex,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Box _progressBox;
  bool _boxReady = false;

  TopicData get topic => widget.topic;
  LessonData get lesson => topic.lessons[widget.lessonIndex];
  bool get _hasNext => widget.lessonIndex < topic.lessons.length - 1;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _progressBox = await Hive.openBox('learn_progress');
    if (mounted) {
      setState(() => _boxReady = true);
      // Mark as read
      await _progressBox.put(lesson.id, true);
    }
  }

  void _goToNext() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) => LessonScreen(
          topic: topic,
          lessonIndex: widget.lessonIndex + 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          // ── Top bar ──
          Container(
            padding: EdgeInsets.only(
              top: topPad + 8,
              left: 12,
              right: 20,
              bottom: 12,
            ),
            color: AppColors.background(context),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
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
                      Text(
                        topic.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      Text(
                        'Lesson ${widget.lessonIndex + 1} of ${topic.lessons.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                if (_boxReady)
                  Icon(Icons.check_circle,
                      color: AppColors.success, size: 22),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    lesson.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    '${lesson.readingMinutes} min read',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Blocks
                  ...List.generate(lesson.blocks.length, (i) {
                    final block = lesson.blocks[i];
                    final delay = Duration(milliseconds: 100 + 80 * i);

                    if (block.type == BlockType.funFact) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFunFactCard(block.text),
                      ).animate().fadeIn(duration: 400.ms, delay: delay);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        block.text,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textPrimary(context).withValues(alpha: 0.85),
                          height: 1.8,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: delay);
                  }),

                  const SizedBox(height: 20),

                  // Next lesson button
                  if (_hasNext) _buildNextButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // FUN FACT CARD
  // ═══════════════════════════════════════

  Widget _buildFunFactCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.2)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u{1F4A1} Fun Fact:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textPrimary(context).withValues(alpha: 0.85),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // NEXT BUTTON
  // ═══════════════════════════════════════

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _goToNext,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next Lesson \u2192',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
