import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/bookmark_controller.dart';
import '../../controllers/explore_controller.dart';
import '../../models/bookmark_model.dart';
import '../../models/nasa_image.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

// ═════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════

String _formatNasaDate(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

// ═════════════════════════════════════════════
// TOP-LEVEL: PageView wrapper
// ═════════════════════════════════════════════

class ImageDetailScreen extends StatefulWidget {
  final List<NasaImage> images;
  final int initialIndex;

  const ImageDetailScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemCount: widget.images.length,
        itemBuilder: (context, index) => _DetailPage(
          image: widget.images[index],
          pageIndex: index,
          totalCount: widget.images.length,
          pageController: _pageController,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SINGLE PAGE
// ═════════════════════════════════════════════

class _DetailPage extends StatefulWidget {
  final NasaImage image;
  final int pageIndex;
  final int totalCount;
  final PageController pageController;

  const _DetailPage({
    required this.image,
    required this.pageIndex,
    required this.totalCount,
    required this.pageController,
  });

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage> {
  final _transformController = TransformationController();
  Timer? _hintTimer;

  bool _hintVisible = true;
  bool _descExpanded = false;
  List<NasaImage> _related = [];
  bool _relatedLoading = true;
  late String _currentImageUrl;

  NasaImage get img => widget.image;

  // Theme shortcuts used throughout
  Color get _textPrimary => AppColors.textPrimary(context);
  Color get _textSecondary => AppColors.textSecondary(context);
  Color get _cardColor => AppColors.card(context);
  Color get _borderColor => AppColors.cardBorder(context);
  Color get _contentBg => AppColors.background(context);

  @override
  void initState() {
    super.initState();
    // Show medium URL immediately — hero appears without delay
    _currentImageUrl = img.imageUrl;
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hintVisible = false);
    });
    // Delay related load so hero image gets bandwidth first
    Future.delayed(const Duration(milliseconds: 700), _loadRelated);
    // Silently pre-cache the large URL, then swap when ready
    _upgradeToLarge();
  }

  @override
  void dispose() {
    _transformController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRelated() async {
    if (!mounted || img.keywords.isEmpty) {
      if (mounted) setState(() => _relatedLoading = false);
      return;
    }
    try {
      final results = await ApiService.searchNasaImages(
          query: img.keywords.first, page: 1);
      if (mounted) {
        setState(() {
          _related = results
              .where((r) => r.nasaId != img.nasaId)
              .take(8)
              .toList();
          _relatedLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _relatedLoading = false);
    }
  }

  /// Upgrades the hero image to the highest available quality URL.
  /// 1. HEAD ~large.jpg to confirm it exists on CDN.
  /// 2. If not, query the NASA asset manifest for the best available variant.
  /// 3. Pre-cache the confirmed URL, then swap the hero seamlessly.
  Future<void> _upgradeToLarge() async {
    final largeUrl = img.largeImageUrl;
    if (largeUrl.isEmpty) return;

    String? confirmedUrl;

    // Step 1: Verify ~large.jpg exists via HEAD request
    try {
      final resp = await http
          .head(Uri.parse(largeUrl))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        confirmedUrl = largeUrl;
      }
    } catch (_) {
      // Network error or timeout — fall through to manifest lookup
    }

    // Step 2: Asset manifest fallback — find best available URL
    if (confirmedUrl == null && img.nasaId.isNotEmpty) {
      try {
        final manifestResp = await http
            .get(Uri.parse(
                'https://images-api.nasa.gov/asset/${img.nasaId}'))
            .timeout(const Duration(seconds: 8));
        if (manifestResp.statusCode == 200) {
          final body =
              jsonDecode(manifestResp.body) as Map<String, dynamic>;
          final items =
              (body['collection']?['items'] as List?) ?? [];
          final urls = items
              .map((e) => (e['href'] as String?) ?? '')
              .where((u) =>
                  u.endsWith('.jpg') ||
                  u.endsWith('.jpeg') ||
                  u.endsWith('.png'))
              .toList();
          // Prefer ~large, then ~orig, then any image URL
          final found = urls.firstWhere(
            (u) => u.contains('~large'),
            orElse: () => urls.firstWhere(
              (u) => u.contains('~orig'),
              orElse: () => '',
            ),
          );
          if (found.isNotEmpty) confirmedUrl = found;
        }
      } catch (_) {
        // Manifest unavailable — keep thumb
      }
    }

    if (confirmedUrl == null || confirmedUrl == img.imageUrl) return;

    // Step 3: Pre-cache before swapping so the hero never shows a blank frame
    try {
      await precacheImage(
        CachedNetworkImageProvider(confirmedUrl),
        // ignore: use_build_context_synchronously
        context,
      );
      if (mounted) {
        setState(() => _currentImageUrl = confirmedUrl!);
      }
    } catch (_) {
      // Keep thumb if caching fails
    }
  }

  /// Current hero URL: starts as medium, upgrades to large once cached.
  String get _displayUrl => _currentImageUrl;

  void _onDoubleTapDown(TapDownDetails d) {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else {
      const s = 2.5;
      final m = Matrix4.identity();
      m.setEntry(0, 0, s);
      m.setEntry(1, 1, s);
      m.setEntry(2, 2, s);
      m.setEntry(0, 3, -d.localPosition.dx * (s - 1));
      m.setEntry(1, 3, -d.localPosition.dy * (s - 1));
      _transformController.value = m;
    }
  }

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(ShareParams(
        text:
            '${img.title}\n\nNASA / ${img.center}\n\nShared via Cosmic Facts 🌌',
      ));
    } catch (_) {}
  }

  Future<void> _openInBrowser() async {
    try {
      await launchUrl(Uri.parse(img.imageUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  bool get _isBookmarked {
    try {
      return Get.find<BookmarkController>().isBookmarked(img.nasaId);
    } catch (_) {
      return false;
    }
  }

  void _toggleBookmark() {
    try {
      final ctrl = Get.find<BookmarkController>();
      ctrl.toggleBookmark(BookmarkModel(
        id: img.nasaId,
        type: 'image',
        title: img.title,
        subtitle: img.center,
        imageUrl: img.imageUrl,
        data: jsonEncode({
          'nasa_id': img.nasaId,
          'title': img.title,
          'description': img.description,
          'image_url': img.imageUrl,
          'date_created': img.dateCreated,
          'center': img.center,
          'keywords': img.keywords,
        }),
        savedAt: DateTime.now(),
      ));
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.sizeOf(context).height * 0.55;
    return Scaffold(
      backgroundColor: _contentBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(imageHeight)),
          SliverToBoxAdapter(
            child: _buildContent()
                .animate()
                .fadeIn(duration: 380.ms, delay: 120.ms)
                .slideY(begin: 0.08, end: 0, duration: 380.ms, delay: 120.ms),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // HERO — 55% height, zoom, overlay buttons
  // ─────────────────────────────────────────

  Widget _buildHero(double imageHeight) {
    return SizedBox(
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image + pinch-to-zoom
          ClipRect(
            child: GestureDetector(
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: () {},
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: _displayUrl,
                  width: double.infinity,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                  filterQuality: FilterQuality.high,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (ctx, url) => Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase(ctx),
                    highlightColor: AppColors.shimmerHighlight(ctx),
                    child: Container(
                        height: imageHeight,
                        color: AppColors.card(ctx)),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    height: imageHeight,
                    color: AppColors.surface(ctx),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_border,
                              color: AppColors.accentBlue, size: 52),
                          const SizedBox(height: 12),
                          Text('Image unavailable',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom gradient — last 30%
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: imageHeight * 0.32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),

          // Top bar (back + share + bookmark)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: CupertinoIcons.back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _CircleButton(
                        icon: CupertinoIcons.share, onTap: _share),
                    const SizedBox(width: 10),
                    _CircleButton(
                      icon: _isBookmarked
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      onTap: _toggleBookmark,
                      filled: _isBookmarked,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom overlay — counter + dots + hint
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Pinch hint fades out
                AnimatedOpacity(
                  opacity: _hintVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.52),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pinch_outlined,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text('Pinch to zoom',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color:
                                    Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Counter + dots
                if (widget.totalCount > 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.pageIndex + 1} of ${widget.totalCount}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.totalCount <= 15)
                        SmoothPageIndicator(
                          controller: widget.pageController,
                          count: widget.totalCount,
                          effect: const WormEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            spacing: 6,
                            activeDotColor: Colors.white,
                            dotColor: Color(0x55FFFFFF),
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

  // ─────────────────────────────────────────
  // CONTENT — scrollable section below hero
  // ─────────────────────────────────────────

  Widget _buildContent() {
    return Container(
      color: _contentBg,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A) Source row
          _buildSourceRow(),
          const SizedBox(height: 14),

          // B) Title
          Text(
            img.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 22),

          // C) 3 stat cards
          _buildStatsRow(),
          const SizedBox(height: 24),

          // D) Gradient divider
          _gradientDivider(),
          const SizedBox(height: 24),

          // E) Description
          if (img.description.isNotEmpty) ...[
            _buildDescription(),
            const SizedBox(height: 28),
          ],

          // F) More Like This
          _buildMoreLikeThis(),
          if (!_relatedLoading && _related.isNotEmpty)
            const SizedBox(height: 28),

          // G) Keywords
          if (img.keywords.isNotEmpty) ...[
            _buildKeywords(),
            const SizedBox(height: 28),
          ],

          // H) Image info card
          _buildInfoCard(),
          const SizedBox(height: 24),

          // I) Action buttons
          _buildActionButtons(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSourceRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            img.center.isNotEmpty ? 'NASA / ${img.center}' : 'NASA',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
              color: _textSecondary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          _formatNasaDate(img.dateCreated),
          style: GoogleFonts.inter(fontSize: 13, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final year =
        DateTime.tryParse(img.dateCreated)?.year.toString() ?? '—';
    final stats = [
      (Icons.camera_alt_outlined,
          img.center.isNotEmpty ? img.center : 'NASA', 'Source'),
      (Icons.calendar_today_outlined, year, 'Year'),
      (Icons.label_outline_rounded, '${img.keywords.length} tags', 'Tags'),
    ];

    return Row(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
        return Expanded(
          child: Container(
            height: 68,
            margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
              boxShadow: AppColors.cardShadow(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s.$1, size: 16, color: AppColors.accentBlue),
                const SizedBox(height: 5),
                Text(
                  s.$2,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  s.$3,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: _textSecondary),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.15, end: 0, duration: 320.ms),
        );
      }),
    );
  }

  Widget _gradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.accentBlue.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: Text(
            img.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _textPrimary.withValues(alpha: 0.78),
              height: 1.75,
            ),
            maxLines: _descExpanded ? 999 : 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (img.description.length > 200)
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _descExpanded ? 'Show Less' : 'Read More',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMoreLikeThis() {
    // Don't show section if no keywords or nothing loaded and done loading
    if (img.keywords.isEmpty) return const SizedBox.shrink();
    if (!_relatedLoading && _related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More Like This',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 162,
          child: _relatedLoading ? _relatedShimmer() : _relatedGrid(),
        ),
      ],
    );
  }

  Widget _relatedGrid() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: _related.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final rel = _related[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ImageDetailScreen(
                images: _related, initialIndex: i),
          )),
          child: SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: rel.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) =>
                        _shimmerBox(120, 120, radius: 14),
                    errorWidget: (ctx, url, err) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.card(ctx),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.star_border,
                          color: AppColors.accentBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                  duration: 340.ms,
                  delay: Duration(milliseconds: 55 * i)),
        );
      },
    );
  }

  Widget _relatedShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(120, 120, radius: 14),
          const SizedBox(height: 6),
          _shimmerBox(110, 14, radius: 4),
          const SizedBox(height: 4),
          _shimmerBox(80, 12, radius: 4),
        ],
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 8}) {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _textSecondary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: img.keywords.take(12).map((k) {
            return GestureDetector(
              onTap: () {
                try {
                  Get.find<ExploreController>().searchImages(k);
                } catch (_) {}
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.4)),
                ),
                child: Text(
                  k,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final dateStr = _formatNasaDate(img.dateCreated);
    final nasaIdShort = img.nasaId.length > 22
        ? '${img.nasaId.substring(0, 22)}…'
        : img.nasaId;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'Image Details',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          _infoRow(
            Icons.explore_outlined,
            'Source',
            img.center.isNotEmpty ? img.center : 'NASA',
          ),
          _infoRow(
            Icons.photo_camera_outlined,
            'NASA ID',
            nasaIdShort,
            trailing: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: img.nasaId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('NASA ID copied',
                        style: GoogleFonts.inter(fontSize: 13)),
                    backgroundColor: AppColors.accentBlue,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Copy',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ),
          _infoRow(Icons.calendar_today_outlined, 'Date', dateStr),
          _infoRow(
            Icons.label_outline_rounded,
            'Keywords',
            '${img.keywords.length}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Container(height: 1, color: _borderColor),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: AppColors.accentBlue.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: _textSecondary)),
              const Spacer(),
              if (trailing != null) ...[trailing, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final bookmarked = _isBookmarked;
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.open_in_browser_rounded,
            label: 'Open Image',
            onTap: _openInBrowser,
            gradient: AppColors.primaryGradient,
            foreground: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: CupertinoIcons.share,
            label: 'Share',
            onTap: _share,
            cardColor: _cardColor,
            borderColor: _borderColor,
            foreground: _textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: bookmarked
                ? CupertinoIcons.bookmark_fill
                : CupertinoIcons.bookmark,
            label: bookmarked ? 'Saved' : 'Bookmark',
            onTap: _toggleBookmark,
            gradient: bookmarked ? AppColors.primaryGradient : null,
            cardColor: bookmarked ? null : _cardColor,
            borderColor: bookmarked ? null : _borderColor,
            foreground: bookmarked ? Colors.white : _textPrimary,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// CIRCLE BUTTON — top bar overlay
// ═════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.accentBlue
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// ACTION BUTTON — bottom row
// ═════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color? cardColor;
  final Color? borderColor;
  final Color foreground;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.foreground,
    this.gradient,
    this.cardColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? cardColor : null,
          borderRadius: BorderRadius.circular(16),
          border: gradient == null && borderColor != null
              ? Border.all(color: borderColor!)
              : null,
          boxShadow: gradient != null
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
