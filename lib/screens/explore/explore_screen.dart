import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/explore_controller.dart';
import '../../data/cosmic_tools.dart';
import '../../models/nasa_image.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shimmer/shimmer_box.dart';
import 'ar_sky_map_screen.dart';
import 'image_detail_screen.dart';
import 'nasa_gallery_screen.dart';
import 'solar_system_screen.dart';
import 'missions_3d_screen.dart';
import 'spacecraft_tracker_screen.dart';
import 'wallpapers_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();
  // Anchors the category-pills row so "See All →" can scroll it into view.
  final _galleryKey = GlobalKey();
  bool _searchFocused = false;

  ExploreController get _ctrl => Get.find<ExploreController>();
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const List<Map<String, String>> _categories = [
    {'label': 'All',        'icon': '✨', 'query': ''},
    {'label': 'JWST',       'icon': '🔭', 'query': 'james webb telescope'},
    {'label': 'Hubble',     'icon': '🌌', 'query': 'hubble space telescope'},
    {'label': 'Nebulae',    'icon': '☁️', 'query': 'nebula'},
    {'label': 'Galaxies',   'icon': '🌀', 'query': 'galaxy deep field'},
    {'label': 'Planets',    'icon': '🪐', 'query': 'planet solar system'},
    {'label': 'Earth',      'icon': '🌍', 'query': 'earth from space'},
    {'label': 'Stars',      'icon': '⭐', 'query': 'star cluster supernova'},
    {'label': 'Black Holes','icon': '🕳️', 'query': 'black hole accretion'},
    {'label': 'Mars',       'icon': '🔴', 'query': 'mars surface rover'},
    {'label': 'Launches',   'icon': '🚀', 'query': 'rocket launch'},
    {'label': 'Astronauts', 'icon': '👨‍🚀','query': 'astronaut spacewalk'},
    {'label': 'Wallpapers', 'icon': '🖼️', 'query': ''},
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _ctrl.loadMore();
    }
  }

  void _preloadImages(List images) {
    final count = min(6, images.length);
    for (var i = 0; i < count; i++) {
      precacheImage(
        CachedNetworkImageProvider(images[i].imageUrl as String),
        context,
      );
    }
  }

  void _openDetail(List<NasaImage> imgs, int index) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ImageDetailScreen(
          images: imgs,
          initialIndex: index,
        ),
      ),
    );
  }

  // ── Height factor for masonry tiles ──
  double _getHeightFactor(int index) {
    const patterns = [1.3, 0.9, 1.1, 1.5, 0.8, 1.2, 1.0, 1.4];
    return patterns[index % patterns.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background(context),
      child: SafeArea(
        bottom: false,
        // Single Obx wraps the CustomScrollView so all observable changes
        // trigger one rebuild. Scroll position is preserved by _scrollController.
        child: Obx(() {
          final isDark = _isDark;
          final hasError = _ctrl.hasError.value;
          final isLoading = _ctrl.isLoading.value;
          final imgs = _ctrl.images.toList();
          final jwstImgs = _ctrl.jwstImages.toList();
          final selectedCat = _ctrl.selectedCategory.value;

          // Warm cache for first visible images
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && imgs.isNotEmpty) _preloadImages(imgs);
          });

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            cacheExtent: 500,
            slivers: [
              // ══════════════════════════════════════
              // SECTION 1 — Top bar + Search
              // ══════════════════════════════════════
              SliverToBoxAdapter(child: _buildTopBar(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildSearchBar(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ══════════════════════════════════════
              // SECTION 2 — JWST Featured
              // ══════════════════════════════════════
              SliverToBoxAdapter(
                child: _buildJWSTHeader(isDark),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: jwstImgs.isEmpty
                      ? _buildJWSTShimmer()
                      : _buildJWSTCarousel(jwstImgs, isDark),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ══════════════════════════════════════
              // SECTION 3 — Interactive Experiences
              // ══════════════════════════════════════
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  '🚀 Interactive Experiences',
                  isDark,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFB100FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildInteractiveCards()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ══════════════════════════════════════
              // SECTION 3.5 — Cosmic Tools (discoverability hub)
              // ══════════════════════════════════════
              SliverToBoxAdapter(child: _buildCosmicToolsSection(isDark)),

              // ══════════════════════════════════════
              // SECTION 4 — Category pills
              // ══════════════════════════════════════
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _galleryKey,
                  child: _buildCategoryPills(isDark, selectedCat),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ══════════════════════════════════════
              // SECTION 5 — Image Gallery header
              // ══════════════════════════════════════
              SliverToBoxAdapter(
                child: _buildGalleryHeader(imgs.length, isDark),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ══════════════════════════════════════
              // SECTION 6 — Masonry grid / states
              // ══════════════════════════════════════
              if (hasError && imgs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildError(),
                )
              else if (isLoading && imgs.isEmpty)
                _buildShimmerSliver()
              else if (imgs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(),
                )
              else ...[
                // Preview grid: first 6 images only — full gallery lives
                // in NasaGalleryScreen.
                _buildMasonrySliver(imgs.take(6).toList(), isDark),
                SliverToBoxAdapter(
                  child: _buildViewFullGalleryButton(isDark),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 1: Top bar ──
  // ══════════════════════════════════════
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Explore',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF0D0D2E),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => _buildFilterSheet(context),
              );
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 1: Search bar ──
  // ══════════════════════════════════════
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface(context) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchFocused
                ? AppColors.accentBlue.withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
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
              : (isDark
                  ? const <BoxShadow>[]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]),
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
    );
  }

  // ══════════════════════════════════════
  // ── Section header (reusable) ──
  // ══════════════════════════════════════
  Widget _buildSectionHeader(
    String title,
    bool isDark, {
    LinearGradient? gradient,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: gradient ??
                  const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 2: JWST Featured ──
  // ══════════════════════════════════════
  Widget _buildJWSTHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Row(children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '✨ James Webb Telescope',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ]),
          ),
          TextButton(
            onPressed: () {
              _ctrl.filterByCategory('JWST');
              // Selecting the pill is reactive (controller's selectedCategory
              // drives the pill highlight via Obx). Scroll down after a short
              // delay so the filter has a chance to apply first.
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                final ctx = _galleryKey.currentContext;
                if (ctx == null || !ctx.mounted) return;
                Scrollable.ensureVisible(
                  ctx,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  alignment: 0.0,
                );
              });
            },
            child: const Text(
              'See All →',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJWSTCarousel(List<NasaImage> jwstImages, bool isDark) {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.88),
      itemCount: jwstImages.length.clamp(0, 5),
      itemBuilder: (context, index) {
        final img = jwstImages[index];
        return GestureDetector(
          onTap: () => _openDetail(jwstImages, index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF)
                      .withValues(alpha: isDark ? 0.3 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: img.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 700,
                    placeholder: (c, u) => Container(
                      color: isDark
                          ? const Color(0xFF141438)
                          : const Color(0xFFEEEEFF),
                    ),
                    errorWidget: (c, u, e) => Container(
                      color: const Color(0xFF141438),
                      child: const Icon(Icons.broken_image,
                          color: Colors.white30),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF)
                            .withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'JWST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 3: Interactive Experiences ──
  // ══════════════════════════════════════
  Widget _buildInteractiveCards() {
    return Column(
      children: [
        // 1. AR Sky Map
        _buildExperienceCard(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const ArSkyMapScreen()),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1A0A3A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
          ),
          icon: Icons.camera_alt_outlined,
          title: 'AR Sky Map',
          subtitle: 'Point at sky to identify stars & planets',
          badge: _buildPillBadge(
            text: 'LIVE',
            color: const Color(0xFF6C63FF),
            bgAlpha: 0.2,
          ),
        ),

        // 2. 3D Solar System
        _buildExperienceCard(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const SolarSystemScreen()),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0A0A), Color(0xFF2A1A00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderColor: const Color(0xFFFFB800).withValues(alpha: 0.4),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFF6D00)],
          ),
          icon: Icons.public,
          title: '3D Solar System',
          subtitle: 'Explore all 8 planets interactively',
          badge: _buildPillBadge(
            text: '3D',
            color: const Color(0xFFFFB800),
            bgAlpha: 0.15,
          ),
        ),

        // 3. Spacecraft Tracker
        _buildExperienceCard(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => const SpacecraftTrackerScreen()),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF001A2E), Color(0xFF0A0A1A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderColor: const Color(0xFF00E676).withValues(alpha: 0.35),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF00B4D8)],
          ),
          icon: Icons.track_changes,
          title: 'Spacecraft Tracker',
          subtitle: 'ISS \u2022 Hubble \u2022 JWST \u2014 Live',
          badge: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Historic Missions 3D
        _buildExperienceCard(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => const Missions3DScreen()),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0A0A), Color(0xFF0A1A2A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderColor: const Color(0xFFFFB800).withValues(alpha: 0.4),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFF6D00)],
          ),
          icon: Icons.rocket_launch_outlined,
          title: 'Historic Missions 3D',
          subtitle: 'Voyager \u2022 Rovers \u2022 Cassini \u2022 Apollo',
          badge: _buildPillBadge(
            text: '3D',
            color: const Color(0xFFFFB800),
            bgAlpha: 0.15,
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceCard({
    required VoidCallback onTap,
    required LinearGradient gradient,
    required Color borderColor,
    required LinearGradient iconGradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              badge,
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required String text,
    required Color color,
    required double bgAlpha,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 4: Category pills ──
  // ══════════════════════════════════════
  Widget _buildCategoryPills(bool isDark, String selectedCat) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final label = cat['label']!;
          final isSelected = label == selectedCat;
          return GestureDetector(
            onTap: () {
              if (label == 'Wallpapers') {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const WallpapersScreen(),
                  ),
                );
                return;
              }
              _ctrl.filterByCategory(label);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : (isDark ? const Color(0xFF141438) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.12)),
                  width: 1,
                ),
                boxShadow: isSelected && !isDark
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF)
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat['icon']!,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    label,
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
        },
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 5: Image Gallery header ──
  // ══════════════════════════════════════
  Widget _buildGalleryHeader(int count, bool isDark) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const NasaGalleryScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4D8), Color(0xFF6C63FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '🖼️ Space Image Gallery',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF6C63FF),
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── "View Full Gallery" button shown below the 6-image preview grid ──
  Widget _buildViewFullGalleryButton(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const NasaGalleryScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141438) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, color: Color(0xFF6C63FF), size: 18),
            SizedBox(width: 8),
            Text(
              'View Full Gallery',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward,
                color: Color(0xFF6C63FF), size: 16),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // ── SECTION 6: Masonry grid sliver ──
  // ══════════════════════════════════════
  Widget _buildMasonrySliver(List<NasaImage> displayImages, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childCount: displayImages.length,
        itemBuilder: (context, index) {
          final img = displayImages[index];
          final heightFactor = _getHeightFactor(index);
          return GestureDetector(
            onTap: () => _openDetail(displayImages, index),
            child: _buildMasonryTile(img, heightFactor, isDark),
          );
        },
      ),
    );
  }

  Widget _buildMasonryTile(
      NasaImage img, double heightFactor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
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
              height: 140 * heightFactor,
              memCacheWidth: 400,
              placeholder: (context, url) => Container(
                height: 140 * heightFactor,
                color: isDark
                    ? const Color(0xFF141438)
                    : const Color(0xFFEEEEFF),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color:
                          const Color(0xFF6C63FF).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              errorWidget: (c, u, e) => Container(
                height: 140 * heightFactor,
                color: isDark
                    ? const Color(0xFF141438)
                    : const Color(0xFFEEEEFF),
                child: Center(
                  child: Icon(Icons.stars_rounded,
                      color:
                          const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      size: 32),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shimmer sliver for initial loading ──
  Widget _buildShimmerSliver() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childCount: 8,
        itemBuilder: (_, i) {
          const patterns = [1.3, 0.9, 1.1, 1.5, 0.8, 1.2, 1.0, 1.4];
          final h = 140 * patterns[i % patterns.length];
          return ShimmerBox(height: h, borderRadius: 14);
        },
      ),
    );
  }

  // ── JWST shimmer placeholder ──
  Widget _buildJWSTShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 3,
      itemBuilder: (_, i) => const ShimmerBox(
        width: 280,
        height: 180,
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 6),
      ),
    );
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

  // ═════════════════════════════════════════════
  // FILTER / SORT BOTTOM SHEET
  // ═════════════════════════════════════════════

  Widget _buildFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141438) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Sort & Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SORT BY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              ['Latest First', Icons.new_releases_outlined],
              ['Oldest First', Icons.history],
              ['A \u2192 Z', Icons.sort_by_alpha],
            ].map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item[1] as IconData,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                  title: Text(
                    item[0] as String,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                )),
            const SizedBox(height: 8),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 8),
            Text(
              'VIEW',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              ['Grid View', Icons.grid_view],
              ['List View', Icons.view_list_outlined],
            ].map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item[1] as IconData,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                  title: Text(
                    item[0] as String,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                )),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  // SECTION 3.5 — COSMIC TOOLS
  // Categorized hub that surfaces specialized features
  // (live data, calculators, imagery, explorers).
  // ═════════════════════════════════════════════

  Widget _buildCosmicToolsSection(bool isDark) {
    final grouped = CosmicTools.grouped;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCosmicToolsHeader(isDark),
        for (final cat in CosmicTools.categoryOrder)
          if ((grouped[cat] ?? const []).isNotEmpty)
            _buildToolCategory(cat, grouped[cat]!, isDark),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCosmicToolsHeader(bool isDark) {
    final primaryText =
        isDark ? Colors.white : const Color(0xFF0A1628);
    final secondaryText = AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cosmic Tools',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explore live data, calculators & galleries',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCategory(
    String category,
    List<CosmicTool> tools,
    bool isDark,
  ) {
    final accent = CosmicTools.categoryAccents[category]!;
    final icon = CosmicTools.categoryIcons[category]!;
    final name = CosmicTools.categoryNames[category]!;
    final secondaryText = AppColors.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: accent,
                ),
              ),
              const Spacer(),
              Text(
                '${tools.length} tools',
                style: TextStyle(
                  fontSize: 11,
                  color: secondaryText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tools.length,
            itemBuilder: (ctx, i) => _buildToolCard(tools[i], isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(CosmicTool tool, bool isDark) {
    final primaryText =
        isDark ? Colors.white : const Color(0xFF0A1628);
    final secondaryText = AppColors.textSecondary(context);
    final cardBg = isDark ? const Color(0xFF0F1428) : Colors.white;
    final accent = tool.accentColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => tool.screenBuilder()),
        );
      },
      child: Container(
        width: 200,
        height: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.25),
          ),
          boxShadow: isDark
              ? const <BoxShadow>[]
              : [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.3),
                        accent.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(tool.icon, size: 20, color: accent),
                ),
                const Spacer(),
                if (tool.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tool.badge!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              tool.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tool.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: secondaryText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
