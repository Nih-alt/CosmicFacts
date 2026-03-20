import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../controllers/quiz_controller.dart';
import '../../data/quiz_questions.dart';
import '../../theme/app_colors.dart';
import 'quiz_play_screen.dart';

class QuizHubScreen extends StatefulWidget {
  const QuizHubScreen({super.key});

  @override
  State<QuizHubScreen> createState() => _QuizHubScreenState();
}

class _QuizHubScreenState extends State<QuizHubScreen> {
  late Box _statsBox;
  bool _boxReady = false;
  Timer? _countdownTimer;
  Duration _timeToMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _openBox();
    _startCountdown();
  }

  Future<void> _openBox() async {
    _statsBox = await Hive.openBox('quiz_stats');
    _checkDailyReset();
    if (mounted) setState(() => _boxReady = true);
  }

  void _checkDailyReset() {
    final lastDate = _statsBox.get('lastQuizDate', defaultValue: '') as String;
    if (lastDate.isNotEmpty) {
      final last = DateTime.tryParse(lastDate);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (last != null && lastDate != today) {
        _statsBox.put('dailyCompleted', false);
        final diff = DateTime.now().difference(last).inDays;
        if (diff > 1) {
          _statsBox.put('currentStreak', 0);
        }
      }
    }
  }

  void _startCountdown() {
    _updateTimeToMidnight();
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        _updateTimeToMidnight();
        setState(() {});
      }
    });
  }

  void _updateTimeToMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timeToMidnight = midnight.difference(now);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  int _getStat(String key, [int def = 0]) {
    if (!_boxReady) return def;
    return _statsBox.get(key, defaultValue: def) as int;
  }

  bool get _dailyCompleted {
    if (!_boxReady) return false;
    return _statsBox.get('dailyCompleted', defaultValue: false) as bool;
  }

  int get _totalPoints => _getStat('totalPoints');
  int get _currentStreak => _getStat('currentStreak');

  double get _accuracy {
    final correct = _getStat('totalCorrect');
    final wrong = _getStat('totalWrong');
    final total = correct + wrong;
    if (total == 0) return 0;
    return correct / total * 100;
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: _buildDailyChallenge(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text('Quiz Modes',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildModeCard(
                      icon: '\u26A1',
                      title: 'Speed Round',
                      subtitle: '20 questions \u2022 10 sec each \u2022 Beat the clock',
                      difficulty: 'Medium',
                      bestLabel: 'Best: ${_getStat('speedBestScore')}/20',
                      glowColor: AppColors.accentCyan,
                      onTap: _startSpeedRound,
                    ),
                    const SizedBox(height: 12),
                    _buildModeCard(
                      icon: '\u{1F4DA}',
                      title: 'Topic Expert',
                      subtitle: 'Choose a topic \u2022 10 questions \u2022 No time limit',
                      difficulty: 'You choose',
                      bestLabel: 'Pick a topic',
                      glowColor: AppColors.accentPurple,
                      onTap: _showTopicPicker,
                    ),
                    const SizedBox(height: 12),
                    _buildModeCard(
                      icon: '\u{1F3B2}',
                      title: 'Random Mix',
                      subtitle: '15 random questions from all topics',
                      difficulty: 'Mixed',
                      bestLabel: 'Test your overall space knowledge',
                      glowColor: AppColors.accentOrange,
                      onTap: _startRandomMix,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Your Stats',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsGrid(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: _buildRankCard(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context), size: 26),
          ),
          const SizedBox(width: 4),
          Text('Space Quiz',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const Spacer(),
          const Text('\u{1F9E0}', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // DAILY CHALLENGE
  // ═══════════════════════════════════════

  Widget _buildDailyChallenge() {
    final hours = _timeToMidnight.inHours;
    final minutes = _timeToMidnight.inMinutes % 60;

    return GestureDetector(
      onTap: _dailyCompleted ? null : _startDailyChallenge,
      child: _AnimatedGradientCard(
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('\u{1F525} Daily Challenge',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              decoration: TextDecoration.none)),
                    ),
                    const Spacer(),
                    if (_currentStreak > 0)
                      Text('\u{1F525} $_currentStreak Day Streak!',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.starGold,
                              decoration: TextDecoration.none)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('5 new questions every day',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        decoration: TextDecoration.none)),
                const Spacer(),
                if (_dailyCompleted) ...[
                  Text('\u2705 Completed! Come back tomorrow',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 4),
                  Text('Resets in ${hours}h ${minutes}m',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          decoration: TextDecoration.none)),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Play Now \u2192',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2A1060),
                            decoration: TextDecoration.none)),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
        );
  }

  // ═══════════════════════════════════════
  // MODE CARDS
  // ═══════════════════════════════════════

  Widget _buildModeCard({
    required String icon,
    required String title,
    required String subtitle,
    required String difficulty,
    required String bestLabel,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: glowColor.withValues(alpha: 0.3), width: 1),
          boxShadow: AppColors.coloredShadow(context, glowColor),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context))),
                  const SizedBox(height: 4),
                  Text(bestLabel,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: glowColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                color: AppColors.textSecondary(context), size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════
  // STATS GRID
  // ═══════════════════════════════════════

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statCard('Total Quizzes', '${_getStat('totalQuizzes')}',
            CupertinoIcons.game_controller, AppColors.accentCyan),
        _statCard('Best Streak', '${_getStat('bestStreak')} days',
            CupertinoIcons.flame, AppColors.accentOrange),
        _statCard('Accuracy', '${_accuracy.toStringAsFixed(0)}%',
            CupertinoIcons.checkmark_seal, AppColors.success),
        _statCard('Rank', QuizController.getRank(_totalPoints).split(' ').last,
            CupertinoIcons.star, AppColors.starGold),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // RANK CARD
  // ═══════════════════════════════════════

  Widget _buildRankCard() {
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
          Row(
            children: [
              Text('Current Rank',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context))),
              const Spacer(),
              Text('$points pts',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.starGold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(rank,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.divider(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
            ),
          ),
          const SizedBox(height: 6),
          Text('$points / $next to next rank',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  // ═══════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════

  void _startDailyChallenge() {
    final rng = Random(DateTime.now().day + DateTime.now().month * 31);
    final shuffled = List<QuizQuestion>.from(allQuizQuestions)..shuffle(rng);
    final questions = shuffled.take(5).toList();
    _navigateToQuiz(questions, 'daily');
  }

  void _startSpeedRound() {
    final shuffled = List<QuizQuestion>.from(allQuizQuestions)..shuffle();
    final questions = shuffled.take(20).toList();
    _navigateToQuiz(questions, 'speed');
  }

  void _startRandomMix() {
    final shuffled = List<QuizQuestion>.from(allQuizQuestions)..shuffle();
    final questions = shuffled.take(15).toList();
    _navigateToQuiz(questions, 'random');
  }

  void _showTopicPicker() {
    final topics = allQuizQuestions.map((q) => q.topic).toSet().toList()..sort();

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => Material(
        color: Colors.transparent,
        child: Container(
          height: 420,
          decoration: BoxDecoration(
            color: AppColors.surface(sheetContext),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(sheetContext).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose a Topic',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(sheetContext),
                      decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: topics.length,
                  itemBuilder: (context, i) {
                    final topic = topics[i];
                    final count =
                        allQuizQuestions.where((q) => q.topic == topic).length;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                        _startTopicQuiz(topic);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.glass(sheetContext),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.glassBorder(sheetContext)),
                          boxShadow: AppColors.cardShadow(sheetContext),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(topic,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary(sheetContext),
                                      decoration: TextDecoration.none)),
                            ),
                            Text('$count Q',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.accentPurple,
                                    decoration: TextDecoration.none)),
                            const SizedBox(width: 8),
                            Icon(CupertinoIcons.chevron_right,
                                size: 14,
                                color: AppColors.textSecondary(sheetContext)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTopicQuiz(String topic) {
    final topicQs =
        allQuizQuestions.where((q) => q.topic == topic).toList()..shuffle();
    final questions = topicQs.take(10).toList();
    _navigateToQuiz(questions, 'topic');
  }

  void _navigateToQuiz(List<QuizQuestion> questions, String mode) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => QuizPlayScreen(questions: questions, mode: mode),
      ),
    ).then((_) {
      if (mounted) setState(() {}); // Refresh stats
    });
  }
}

// ═══════════════════════════════════════
// ANIMATED GRADIENT CARD
// ═══════════════════════════════════════

class _AnimatedGradientCard extends StatefulWidget {
  final Widget child;
  const _AnimatedGradientCard({required this.child});

  @override
  State<_AnimatedGradientCard> createState() => _AnimatedGradientCardState();
}

class _AnimatedGradientCardState extends State<_AnimatedGradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF6B2FA0), const Color(0xFF9B59B6),
                    _ctrl.value)!,
                Color.lerp(const Color(0xFFB8860B), const Color(0xFFDAA520),
                    _ctrl.value)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B5BFF).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
