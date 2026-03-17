import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../../models/space_article.dart';
import '../../theme/app_colors.dart';
import 'article_detail_screen.dart';

// ═════════════════════════════════════════════
// BADGE GRADIENT PER SOURCE
// ═════════════════════════════════════════════

LinearGradient _badgeGradient(String source) {
  final s = source.toLowerCase();
  if (s.contains('nasa')) {
    return const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)]);
  }
  if (s.contains('isro')) {
    return const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF6F00)]);
  }
  if (s.contains('spacex')) {
    return const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0097A7)]);
  }
  if (s.contains('esa')) {
    return const LinearGradient(colors: [Color(0xFF00E096), Color(0xFF00A86B)]);
  }
  return const LinearGradient(colors: [Color(0xFF7B5BFF), Color(0xFF5B3FD4)]);
}

// ═════════════════════════════════════════════
// CONTROLLER (session-scoped)
// ═════════════════════════════════════════════

class _FeedController extends GetxController {
  final currentPage = 0.obs;
  final liked = <int, bool>{}.obs;
  final bookmarked = <int, bool>{}.obs;
  final showSwipeHint = true.obs;

  void toggleLike(int id) => liked[id] = !(liked[id] ?? false);
  void toggleBookmark(int id) => bookmarked[id] = !(bookmarked[id] ?? false);
  bool isLiked(int id) => liked[id] ?? false;
  bool isBookmarked(int id) => bookmarked[id] ?? false;
}

// ═════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════

class StoryFeedScreen extends StatefulWidget {
  final int initialIndex;
  const StoryFeedScreen({super.key, this.initialIndex = 0});

  @override
  State<StoryFeedScreen> createState() => _StoryFeedScreenState();
}

class _StoryFeedScreenState extends State<StoryFeedScreen> {
  late final PageController _pageController;
  late final _FeedController _feed;
  final _homeCtrl = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _feed = Get.put(_FeedController());
    _feed.currentPage.value = widget.initialIndex;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _feed.showSwipeHint.value = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<_FeedController>();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _feed.currentPage.value = index;
    // Infinite scroll: prefetch when 5 from end
    if (index >= _homeCtrl.stories.length - 5) {
      _homeCtrl.loadMoreStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Obx(() {
        final stories = _homeCtrl.stories;

        if (stories.isEmpty && _homeCtrl.isLoading.value) {
          return const Center(
            child: CupertinoActivityIndicator(color: AppColors.accentPurple, radius: 14),
          );
        }

        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.doc_text, size: 48, color: AppColors.textSecondaryDark),
                const SizedBox(height: 16),
                Text('No stories available',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 24),
                CupertinoButton(
                  color: AppColors.accentPurple,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _homeCtrl.refreshData,
                  child: Text('Refresh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return _StoryPage(
                  article: stories[index],
                  index: index,
                );
              },
            ),
            // Loading more indicator
            if (_homeCtrl.isLoadingMore.value)
              const Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: CupertinoActivityIndicator(color: AppColors.accentPurple),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════
// SINGLE STORY PAGE
// ═════════════════════════════════════════════

class _StoryPage extends StatelessWidget {
  final SpaceArticle article;
  final int index;

  const _StoryPage({required this.article, required this.index});

  @override
  Widget build(BuildContext context) {
    final feed = Get.find<_FeedController>();
    final homeCtrl = Get.find<HomeController>();

    return Stack(
      children: [
        // LAYER 0: Base dark color + starfield (always visible)
        Positioned.fill(
          child: Container(color: AppColors.backgroundDark),
        ),
        const Positioned.fill(child: _Starfield()),
        // Nebula glow
        const _NebulaGlow(),

        // LAYER 1: Article image on top of stars (if available)
        if (article.imageUrl.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

        // LAYER 2: Dark gradient overlay for text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.3, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // LAYER 3: Content
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: badge + time + close ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: _badgeGradient(article.newsSite),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.newsSite,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(article.publishedAt),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: const Icon(CupertinoIcons.xmark,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Push everything to bottom
              const Spacer(),

              // ── Bottom content — overlaid on dark gradient ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source icon
                    Icon(Icons.public,
                            size: 24,
                            color: Colors.white.withValues(alpha: 0.7))
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms),

                    const SizedBox(height: 10),

                    // Headline
                    Text(
                      article.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 150.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 500.ms,
                            delay: 150.ms),

                    const SizedBox(height: 12),

                    // Summary
                    Text(
                      article.summary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 250.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 500.ms,
                            delay: 250.ms),

                    const SizedBox(height: 16),

                    // Read Full Article button
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) =>
                              ArticleDetailScreen(article: article),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.accentPurple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Read Full Article →',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                    const SizedBox(height: 20),

                    // Bottom action row
                    Obx(() {
                      final liked = feed.isLiked(article.id);
                      final bookmarked = feed.isBookmarked(article.id);
                      final page = feed.currentPage.value;
                      return Row(
                        children: [
                          _ActionButton(
                            icon: liked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: liked
                                ? const Color(0xFFFF4D6A)
                                : Colors.white.withValues(alpha: 0.6),
                            onTap: () => feed.toggleLike(article.id),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: bookmarked
                                ? CupertinoIcons.bookmark_fill
                                : CupertinoIcons.bookmark,
                            color: bookmarked
                                ? AppColors.starGold
                                : Colors.white.withValues(alpha: 0.6),
                            onTap: () => feed.toggleBookmark(article.id),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: CupertinoIcons.share,
                            color: Colors.white.withValues(alpha: 0.6),
                            onTap: () {},
                          ),
                          const Spacer(),
                          Text(
                            '${page + 1} of ${homeCtrl.stories.length}',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

// ═════════════════════════════════════════════
// ACTION BUTTON
// ═════════════════════════════════════════════

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _anim.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Icon(widget.icon, size: 22, color: widget.color),
      ),
    );
  }
}


// ═════════════════════════════════════════════
// STARFIELD — twinkling stars behind every card
// ═════════════════════════════════════════════

class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rng = Random(53);

    return Stack(
      children: List.generate(35, (i) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final isLarge = i % 8 == 0;
        final starSize = isLarge ? (3.0 + rng.nextDouble()) : (1.0 + rng.nextDouble() * 2);
        final delay = Duration(milliseconds: rng.nextInt(2000));
        final duration = Duration(milliseconds: 1000 + rng.nextInt(2000));

        Widget star = Container(
          width: starSize,
          height: starSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7 + rng.nextDouble() * 0.3),
            shape: BoxShape.circle,
            boxShadow: isLarge
                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 4)]
                : null,
          ),
        );

        star = star
            .animate(onPlay: (c) => c.repeat(reverse: true), delay: delay)
            .fadeIn(duration: duration)
            .then()
            .fadeOut(duration: duration);

        return Positioned(left: x, top: y, child: star);
      }),
    );
  }
}

// ═════════════════════════════════════════════
// NEBULA GLOW — subtle cosmic atmosphere
// ═════════════════════════════════════════════

class _NebulaGlow extends StatelessWidget {
  const _NebulaGlow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // Purple glow
        Positioned(
          left: size.width * 0.2,
          bottom: size.height * 0.25,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(begin: 0.4, duration: const Duration(seconds: 3))
              .then()
              .fadeOut(duration: const Duration(seconds: 3)),
        ),
        // Cyan glow
        Positioned(
          right: size.width * 0.15,
          bottom: size.height * 0.35,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentCyan.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(begin: 0.3, duration: const Duration(milliseconds: 3500))
              .then()
              .fadeOut(duration: const Duration(milliseconds: 3500)),
        ),
      ],
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
