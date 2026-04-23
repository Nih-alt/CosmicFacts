import 'dart:async';
import 'dart:convert';
import 'dart:ui';

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
// DESIGN TOKENS
// ═════════════════════════════════════════════
// Explore section keeps the older purple→cyan accent language (the
// rest of the app uses blue→cyan). This detail screen matches its
// parent surface so transitions feel coherent.
const _accentPurple = Color(0xFF6C63FF);
const _accentCyan = Color(0xFF00B4D8);
const _purpleCyanGradient = LinearGradient(
  colors: [_accentPurple, _accentCyan],
);

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
  bool _detailsExpanded = false;
  List<NasaImage> _related = [];
  bool _relatedLoading = true;
  late String _currentImageUrl;

  NasaImage get img => widget.image;

  // Theme shortcuts used throughout
  Color get _textPrimary => AppColors.textPrimary(context);
  Color get _textSecondary => AppColors.textSecondary(context);
  Color get _contentBg => AppColors.background(context);
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _glassFill => _isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.04);
  Color get _glassBorder => _isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.08);

  @override
  void initState() {
    super.initState();
    _currentImageUrl = img.imageUrl;
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hintVisible = false);
    });
    Future.delayed(const Duration(milliseconds: 700), _loadRelated);
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
  Future<void> _upgradeToLarge() async {
    final largeUrl = img.largeImageUrl;
    if (largeUrl.isEmpty) return;

    String? confirmedUrl;

    try {
      final resp = await http
          .head(Uri.parse(largeUrl))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        confirmedUrl = largeUrl;
      }
    } catch (_) {}

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
          final found = urls.firstWhere(
            (u) => u.contains('~large'),
            orElse: () => urls.firstWhere(
              (u) => u.contains('~orig'),
              orElse: () => '',
            ),
          );
          if (found.isNotEmpty) confirmedUrl = found;
        }
      } catch (_) {}
    }

    if (confirmedUrl == null || confirmedUrl == img.imageUrl) return;

    try {
      await precacheImage(
        CachedNetworkImageProvider(confirmedUrl),
        // ignore: use_build_context_synchronously
        context,
      );
      if (mounted) {
        setState(() => _currentImageUrl = confirmedUrl!);
      }
    } catch (_) {}
  }

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
            '${img.title}\n\nSource: NASA Image Library / ${img.center}\n\nShared via Cosmic Facts \u{1F30C} (not affiliated with NASA)',
      ));
    } catch (_) {}
  }

  Future<void> _openInBrowser() async {
    try {
      final url = img.hdUrl.isNotEmpty
          ? img.hdUrl
          : (img.largeImageUrl.isNotEmpty
              ? img.largeImageUrl
              : img.imageUrl);
      await launchUrl(Uri.parse(url),
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
    // CHANGE 1 — hero takes 45% of screen height
    final imageHeight = MediaQuery.sizeOf(context).height * 0.45;
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
  // HERO — 45% height, zoom, frosted overlay buttons, gradient fade
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
                                  color: AppColors.textSecondary(ctx))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Seamless gradient fade: transparent → AppColors.background(context)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: imageHeight * 0.5,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      _contentBg.withValues(alpha: 0.6),
                      _contentBg,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pinch hint — fades out after 2s, top-center
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hintVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(child: _buildFrostedPillHint()),
              ),
            ),
          ),

          // Top bar (frosted back + share + bookmark)
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
                    _FrostedCircleButton(
                      icon: CupertinoIcons.back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _FrostedCircleButton(
                      icon: CupertinoIcons.share,
                      onTap: _share,
                    ),
                    const SizedBox(width: 10),
                    _FrostedCircleButton(
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

          // Bottom bar: floating source chip + counter/dots on the fade zone
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: _buildSourceChip()),
                const Spacer(),
                if (widget.totalCount > 1) _buildCounterBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedPillHint() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pinch_outlined,
                  color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text('Pinch to zoom',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
        ),
      ),
    );
  }

  // CHANGE 2 — floating glass source chip + date
  Widget _buildSourceChip() {
    final date = _formatNasaDate(img.dateCreated);
    final source = img.center.isNotEmpty
        ? 'Source: NASA / ${img.center}'
        : 'Source: NASA Image Library';
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (r) =>
                    _purpleCyanGradient.createShader(r),
                child: const Icon(Icons.auto_awesome,
                    size: 13, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _textSecondary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15)),
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
      ),
    );
  }

  // ─────────────────────────────────────────
  // CONTENT — scrollable section below hero
  // ─────────────────────────────────────────

  Widget _buildContent() {
    return Container(
      color: _contentBg,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
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

          // CHANGE 3 — glass stat pills
          _buildStatPills(),
          const SizedBox(height: 28),

          // CHANGE 4 — description with decorative gradient line
          if (img.description.isNotEmpty) ...[
            _gradientAccentLine(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 28),
          ],

          // CHANGE 5 — More Like This: horizontal, 160px cards
          _buildMoreLikeThis(),
          if (!_relatedLoading && _related.isNotEmpty)
            const SizedBox(height: 28),

          // CHANGE 6 — tappable hashtag chips
          if (img.keywords.isNotEmpty) ...[
            _buildKeywords(),
            const SizedBox(height: 24),
          ],

          // CHANGE 7 — collapsible Image Details
          _buildCollapsibleInfoCard(),
          const SizedBox(height: 24),

          // CHANGE 8 — primary action + two icon circles
          _buildActionStack(),

          // Safe-area padding for gesture-nav devices
          SizedBox(
            height: 24 + MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // CHANGE 3 — Glass stat pills
  // ─────────────────────────────────────────
  Widget _buildStatPills() {
    final year =
        DateTime.tryParse(img.dateCreated)?.year.toString() ?? '—';
    final stats = [
      (Icons.camera_alt_outlined,
          img.center.isNotEmpty ? img.center : 'NASA', 'Source'),
      (Icons.calendar_today_outlined, year, 'Year'),
      (Icons.label_outline_rounded, '${img.keywords.length}', 'Tags'),
    ];

    return Row(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 86,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: _glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _glassBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.$1, size: 18, color: _accentPurple),
                      const SizedBox(height: 6),
                      Text(
                        s.$2,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.$3,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _textSecondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.15, end: 0, duration: 320.ms),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  // CHANGE 4 — Decorative gradient line + description
  // ─────────────────────────────────────────
  Widget _gradientAccentLine() {
    return Container(
      width: 40,
      height: 3,
      decoration: BoxDecoration(
        gradient: _purpleCyanGradient,
        borderRadius: BorderRadius.circular(2),
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
              color: _textPrimary.withValues(alpha: 0.85),
              height: 1.6,
            ),
            maxLines: _descExpanded ? 999 : 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (img.description.length > 200)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    _purpleCyanGradient.createShader(bounds),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _descExpanded ? 'Show Less' : 'Read More',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _descExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // CHANGE 5 — More Like This, horizontal row, 160 wide
  // ─────────────────────────────────────────
  Widget _buildMoreLikeThis() {
    if (img.keywords.isEmpty) return const SizedBox.shrink();
    if (!_relatedLoading && _related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _gradientAccentLine(),
            const SizedBox(width: 10),
            Text(
              'More Like This',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: _relatedLoading ? _relatedShimmer() : _relatedList(),
        ),
      ],
    );
  }

  Widget _relatedList() {
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
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isDark
                        ? const []
                        : [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: rel.imageUrl,
                      width: 160,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) =>
                          _shimmerBox(160, 140, radius: 14),
                      errorWidget: (ctx, url, err) => Container(
                        width: 160,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.card(ctx),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.star_border,
                            color: AppColors.accentBlue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
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
          _shimmerBox(160, 140, radius: 14),
          const SizedBox(height: 8),
          _shimmerBox(150, 12, radius: 4),
          const SizedBox(height: 4),
          _shimmerBox(110, 12, radius: 4),
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

  // ─────────────────────────────────────────
  // CHANGE 6 — Hashtag chips
  // ─────────────────────────────────────────
  Widget _buildKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _gradientAccentLine(),
            const SizedBox(width: 10),
            Text(
              'Tags',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: img.keywords.take(12).map((k) {
            return _HashtagChip(
              label: k,
              isDark: _isDark,
              onTap: () {
                try {
                  Get.find<ExploreController>().searchImages(k);
                } catch (_) {}
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // CHANGE 7 — Collapsible Image Details
  // ─────────────────────────────────────────
  Widget _buildCollapsibleInfoCard() {
    final dateStr = _formatNasaDate(img.dateCreated);
    final nasaIdShort = img.nasaId.length > 22
        ? '${img.nasaId.substring(0, 22)}…'
        : img.nasaId;
    final keywordsStr =
        img.keywords.isEmpty ? '—' : '${img.keywords.length}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — tappable to toggle
          InkWell(
            onTap: () =>
                setState(() => _detailsExpanded = !_detailsExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: _accentPurple),
                  const SizedBox(width: 10),
                  Text(
                    'Image Details',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _detailsExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                _infoRow(
                  Icons.explore_outlined,
                  'Source',
                  img.center.isNotEmpty ? img.center : 'NASA Image Library',
                ),
                _infoRow(
                  Icons.photo_camera_outlined,
                  'NASA ID',
                  nasaIdShort,
                  trailing: _CopyChip(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: img.nasaId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('NASA ID copied',
                              style: GoogleFonts.inter(fontSize: 13)),
                          backgroundColor: _accentPurple,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
                _infoRow(Icons.calendar_today_outlined, 'Date', dateStr),
                _infoRow(
                  Icons.label_outline_rounded,
                  'Keywords',
                  keywordsStr,
                  isLast: true,
                ),
              ],
            ),
            crossFadeState: _detailsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 260),
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
        Container(height: 1, color: AppColors.divider(context)),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: _accentPurple.withValues(alpha: 0.85)),
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
        if (isLast) const SizedBox(height: 4),
      ],
    );
  }

  // ─────────────────────────────────────────
  // CHANGE 8 — Primary button + two icon circles
  // ─────────────────────────────────────────
  Widget _buildActionStack() {
    final bookmarked = _isBookmarked;
    return Column(
      children: [
        _PrimaryActionButton(
          icon: Icons.download_rounded,
          label: 'Open Full HD',
          gradient: _purpleCyanGradient,
          onTap: _openInBrowser,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconCircleButton(
              icon: CupertinoIcons.share,
              label: 'Share',
              isDark: _isDark,
              onTap: _share,
            ),
            const SizedBox(width: 22),
            _IconCircleButton(
              icon: bookmarked
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              label: bookmarked ? 'Saved' : 'Bookmark',
              isDark: _isDark,
              highlighted: bookmarked,
              onTap: _toggleBookmark,
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// FROSTED CIRCLE BUTTON — top bar overlay
// ═════════════════════════════════════════════

class _FrostedCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _FrostedCircleButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: filled
                  ? _accentPurple.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// HASHTAG CHIP
// ═════════════════════════════════════════════

class _HashtagChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _HashtagChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? _accentPurple.withValues(alpha: 0.18)
        : _accentPurple.withValues(alpha: 0.1);
    final border = isDark
        ? _accentPurple.withValues(alpha: 0.35)
        : _accentPurple.withValues(alpha: 0.25);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Text(
              '#$label',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _accentPurple,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// COPY CHIP (outlined)
// ═════════════════════════════════════════════

class _CopyChip extends StatelessWidget {
  final VoidCallback onTap;
  const _CopyChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _accentPurple.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy, size: 11, color: _accentPurple),
            const SizedBox(width: 4),
            Text(
              'Copy',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _accentPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// PRIMARY ACTION BUTTON (full width, gradient)
// ═════════════════════════════════════════════

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accentPurple.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SMALL ICON-CIRCLE BUTTON (Share / Bookmark)
// ═════════════════════════════════════════════

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool highlighted;
  final VoidCallback onTap;

  const _IconCircleButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted
        ? _accentPurple.withValues(alpha: 0.18)
        : (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05));
    final border = highlighted
        ? _accentPurple.withValues(alpha: 0.5)
        : (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08));
    final fg = highlighted
        ? _accentPurple
        : AppColors.textPrimary(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: Icon(icon, size: 22, color: fg),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
