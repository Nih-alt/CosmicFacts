import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/api_endpoints.dart';
import '../../controllers/bookmark_controller.dart';
import '../../models/bookmark_model.dart';
import '../../services/api_service.dart';
import '../../utils/earth_geo_helper.dart';
import '../../widgets/shimmer/shimmer_circle.dart';

/// Editorial viewer for NASA EPIC daily Earth photography.
///
/// Layout: minimal top bar → full-bleed hero image (single best frame
/// per day) → editorial caption → About this view → Cosmic Context (live-
/// calculated stats) → The Mission (DSCOVR + EPIC) → date navigation →
/// collapsible technical details → solid sticky action bar.
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

  /// Pick the middle frame of the day — usually the best Earth centering.
  static int _pickBestIndex(List<dynamic> images) =>
      images.isEmpty ? 0 : images.length ~/ 2;

  Future<void> _loadImagesForDate(String dateStr) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final result = await ApiService.getEpicImages(date: dateStr);
    if (result.isNotEmpty && mounted) {
      setState(() {
        _images = result;
        _selectedIndex = _pickBestIndex(result);
        _currentDate = dateStr;
        _isLoading = false;
      });
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
          _selectedIndex = _pickBestIndex(result);
          _currentDate = dateStr;
          _isLoading = false;
        });
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
    return ApiEndpoints.epicImageJpg(_currentDate, imageName);
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
                              _buildAboutThisView(),
                              _buildCosmicContext(),
                              _buildMission(),
                              _buildDateNav(),
                              _buildTechDetails(),
                              const SizedBox(height: 24),
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
      // Tap opens the fullscreen HD viewer (pinch-to-zoom). Horizontal
      // swipe changes day. Keeping zoom out of the inline image
      // eliminates per-frame InteractiveViewer overhead while scrolling.
      onTap: _openFullResolution,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -300 && _canGoNextDay) {
          _goToNextDay();
        } else if (v > 300) {
          _goToPreviousDay();
        }
      },
      child: Container(
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
              child: ShimmerCircle(
                size: heroHeight * 0.7,
                overlay: true,
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
    );
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
    );
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
  // D1) ABOUT THIS VIEW — region + sunlit side
  // ─────────────────────────────────────────────────────────────
  Widget _buildAboutThisView() {
    if (_images.isEmpty) return const SizedBox.shrink();
    final img = _images[_selectedIndex];
    final coords = img['centroid_coordinates'] as Map<String, dynamic>?;
    final lat = (coords?['lat'] as num?)?.toDouble();
    final lon = (coords?['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) return const SizedBox.shrink();

    final regionText = EarthGeoHelper.describeRegion(lat, lon);
    final sunlitText = EarthGeoHelper.describeSunlitSide(lon);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this view',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.public, size: 16, color: _secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  regionText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.wb_sunny_outlined,
                    size: 16, color: _secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sunlitText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // D2) COSMIC CONTEXT — 2×2 stat grid (live-calculated)
  // ─────────────────────────────────────────────────────────────
  Widget _buildCosmicContext() {
    if (_currentDate.isEmpty) return const SizedBox.shrink();
    final DateTime date;
    try {
      date = DateTime.parse(_currentDate);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final sunMillionKm = EarthGeoHelper.earthSunDistanceMillionKm(date);
    final moonKm       = EarthGeoHelper.earthMoonDistanceKm(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cosmic Context',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _statCard(
                label: 'DISTANCE FROM SUN',
                value: '${sunMillionKm.toStringAsFixed(2)}M km',
                icon: Icons.wb_sunny,
              ),
              _statCard(
                label: 'DISTANCE FROM MOON',
                value: '${(moonKm / 1000).toStringAsFixed(0)}K km',
                icon: Icons.brightness_2,
              ),
              _statCard(
                label: 'ORBITAL SPEED',
                value: '107,200 km/h',
                icon: Icons.speed,
              ),
              _statCard(
                label: 'ROTATION (EQUATOR)',
                value: '1,670 km/h',
                icon: Icons.refresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _secondary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: _accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: _secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // D3) THE MISSION — DSCOVR + EPIC educational card
  // ─────────────────────────────────────────────────────────────
  Widget _buildMission() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Mission',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _secondary.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _missionEntry(
                  icon: Icons.satellite_alt,
                  name: 'DSCOVR',
                  kind: 'Satellite',
                  body:
                      'Launched in 2015, the Deep Space Climate Observatory '
                      'orbits at the L1 Lagrange point — a gravitational '
                      'sweet spot 1.5 million km between Earth and the Sun.',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    color: _secondary.withValues(alpha: 0.1),
                    height: 1,
                  ),
                ),
                _missionEntry(
                  icon: Icons.camera_alt,
                  name: 'EPIC',
                  kind: 'Camera',
                  body:
                      'The Earth Polychromatic Imaging Camera takes 10–22 '
                      'photos daily across 10 narrowband filters, capturing '
                      'the full sunlit face of Earth in stunning '
                      '2048×2048 detail.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionEntry({
    required IconData icon,
    required String name,
    required String kind,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: _accent),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: _primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              kind,
              style: GoogleFonts.inter(fontSize: 12, color: _secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.6,
            color: _secondary,
          ),
        ),
      ],
    );
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
    );
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
            child: ShimmerCircle(size: h * 0.7, overlay: true),
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
