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

  ExploreController get _ctrl => Get.find<ExploreController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 400) {
      _ctrl.loadMore();
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
          children: [
            // ── Top bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explore',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Wallpapers banner ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const WallpapersScreen()),
                ),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPurple, AppColors.accentCyan],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.photo_on_rectangle,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Space Wallpapers',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('HD cosmic wallpapers for your phone',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right,
                          color: Colors.white.withValues(alpha: 0.7), size: 16),
                    ],
                  ),
                ),
              ),
            ),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CupertinoTextField(
                controller: _ctrl.searchTextController,
                onChanged: _ctrl.onSearchChanged,
                onSubmitted: (q) {
                  if (q.trim().isNotEmpty) _ctrl.searchImages(q.trim());
                },
                placeholder: 'Search galaxies, nebulae, planets...',
                placeholderStyle: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary(context)),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary(context)),
                cursorColor: AppColors.accentPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.searchBar(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.cardShadow(context),
                ),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.search,
                      size: 18, color: AppColors.textSecondary(context)),
                ),
                suffix: Obx(() {
                  if (!_ctrl.isSearching.value) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: _ctrl.clearSearch,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(CupertinoIcons.xmark_circle_fill,
                          size: 18, color: AppColors.textSecondary(context)),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // ── Category pills ──
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ExploreController.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = ExploreController.categories[i];
                  return Obx(() {
                    final selected = cat == _ctrl.selectedCategory.value;
                    return GestureDetector(
                      onTap: () => _ctrl.filterByCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient:
                              selected ? AppColors.primaryGradient : null,
                          color: selected ? null : AppColors.card(context),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected ? null : AppColors.cardShadow(context),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 8),

            // ── Grid content ──
            Expanded(child: _buildGridArea()),
          ],
        ),
      ),
    );
  }

  // ── Grid area (switches between loading/error/empty/grid) ──

  Widget _buildGridArea() {
    return Obx(() {
      if (_ctrl.hasError.value && _ctrl.images.isEmpty) {
        return _buildError();
      }
      if (_ctrl.isLoading.value && _ctrl.images.isEmpty) {
        return _ShimmerGrid();
      }
      if (_ctrl.images.isEmpty) {
        return _buildEmpty();
      }
      return _buildImageGrid();
    });
  }

  Widget _buildImageGrid() {
    final images = _ctrl.images;

    return Obx(() {
      final loadingMore = _ctrl.isLoadingMore.value;
      final count = images.length + (loadingMore ? 3 : 0);

      return GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.72,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          if (index >= images.length) {
            return _buildShimmerTile();
          }
          return _buildImageTile(images[index], index);
        },
      );
    });
  }

  Widget _buildImageTile(NasaImage image, int index) {
    return GestureDetector(
      onTap: () => _openDetail(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: AppColors.card(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, _) => Container(
                    color: AppColors.card(context),
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 8,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.card(context),
                    child: Center(
                      child: Icon(CupertinoIcons.star,
                          size: 20, color: AppColors.textSecondary(context)),
                    ),
                  ),
                ),
              ),
              // Title strip
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                color: AppColors.surface(context),
                child: Text(
                  image.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary(context).withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerTile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase(context),
        highlightColor: AppColors.shimmerHighlight(context),
        child: Container(color: AppColors.shimmerBase(context)),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.wifi_slash,
              size: 48, color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text("Couldn't load images",
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentPurple,
            borderRadius: BorderRadius.circular(12),
            onPressed: _ctrl.loadTrendingImages,
            child: Text('Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.search,
              size: 48, color: AppColors.textSecondary(context)),
          const SizedBox(height: 12),
          Text('No images found',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 4),
          Text('Try a different search term',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SHIMMER GRID
// ═════════════════════════════════════════════

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.72,
      ),
      itemCount: 12,
      itemBuilder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase(context),
          highlightColor: AppColors.shimmerHighlight(context),
          child: Container(color: AppColors.shimmerBase(context)),
        ),
      ),
    );
  }
}
