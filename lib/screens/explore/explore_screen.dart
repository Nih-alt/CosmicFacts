import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/explore_controller.dart';
import '../../models/nasa_image.dart';
import '../../theme/app_colors.dart';
import 'image_detail_screen.dart';
import 'wallpapers_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();
  bool _searchFocused = false;

  ExploreController get _ctrl => Get.find<ExploreController>();
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Controller categories + Wallpapers as a special nav pill
  static const _displayCategories = [
    'All', 'Galaxies', 'Nebulae', 'Planets', 'Earth',
    'Rockets', 'Astronauts', 'Moon', 'Stars', 'JWST', 'Wallpapers',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 400) {
      _ctrl.loadMore();
    }
  }

  /// Warms the image cache for the first few grid images so they appear
  /// instantly when the grid renders.
  void _preloadImages(List images) {
    final count = min(6, images.length);
    for (var i = 0; i < count; i++) {
      precacheImage(
        CachedNetworkImageProvider(images[i].imageUrl as String),
        context,
      );
    }
  }

  void _openDetail(int index) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ImageDetailScreen(
          images: _ctrl.images.toList(),
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explore',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder(context),
                      ),
                      boxShadow: AppColors.cardShadow(context),
                    ),
                    child: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      size: 18,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _searchFocused
                        ? AppColors.accentBlue.withValues(alpha: 0.6)
                        : AppColors.cardBorder(context),
                    width: _searchFocused ? 1.5 : 1.0,
                  ),
                  boxShadow: _searchFocused
                      ? [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : AppColors.cardShadow(context),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl.searchTextController,
                        focusNode: _searchFocusNode,
                        onChanged: _ctrl.onSearchChanged,
                        onSubmitted: (q) {
                          if (q.trim().isNotEmpty) _ctrl.searchImages(q.trim());
                        },
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textPrimary(context),
                        ),
                        cursorColor: AppColors.accentBlue,
                        decoration: InputDecoration(
                          hintText: 'Search the cosmos...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary(context)
                                .withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (!_ctrl.isSearching.value) {
                        return const SizedBox(width: 14);
                      }
                      return GestureDetector(
                        onTap: _ctrl.clearSearch,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 18,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Category pills ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20),
                itemCount: _displayCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final cat = _displayCategories[i];
                  return Obx(() {
                    final selected = cat == _ctrl.selectedCategory.value;
                    return GestureDetector(
                      onTap: () {
                        if (cat == 'Wallpapers') {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const WallpapersScreen(),
                            ),
                          );
                          return;
                        }
                        _ctrl.filterByCategory(cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient:
                              selected ? AppColors.primaryGradient : null,
                          color: selected
                              ? null
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : AppColors.cardBorder(context),
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.accentBlue
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : AppColors.cardShadow(context),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Grid / content area ──
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    return Obx(() {
      if (_ctrl.hasError.value && _ctrl.images.isEmpty) {
        return _buildError();
      }
      if (_ctrl.isLoading.value && _ctrl.images.isEmpty) {
        return const _ShimmerGrid();
      }
      if (_ctrl.images.isEmpty) {
        return _buildEmpty();
      }
      return _buildImageList();
    });
  }

  Widget _buildImageList() {
    return Obx(() {
      final images = _ctrl.images.toList();
      final loadingMore = _ctrl.isLoadingMore.value;
      final items = _buildLayoutItems(images);

      // Warm the cache for the first visible items
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _preloadImages(images);
      });

      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: items.length + (loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CupertinoActivityIndicator(
                    color: AppColors.accentBlue),
              ),
            );
          }
          final item = items[i];
          if (item is _FeaturedItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeaturedCard(
                image: item.image,
                onTap: () => _openDetail(item.imageIndex),
              ),
            );
          }
          final pair = item as _PairItem;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ImageCard(
                      image: pair.left,
                      onTap: () => _openDetail(pair.leftIndex),
                      isDark: _isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: pair.right != null
                        ? _ImageCard(
                            image: pair.right!,
                            onTap: () => _openDetail(pair.rightIndex!),
                            isDark: _isDark,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  List<Object> _buildLayoutItems(List<NasaImage> images) {
    final items = <Object>[];
    int i = 0;
    while (i < images.length) {
      if (i % 7 == 0) {
        items.add(_FeaturedItem(image: images[i], imageIndex: i));
        i++;
      } else {
        final left = images[i];
        final leftIndex = i;
        i++;
        if (i < images.length) {
          items.add(_PairItem(
              left: left,
              leftIndex: leftIndex,
              right: images[i],
              rightIndex: i));
          i++;
        } else {
          items.add(_PairItem(left: left, leftIndex: leftIndex));
        }
      }
    }
    return items;
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.wifi_slash,
                  size: 32, color: AppColors.accentBlue),
            ),
            const SizedBox(height: 20),
            Text(
              "Couldn't load images",
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _ctrl.loadTrendingImages,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.photo,
            size: 56,
            color: AppColors.textSecondary(context).withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'No images found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// LAYOUT ITEMS (plain classes — no sealed needed)
// ═════════════════════════════════════════════

class _FeaturedItem {
  final NasaImage image;
  final int imageIndex;
  const _FeaturedItem({required this.image, required this.imageIndex});
}

class _PairItem {
  final NasaImage left;
  final int leftIndex;
  final NasaImage? right;
  final int? rightIndex;
  const _PairItem({
    required this.left,
    required this.leftIndex,
    this.right,
    this.rightIndex,
  });
}

// ═════════════════════════════════════════════
// FEATURED CARD — full width, 200px, overlaid title
// ═════════════════════════════════════════════

class _FeaturedCard extends StatelessWidget {
  final NasaImage image;
  final VoidCallback onTap;

  const _FeaturedCard({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => ColoredBox(
                  color: AppColors.card(ctx),
                  child: const Center(
                    child: CupertinoActivityIndicator(
                        color: AppColors.accentBlue),
                  ),
                ),
                errorWidget: (ctx, url, err) => ColoredBox(
                  color: AppColors.card(ctx),
                  child: const Center(
                    child: Icon(Icons.star_border,
                        color: AppColors.accentBlue, size: 40),
                  ),
                ),
              ),
              // Dark gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
              // Badge + title
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NASA Featured',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      image.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// NORMAL IMAGE CARD — 2-column, square image + title strip
// ═════════════════════════════════════════════

class _ImageCard extends StatelessWidget {
  final NasaImage image;
  final VoidCallback onTap;
  final bool isDark;

  const _ImageCard({
    required this.image,
    required this.onTap,
    required this.isDark,
  });

  Widget _buildErrorWidget(BuildContext context) {
    // Try the original ~thumb.jpg URL as a last-resort fallback display
    return ColoredBox(
      color: AppColors.card(context),
      child: const Center(
        child: Icon(Icons.star_border, color: AppColors.accentBlue, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface(context),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (square)
              AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  filterQuality: FilterQuality.medium,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (ctx, url) => ColoredBox(
                    color: AppColors.card(ctx),
                    child: const Center(
                      child: CupertinoActivityIndicator(
                          color: AppColors.accentBlue),
                    ),
                  ),
                  errorWidget: (ctx, url, err) => _buildErrorWidget(ctx),
                ),
              ),
              // Title strip
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Text(
                  image.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                    height: 1.35,
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

// ═════════════════════════════════════════════
// SHIMMER GRID — mirrors featured + pair layout
// ═════════════════════════════════════════════

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: 5,
      itemBuilder: (_, i) {
        // Every 3rd item mirrors a featured slot
        if (i % 3 == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _shimmerBox(
                height: 200, radius: 20, base: base, highlight: highlight),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _shimmerBox(
                    height: 190, radius: 20, base: base, highlight: highlight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shimmerBox(
                    height: 190, radius: 20, base: base, highlight: highlight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double height,
    required double radius,
    required Color base,
    required Color highlight,
  }) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
