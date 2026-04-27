import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../controllers/explore_controller.dart';
import '../../models/nasa_image.dart';
import '../../widgets/shimmer/shimmer_box.dart';
import 'image_detail_screen.dart';

/// Dedicated full-screen NASA Image Gallery.
///
/// Reuses the shared [ExploreController] — does NOT instantiate a new one.
/// All search / filter / pagination state stays in sync with the Explore tab.
class NasaGalleryScreen extends StatefulWidget {
  const NasaGalleryScreen({super.key});

  @override
  State<NasaGalleryScreen> createState() => _NasaGalleryScreenState();
}

class _NasaGalleryScreenState extends State<NasaGalleryScreen> {
  final _scrollController = ScrollController();
  late final ExploreController exploreController;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const List<Map<String, String>> _galleryCategories = [
    {'label': 'All',         'icon': '✨'},
    {'label': 'JWST',        'icon': '🔭'},
    {'label': 'Hubble',      'icon': '🌌'},
    {'label': 'Nebulae',     'icon': '☁️'},
    {'label': 'Galaxies',    'icon': '🌀'},
    {'label': 'Planets',     'icon': '🪐'},
    {'label': 'Earth',       'icon': '🌍'},
    {'label': 'Stars',       'icon': '⭐'},
    {'label': 'Black Holes', 'icon': '🕳️'},
    {'label': 'Mars',        'icon': '🔴'},
    {'label': 'Launches',    'icon': '🚀'},
    {'label': 'Astronauts',  'icon': '👨‍🚀'},
  ];

  @override
  void initState() {
    super.initState();
    exploreController = Get.find<ExploreController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      exploreController.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF5F5FF),
      body: Column(
        children: [
          // ── TOP BAR ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141438)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Space Image Gallery',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Text(
                              '${exploreController.images.length} images loaded',
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 11,
                              ),
                            )),
                        Text(
                          'Images courtesy NASA Public Domain',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.black38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141438) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: TextField(
                controller: exploreController.searchTextController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search galaxies, nebulae, planets...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 20,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: exploreController.searchTextController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          exploreController.clearSearch();
                        },
                        child: Icon(
                          Icons.close,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 18,
                        ),
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (q) {
                  if (q.trim().isNotEmpty) {
                    exploreController.searchImages(q.trim());
                  }
                },
                onChanged: (q) {
                  if (q.isEmpty) exploreController.clearSearch();
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── CATEGORY PILLS ──
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _galleryCategories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _galleryCategories[index];
                return Obx(() {
                  final isSelected =
                      exploreController.selectedCategory.value ==
                          cat['label'];
                  return GestureDetector(
                    onTap: () =>
                        exploreController.filterByCategory(cat['label']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : (isDark
                                ? const Color(0xFF141438)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['icon']!,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            cat['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF444466)),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── GRID ──
          Expanded(
            child: Obx(() {
              final images = exploreController.images.toList();

              if (exploreController.isLoading.value && images.isEmpty) {
                return _buildShimmer(isDark);
              }

              if (images.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No images found',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return MasonryGridView.count(
                controller: _scrollController,
                cacheExtent: 500,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                itemCount: images.length + 1,
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return Obx(() => exploreController.isLoadingMore.value
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink());
                  }

                  final img = images[index];
                  const heights = [1.3, 0.9, 1.1, 1.5, 0.8, 1.2, 1.0, 1.4];
                  final h = heights[index % heights.length];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ImageDetailScreen(
                          images: images,
                          initialIndex: index,
                        ),
                      ),
                    ),
                    child: _buildTile(img, h, isDark),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(NasaImage img, double h, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: img.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 140 * h,
              memCacheWidth: 400,
              placeholder: (c, u) => Container(
                height: 140 * h,
                color: isDark
                    ? const Color(0xFF141438)
                    : const Color(0xFFEEEEFF),
              ),
              errorWidget: (c, u, e) => Container(
                height: 140 * h,
                color: isDark
                    ? const Color(0xFF141438)
                    : const Color(0xFFEEEEFF),
                child: Center(
                  child: Icon(
                    Icons.stars_rounded,
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    size: 32,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  img.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  img.center.isNotEmpty ? img.center : 'NASA',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DRIFT FIX: previously used inline purple-tinted hex (0xFF141438 /
  // 0xFFEEEEFF). Now routed through ShimmerBox → AppColors.shimmer*,
  // matching the rest of the app. Visually slightly bluer.
  Widget _buildShimmer(bool isDark) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 10,
      itemBuilder: (_, i) {
        const heights = [1.3, 0.9, 1.1, 1.5, 0.8, 1.2, 1.0, 1.4];
        final h = heights[i % heights.length];
        return ShimmerBox(height: 140 * h, borderRadius: 14);
      },
    );
  }
}
