import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/home_controller.dart';
import '../../models/space_article.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../stories/story_feed_screen.dart';
import '../explore/explore_screen.dart';
import '../launches/launches_screen.dart';
import '../learn/learn_screen.dart';
import '../learn/space_quotes_screen.dart';
import '../profile/profile_screen.dart';
import '../quick_actions/iss_tracker_screen.dart';
import '../quick_actions/asteroids_screen.dart';
import '../quick_actions/moon_phase_screen.dart';
import '../quick_actions/space_calendar_screen.dart';
import 'apod_archive_screen.dart';
import 'earth_from_space_screen.dart';
import 'search_screen.dart';
import 'space_stats_screen.dart';

// ═════════════════════════════════════════════
// TAB SCAFFOLD
// ═════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  final _tabs = const <Widget>[
    _HomeTab(),
    ExploreScreen(),
    LaunchesScreen(),
    LearnScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('HOME: Building');
    try {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: IndexedStack(index: _currentTab, children: _tabs),
        bottomNavigationBar: Theme(
          data: ThemeData(splashColor: Colors.transparent),
          child: CupertinoTabBar(
            backgroundColor: AppColors.navBar(context),
            border: Border(
              top: BorderSide(
                color: AppColors.divider(context),
                width: 0.5,
              ),
            ),
            activeColor: AppColors.accentBlue,
            inactiveColor: AppColors.textSecondary(context),
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.rocket_launch_rounded), label: 'Launches'),
              BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'Learn'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('HomeScreen build error: $e');
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Pull down to refresh',
                  style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }
  }
}

// ═════════════════════════════════════════════
// PLACEHOLDER TABS
// ═════════════════════════════════════════════
// HOME TAB
// ═════════════════════════════════════════════

class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _storyController = PageController(viewportFraction: 0.92);
  int _currentStory = 0;
  String _selectedStoryCategory = 'All';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _compactCategories = [
    ('All', ''),
    ('Space News', '\u{1F534}'),
    ('India Space', '\u{1F1EE}\u{1F1F3}'),
    ('SpaceX', '\u{1F680}'),
  ];

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Stack(
      children: [
        const _Starfield(),
        Obx(() {
          if (ctrl.hasError.value && ctrl.stories.isEmpty) {
            return _ErrorState(onRetry: ctrl.refreshData);
          }

          return RefreshIndicator(
            onRefresh: ctrl.refreshData,
            color: AppColors.accentBlue,
            backgroundColor: AppColors.surface(context),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Offline banner
                if (ctrl.isOffline.value)
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.wifi_slash, size: 16,
                                color: AppColors.accentOrange.withValues(alpha: 0.8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Showing offline data',
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.accentOrange)),
                            ),
                            GestureDetector(
                              onTap: ctrl.dismissOfflineBanner,
                              child: Icon(CupertinoIcons.xmark, size: 14,
                                  color: AppColors.accentOrange.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top bar
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Cosmic Facts',
                                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                          ),
                          _BellIconButton(isDark: _isDark),
                          CupertinoButton(
                            padding: const EdgeInsets.all(6),
                            onPressed: () => Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => const SearchScreen()),
                            ),
                            child: Icon(CupertinoIcons.search, size: 22, color: AppColors.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── APOD ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: _buildApodCard(ctrl),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                ),

                // ── Quick Actions ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: const _QuickActions(),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 100.ms),
                ),

                // ── Stories header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Space Stories',
                              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => StoryFeedScreen(initialCategory: _selectedStoryCategory)),
                          ),
                          child: Text('See All \u2192',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accentBlue)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms),
                ),

                // ── Compact category pills ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _compactCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _compactCategories[index];
                          final isSelected = _selectedStoryCategory == cat.$1;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedStoryCategory = cat.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.primaryGradient : null,
                                color: isSelected ? null : AppColors.card(context),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? null : Border.all(
                                  color: _isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AppColors.cardBorder(context),
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.3), blurRadius: 8)]
                                    : AppColors.cardShadow(context),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (cat.$2.isNotEmpty) ...[
                                    Text(cat.$2, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(cat.$1,
                                      style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary(context),
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── Stories PageView ──
                SliverToBoxAdapter(
                  child: ctrl.isLoading.value
                      ? _shimmerRect(300, margin: const EdgeInsets.symmetric(horizontal: 20), context: context)
                      : SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: _storyController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (i) => setState(() => _currentStory = i),
                            itemCount: ctrl.stories.length.clamp(0, 5),
                            itemBuilder: (context, index) {
                              final article = ctrl.stories[index];
                              return AnimatedBuilder(
                                animation: _storyController,
                                builder: (context, child) {
                                  double v = 1.0;
                                  if (_storyController.position.haveDimensions) {
                                    v = (_storyController.page ?? 0) - index;
                                    v = (1 - v.abs() * 0.05).clamp(0.95, 1.0);
                                  }
                                  return Transform.scale(scale: v, child: child);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) => StoryFeedScreen(initialIndex: index),
                                      ),
                                    ),
                                    child: _LiveStoryCard(article: article),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),

                // Story dots
                if (!ctrl.isLoading.value && ctrl.stories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(ctrl.stories.length.clamp(0, 5), (i) {
                          final active = i == _currentStory;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: active ? AppColors.primaryGradient : null,
                              color: active ? null : Colors.white.withValues(alpha: 0.12),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                // ── Trending Facts ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Trending Facts 🔥',
                              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                        ),
                        Icon(CupertinoIcons.forward, size: 18, color: AppColors.textSecondary(context)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 400.ms),
                ),
                SliverToBoxAdapter(
                  child: const _TrendingFactsRow()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 500.ms),
                ),

                // ── This Day in Space ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text('This Day in Space 📅',
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 600.ms),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: const _TodayInSpaceCard(),
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 700.ms),
                ),

                // ── Quote of the Day ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text('Quote of the Day \u2728',
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                  ).animate().fadeIn(duration: 500.ms, delay: 800.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 800.ms),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _QuoteOfDayCard(isDark: _isDark),
                  ).animate().fadeIn(duration: 500.ms, delay: 900.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 900.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildApodCard(HomeController ctrl) {
    final apod = ctrl.todayApod.value;
    if (ctrl.isLoading.value || apod == null) {
      return _shimmerRect(160, context: context);
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => ApodArchiveScreen(initialDate: apod.date)),
      ),
      child: Container(
        height: 160,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (apod.mediaType == 'image')
              CachedNetworkImage(
                imageUrl: apod.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.cardDark),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.cardDark,
                  child: const Icon(CupertinoIcons.photo, color: AppColors.textSecondaryDark, size: 36),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.2),
                      AppColors.accentCyan.withValues(alpha: 0.12),
                      AppColors.surfaceDark,
                    ],
                  ),
                ),
              ),
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Astronomy Photo of the Day',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(apod.title,
                                style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('Tap to explore today\'s cosmic wonder',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.67))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(CupertinoIcons.arrow_right, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// QUOTE OF THE DAY CARD (Home)
// ═════════════════════════════════════════════

class _QuoteOfDayCard extends StatelessWidget {
  final bool isDark;
  const _QuoteOfDayCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final quote = getDailyQuote();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const SpaceQuotesScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? AppColors.accentBlue.withValues(alpha: 0.08)
              : AppColors.accentBlue.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.15)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('\u201C', style: GoogleFonts.spaceGrotesk(
                    fontSize: 32, fontWeight: FontWeight.w700,
                    color: AppColors.accentBlue.withValues(alpha: 0.4))),
                const Spacer(),
                Icon(CupertinoIcons.chevron_right, size: 16,
                    color: AppColors.textSecondary(context)),
              ],
            ),
            Text(
              quote.quote,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary(context),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              '\u2014 ${quote.author}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SHIMMER PLACEHOLDER
// ═════════════════════════════════════════════

Widget _shimmerRect(double height, {EdgeInsets margin = EdgeInsets.zero, BuildContext? context}) {
  final base = context != null ? AppColors.shimmerBase(context) : AppColors.cardDark;
  final highlight = context != null ? AppColors.shimmerHighlight(context) : AppColors.surfaceDark;
  return Padding(
    padding: margin,
    child: Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════
// ERROR STATE
// ═════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.wifi_slash, size: 48, color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text('No internet connection',
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
          const SizedBox(height: 8),
          Text('Check your connection and try again',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: onRetry,
            child: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// LIVE STORY CARD (uses SpaceArticle)
// ═════════════════════════════════════════════

class _LiveStoryCard extends StatelessWidget {
  final SpaceArticle article;
  const _LiveStoryCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Article image
          CachedNetworkImage(
            imageUrl: article.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.cardDark),
            errorWidget: (_, _, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentBlue.withValues(alpha: 0.15),
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
          ),
          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.25, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    article.newsSite,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                // Headline
                Text(
                  article.title,
                  style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    article.summary,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.73), height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Bottom row
                Row(
                  children: [
                    Icon(CupertinoIcons.time, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 5),
                    Text(
                      _timeAgo(article.publishedAt),
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    const Spacer(),
                    Text(article.newsSite,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STARFIELD
// ═════════════════════════════════════════════

class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rng = Random(77);
    return Stack(
      children: List.generate(35, (i) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final starSize = 1.0 + rng.nextDouble() * 1.5;
        final delay = Duration(milliseconds: rng.nextInt(2000));
        final duration = Duration(milliseconds: 400 + rng.nextInt(1600));
        return Positioned(
          left: x, top: y,
          child: Container(
            width: starSize, height: starSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6 + rng.nextDouble() * 0.4),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true), delay: delay)
              .fadeIn(duration: duration).then().fadeOut(duration: duration),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════
// QUICK ACTIONS (unchanged)
// ═════════════════════════════════════════════

class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Widget screen;
  const _QuickActionItem(this.icon, this.label, this.iconBg, this.screen);
}

final _quickActions = [
  _QuickActionItem(CupertinoIcons.antenna_radiowaves_left_right, 'ISS Tracker', const Color(0xFF38BDF8), const ISSTrackerScreen()),
  _QuickActionItem(CupertinoIcons.sparkles, 'Asteroids', const Color(0xFFFB923C), const AsteroidsScreen()),
  _QuickActionItem(CupertinoIcons.moon_fill, 'Moon', const Color(0xFFFFD700), const MoonPhaseScreen()),
  _QuickActionItem(CupertinoIcons.calendar, 'Calendar', const Color(0xFF34D399), const SpaceCalendarScreen()),
  _QuickActionItem(CupertinoIcons.chart_bar_fill, 'Live Stats', const Color(0xFF3B82F6), const SpaceStatsScreen()),
  _QuickActionItem(CupertinoIcons.globe, 'Earth', const Color(0xFF4A90D9), const EarthFromSpaceScreen()),
];

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _quickActions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => action.screen),
              );
            },
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: action.iconBg.withValues(alpha: isDark ? 0.2 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: action.iconBg.withValues(alpha: isDark ? 0.4 : 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(action.icon, color: action.iconBg, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF0A1628),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════
// TRENDING FACTS (unchanged, still hardcoded)
// ═════════════════════════════════════════════

class _TrendingFact {
  final String emoji;
  final String text;
  const _TrendingFact(this.emoji, this.text);
}

const _trendingFacts = [
  _TrendingFact('🌍', 'Earth is the only planet not named after a god'),
  _TrendingFact('🚀', 'A space suit costs approximately \$12 million'),
  _TrendingFact('⭐', 'There are more stars than grains of sand on Earth'),
  _TrendingFact('☄️', 'Halley\'s Comet won\'t return until 2061'),
  _TrendingFact('🌑', 'The Moon is drifting 3.8cm away from Earth every year'),
  _TrendingFact('🪐', 'Saturn would float if placed in a giant bathtub'),
];

List<_TrendingFact> _getDailyFacts(List<_TrendingFact> allFacts) {
  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final shuffled = List<_TrendingFact>.from(allFacts)..shuffle(Random(seed));
  return shuffled.take(5).toList();
}

class _TrendingFactsRow extends StatelessWidget {
  const _TrendingFactsRow();
  @override
  Widget build(BuildContext context) {
    final facts = _getDailyFacts(_trendingFacts);
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: facts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final fact = facts[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.glass(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder(context)),
                  boxShadow: AppColors.cardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fact.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(fact.text,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context), height: 1.35),
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════
// THIS DAY IN SPACE (unchanged)
// ═════════════════════════════════════════════

class _TodayInSpaceCard extends StatelessWidget {
  const _TodayInSpaceCard();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    final month = months[now.month - 1];
    final day = now.day.toString().padLeft(2, '0');
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradientVertical
                    .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                blendMode: BlendMode.srcIn,
                child: Column(
                  children: [
                    Text(month, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                    Text(day, style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context), height: 1.1)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 50, color: AppColors.divider(context)),
              const SizedBox(width: 20),
              Expanded(
                child: Text('1958 — Vanguard 1 satellite launched, still orbiting today!',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary(context), height: 1.45)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

// ═════════════════════════════════════════════
// BELL ICON WITH BADGE
// ═════════════════════════════════════════════

class _BellIconButton extends StatefulWidget {
  final bool isDark;
  const _BellIconButton({required this.isDark});

  @override
  State<_BellIconButton> createState() => _BellIconButtonState();
}

class _BellIconButtonState extends State<_BellIconButton> {
  bool _hasActive = false;

  @override
  void initState() {
    super.initState();
    _loadBadge();
  }

  void _loadBadge() {
    final s = Hive.box('settings');
    final master = s.get('notifications_enabled', defaultValue: false) == true;
    final daily = s.get('notif_daily_fact', defaultValue: true) == true;
    final apod = s.get('notif_apod', defaultValue: true) == true;
    final quiz = s.get('notif_quiz', defaultValue: true) == true;
    setState(() => _hasActive = master && (daily || apod || quiz));
  }

  Future<void> _showSheet() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => _NotificationSheet(onChanged: _loadBadge),
    );
    _loadBadge();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(6),
      onPressed: _showSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(CupertinoIcons.bell, size: 22, color: AppColors.textSecondary(context)),
          if (_hasActive)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// NOTIFICATION BOTTOM SHEET
// ═════════════════════════════════════════════

class _NotificationSheet extends StatefulWidget {
  final VoidCallback onChanged;
  const _NotificationSheet({required this.onChanged});

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  late bool _master;
  late bool _daily;
  late bool _apod;
  late bool _quiz;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    final s = Hive.box('settings');
    _master = s.get('notifications_enabled', defaultValue: false) == true;
    _daily = s.get('notif_daily_fact', defaultValue: true) == true;
    _apod = s.get('notif_apod', defaultValue: true) == true;
    _quiz = s.get('notif_quiz', defaultValue: true) == true;
  }

  Future<void> _save() async {
    final s = Hive.box('settings');
    await s.put('notifications_enabled', _master);
    await s.put('notif_daily_fact', _daily);
    await s.put('notif_apod', _apod);
    await s.put('notif_quiz', _quiz);
    await s.put('notifications', _master);

    await NotificationService.cancelAll();
    if (_master) {
      if (_daily) await NotificationService.scheduleDailyFact();
      if (_apod) await NotificationService.scheduleApodReminder();
      if (_quiz) await NotificationService.scheduleQuizReminder();
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Notifications 🔔',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Master toggle
              _buildRow(
                title: 'Enable Notifications',
                subtitle: 'Master toggle for all notifications',
                value: _master,
                onChanged: (v) { setState(() => _master = v); _save(); },
              ),
              const SizedBox(height: 4),
              // Individual toggles (dimmed if master off)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _master ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !_master,
                  child: Column(
                    children: [
                      _buildRow(
                        title: 'Daily Space Fact',
                        subtitle: 'Every morning at 8 AM',
                        value: _daily,
                        onChanged: (v) { setState(() => _daily = v); _save(); },
                      ),
                      const SizedBox(height: 4),
                      _buildRow(
                        title: 'Daily Space Photo Alert',
                        subtitle: 'New astronomy photo available',
                        value: _apod,
                        onChanged: (v) { setState(() => _apod = v); _save(); },
                      ),
                      const SizedBox(height: 4),
                      _buildRow(
                        title: 'Quiz Reminder',
                        subtitle: 'Evening streak reminder',
                        value: _quiz,
                        onChanged: (v) { setState(() => _quiz = v); _save(); },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Done',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.accentBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
