import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/home_controller.dart';
import '../../models/space_article.dart';
import '../../theme/app_colors.dart';
import '../stories/story_feed_screen.dart';
import '../explore/explore_screen.dart';
import '../launches/launches_screen.dart';
import 'apod_detail_screen.dart';

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
    _PlaceholderTab(icon: Icons.school, label: 'Learn'),
    _PlaceholderTab(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(index: _currentTab, children: _tabs),
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent),
        child: CupertinoTabBar(
          backgroundColor: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          activeColor: AppColors.accentPurple,
          inactiveColor: AppColors.textSecondaryDark,
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
  }
}

// ═════════════════════════════════════════════
// PLACEHOLDER TABS
// ═════════════════════════════════════════════

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient
                  .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
              blendMode: BlendMode.srcIn,
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Coming soon', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
    );
  }
}

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
            color: AppColors.accentPurple,
            backgroundColor: AppColors.surfaceDark,
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
                                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(6),
                            onPressed: () {},
                            child: const Icon(CupertinoIcons.bell, size: 22, color: AppColors.textSecondaryDark),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(6),
                            onPressed: () {},
                            child: const Icon(CupertinoIcons.search, size: 22, color: AppColors.textSecondaryDark),
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
                              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => const StoryFeedScreen()),
                          ),
                          child: Text('See All',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accentPurple)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms),
                ),

                // ── Stories PageView ──
                SliverToBoxAdapter(
                  child: ctrl.isLoading.value
                      ? _shimmerRect(300, margin: const EdgeInsets.symmetric(horizontal: 20))
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
                              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const Icon(CupertinoIcons.forward, size: 18, color: AppColors.textSecondaryDark),
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
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
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
      return _shimmerRect(160);
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => ApodDetailScreen(apod: apod)),
      ),
      child: Container(
        height: 160,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.15),
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
                      AppColors.accentPurple.withValues(alpha: 0.2),
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
                    child: Text('NASA APOD',
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
// SHIMMER PLACEHOLDER
// ═════════════════════════════════════════════

Widget _shimmerRect(double height, {EdgeInsets margin = EdgeInsets.zero}) {
  return Padding(
    padding: margin,
    child: Shimmer.fromColors(
      baseColor: AppColors.cardDark,
      highlightColor: const Color(0xFF1E1E4A),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
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
          const Icon(CupertinoIcons.wifi_slash, size: 48, color: AppColors.textSecondaryDark),
          const SizedBox(height: 16),
          Text('No internet connection',
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Check your connection and try again',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryDark)),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentPurple,
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
            color: AppColors.accentPurple.withValues(alpha: 0.1),
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
                    AppColors.accentPurple.withValues(alpha: 0.15),
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
  final String emoji;
  final String label;
  final Color color1;
  final Color color2;
  const _QuickActionItem(this.emoji, this.label, this.color1, this.color2);
}

const _quickActions = [
  _QuickActionItem('🛰️', 'ISS Tracker', AppColors.accentCyan, Color(0xFF0097A7)),
  _QuickActionItem('☄️', 'Asteroids', Color(0xFF90A4AE), Color(0xFF546E7A)),
  _QuickActionItem('🌙', 'Moon', AppColors.starGold, Color(0xFFFFA000)),
  _QuickActionItem('📅', 'Events', AppColors.accentPurple, Color(0xFF4A148C)),
];

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
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
            onTap: () => showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text('Coming Soon 🚀'),
                content: const Text('This feature is being built. Stay tuned!'),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [action.color1.withValues(alpha: 0.25), action.color2.withValues(alpha: 0.15)],
                      ),
                      border: Border.all(color: action.color1.withValues(alpha: 0.2)),
                    ),
                    child: Center(child: Text(action.emoji, style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(height: 8),
                  Text(action.label,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
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

class _TrendingFactsRow extends StatelessWidget {
  const _TrendingFactsRow();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _trendingFacts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final fact = _trendingFacts[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fact.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(fact.text,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white, height: 1.35),
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
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradientVertical
                    .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                blendMode: BlendMode.srcIn,
                child: Column(
                  children: [
                    Text(month, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(day, style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(width: 20),
              Expanded(
                child: Text('1958 — Vanguard 1 satellite launched, still orbiting today!',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.45)),
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
