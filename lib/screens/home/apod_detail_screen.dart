import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/api_endpoints.dart';
import '../../models/apod_model.dart';
import '../../theme/app_colors.dart';

class ApodDetailScreen extends StatefulWidget {
  final ApodModel apod;

  const ApodDetailScreen({super.key, required this.apod});

  @override
  State<ApodDetailScreen> createState() => _ApodDetailScreenState();
}

class _ApodDetailScreenState extends State<ApodDetailScreen> {
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;

    // Video APODs → text-only fallback (matches existing share pattern).
    if (widget.apod.mediaType != 'image') {
      await _shareTextOnly();
      return;
    }

    setState(() => _isSharing = true);

    try {
      // Wait for the next frame so the off-screen poster is laid out and the
      // cached APOD image has had a chance to paint into the RepaintBoundary.
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        await _shareTextOnly();
        return;
      }

      // pixelRatio 3.0 → 360×450 logical → 1080×1350 actual (Instagram 4:5).
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await _shareTextOnly();
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filename =
          'cosmic_apod_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: _buildCaption(),
        ),
      );
    } catch (e) {
      debugPrint('APOD share capture failed, falling back to text: $e');
      await _shareTextOnly();
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareTextOnly() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '${_buildCaption()}\n\n${widget.apod.imageUrl}',
        ),
      );
    } catch (_) {}
  }

  String _buildCaption() {
    return '🌌 ${widget.apod.title}\n\n'
        'Astronomy Picture of the Day — ${widget.apod.date}\n'
        'Source: NASA APOD public archive (api.nasa.gov)\n\n'
        '📲 Browse daily NASA photos on Cosmic Facts:\n'
        '${ApiEndpoints.playStore}\n\n'
        'Shared via Cosmic Facts — not affiliated with NASA';
  }

  @override
  Widget build(BuildContext context) {
    final apod = widget.apod;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Image + nav bar
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Hero image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: apod.mediaType == 'image'
                          ? CachedNetworkImage(
                              imageUrl: apod.imageUrl,
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                height: 350,
                                color: AppColors.card(context),
                                child: const Center(
                                  child: CupertinoActivityIndicator(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                height: 350,
                                color: AppColors.card(context),
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 48,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            )
                          : Container(
                              height: 350,
                              color: AppColors.card(context),
                              child: Center(
                                child: Text(
                                  'Video content',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    // Back + share
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.all(8),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                child: const Icon(
                                  CupertinoIcons.back,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            CupertinoButton(
                              padding: const EdgeInsets.all(8),
                              onPressed: _isSharing ? null : _handleShare,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                child: Center(
                                  child: _isSharing
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CupertinoActivityIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          CupertinoIcons.share,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        apod.date,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        apod.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Explanation
                      Text(
                        apod.explanation,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary(context)
                              .withValues(alpha: 0.85),
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Off-screen poster captured for sharing.
          // Always rendered (so it's laid out and the image cache is warm),
          // pushed far off-screen so the user never sees it.
          Positioned(
            left: -9999,
            top: 0,
            child: RepaintBoundary(
              key: _shareKey,
              child: _ShareablePoster(apod: apod),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SHAREABLE POSTER (4:5 portrait, 360×450 logical → 1080×1350 at 3x)
// ═════════════════════════════════════════════

class _ShareablePoster extends StatelessWidget {
  final ApodModel apod;
  const _ShareablePoster({required this.apod});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SizedBox(
        width: 360,
        height: 450,
        child: Stack(
          children: [
            // 1. APOD image (top portion, full-bleed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 320,
              child: CachedNetworkImage(
                imageUrl: apod.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: const Color(0xFF0A1E36)),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFF0A1E36),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white24,
                    size: 60,
                  ),
                ),
              ),
            ),

            // 2. Dark gradient over image bottom (so title is legible)
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Title + date over image
            Positioned(
              left: 20,
              right: 20,
              bottom: 145,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    apod.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black.withValues(alpha: 0.7),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${apod.date}  ·  via NASA APOD',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Brand strip — bottom 130px, blue→cyan gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0066CC),
                      Color(0xFF38BDF8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // App icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/app_icon.jpg',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cosmic Facts',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Daily NASA photos · ISS · 84 lessons',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Get it on Google Play',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. NASA disclaimer — tiny footer line inside the brand strip
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Not affiliated with NASA',
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
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
