import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/quiz_controller.dart';
import '../../theme/app_colors.dart';

class QuizResultsScreen extends StatefulWidget {
  final int score;
  final int correct;
  final int wrong;
  final int total;
  final String mode;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.mode,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late Box _statsBox;
  bool _boxReady = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _statsBox = await Hive.openBox('quiz_stats');
    if (mounted) setState(() => _boxReady = true);
  }

  double get _percentage =>
      widget.total > 0 ? widget.correct / widget.total : 0;

  int get _totalPoints {
    if (!_boxReady) return 0;
    return _statsBox.get('totalPoints', defaultValue: 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti
            ..._buildConfetti(),

            // Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildResultIcon(),
                  const SizedBox(height: 24),
                  _buildScoreCircle(),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildPointsBreakdown(),
                  const SizedBox(height: 24),
                  _buildRankProgress(),
                  const SizedBox(height: 32),
                  _buildButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONFETTI
  // ═══════════════════════════════════════

  List<Widget> _buildConfetti() {
    if (_percentage < 0.6) return [];
    final rng = Random(42);
    return List.generate(20, (i) {
      final colors = [
        AppColors.accentPurple,
        AppColors.accentCyan,
        AppColors.starGold,
        AppColors.accentOrange,
        AppColors.success,
      ];
      return Positioned(
        left: rng.nextDouble() * 400,
        top: -20.0 + rng.nextDouble() * 100,
        child: Container(
          width: 6 + rng.nextDouble() * 4,
          height: 6 + rng.nextDouble() * 4,
          decoration: BoxDecoration(
            color: colors[i % colors.length],
            shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
                i % 2 != 0 ? BorderRadius.circular(2) : null,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .slideY(
                begin: 0,
                end: 15,
                duration: Duration(milliseconds: 2000 + rng.nextInt(3000)))
            .fadeOut(delay: Duration(milliseconds: 1500 + rng.nextInt(2000))),
      );
    });
  }

  // ═══════════════════════════════════════
  // RESULT ICON
  // ═══════════════════════════════════════

  Widget _buildResultIcon() {
    String icon;
    String text;
    Color textColor;

    if (_percentage >= 0.8) {
      icon = '\u{1F3C6}';
      text = 'Excellent!';
      textColor = AppColors.starGold;
    } else if (_percentage >= 0.6) {
      icon = '\u2B50';
      text = 'Great Job!';
      textColor = AppColors.accentPurple;
    } else if (_percentage >= 0.4) {
      icon = '\u{1F44D}';
      text = 'Good Try!';
      textColor = AppColors.accentCyan;
    } else {
      icon = '\u{1F4AA}';
      text = 'Keep Learning!';
      textColor = AppColors.textPrimary(context);
    }

    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 12),
        Text(text,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 28, fontWeight: FontWeight.w700, color: textColor)),
      ],
    ).animate().fadeIn(duration: 600.ms).scale(
        begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  // ═══════════════════════════════════════
  // SCORE CIRCLE
  // ═══════════════════════════════════════

  Widget _buildScoreCircle() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: _percentage,
              strokeWidth: 10,
              backgroundColor: AppColors.divider(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.correct}/${widget.total}',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              Text('Score: ${widget.score} points',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary(context))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  // ═══════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════

  Widget _buildStatsRow() {
    return Row(
      children: [
        _miniStat('Correct', '${widget.correct}', AppColors.success),
        const SizedBox(width: 12),
        _miniStat('Wrong', '${widget.wrong}', AppColors.error),
        const SizedBox(width: 12),
        _miniStat(
            'Accuracy', '${(_percentage * 100).round()}%', AppColors.accentPurple),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary(context))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // POINTS BREAKDOWN
  // ═══════════════════════════════════════

  Widget _buildPointsBreakdown() {
    int speedBonus = 0;
    int streakBonus = 0;
    int basePoints = widget.score;

    if (widget.mode == 'speed') {
      speedBonus = (widget.correct * 2).clamp(0, 40);
      basePoints -= speedBonus;
    }
    if (widget.mode == 'daily') {
      streakBonus = 20;
      basePoints -= streakBonus;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Points Earned',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 12),
          _pointRow('Correct answers', '+$basePoints pts'),
          if (speedBonus > 0) _pointRow('Speed bonus', '+$speedBonus pts'),
          if (streakBonus > 0) _pointRow('Streak bonus', '+$streakBonus pts'),
          Divider(color: AppColors.divider(context), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              Text('${widget.score} pts',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.starGold)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _pointRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary(context))),
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
  // RANK PROGRESS
  // ═══════════════════════════════════════

  Widget _buildRankProgress() {
    final points = _totalPoints;
    final rank = QuizController.getRank(points);
    final next = QuizController.getNextRankThreshold(points);
    final current = QuizController.getCurrentRankThreshold(points);
    final progress = (points - current) / (next - current);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.2)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rank,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.divider(context),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accentPurple),
            ),
          ),
          const SizedBox(height: 6),
          Text('$points / $next to next rank',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms);
  }

  // ═══════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════

  Widget _buildButtons() {
    return Column(
      children: [
        // Share
        SizedBox(
          width: double.infinity,
          height: 52,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: AppColors.accentPurple,
            borderRadius: BorderRadius.circular(14),
            onPressed: _shareScore,
            child: Text('Share Score',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        // Back to Hub
        SizedBox(
          width: double.infinity,
          height: 52,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.glassBorder(context)),
              ),
              child: Text('Back to Quiz Hub',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context))),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms);
  }

  void _shareScore() {
    SharePlus.instance.share(
      ShareParams(
        text:
          'I scored ${widget.correct}/${widget.total} on Cosmic Facts Space Quiz! \u{1F30C}\u{1F9E0}\n\nDownload Cosmic Facts and test your space knowledge!',
      ),
    );
  }
}
