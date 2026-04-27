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
import 'earth_rotation_player_screen.dart';

/// Editorial / cinema-style viewer for NASA EPIC daily Earth photography.
///
/// Layout: minimal top bar → full-bleed hero image (60% screen height) →
/// magazine-style caption block → "Watch Earth rotate" CTA → date nav →
/// collapsible technical details → frosted sticky action bar.
class EarthFromSpaceScreen extends StatefulWidget {
  const EarthFromSpaceScreen({super.key});

  @override
  State<EarthFromSpaceScreen> createState() => _EarthFromSpaceScreenState();
}

class _EarthFromSpaceScreenState extends State<EarthFromSpaceScreen> {
  // ── data ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _images = [];
  List<String> _availableDates = [];
  int _selectedIndex = 0;
  int _dateIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentDate = '';

  // ── ui state ─────────────────────────────────────────────────────
  bool _techExpanded = false;

  // ── theme helpers ────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF050510) : const Color(0xFFFAFAFA);
  Color get _primary =>
      _isDark ? Colors.white : const Color(0xFF0A1628);
  Color get _secondary =>
      _isDark ? const Color(0xFF9BA3B8) : const Color(0xFF5B6B85);
  Color get _accent =>
      _isDark ? const Color(0xFF4A90E2) : const Color(0xFF1E40AF);

  @override
  void initState() {
    super.initState();
    _loadLatestAvailable();
  }

  // ═══════════════════════════════════════════════════════════════
  // PRESERVED API LOGIC
  // ═══════════════════════════════════════════════════════════════
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
    await _loadImagesByGuessing(
        DateTime.now().subtract(const Duration(days: 2)));
  }

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
      _precacheNeighbors();
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

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
        _precacheNeighbors();
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

  void _precacheNeighbors() {
    final count = _images.length.clamp(0, 4);
    for (int i = 0; i < count; i++) {
      precacheImage(
        CachedNetworkImageProvider(_imageUrl(_images[i])),
        context,
      );
    }
  }

  // ── URL helpers ──
  /// Mid-quality JPG (~200 KB) — readable at full bleed, lighter than the
  /// 5–10 MB PNG. Constructed inline from EPIC's documented URL pattern;
  /// `api_service.dart` is intentionally untouched.
  String _imageUrl(Map<String, dynamic> img) {
    final imageName = img['image']?.toString() ?? '';
    final parts = _currentDate.split('-');
    if (parts.length != 3) {
      return ApiService.getEpicImageUrl(_currentDate, imageName,
          thumbnail: true);
    }
    return 'https://epic.gsfc.nasa.gov/archive/natural/'
        '${parts[0]}/${parts[1]}/${parts[2]}/jpg/$imageName.jpg';
  }

  String _fullUrl(Map<String, dynamic> img) {
    final imageName = img['image']?.toString() ?? '';
    return ApiService.getEpicImageUrl(_currentDate, imageName,
        thumbnail: false);
  }

  // ── navigation ──
  void _goToPreviousDay() {
    if (_availableDates.isNotEmpty) {
      if (_dateIndex < _availableDates.length - 1) {
        _dateIndex++;
        _loadImagesForDate(_availableDates[_dateIndex]);
      }
    } else if (_currentDate.isNotEmpty) {
      final prev =
          DateTime.parse(_currentDate).subtract(const Duration(days: 1));
      _loadImagesByGuessing(prev);
    }
  }

  void _goToNextDay() {
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

  bool get _canGoNextDay {
    if (_availableDates.isNotEmpty) return _dateIndex > 0;
    if (_currentDate.isEmpty) return false;
    final next = DateTime.parse(_currentDate).add(const Duration(days: 1));
    return !next.isAfter(DateTime.now());
  }

  void _showDatePicker() {
    if (_currentDate.isEmpty) return;
    final initial = DateTime.parse(_currentDate);
    DateTime selected = initial;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: _bg,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadImagesByGuessing(selected);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: DateTime(2015, 6, 1),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRotationPlayer() {
    if (_images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EarthRotationPlayerScreen(
          images: _images,
          date: _currentDate,
          initialIndex: _selectedIndex,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final showActions = !_isLoading && !_hasError && _images.isNotEmpty;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _hasError
                      ? _buildError()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHero(),
                              _buildCaption(),
                              _buildWatchCta(),
                              _buildDateNav(),
                              _buildTechDetails(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showActions ? _buildActionBar() : null,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // A) TOP BAR — minimal
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _circleIcon(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            _circleIcon(
              icon: Icons.info_outline,
              onTap: _showInfoSheet,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: _primary),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // B) HERO IMAGE — full bleed, 60% screen height
  // ─────────────────────────────────────────────────────────────
  Widget _buildHero() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final url = _imageUrl(img);
    final heroHeight = MediaQuery.of(context).size.height * 0.6;

    return GestureDetector(
      // Tap or long-press opens the fullscreen player where zoom + manual
      // frame navigation live. Keeping zoom out of the inline image
      // eliminates per-frame InteractiveViewer overhead while scrolling.
      onTap: _openRotationPlayer,
      onLongPress: _openRotationPlayer,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -300 && _canGoNextDay) {
          _goToNextDay();
        } else if (v > 300) {
          _goToPreviousDay();
        }
      },
      child: SizedBox(
        height: heroHeight,
        child: Stack(
          children: [
            Container(
              color: Colors.black,
              width: double.infinity,
              height: heroHeight,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  cacheKey: 'epic_hero_${img['image']}',
                  fit: BoxFit.contain,
                  // Decode at half resolution — quality stays high on phone
                  // displays while memory drops ~75%.
                  memCacheWidth: 1024,
                  memCacheHeight: 1024,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, _) => Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.06),
                      highlightColor: Colors.white.withValues(alpha: 0.18),
                      child: Container(
                        width: heroHeight * 0.7,
                        height: heroHeight * 0.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.photo,
                            size: 48, color: Colors.white38),
                        const SizedBox(height: 8),
                        Text('Image unavailable',
                            style: GoogleFonts.inter(
                                color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Frame indicator bars
            if (_images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: _FrameBars(
                  total: _images.length,
                  current: _selectedIndex,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // C) EDITORIAL CAPTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildCaption() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final dateStr = img['date']?.toString() ?? '';
    final timeStr = _extractTime(dateStr);
    final coords = img['centroid_coordinates'] as Map<String, dynamic>?;
    final lat = (coords?['lat'] as num?)?.toDouble();
    final lon = (coords?['lon'] as num?)?.toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatEditorialDate(_currentDate),
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w500,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr.isNotEmpty ? '$timeStr UTC' : '— UTC',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              letterSpacing: 1.5,
              color: _secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Earth from a million miles away',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              height: 1.2,
              letterSpacing: -0.5,
              color: _primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _composeStorytellingText(lat, lon),
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
              color: _secondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  String _composeStorytellingText(double? lat, double? lon) {
    if (lat == null || lon == null) {
      return "Captured by the EPIC instrument aboard NASA's DSCOVR satellite "
          'at the L1 Lagrange point — a vantage 1.5 million km from Earth '
          'where the Sun and our planet appear to pull on each other equally.';
    }
    final latStr = '${lat.abs().toStringAsFixed(1)}° ${lat >= 0 ? 'N' : 'S'}';
    final lonStr = '${lon.abs().toStringAsFixed(1)}° ${lon >= 0 ? 'E' : 'W'}';
    return 'Centered at $latStr, $lonStr — captured by the EPIC instrument '
        "aboard NASA's DSCOVR satellite at the L1 Lagrange point, "
        '1.5 million kilometres away.';
  }

  // ─────────────────────────────────────────────────────────────
  // D) WATCH EARTH ROTATE — hero CTA
  // ─────────────────────────────────────────────────────────────
  Widget _buildWatchCta() {
    if (_images.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: GestureDetector(
        onTap: _openRotationPlayer,
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _secondary.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E40AF), Color(0xFF38BDF8)],
                  ),
                ),
                child: const Icon(Icons.play_arrow,
                    size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WATCH EARTH ROTATE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: _secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_images.length} frames • 24-hour timelapse',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: _secondary.withValues(alpha: 0.7), size: 22),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // E) DATE NAVIGATION
  // ─────────────────────────────────────────────────────────────
  Widget _buildDateNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                icon: Icons.chevron_left,
                onTap: _goToPreviousDay,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showDatePicker,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Text(
                        _formatLongDate(_currentDate),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to pick date',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Opacity(
                opacity: _canGoNextDay ? 1 : 0.35,
                child: _circleIcon(
                  icon: Icons.chevron_right,
                  onTap: _canGoNextDay ? _goToNextDay : () {},
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 0.5,
            color: _secondary.withValues(alpha: 0.30),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // F) TECHNICAL DETAILS — collapsible
  // ─────────────────────────────────────────────────────────────
  Widget _buildTechDetails() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final coords = img['centroid_coordinates'] as Map<String, dynamic>?;
    final lat = (coords?['lat'] as num?)?.toDouble();
    final lon = (coords?['lon'] as num?)?.toDouble();
    final coordStr = (lat != null && lon != null)
        ? '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°'
        : 'L1 Lagrange Point';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _techExpanded = !_techExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: _secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Technical details',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _secondary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _techExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child:
                        Icon(Icons.expand_more, size: 18, color: _secondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _techExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow('Camera', 'EPIC'),
                        _detailRow('Satellite', 'DSCOVR'),
                        _detailRow('Position', coordStr),
                        _detailRow('Resolution', '2048 × 2048 px'),
                        _detailRow('Distance', '1.5 million km'),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _openFullResolution,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'View full resolution →',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _accent,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    _accent.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _secondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // G) STICKY ACTION BAR — solid (no BackdropFilter; jank-free).
  // ─────────────────────────────────────────────────────────────
  Widget _buildActionBar() {
    final bg = _isDark
        ? const Color(0xFF050514).withValues(alpha: 0.98)
        : Colors.white.withValues(alpha: 0.98);
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(
              color: _secondary.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
        ),
        child: Obx(() {
          final bookmarks = Get.find<BookmarkController>();
          final id =
              _images.isEmpty ? '' : 'epic_${_currentDate}_$_selectedIndex';
          final isBookmarked = id.isNotEmpty && bookmarks.isBookmarked(id);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionItem(
                icon: Icons.download_outlined,
                label: 'Save HD',
                onTap: _downloadImage,
              ),
              _actionItem(
                icon: Icons.ios_share,
                label: 'Share',
                onTap: _shareImage,
              ),
              _actionItem(
                icon: isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: 'Save',
                onTap: _bookmarkImage,
                active: isBookmarked,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _actionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final color = active ? _accent : _primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOADING / ERROR
  // ─────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    final h = MediaQuery.of(context).size.height * 0.6;
    return Column(
      children: [
        Container(
          height: h,
          width: double.infinity,
          color: Colors.black,
          child: Center(
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.06),
              highlightColor: Colors.white.withValues(alpha: 0.18),
              child: Container(
                width: h * 0.7,
                height: h * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const CupertinoActivityIndicator(radius: 9),
              const SizedBox(width: 10),
              Text(
                'Loading Earth photos…',
                style: GoogleFonts.inter(fontSize: 13, color: _secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Earth images unavailable',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "NASA's EPIC camera captures Earth daily — try again later.",
              style: GoogleFonts.inter(fontSize: 13, color: _secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadLatestAvailable,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 11),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Try again',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  // ═══════════════════════════════════════════════════════════════
  // ACTION HANDLERS — preserved
  // ═══════════════════════════════════════════════════════════════
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
        text: '🌍 Earth from Space — $_currentDate\n\n'
            'Via NASA DSCOVR/EPIC public archive — 1.5 million km away!\n\n'
            'Shared via Cosmic Facts 🌌 (not affiliated with NASA)',
      ));
    } catch (_) {}
  }

  void _bookmarkImage() {
    if (_images.isEmpty) return;
    final img = _images[_selectedIndex];
    final url = _imageUrl(img);
    final bm = BookmarkModel(
      id: 'epic_${_currentDate}_$_selectedIndex',
      type: 'image',
      title: 'Earth from Space — $_currentDate',
      subtitle: 'Via NASA EPIC Public API',
      imageUrl: url,
      data: jsonEncode(img),
      savedAt: DateTime.now(),
    );
    Get.find<BookmarkController>().toggleBookmark(bm);
  }

  void _openFullResolution() {
    if (_images.isEmpty) return;
    final img = _images[_selectedIndex];
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => _HdViewerScreen(
          hdUrl: _fullUrl(img),
          previewUrl: _imageUrl(img),
          date: _currentDate,
          isDark: _isDark,
          primary: _primary,
          secondary: _secondary,
        ),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _secondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'About EPIC',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.3,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "These photos come from NASA's DSCOVR satellite at the L1 "
                  "Lagrange point, ~1.5 million km from Earth. The EPIC "
                  "(Earth Polychromatic Imaging Camera) captures full-disc "
                  "images of the sunlit side as it rotates. Multiple frames "
                  "per day form a 24-hour rotation.\n\n"
                  "Images are typically available 2-3 days after capture due "
                  "to processing. Sourced from the NASA EPIC public API. "
                  "This app is not affiliated with or endorsed by NASA.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.6,
                    color: _primary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── date formatting helpers ──
  static const _months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];
  static const _monthsTitle = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatEditorialDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatLongDate(String iso) {
    if (iso.isEmpty) return 'Loading…';
    try {
      final dt = DateTime.parse(iso);
      return '${_monthsTitle[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  /// EPIC `date` strings are formatted "YYYY-MM-DD HH:MM:SS".
  String _extractTime(String dt) {
    if (dt.contains(' ')) {
      final t = dt.split(' ').last;
      return t.length >= 8 ? t.substring(0, 8) : t;
    }
    return '';
  }
}

// ═══════════════════════════════════════════════════════════════════
// FRAME BARS — slim vertical markers showing position within a day
// ═══════════════════════════════════════════════════════════════════
class _FrameBars extends StatelessWidget {
  final int total;
  final int current;
  const _FrameBars({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(total, (i) {
          final active = i == current;
          return Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: active ? 1.0 : 0.30),
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HD VIEWER — preserved logic, refreshed shell
// ═══════════════════════════════════════════════════════════════════
class _HdViewerScreen extends StatelessWidget {
  final String hdUrl;
  final String previewUrl;
  final String date;
  final bool isDark;
  final Color primary;
  final Color secondary;

  const _HdViewerScreen({
    required this.hdUrl,
    required this.previewUrl,
    required this.date,
    required this.isDark,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 6.0,
                child: CachedNetworkImage(
                  imageUrl: hdUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: previewUrl,
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
                              Text(
                                'Loading HD…',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  errorWidget: (_, _, _) => Center(
                    child: Text(
                      'Failed to load HD image',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.white60),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 16,
              child: Text(
                '2048 × 2048 — pinch to zoom',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
