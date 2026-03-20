import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/nasa_image.dart';
import '../../theme/app_colors.dart';

class WallpaperPreviewScreen extends StatefulWidget {
  final NasaImage image;
  const WallpaperPreviewScreen({super.key, required this.image});

  @override
  State<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends State<WallpaperPreviewScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _hdUrl {
    // NASA image URLs: replace ~thumb with ~orig for HD
    final url = widget.image.imageUrl;
    return url.replaceAll('~thumb', '~orig').replaceAll('~medium', '~orig');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen image
          InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: CachedNetworkImage(
              imageUrl: widget.image.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => const Center(child: CupertinoActivityIndicator(color: Colors.white)),
              errorWidget: (_, _, _) => const Center(child: Icon(CupertinoIcons.photo, size: 64, color: Colors.white38)),
            ),
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(CupertinoIcons.xmark, () => Navigator.pop(context)),
                _circleBtn(CupertinoIcons.arrow_down_to_line, _downloadHD),
              ],
            ),
          ),

          // Bottom bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.85)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.image.title,
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('NASA \u2022 ${widget.image.center}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.accentPurple)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Download / Set Wallpaper
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(14),
                            onPressed: _downloadHD,
                            child: Text('Download HD', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share
                      Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => SharePlus.instance.share(ShareParams(
                            text: '${widget.image.title}\n\nNASA Space Wallpaper\n${widget.image.imageUrl}\n\nvia Cosmic Facts',
                          )),
                          child: const Icon(CupertinoIcons.share, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  void _downloadHD() async {
    final uri = Uri.tryParse(_hdUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
