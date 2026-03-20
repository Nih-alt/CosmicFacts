import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/quiz_controller.dart';
import '../../data/quiz_questions.dart';
import '../../theme/app_colors.dart';
import 'quiz_results_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String mode;

  const QuizPlayScreen({
    super.key,
    required this.questions,
    required this.mode,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with TickerProviderStateMixin {
  late QuizController _ctrl;
  late AnimationController _slideCtrl;
  bool _navigatedToResults = false;

  // Floating points animation
  bool _showPoints = false;
  int _lastPoints = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(QuizController(), tag: 'quiz_play');
    _ctrl.startQuiz(widget.questions, widget.mode);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Listen for quiz end
    ever(_ctrl.lives, (lives) {
      if (lives <= 0 && _ctrl.hasLives && !_navigatedToResults) {
        _goToResults();
      }
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    Get.delete<QuizController>(tag: 'quiz_play');
    super.dispose();
  }

  void _goToResults() {
    if (_navigatedToResults) return;
    _navigatedToResults = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => QuizResultsScreen(
              score: _ctrl.score.value,
              correct: _ctrl.correctCount.value,
              wrong: _ctrl.wrongCount.value,
              total: _ctrl.totalQuestions,
              mode: widget.mode,
            ),
          ),
        );
      }
    });
  }

  void _onAnswer(int index) {
    if (_ctrl.answered.value) return;

    final isCorrect = index == _ctrl.current.correctIndex;
    if (isCorrect) {
      int pts = 10;
      if (_ctrl.current.difficulty == 'hard') pts = 15;
      if (_ctrl.current.difficulty == 'easy') pts = 5;
      setState(() {
        _showPoints = true;
        _lastPoints = pts;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showPoints = false);
      });
    }

    _ctrl.selectAnswer(index);

    // Check if this was the last question
    if (_ctrl.isLastQuestion) {
      Future.delayed(Duration(milliseconds: isCorrect ? 1500 : 2000), () {
        _goToResults();
      });
    } else {
      // Listen for next question
      Future.delayed(Duration(milliseconds: isCorrect ? 1500 : 2000), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Obx(() {
          final q = _ctrl.current;
          final qNum = _ctrl.currentQuestion.value;

          return Column(
            children: [
              _buildTopBar(),
              _buildProgressBar(),
              const SizedBox(height: 8),

              // Lives or Timer
              if (_ctrl.hasLives) _buildLives(),
              if (_ctrl.isSpeedMode) _buildTimer(),

              const SizedBox(height: 16),

              // Question area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Question pill + difficulty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.accentPurple,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text('Q${qNum + 1}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          _difficultyBadge(q.difficulty),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Question text
                      Text(q.question,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                              height: 1.3)),
                      const SizedBox(height: 32),

                      // Answer options
                      ...List.generate(4, (i) {
                        if (_ctrl.hiddenOptions.contains(i)) {
                          return const SizedBox.shrink();
                        }
                        return _buildOption(i, q);
                      }),

                      const SizedBox(height: 16),

                      // Explanation
                      if (_ctrl.showExplanation.value) _buildExplanation(q),

                      const SizedBox(height: 16),

                      // Floating points
                      if (_showPoints)
                        Text('+$_lastPoints pts',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.starGold))
                            .animate()
                            .fadeIn(duration: 200.ms)
                            .slideY(begin: 0, end: -0.5, duration: 800.ms)
                            .fadeOut(delay: 600.ms),
                    ],
                  ),
                ),
              ),

              // Lifelines
              _buildLifelines(),
              const SizedBox(height: 16),
            ],
          );
        }),
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
            onPressed: _showQuitDialog,
            child: Icon(CupertinoIcons.xmark,
                color: AppColors.textPrimary(context), size: 22),
          ),
          const Spacer(),
          Obx(() => Text(
              '${_ctrl.currentQuestion.value + 1}/${_ctrl.totalQuestions}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context)))),
          const Spacer(),
          Obx(() => Row(
                children: [
                  const Text('\u2B50', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('${_ctrl.score.value}',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.starGold)),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final progress =
          (_ctrl.currentQuestion.value + 1) / _ctrl.totalQuestions;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.divider(context),
            valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════
  // LIVES
  // ═══════════════════════════════════════

  Widget _buildLives() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final alive = i < _ctrl.lives.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                alive ? '\u2764\uFE0F' : '\u{1F5A4}',
                style: TextStyle(fontSize: alive ? 22 : 20),
              ),
            );
          }),
        ),
      );
    });
  }

  // ═══════════════════════════════════════
  // TIMER
  // ═══════════════════════════════════════

  Widget _buildTimer() {
    return Obx(() {
      final t = _ctrl.timeLeft.value;
      Color timerColor;
      if (t > 6) {
        timerColor = AppColors.success;
      } else if (t > 3) {
        timerColor = AppColors.starGold;
      } else {
        timerColor = AppColors.error;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: t / 10,
                strokeWidth: 4,
                backgroundColor: AppColors.divider(context),
                valueColor: AlwaysStoppedAnimation(timerColor),
              ),
              Text('$t',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: timerColor)),
            ],
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════
  // OPTIONS
  // ═══════════════════════════════════════

  Widget _buildOption(int index, QuizQuestion q) {
    final labels = ['A', 'B', 'C', 'D'];
    final isAnswered = _ctrl.answered.value;
    final isSelected = _ctrl.selectedAnswer.value == index;
    final isCorrect = q.correctIndex == index;

    Color bgColor = AppColors.glass(context);
    Color borderColor = AppColors.glassBorder(context);
    Color textColor = AppColors.textPrimary(context);
    IconData? trailingIcon;

    if (isAnswered) {
      if (isCorrect) {
        bgColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        trailingIcon = CupertinoIcons.checkmark_circle_fill;
      } else if (isSelected && !isCorrect) {
        bgColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error;
        trailingIcon = CupertinoIcons.xmark_circle_fill;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isAnswered ? null : () => _onAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: AppColors.cardShadow(context),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPurple.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(labels[index],
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPurple)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(q.options[index],
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon,
                    size: 22,
                    color: isCorrect ? AppColors.success : AppColors.error),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
  }

  Widget _difficultyBadge(String diff) {
    Color c;
    switch (diff) {
      case 'easy':
        c = AppColors.success;
        break;
      case 'hard':
        c = AppColors.error;
        break;
      default:
        c = AppColors.accentOrange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(diff[0].toUpperCase() + diff.substring(1),
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }

  // ═══════════════════════════════════════
  // EXPLANATION
  // ═══════════════════════════════════════

  Widget _buildExplanation(QuizQuestion q) {
    final isCorrect =
        _ctrl.selectedAnswer.value == q.correctIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\u{1F4A1} ${q.explanation}',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                  height: 1.4)),
          if (isCorrect && q.funFact.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('\u{1F389} ${q.funFact}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.starGold,
                    height: 1.4)),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  // ═══════════════════════════════════════
  // LIFELINES
  // ═══════════════════════════════════════

  Widget _buildLifelines() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _lifelineButton(0, '50:50', _ctrl.lifelines[0]),
            _lifelineButton(1, '\u23ED\uFE0F', _ctrl.lifelines[1]),
            if (_ctrl.isSpeedMode)
              _lifelineButton(2, '+10s', _ctrl.lifelines[2]),
          ],
        ),
      );
    });
  }

  Widget _lifelineButton(int index, String label, bool available) {
    return GestureDetector(
      onTap: available && !_ctrl.answered.value
          ? () => _ctrl.useLifeline(index)
          : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: available
              ? AppColors.glass(context)
              : AppColors.divider(context),
          border: Border.all(
            color: available
                ? AppColors.accentPurple.withValues(alpha: 0.4)
                : AppColors.glassBorder(context),
          ),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: available
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
                decoration:
                    available ? TextDecoration.none : TextDecoration.lineThrough)),
      ),
    );
  }

  // ═══════════════════════════════════════
  // QUIT DIALOG
  // ═══════════════════════════════════════

  void _showQuitDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // quiz
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
