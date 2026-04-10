import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/learn_content.dart';
import '../../theme/app_colors.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../quiz/quiz_hub_screen.dart';
import 'planet_comparator_screen.dart';
import 'space_calculator_screen.dart';
import 'space_glossary_screen.dart';
import 'space_quotes_screen.dart';
import 'astronaut_directory_screen.dart';
import 'constellation_guide_screen.dart';
import 'topic_detail_screen.dart';
import 'universe_timeline_screen.dart';
import 'active_missions_screen.dart';
import '../explore/exoplanet_explorer_screen.dart';
import '../research/space_research_screen.dart';
import '../weather/space_weather_screen.dart';
import '../quick_actions/space_calendar_screen.dart';
import '../tools/stargazing_forecast_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Box _progressBox;
  bool _boxReady = false;

  static const _topicGlowColors = <Color>[
    AppColors.accentBlue, AppColors.accentCyan, Color(0xFFFFD700),
    Color(0xFF4A90D9), Color(0xFFB0B0C0), Color(0xFFFF6B35),
    Color(0xFF00BFA5), Color(0xFFFF9933), Color(0xFF00E096),
    Color(0xFF5B3FBF), Color(0xFFFF4D6A), Color(0xFFE040FB),
  ];

  // Light-mode tint colors per topic
  static const _topicLightTints = <Color>[
    Color(0xFFF5F0FF), Color(0xFFF0F8FF), Color(0xFFFFFCF0),
    Color(0xFFF0F5FF), Color(0xFFF5F5FA), Color(0xFFFFF5F0),
    Color(0xFFF0FFFA), Color(0xFFFFF8F0), Color(0xFFF0FFF5),
    Color(0xFFF8F0FF), Color(0xFFFFF0F0), Color(0xFFFFF0F8),
  ];

  // Decorative icons per topic (shown top-right at low opacity)
  static const _topicDecoIcons = <IconData>[
    Icons.brightness_3, Icons.all_inclusive, Icons.auto_awesome,
    Icons.public, Icons.nightlight_round, Icons.local_fire_department,
    Icons.remove_red_eye, Icons.flight, Icons.eco,
    Icons.waves, Icons.flare, Icons.satellite_alt,
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

  int get _totalCompleted {
    if (!_boxReady) return 0;
    int count = 0;
    for (final t in allTopics) {
      count += _completedCount(t);
    }
    return count;
  }

  int get _totalLessons {
    int count = 0;
    for (final t in allTopics) {
      count += t.lessons.length;
    }
    return count;
  }

  // Topics user has started but not finished
  List<MapEntry<TopicData, int>> get _inProgressTopics {
    if (!_boxReady) return [];
    final result = <MapEntry<TopicData, int>>[];
    for (final t in allTopics) {
      final c = _completedCount(t);
      if (c > 0 && c < t.lessons.length) result.add(MapEntry(t, c));
    }
    return result;
  }

  // Daily fun fact based on date
  String get _dailyFact {
    final allFacts = <String>[];
    for (final topic in allTopics) {
      for (final lesson in topic.lessons) {
        for (final block in lesson.blocks) {
          if (block.type == BlockType.funFact) allFacts.add(block.text);
        }
      }
    }
    if (allFacts.isEmpty) return '';
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return allFacts[dayOfYear % allFacts.length];
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final inProgress = _inProgressTopics;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 500,
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildQuizBanner(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Tools & Discovery',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary(context))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildToolsRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildFeaturedCard(),
              ),
            ),

            // Continue Learning
            if (inProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Continue Learning',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary(context))),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildContinueRow(inProgress)),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],

            // Topics header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Topics',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary(context))),
                  ],
                ),
              ),
            ),

            // Topics grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTopicCard(
                      allTopics[index], _topicGlowColors[index], index),
                  childCount: allTopics.length,
                ),
              ),
            ),

            // Daily fact
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: _buildDailyFact(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // QUIZ BANNER
  // ═══════════════════════════════════════

  int get _quizStreak {
    if (!_boxReady) return 0;
    final quizBox = Hive.box('quiz_stats');
    return quizBox.get('currentStreak', defaultValue: 0) as int;
  }

  Widget _buildQuizBanner() {
    final streak = _quizStreak;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => const QuizHubScreen()),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFDAA520), Color(0xFFFF8C00)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDAA520).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const Text('\u{1F9E0}', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Space Quiz',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text('Test your knowledge',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            if (streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('\u{1F525} $streak',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // ═══════════════════════════════════════
  // TOOLS ROW (horizontal scroll)
  // ═══════════════════════════════════════

  static const _toolData = <_ToolInfo>[
    _ToolInfo(Icons.calculate_rounded, 'Calculator', '8 calculators', [AppColors.accentBlue, AppColors.accentCyan]),
    _ToolInfo(Icons.compare_arrows_rounded, 'Comparator', 'Compare worlds', [AppColors.accentCyan, Color(0xFF4A90D9)]),
    _ToolInfo(Icons.menu_book_rounded, 'Glossary', '200+ terms', [Color(0xFFDAA520), Color(0xFFFFD700)]),
    _ToolInfo(Icons.timeline_rounded, 'Timeline', '13.8B years', [Color(0xFFFF6B35), Color(0xFFFF4D6A)]),
    _ToolInfo(Icons.format_quote_rounded, 'Quotes', '100+ quotes', [Color(0xFFE040FB), Color(0xFFAB47BC)]),
    _ToolInfo(Icons.calendar_month_rounded, 'Calendar', 'Space events', [Color(0xFF4A90D9), Color(0xFF1E88E5)]),
    _ToolInfo(Icons.people_rounded, 'Astronauts', '50 heroes', [Color(0xFFFF4D6A), Color(0xFFFF6B35)]),
    _ToolInfo(Icons.auto_awesome_rounded, 'Stars', '30 patterns', [Color(0xFF4FC3F7), Color(0xFF7986CB)]),
    _ToolInfo(Icons.satellite_alt_rounded, 'Missions', '20 missions', [Color(0xFF6C63FF), Color(0xFF448AFF)]),
    _ToolInfo(Icons.blur_circular_rounded, 'Exoplanets', '5,000+ worlds', [Color(0xFF00E676), Color(0xFF6C63FF)]),
    _ToolInfo(Icons.article_outlined, 'Research', 'Latest papers', [Color(0xFFFFB800), Color(0xFFFF8F00)]),
    _ToolInfo(Icons.wb_sunny_outlined, 'Weather', 'Live solar data', [Color(0xFFFFAB40), Color(0xFFFF5252)]),
    _ToolInfo(Icons.nights_stay_outlined, 'Stargazing', "Tonight's sky", [Color(0xFF00B4D8), Color(0xFF6C63FF)]),
  ];

  Widget _buildToolsRow() {
    final screens = [
      const SpaceCalculatorScreen(),
      const PlanetComparatorScreen(),
      const SpaceGlossaryScreen(),
      const UniverseTimelineScreen(),
      const SpaceQuotesScreen(),
      const SpaceCalendarScreen(),
      const AstronautDirectoryScreen(),
      const ConstellationGuideScreen(),
      const ActiveMissionsScreen(),
      const ExoplanetExplorerScreen(),
      const SpaceResearchScreen(),
      const SpaceWeatherScreen(),
      const StargazingForecastScreen(),
    ];
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _toolData.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = _toolData[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => screens[i]),
            ),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isDark ? null : AppColors.cardLight,
                gradient: _isDark ? LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.surfaceDark, t.colors[0].withValues(alpha: 0.08)],
                ) : null,
                border: Border.all(color: t.colors[0].withValues(alpha: _isDark ? 0.15 : 0.1)),
                boxShadow: _isDark
                  ? [BoxShadow(color: t.colors[0].withValues(alpha: 0.06), blurRadius: 16)]
                  : [BoxShadow(color: t.colors[0].withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4)),
                     BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: t.colors),
                      boxShadow: [BoxShadow(color: t.colors[0].withValues(alpha: 0.25), blurRadius: 8)],
                    ),
                    child: Icon(t.icon, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Text(t.name,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context))),
                  Text(t.sub,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary(context))),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 60 * i));
        },
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
                Text('Learn',
                    style: GoogleFonts.spaceGrotesk(fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                const SizedBox(height: 2),
                Text('Deep dive into the cosmos',
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const BookmarksScreen()),
            ),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(context)),
                boxShadow: AppColors.cardShadow(context),
              ),
              child: Icon(Icons.bookmark_border_rounded,
                  color: AppColors.textPrimary(context), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // FEATURED HERO CARD
  // ═══════════════════════════════════════

  Widget _buildFeaturedCard() {
    final blackHoles = allTopics[0];
    final total = _totalLessons;
    final completed = _totalCompleted;
    final pct = total > 0 ? completed / total : 0.0;

    return GestureDetector(
      onTap: () => _openTopic(blackHoles),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1060), Color(0xFF0A0A30), Color(0xFF061030)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.25),
              blurRadius: 24, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated star particles
            ...List.generate(8, (i) {
              final rng = Random(i * 13);
              final delay = Duration(milliseconds: rng.nextInt(2000));
              final dur = Duration(milliseconds: 1200 + rng.nextInt(1500));
              return Positioned(
                left: rng.nextDouble() * 360,
                top: rng.nextDouble() * 220,
                child: Container(
                  width: 1.5 + rng.nextDouble() * 2,
                  height: 1.5 + rng.nextDouble() * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4 + rng.nextDouble() * 0.4),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true), delay: delay)
                    .fadeIn(duration: dur).then().fadeOut(duration: dur),
              );
            }),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(blackHoles.emoji, style: const TextStyle(fontSize: 44)),
                  const Spacer(),
                  Text(blackHoles.name,
                      style: GoogleFonts.spaceGrotesk(fontSize: 24,
                          fontWeight: FontWeight.w700, color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
                  const SizedBox(height: 4),
                  Text(blackHoles.description,
                      style: GoogleFonts.inter(fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Start Learning \u2192',
                        style: GoogleFonts.inter(fontSize: 13,
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
            ),

            // Overall progress circle — bottom right (in Stack, no column impact)
            if (completed > 0)
              Positioned(
                right: 20, bottom: 20,
                child: SizedBox(
                  width: 44, height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentCyan),
                      ),
                      Text('${(pct * 100).round()}%',
                          style: GoogleFonts.inter(fontSize: 10,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }

  // ═══════════════════════════════════════
  // CONTINUE LEARNING ROW
  // ═══════════════════════════════════════

  Widget _buildContinueRow(List<MapEntry<TopicData, int>> items) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final topic = items[i].key;
          final done = items[i].value;
          final glowIdx = allTopics.indexOf(topic);
          final glow = glowIdx >= 0 ? _topicGlowColors[glowIdx] : AppColors.accentBlue;
          return GestureDetector(
            onTap: () => _openTopic(topic),
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder(context)),
                boxShadow: AppColors.coloredShadow(context, glow),
              ),
              child: Row(
                children: [
                  Text(topic.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(topic.name,
                            style: GoogleFonts.spaceGrotesk(fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Lesson $done/${topic.lessons.length}',
                            style: GoogleFonts.inter(fontSize: 12,
                                color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, size: 14,
                      color: AppColors.textSecondary(context)),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 60 * i));
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOPIC CARD — premium themed version
  // ═══════════════════════════════════════

  static const _topicThemes = <String, (List<Color>, Color, Color, IconData)>{
    'Black Holes':          ([Color(0xFF1A0533), Color(0xFF0D0221)], Color(0xFFAA00FF), Color(0xFF7B00FF), Icons.radio_button_unchecked),
    'Galaxies':             ([Color(0xFF001A3A), Color(0xFF000D2B)], Color(0xFF2979FF), Color(0xFF0D47A1), Icons.blur_circular),
    'Stars & Supernovae':   ([Color(0xFF2A1500), Color(0xFF1A0D00)], Color(0xFFFFAB00), Color(0xFFFF6D00), Icons.star_border),
    'Planets':              ([Color(0xFF003320), Color(0xFF001A10)], Color(0xFF00E676), Color(0xFF00BFA5), Icons.circle_outlined),
    'Moons':                ([Color(0xFF0A0A2E), Color(0xFF050514)], Color(0xFF7986CB), Color(0xFF3949AB), Icons.nightlight_round),
    'Asteroids & Comets':   ([Color(0xFF1A1A2E), Color(0xFF0D0D1A)], Color(0xFF80DEEA), Color(0xFF00838F), Icons.architecture),
    'Telescopes & Missions':([Color(0xFF001A2E), Color(0xFF00101A)], Color(0xFF00E5FF), Color(0xFF006064), Icons.satellite_alt),
    'Space Exploration':    ([Color(0xFF0D1A2E), Color(0xFF060D1A)], Color(0xFF40C4FF), Color(0xFF0277BD), Icons.rocket_launch_outlined),
    'Earth & Climate':      ([Color(0xFF003300), Color(0xFF001A00)], Color(0xFF76FF03), Color(0xFF33691E), Icons.biotech_outlined),
    'Dark Matter & Energy': ([Color(0xFF0A0A2E), Color(0xFF050514)], Color(0xFF7986CB), Color(0xFF3949AB), Icons.blur_on),
    'Big Bang & Universe':  ([Color(0xFF1A1A00), Color(0xFF0D0D00)], Color(0xFFFFEE58), Color(0xFFF57F17), Icons.all_inclusive),
    'Exoplanets & Aliens':  ([Color(0xFF1A0020), Color(0xFF0D0013)], Color(0xFFE040FB), Color(0xFFAD1457), Icons.cloud_outlined),
  };

  static (List<Color>, Color, Color, IconData) _getTopicTheme(String name) {
    return _topicThemes[name] ??
        (const [Color(0xFF1A1A3A), Color(0xFF0D0D2E)], const Color(0xFF6C63FF), const Color(0xFF3D35CC), Icons.auto_awesome_outlined);
  }

  Widget _buildTopicCard(TopicData topic, Color glow, int index) {
    final completed = _completedCount(topic);
    final total = topic.lessons.length;
    final progress = total > 0 ? completed / total : 0.0;

    final (gradColors, accent, glowC, decorIcon) = _isDark
        ? _getTopicTheme(topic.name)
        : ([Colors.white, _topicLightTints[index]], glow, glow, _topicDecoIcons[index]);

    return GestureDetector(
      onTap: () => _openTopic(topic),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradColors,
          ),
          border: Border.all(
            color: accent.withValues(alpha: _isDark ? 0.25 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: glowC.withValues(alpha: _isDark ? 0.2 : 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (!_isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative large icon
            Positioned(
              top: -8,
              right: -8,
              child: Icon(decorIcon,
                  size: 80,
                  color: accent.withValues(alpha: _isDark ? 0.08 : 0.07)),
            ),
            // Dot star particles
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _isDark ? 0.4 : 0.0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 36,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _isDark ? 0.25 : 0.0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 56,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: _isDark ? 0.5 : 0.0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container with glow
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(topic.emoji,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const Spacer(),
                  // Topic name
                  Text(topic.name,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: _isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  // Lesson count with accent dot
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        completed > 0
                            ? '$completed/$total completed'
                            : '${topic.lessons.length} lessons',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isDark
                                ? Colors.white60
                                : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: _isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 60 * index))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * index),
        );
  }

  // ═══════════════════════════════════════
  // DAILY FACT
  // ═══════════════════════════════════════

  Widget _buildDailyFact() {
    final fact = _dailyFact;
    if (fact.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _isDark
            ? AppColors.accentBlue.withValues(alpha: 0.08)
            : const Color(0xFFF5F0FF),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.15)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u{1F4A1}', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Space Fact',
                    style: GoogleFonts.spaceGrotesk(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBlue)),
                const SizedBox(height: 6),
                Text(fact,
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textPrimary(context).withValues(alpha: 0.85),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  // ═══════════════════════════════════════

  void _openTopic(TopicData topic) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }
}

class _ToolInfo {
  final IconData icon;
  final String name, sub;
  final List<Color> colors;
  const _ToolInfo(this.icon, this.name, this.sub, this.colors);
}
