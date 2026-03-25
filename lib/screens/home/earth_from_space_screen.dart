import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/bookmark_controller.dart';
import '../../models/bookmark_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class EarthFromSpaceScreen extends StatefulWidget {
  const EarthFromSpaceScreen({super.key});

  @override
  State<EarthFromSpaceScreen> createState() => _EarthFromSpaceScreenState();
}

class _EarthFromSpaceScreenState extends State<EarthFromSpaceScreen> {
  List<Map<String, dynamic>> _images = [];
  List<String> _availableDates = [];
  int _selectedIndex = 0;
  int _dateIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentDate = '';
  Timer? _autoPlayTimer;
  bool _autoPlaying = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadLatestAvailable();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  /// First fetch available dates from EPIC API, then load the most recent.
  Future<void> _loadLatestAvailable() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final dates = await ApiService.getEpicAvailableDates();
      if (dates.isNotEmpty && mounted) {
        _availableDates = dates;
        _dateIndex = 0;
        await _loadImagesForDate(dates.first);
        return;
      }
    } catch (_) {}

    // Fallback: try specific recent dates
    await _loadImagesByGuessing(DateTime.now().subtract(const Duration(days: 2)));
  }

  /// Load images for a specific known-available date.
  Future<void> _loadImagesForDate(String dateStr) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await ApiService.getEpicImages(date: dateStr);
    if (result.isNotEmpty && mounted) {
      setState(() {
        _images = result;
        _selectedIndex = 0;
        _currentDate = dateStr;
        _isLoading = false;
      });
      _precacheThumbnails();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  /// Fallback: try dates going back up to 8 days.
  Future<void> _loadImagesByGuessing(DateTime startDate) async {
    for (int i = 0; i < 8; i++) {
      final tryDate = startDate.subtract(Duration(days: i));
      final dateStr =
          '${tryDate.year}-${tryDate.month.toString().padLeft(2, '0')}-${tryDate.day.toString().padLeft(2, '0')}';
      final result = await ApiService.getEpicImages(date: dateStr);
      if (result.isNotEmpty && mounted) {
        setState(() {
          _images = result;
          _selectedIndex = 0;
          _currentDate = dateStr;
          _isLoading = false;
        });
        _precacheThumbnails();
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _precacheThumbnails() {
    final count = _images.length.clamp(0, 4);
    for (int i = 0; i < count; i++) {
      final url = _thumbUrl(_images[i]);
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }

  void _precacheNext(int current) {
    final next = (current + 1) % _images.length;
    precacheImage(
        CachedNetworkImageProvider(_thumbUrl(_images[next])), context);
  }

  /// Thumbnail URL (~15 KB, 120x120 JPG) — loads instantly.
  String _thumbUrl(Map<String, dynamic> img) {
    final imageName = img['image']?.toString() ?? '';
    return ApiService.getEpicImageUrl(_currentDate, imageName,
        thumbnail: true);
  }

  /// Full resolution URL (~5-10 MB, 2048x2048 PNG) — only for HD view.
  String _fullUrl(Map<String, dynamic> img) {
    final imageName = img['image']?.toString() ?? '';
    return ApiService.getEpicImageUrl(_currentDate, imageName,
        thumbnail: false);
  }

  void _goToPreviousDay() {
    // Navigate to older date
    if (_availableDates.isNotEmpty) {
      if (_dateIndex < _availableDates.length - 1) {
        _dateIndex++;
        _loadImagesForDate(_availableDates[_dateIndex]);
      }
    } else if (_currentDate.isNotEmpty) {
      final prev = DateTime.parse(_currentDate).subtract(const Duration(days: 1));
      _loadImagesByGuessing(prev);
    }
  }

  void _goToNextDay() {
    // Navigate to newer date
    if (_availableDates.isNotEmpty) {
      if (_dateIndex > 0) {
        _dateIndex--;
        _loadImagesForDate(_availableDates[_dateIndex]);
      }
    } else if (_currentDate.isNotEmpty) {
      final next = DateTime.parse(_currentDate).add(const Duration(days: 1));
      if (!next.isAfter(DateTime.now())) {
        _loadImagesByGuessing(next);
      }
    }
  }

  void _toggleAutoPlay() {
    if (_autoPlaying) {
      _autoPlayTimer?.cancel();
      setState(() => _autoPlaying = false);
    } else {
      setState(() => _autoPlaying = true);
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (mounted && _images.isNotEmpty) {
          _precacheNext(_selectedIndex);
          setState(() {
            _selectedIndex = (_selectedIndex + 1) % _images.length;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildDateSelector()),
            if (_isLoading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_hasError)
              SliverToBoxAdapter(child: _buildError())
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: _buildHeroImage(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _buildImageInfo(),
                ),
              ),
              if (_images.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _buildThumbnails(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _buildAboutCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _buildActions(),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow(context),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary(context), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Earth from Space',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Daily photos from 1 million miles away',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showInfoSheet,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Icon(CupertinoIcons.info, size: 18,
                  color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // DATE SELECTOR
  // ═══════════════════════════════════════

  Widget _buildDateSelector() {
    String display = 'Loading...';
    if (_currentDate.isNotEmpty) {
      final dt = DateTime.parse(_currentDate);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      display = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _goToPreviousDay,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Icon(CupertinoIcons.chevron_left, size: 16,
                  color: AppColors.textPrimary(context)),
            ),
          ),
          const SizedBox(width: 16),
          Text(display,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _goToNextDay,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Icon(CupertinoIcons.chevron_right, size: 16,
                  color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO IMAGE (thumbnail-first)
  // ═══════════════════════════════════════

  Widget _buildHeroImage() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final thumbUrl = _thumbUrl(img);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90D9).withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: thumbUrl,
                cacheKey: 'epic_${img['image']}_thumb',
                fit: BoxFit.cover,
                memCacheHeight: 400,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase(context),
                  highlightColor: AppColors.shimmerHighlight(context),
                  child: Container(color: AppColors.shimmerBase(context)),
                ),
                errorWidget: (_, _, _) => Container(
                  color:
                      _isDark ? AppColors.cardDark : const Color(0xFFF0F0FA),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.photo, size: 48,
                          color: AppColors.textSecondary(context)),
                      const SizedBox(height: 8),
                      Text('Image unavailable',
                          style: GoogleFonts.inter(fontSize: 13,
                              color: AppColors.textSecondary(context))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // View HD button
        GestureDetector(
          onTap: () => _openHdViewer(img),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppColors.accentCyan.withValues(alpha: 0.1)
                  : const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.search, size: 14,
                    color: AppColors.accentCyan),
                const SizedBox(width: 6),
                Text('View Full Resolution (2048\u00D72048)',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentCyan)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(
        begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }

  // ═══════════════════════════════════════
  // HD VIEWER (full resolution, on demand)
  // ═══════════════════════════════════════

  void _openHdViewer(Map<String, dynamic> img) {
    final hdUrl = _fullUrl(img);
    final thumbUrl = _thumbUrl(img);

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => _HdViewerScreen(
          hdUrl: hdUrl,
          thumbUrl: thumbUrl,
          date: _currentDate,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // IMAGE INFO
  // ═══════════════════════════════════════

  Widget _buildImageInfo() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final dateStr = img['date']?.toString() ?? '';
    final coords = img['centroid_coordinates'] as Map<String, dynamic>?;
    final lat = coords?['lat']?.toStringAsFixed(1) ?? '?';
    final lon = coords?['lon']?.toStringAsFixed(1) ?? '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.time, size: 14,
                  color: AppColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text('Captured: $dateStr UTC',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: AppColors.textSecondary(context))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(CupertinoIcons.location, size: 14,
                  color: AppColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text('Center: $lat\u00B0 lat, $lon\u00B0 lon',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: AppColors.textSecondary(context))),
            ],
          ),
          if (_images.length > 1) ...[
            const SizedBox(height: 6),
            Text('${_selectedIndex + 1} of ${_images.length} photos',
                style: GoogleFonts.inter(fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPurple)),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  // ═══════════════════════════════════════
  // THUMBNAILS (all use thumb URLs)
  // ═══════════════════════════════════════

  Widget _buildThumbnails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Earth Rotation',
                style: GoogleFonts.spaceGrotesk(fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const Spacer(),
            GestureDetector(
              onTap: _toggleAutoPlay,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _autoPlaying
                      ? AppColors.accentPurple.withValues(alpha: 0.15)
                      : AppColors.glass(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _autoPlaying
                        ? AppColors.accentPurple
                        : AppColors.glassBorder(context),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _autoPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      size: 12,
                      color: _autoPlaying
                          ? AppColors.accentPurple
                          : AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(_autoPlaying ? 'Pause' : 'Play',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _autoPlaying
                                ? AppColors.accentPurple
                                : AppColors.textSecondary(context))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _images.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final url = _thumbUrl(_images[i]);
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.accentCyan
                          : AppColors.glassBorder(context),
                      width: selected ? 2.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: AppColors.accentCyan
                                    .withValues(alpha: 0.3),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      cacheKey: 'epic_${_images[i]['image']}_thumb',
                      fit: BoxFit.cover,
                      memCacheHeight: 120,
                      placeholder: (_, _) =>
                          Container(color: AppColors.shimmerBase(context)),
                      errorWidget: (_, _, _) => Container(
                        color: _isDark
                            ? AppColors.cardDark
                            : const Color(0xFFF0F0FA),
                        child:
                            const Icon(CupertinoIcons.globe, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  // ═══════════════════════════════════════
  // ABOUT CARD
  // ═══════════════════════════════════════

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark
            ? AppColors.accentCyan.withValues(alpha: 0.06)
            : const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.accentCyan.withValues(alpha: 0.15)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this photo',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentCyan)),
          const SizedBox(height: 10),
          _infoRow('Camera', 'EPIC (Earth Polychromatic Imaging Camera)'),
          _infoRow('Satellite', 'DSCOVR'),
          _infoRow(
              'Location', 'L1 Lagrange Point \u2014 1.5M km from Earth'),
          _infoRow('Resolution', '2048 \u00D7 2048 pixels'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary(context))),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context))),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _downloadImage,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.arrow_down_to_line,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Save HD',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _shareImage,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.share, size: 16,
                      color: AppColors.textPrimary(context)),
                  const SizedBox(width: 8),
                  Text('Share',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _bookmarkImage,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.glass(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder(context)),
            ),
            child: Icon(CupertinoIcons.bookmark, size: 18,
                color: AppColors.textPrimary(context)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  // ═══════════════════════════════════════
  // LOADING / ERROR
  // ═══════════════════════════════════════

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBase(context),
            highlightColor: AppColors.shimmerHighlight(context),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase(context),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 10),
              const SizedBox(width: 10),
              Text('Loading Earth photos...',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          const Text('\u{1F30D}', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Earth images unavailable',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context)),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
              'NASA\'s EPIC camera captures Earth daily \u2014 try again later.',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary(context)),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadLatestAvailable,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text('Try Again',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ACTION HANDLERS
  // ═══════════════════════════════════════

  void _downloadImage() async {
    if (_images.isEmpty) return;
    final url = _fullUrl(_images[_selectedIndex]);
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareImage() {
    if (_images.isEmpty) return;
    try {
      SharePlus.instance.share(ShareParams(
        text: '\u{1F30D} Earth from Space \u2014 $_currentDate\n\n'
            'Captured by NASA\'s DSCOVR satellite from 1.5 million km away!\n\n'
            'Shared via Cosmic Facts \u{1F30C}',
      ));
    } catch (_) {}
  }

  void _bookmarkImage() {
    if (_images.isEmpty) return;
    final img = _images[_selectedIndex];
    final url = _thumbUrl(img);
    final bm = BookmarkModel(
      id: 'epic_${_currentDate}_$_selectedIndex',
      type: 'image',
      title: 'Earth from Space \u2014 $_currentDate',
      subtitle: 'NASA EPIC Camera',
      imageUrl: url,
      data: jsonEncode(img),
      savedAt: DateTime.now(),
    );
    Get.find<BookmarkController>().toggleBookmark(bm);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark toggled!',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.surface(context),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('About EPIC',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                const SizedBox(height: 12),
                Text(
                  'These photos are taken by NASA\'s DSCOVR (Deep Space Climate Observatory) '
                  'satellite positioned at the L1 Lagrange point, approximately 1.5 million '
                  'kilometers from Earth.\n\n'
                  'The EPIC (Earth Polychromatic Imaging Camera) captures stunning full-disc '
                  'images of the sunlit side of Earth as it rotates. Multiple images are taken '
                  'each day, showing the Earth\'s rotation.\n\n'
                  'Images are typically available 2-3 days after capture due to processing time.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary(context)
                          .withValues(alpha: 0.85),
                      height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// HD VIEWER SCREEN (loads full 2048x2048 on demand)
// ═════════════════════════════════════════════

class _HdViewerScreen extends StatelessWidget {
  final String hdUrl;
  final String thumbUrl;
  final String date;

  const _HdViewerScreen({
    required this.hdUrl,
    required this.thumbUrl,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.glass(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Full Resolution',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context))),
                        Text('2048 \u00D7 2048 \u2022 Pinch to zoom',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Image
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 6.0,
                child: CachedNetworkImage(
                  imageUrl: hdUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      // Show thumbnail while HD loads
                      CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.contain,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CupertinoActivityIndicator(
                                  color: Colors.white, radius: 10),
                              const SizedBox(width: 10),
                              Text('Loading HD...',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  errorWidget: (_, _, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.exclamationmark_triangle,
                            size: 48,
                            color: AppColors.textSecondary(context)),
                        const SizedBox(height: 12),
                        Text('Failed to load HD image',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
