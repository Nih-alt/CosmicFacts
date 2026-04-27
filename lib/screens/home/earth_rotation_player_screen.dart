import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';

/// Fullscreen immersive viewer that animates through a day's EPIC frames
/// to reveal a 24-hour Earth rotation.
class EarthRotationPlayerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final String date;
  final int initialIndex;

  const EarthRotationPlayerScreen({
    super.key,
    required this.images,
    required this.date,
    this.initialIndex = 0,
  });

  @override
  State<EarthRotationPlayerScreen> createState() =>
      _EarthRotationPlayerScreenState();
}

class _EarthRotationPlayerScreenState extends State<EarthRotationPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  Timer? _advanceTimer;
  Timer? _hideUiTimer;

  int _index = 0;
  bool _playing = true;
  bool _uiVisible = true;
  int _speedIndex = 0; // 0 = 1x, 1 = 2x, 2 = 4x
  static const _speeds = [1, 2, 4];

  static const _baseFrameMs = 800;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageCtrl = PageController(initialPage: _index);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _startAutoPlay();
    _resetUiHideTimer();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _hideUiTimer?.cancel();
    _pageCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── playback control ───────────────────────────────────────────
  Duration get _frameDuration =>
      Duration(milliseconds: (_baseFrameMs / _speeds[_speedIndex]).round());

  void _startAutoPlay() {
    _advanceTimer?.cancel();
    if (!_playing) return;
    _advanceTimer = Timer.periodic(_frameDuration, (_) {
      if (!mounted || widget.images.isEmpty) return;
      final next = (_index + 1) % widget.images.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _startAutoPlay();
    _resetUiHideTimer();
  }

  void _cycleSpeed() {
    setState(() => _speedIndex = (_speedIndex + 1) % _speeds.length);
    _startAutoPlay();
    _resetUiHideTimer();
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
  }

  void _onUserSwipe() {
    // Stop auto-play when the user takes manual control.
    if (_playing) {
      setState(() => _playing = false);
      _advanceTimer?.cancel();
    }
  }

  // ── UI auto-hide ───────────────────────────────────────────────
  void _resetUiHideTimer() {
    _hideUiTimer?.cancel();
    if (!_uiVisible) return;
    _hideUiTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _uiVisible = false);
    });
  }

  void _toggleUi() {
    setState(() => _uiVisible = !_uiVisible);
    _resetUiHideTimer();
  }

  // ── helpers ────────────────────────────────────────────────────
  String _imageUrl(Map<String, dynamic> img) {
    final imageName = img['image']?.toString() ?? '';
    final parts = widget.date.split('-');
    if (parts.length != 3) {
      return ApiService.getEpicImageUrl(widget.date, imageName,
          thumbnail: false);
    }
    // Mid-quality JPG (not modifying api_service): /archive/natural/Y/M/D/jpg/...
    return 'https://epic.gsfc.nasa.gov/archive/natural/'
        '${parts[0]}/${parts[1]}/${parts[2]}/jpg/$imageName.jpg';
  }

  String _formattedDateTime() {
    if (widget.images.isEmpty) return widget.date;
    final dateStr = widget.images[_index]['date']?.toString() ?? '';
    if (dateStr.isEmpty) return widget.date;
    // EPIC date format: "2026-04-25 00:41:06"
    final parts = dateStr.split(' ');
    final ymd = parts.first.split('-');
    final time = parts.length > 1 ? parts[1] : '';
    if (ymd.length != 3) return dateStr;
    final months = const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final m = int.tryParse(ymd[1]) ?? 1;
    final d = int.tryParse(ymd[2]) ?? 1;
    return '${months[m - 1]} $d, ${ymd[0]} — $time UTC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUi,
        onVerticalDragEnd: (details) {
          // Swipe down past threshold → exit.
          final v = details.primaryVelocity ?? 0;
          if (v > 600) Navigator.of(context).pop();
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1) Photo display
            PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                final url = _imageUrl(widget.images[i]);
                return Listener(
                  // Detect a manual horizontal drag start to pause autoplay.
                  onPointerMove: (e) {
                    if (e.delta.dx.abs() > 6) _onUserSwipe();
                  },
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        cacheKey: 'epic_player_${widget.images[i]['image']}',
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: Colors.white38, size: 48),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 2) Top overlay
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _uiVisible ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_uiVisible,
                child: _buildTopOverlay(),
              ),
            ),

            // 3) Bottom overlay
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _uiVisible ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_uiVisible,
                child: _buildBottomOverlay(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            12, MediaQuery.of(context).padding.top + 8, 12, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
              splashRadius: 22,
            ),
            Expanded(
              child: Center(
                child: Text(
                  _formattedDateTime(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                '${_index + 1} / ${widget.images.length}',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay() {
    final speed = _speeds[_speedIndex];
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            18, 28, 18, MediaQuery.of(context).padding.bottom + 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar with frame markers
            _ProgressBar(
              total: widget.images.length,
              current: _index,
              onTap: (i) {
                _pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
                _resetUiHideTimer();
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed selector
                GestureDetector(
                  onTap: _cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      '${speed}x',
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                // Play / pause — large center button
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      _playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // Spacer placeholder so play stays visually centered.
                const SizedBox(width: 56, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin progress line with vertical frame markers; tap a marker to jump.
class _ProgressBar extends StatelessWidget {
  final int total;
  final int current;
  final ValueChanged<int> onTap;

  const _ProgressBar({
    required this.total,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final progress = total <= 1 ? 0.0 : current / (total - 1);
        return SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track
              Center(
                child: Container(
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              // Fill
              Positioned(
                left: 0,
                child: Container(
                  width: w * progress,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.7),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Frame markers
              for (int i = 0; i < total; i++)
                Positioned(
                  left: (w - 3) * (total <= 1 ? 0 : i / (total - 1)),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onTap(i),
                    child: SizedBox(
                      width: 14,
                      height: 16,
                      child: Center(
                        child: Container(
                          width: 3,
                          height: i == current ? 12 : 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: i == current ? 1.0 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
