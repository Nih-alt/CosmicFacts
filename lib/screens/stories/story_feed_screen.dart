import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/home_controller.dart';
import '../../models/space_article.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'article_detail_screen.dart';

// ═════════════════════════════════════════════
// CATEGORY DATA
// ═════════════════════════════════════════════

class _CategoryItem {
  final String label;      // display label shown in UI
  final String emoji;
  final String searchTerm; // term passed to API search
  const _CategoryItem(this.label, this.emoji, [String? searchTerm])
      : searchTerm = searchTerm ?? label;
}

// Maps display label → API search term for categories where they differ.
const _categorySearchTerms = <String, String>{
  'Space News': 'NASA',
  'India Space': 'ISRO',
};

const _allCategories = [
  _CategoryItem('All', ''),
  _CategoryItem('Space News', '\u{1F534}', 'NASA'),
  _CategoryItem('India Space', '\u{1F1EE}\u{1F1F3}', 'ISRO'),
  _CategoryItem('SpaceX', '\u{1F680}'),
  _CategoryItem('ESA', '\u{1F30D}'),
  _CategoryItem('Roscosmos', '\u{1F1F7}\u{1F1FA}'),
  _CategoryItem('Blue Origin', '\u{1F499}'),
  _CategoryItem('Rocket Lab', '\u{26A1}'),
  _CategoryItem('Missions', '\u{1F6F0}\u{FE0F}'),
  _CategoryItem('Science', '\u{1F52C}'),
];

// ═════════════════════════════════════════════
// BADGE GRADIENT PER SOURCE
// ═════════════════════════════════════════════

LinearGradient _badgeGradient(String source) {
  final s = source.toLowerCase();
  if (s.contains('nasa') || s.contains('isro')) {
    return const LinearGradient(colors: [AppColors.accentBlue, Color(0xFF5B3FD4)]);
  }
  if (s.contains('spacex')) {
    return const LinearGradient(colors: [AppColors.accentCyan, Color(0xFF0097A7)]);
  }
  if (s.contains('esa')) {
    return const LinearGradient(colors: [Color(0xFF00E096), Color(0xFF00A86B)]);
  }
  return const LinearGradient(colors: [AppColors.accentBlue, Color(0xFF5B3FD4)]);
}

// ═════════════════════════════════════════════
// CONTROLLER (session-scoped)
// ═════════════════════════════════════════════

class _FeedController extends GetxController {
  final currentPage = 0.obs;
  final liked = <int, bool>{}.obs;
  final bookmarked = <int, bool>{}.obs;
  final showSwipeHint = true.obs;
  final selectedCategory = 'All'.obs;
  final categoryArticles = <SpaceArticle>[].obs;
  final isCategoryLoading = false.obs;
  final categoryHasError = false.obs;
  int _categoryOffset = 0;
  final isCategoryLoadingMore = false.obs;

  void toggleLike(int id) => liked[id] = !(liked[id] ?? false);
  void toggleBookmark(int id) => bookmarked[id] = !(bookmarked[id] ?? false);
  bool isLiked(int id) => liked[id] ?? false;
  bool isBookmarked(int id) => bookmarked[id] ?? false;

  Future<void> selectCategory(String category) async {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    _categoryOffset = 0;
    categoryArticles.clear();
    categoryHasError.value = false;

    if (category == 'All') return; // Use home controller stories

    isCategoryLoading.value = true;
    final searchTerm = _categorySearchTerms[category] ?? category;
    final articles = await ApiService.getNewsByCategory(searchTerm);
    if (articles != null) {
      categoryArticles.assignAll(articles);
      _categoryOffset = articles.length;
    } else {
      categoryHasError.value = true;
    }
    isCategoryLoading.value = false;
  }

  Future<void> loadMoreCategoryArticles() async {
    if (isCategoryLoadingMore.value || selectedCategory.value == 'All') return;
    isCategoryLoadingMore.value = true;
    final searchTerm = _categorySearchTerms[selectedCategory.value] ?? selectedCategory.value;
    final articles = await ApiService.getNewsByCategory(
      searchTerm,
      offset: _categoryOffset,
    );
    if (articles != null && articles.isNotEmpty) {
      categoryArticles.addAll(articles);
      _categoryOffset += articles.length;
    }
    isCategoryLoadingMore.value = false;
  }

  Future<void> retryCategory() async {
    categoryHasError.value = false;
    isCategoryLoading.value = true;
    final searchTerm = _categorySearchTerms[selectedCategory.value] ?? selectedCategory.value;
    final articles = await ApiService.getNewsByCategory(searchTerm);
    if (articles != null) {
      categoryArticles.assignAll(articles);
      _categoryOffset = articles.length;
    } else {
      categoryHasError.value = true;
    }
    isCategoryLoading.value = false;
  }

  @override
  void onClose() {
    categoryArticles.close();
    super.onClose();
  }
}

// ═════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════

class StoryFeedScreen extends StatefulWidget {
  final int initialIndex;
  final String initialCategory;
  const StoryFeedScreen({super.key, this.initialIndex = 0, this.initialCategory = 'All'});

  @override
  State<StoryFeedScreen> createState() => _StoryFeedScreenState();
}

class _StoryFeedScreenState extends State<StoryFeedScreen> {
  late final PageController _pageController;
  late final _FeedController _feed;
  final _homeCtrl = Get.find<HomeController>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _feed = Get.put(_FeedController());
    _feed.currentPage.value = widget.initialIndex;

    if (widget.initialCategory != 'All') {
      _feed.selectCategory(widget.initialCategory);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _feed.showSwipeHint.value = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Defer deletion so Obx listeners in child widgets aren't
    // triggered on a disposed controller during the pop animation.
    Future.microtask(() => Get.delete<_FeedController>(force: true));
    super.dispose();
  }

  void _onPageChanged(int index) {
    _feed.currentPage.value = index;
    final isAll = _feed.selectedCategory.value == 'All';
    final stories = isAll ? _homeCtrl.stories : _feed.categoryArticles;
    if (index >= stories.length - 5) {
      if (isAll) {
        _homeCtrl.loadMoreStories();
      } else {
        _feed.loadMoreCategoryArticles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Safe area + category pills
          SafeArea(
            bottom: false,
            child: _buildCategoryPills(),
          ),
          // Stories
          Expanded(
            child: Obx(() {
              final isAll = _feed.selectedCategory.value == 'All';
              final stories = isAll ? _homeCtrl.stories : _feed.categoryArticles;
              final isLoading = isAll ? _homeCtrl.isLoading.value : _feed.isCategoryLoading.value;
              final hasError = !isAll && _feed.categoryHasError.value;

              if (stories.isEmpty && isLoading) {
                return _buildShimmerLoading();
              }

              if (hasError) {
                return _buildCategoryError();
              }

              if (stories.isEmpty) {
                return _buildEmptyState();
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
                        totalCount: stories.length,
                        isDark: _isDark,
                        feed: _feed,
                      );
                    },
                  ),
                  if ((isAll && _homeCtrl.isLoadingMore.value) ||
                      (!isAll && _feed.isCategoryLoadingMore.value))
                    const Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: CupertinoActivityIndicator(color: AppColors.accentBlue),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider(context),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(CupertinoIcons.back, size: 24,
                      color: AppColors.textPrimary(context)),
                ),
                const SizedBox(width: 12),
                Text('Space Stories',
                    style: GoogleFonts.spaceGrotesk(fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: Obx(() {
              // Read observable eagerly so Obx can track it
              // (itemBuilder is a lazy callback invisible to Obx).
              final selectedCat = _feed.selectedCategory.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _allCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _allCategories[index];
                  final isSelected = selectedCat == cat.label;
                  return GestureDetector(
                    onTap: () {
                      _feed.selectCategory(cat.label);
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                      _feed.currentPage.value = 0;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : (_isDark ? AppColors.cardDark : Colors.white),
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
                          if (cat.emoji.isNotEmpty) ...[
                            Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (_isDark ? Colors.white : AppColors.textPrimaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildCategoryError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle, size: 48,
              color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Obx(() => Text(
            'No stories found for ${_feed.selectedCategory.value}',
            style: GoogleFonts.spaceGrotesk(fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context)),
          )),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: _feed.retryCategory,
            child: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.doc_text, size: 48,
              color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text('No stories available',
              style: GoogleFonts.spaceGrotesk(fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: _homeCtrl.refreshData,
            child: Text('Refresh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SINGLE STORY PAGE
// ═════════════════════════════════════════════

class _StoryPage extends StatelessWidget {
  final SpaceArticle article;
  final int index;
  final int totalCount;
  final bool isDark;
  final _FeedController feed;

  const _StoryPage({
    required this.article,
    required this.index,
    required this.totalCount,
    required this.isDark,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LAYER 0: Base color + starfield
        Positioned.fill(
          child: Container(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          ),
        ),
        if (isDark) const Positioned.fill(child: _Starfield()),
        if (isDark) const _NebulaGlow(),

        // LAYER 1: Article image
        if (article.imageUrl.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              memCacheWidth: 800,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

        // LAYER 2: Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.97),
                      ],
                stops: const [0.0, 0.3, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // LAYER 3: Content
        SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: badge + time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: _badgeGradient(article.newsSite),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.newsSite,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(article.publishedAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.public, size: 24,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.5))
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms),

                    const SizedBox(height: 10),

                    Text(
                      article.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 150.ms),

                    const SizedBox(height: 12),

                    Text(
                      article.summary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.black.withValues(alpha: 0.7),
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 250.ms)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 250.ms),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => ArticleDetailScreen(article: article),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Read Full Article \u2192',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                    const SizedBox(height: 20),

                    Obx(() {
                      final liked = feed.isLiked(article.id);
                      final bookmarked = feed.isBookmarked(article.id);
                      final page = feed.currentPage.value;
                      return Row(
                        children: [
                          _ActionButton(
                            icon: liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                            color: liked
                                ? const Color(0xFFFF4D6A)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.4)),
                            onTap: () => feed.toggleLike(article.id),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: bookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                            color: bookmarked
                                ? AppColors.starGold
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.4)),
                            onTap: () => feed.toggleBookmark(article.id),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: CupertinoIcons.share,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.4),
                            onTap: () {},
                          ),
                          const Spacer(),
                          Text(
                            '${page + 1} of $totalCount',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
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
// STARFIELD
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
// NEBULA GLOW
// ═════════════════════════════════════════════

class _NebulaGlow extends StatelessWidget {
  const _NebulaGlow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
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
                  AppColors.accentBlue.withValues(alpha: 0.06),
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
