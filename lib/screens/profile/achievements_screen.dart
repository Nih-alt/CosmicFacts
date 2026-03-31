import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/achievement_controller.dart';
import '../../data/achievements_data.dart';
import '../../theme/app_colors.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _ctrl = Get.find<AchievementController>();
  String _selectedCategory = 'All';

  static const _categories = [
    'All', 'Learning', 'Quiz', 'Explorer', 'Streak', 'Special',
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<Achievement> get _filtered {
    if (_selectedCategory == 'All') return allAchievements;
    return allAchievements
        .where((a) => a.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Obx(() {
          final unlockedCount = _ctrl.unlocked.length;
          final totalPts = _ctrl.totalPoints.value;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Top Bar ──
              SliverToBoxAdapter(child: _buildTopBar(unlockedCount, totalPts)),
              // ── Category Tabs ──
              SliverToBoxAdapter(child: _buildCategoryTabs()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // ── Badge List ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = _filtered[index];
                      return _buildAchievementCard(achievement, index);
                    },
                    childCount: _filtered.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════

  Widget _buildTopBar(int unlockedCount, int totalPts) {
    final progress = allAchievements.isEmpty
        ? 0.0
        : unlockedCount / allAchievements.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text('Achievements',
                        style: GoogleFonts.spaceGrotesk(fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context))),
                    Text('Earn badges, collect points',
                        style: GoogleFonts.inter(fontSize: 13,
                            color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text('\u2B50 $totalPts pts',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13,
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$unlockedCount/${allAchievements.length} unlocked',
                        style: GoogleFonts.inter(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary(context))),
                    Text('${(progress * 100).round()}%',
                        style: GoogleFonts.inter(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentBlue)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.divider(context),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // CATEGORY TABS
  // ═══════════════════════════════════════

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final active = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accentBlue
                    : _isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(color: AppColors.glassBorder(context)),
                boxShadow: active
                    ? [BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 8, offset: const Offset(0, 2))]
                    : AppColors.cardShadow(context),
              ),
              child: Text(cat,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // ACHIEVEMENT CARD
  // ═══════════════════════════════════════

  Widget _buildAchievementCard(Achievement achievement, int index) {
    final isUnlocked = _ctrl.isUnlocked(achievement.id);
    final prog = _ctrl.getAchievementProgress(achievement);
    final current = _ctrl.getProgress(achievement.requirementType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppColors.starGold.withValues(alpha: 0.4)
                : AppColors.glassBorder(context),
            width: isUnlocked ? 1.5 : 1,
          ),
          boxShadow: isUnlocked
              ? [BoxShadow(
                  color: AppColors.starGold.withValues(alpha: _isDark ? 0.1 : 0.15),
                  blurRadius: 12, spreadRadius: 1)]
              : AppColors.cardShadow(context),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 48, height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          color: _isDark
                              ? AppColors.cardDark
                              : const Color(0xFFE8E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock, size: 10,
                            color: AppColors.textSecondary(context)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isUnlocked
                          ? AppColors.textPrimary(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${achievement.points} pts',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? AppColors.starGold
                          : AppColors.textSecondary(context).withValues(alpha: 0.5),
                    ),
                  ),
                  if (!isUnlocked && prog > 0 && prog < 1) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prog,
                        minHeight: 5,
                        backgroundColor: AppColors.divider(context),
                        valueColor: AlwaysStoppedAnimation(
                          achievement.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$current/${achievement.requirement}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnlocked)
              Icon(Icons.check_circle, color: AppColors.success, size: 22),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 40 * index))
        .slideY(begin: 0.05, end: 0, delay: Duration(milliseconds: 40 * index));
  }
}
