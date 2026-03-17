import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

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
    _PlaceholderTab(icon: Icons.explore, label: 'Explore'),
    _PlaceholderTab(icon: Icons.rocket_launch, label: 'Launches'),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rocket_launch_rounded),
              label: 'Launches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
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
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coming soon',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// HOME TAB — main content
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
    return Stack(
      children: [
        // Starfield background
        const _Starfield(),

        // Content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cosmic Facts',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(6),
                        onPressed: () {},
                        child: const Icon(CupertinoIcons.bell,
                            size: 22, color: AppColors.textSecondaryDark),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(6),
                        onPressed: () {},
                        child: const Icon(CupertinoIcons.search,
                            size: 22, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── NASA APOD Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: const _ApodCard(),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
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
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 100.ms),
            ),

            // ── Space Stories header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Space Stories',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms),
            ),

            // ── Space Stories PageView ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _storyController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStory = i),
                  itemCount: _storyCards.length,
                  itemBuilder: (context, index) {
                    final story = _storyCards[index];
                    return AnimatedBuilder(
                      animation: _storyController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_storyController.position.haveDimensions) {
                          value = (_storyController.page ?? 0) - index;
                          value = (1 - value.abs() * 0.05).clamp(0.95, 1.0);
                        }
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _StoryCard(story: story),
                      ),
                    );
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
            ),

            // Story dots
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_storyCards.length, (i) {
                    final active = i == _currentStory;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: active ? AppColors.primaryGradient : null,
                        color:
                            active ? null : Colors.white.withValues(alpha: 0.12),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Trending Facts header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Trending Facts 🔥',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(CupertinoIcons.forward,
                        size: 18, color: AppColors.textSecondaryDark),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 400.ms),
            ),

            // ── Trending Facts row ──
            SliverToBoxAdapter(
              child: const _TrendingFactsRow()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
            ),

            // ── This Day in Space header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'This Day in Space 📅',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 600.ms),
            ),

            // ── This Day in Space card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const _TodayInSpaceCard(),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 500.ms,
                      delay: 700.ms),
            ),

            // Bottom padding — room above bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// STARFIELD (reused from onboarding)
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
          left: x,
          top: y,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6 + rng.nextDouble() * 0.4),
              shape: BoxShape.circle,
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
                delay: delay,
              )
              .fadeIn(duration: duration)
              .then()
              .fadeOut(duration: duration),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════
// NASA APOD CARD
// ═════════════════════════════════════════════

class _ApodCard extends StatelessWidget {
  const _ApodCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentPurple.withValues(alpha: 0.2),
              AppColors.accentCyan.withValues(alpha: 0.12),
              AppColors.surfaceDark,
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // NASA APOD badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'NASA APOD',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Astronomy Picture of the Day',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to explore today\'s cosmic wonder',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.67),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// QUICK ACTIONS
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
            onTap: () {},
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          action.color1.withValues(alpha: 0.25),
                          action.color2.withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: action.color1.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        action.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
// STORY CARDS DATA
// ═════════════════════════════════════════════

class _StoryData {
  final String source;
  final String headline;
  final String summary;
  final Color badgeColor;
  final Color gradientStart;
  final Color gradientEnd;
  final int likes;
  final String readTime;

  const _StoryData({
    required this.source,
    required this.headline,
    required this.summary,
    required this.badgeColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.likes,
    required this.readTime,
  });
}

const _storyCards = [
  _StoryData(
    source: 'NASA',
    headline: 'The James Webb Telescope\nCaptures New Galaxy',
    summary:
        'A previously unseen galaxy dating back 13.2 billion years has been revealed in stunning infrared detail.',
    badgeColor: AppColors.accentPurple,
    gradientStart: AppColors.accentPurple,
    gradientEnd: Color(0xFF3D1F99),
    likes: 2841,
    readTime: '2 min read',
  ),
  _StoryData(
    source: 'ISRO',
    headline: 'ISRO\'s Gaganyaan\nMission Update',
    summary:
        'India\'s first crewed spaceflight mission enters final testing phase ahead of its historic launch window.',
    badgeColor: Color(0xFFFF9933),
    gradientStart: Color(0xFFFF9933),
    gradientEnd: Color(0xFFFF6F00),
    likes: 3104,
    readTime: '3 min read',
  ),
  _StoryData(
    source: 'SpaceX',
    headline: 'SpaceX Starship\nSuccessfully Lands on Mars',
    summary:
        'The largest rocket ever built completes its first unmanned Mars landing, opening a new chapter in exploration.',
    badgeColor: AppColors.accentCyan,
    gradientStart: AppColors.accentCyan,
    gradientEnd: Color(0xFF0097A7),
    likes: 5720,
    readTime: '4 min read',
  ),
  _StoryData(
    source: 'Fun Fact',
    headline: 'What Happens Inside\na Black Hole?',
    summary:
        'Beyond the event horizon, the known laws of physics break down. Here\'s what scientists theorize awaits.',
    badgeColor: Color(0xFF7B1FA2),
    gradientStart: Color(0xFF7B1FA2),
    gradientEnd: Color(0xFF4A148C),
    likes: 4215,
    readTime: '3 min read',
  ),
  _StoryData(
    source: 'NASA',
    headline: 'Asteroid 2024 XK4\nPasses Close to Earth',
    summary:
        'A 180-meter asteroid safely passes within 2 million km of Earth, the closest encounter this decade.',
    badgeColor: AppColors.accentOrange,
    gradientStart: AppColors.accentOrange,
    gradientEnd: Color(0xFFD84315),
    likes: 1896,
    readTime: '2 min read',
  ),
];

// ═════════════════════════════════════════════
// STORY CARD WIDGET
// ═════════════════════════════════════════════

class _StoryCard extends StatelessWidget {
  final _StoryData story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            story.gradientStart.withValues(alpha: 0.15),
            story.gradientEnd.withValues(alpha: 0.08),
            AppColors.backgroundDark,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: story.gradientStart.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    story.gradientStart.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: story.badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: story.badgeColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    story.source,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: story.badgeColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Headline
                Text(
                  story.headline,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Summary — fills remaining space
                Expanded(
                  child: Text(
                    story.summary,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.73),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Bottom row
                Row(
                  children: [
                    Icon(CupertinoIcons.heart,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 5),
                    Text(
                      _formatCount(story.likes),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(CupertinoIcons.bookmark,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.5)),
                    const Spacer(),
                    Icon(CupertinoIcons.share,
                        size: 17,
                        color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Text(
                      story.readTime,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ═════════════════════════════════════════════
// TRENDING FACTS ROW
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
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fact.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        fact.text,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
// THIS DAY IN SPACE
// ═════════════════════════════════════════════

class _TodayInSpaceCard extends StatelessWidget {
  const _TodayInSpaceCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              // Date
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradientVertical.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                blendMode: BlendMode.srcIn,
                child: Column(
                  children: [
                    Text(
                      month,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      day,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Divider
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.1),
              ),

              const SizedBox(width: 20),

              // Event text
              Expanded(
                child: Text(
                  '1958 — Vanguard 1 satellite launched, still orbiting today!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
