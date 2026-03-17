import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/nasa_image.dart';
import '../../theme/app_colors.dart';

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

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _DetailPage(
            image: widget.images[index],
            formatDate: _formatDate,
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SINGLE DETAIL PAGE
// ═════════════════════════════════════════════

class _DetailPage extends StatefulWidget {
  final NasaImage image;
  final String Function(String) formatDate;

  const _DetailPage({required this.image, required this.formatDate});

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage> {
  bool _expanded = false;

  NasaImage get img => widget.image;

  Future<void> _shareImage() async {
    final text =
        '${img.title}\n\nSource: ${img.center}\n\nShared via Cosmic Facts 🌌';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.sizeOf(context).height * 0.45;

    return Stack(
      children: [
        // ── Scrollable content ──
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image — starts from very top
              CachedNetworkImage(
                imageUrl: img.imageUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: imageHeight,
                  color: AppColors.cardDark,
                  child: const Center(
                    child: CupertinoActivityIndicator(
                        color: AppColors.accentPurple),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: imageHeight,
                  color: AppColors.cardDark,
                  child: const Center(
                    child: Icon(CupertinoIcons.photo,
                        size: 48, color: AppColors.textSecondaryDark),
                  ),
                ),
              ),

              // Content below image
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source + date row
                    Row(
                      children: [
                        Text(
                          'NASA / ${img.center}',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentPurple),
                        ),
                        const Spacer(),
                        Text(
                          widget.formatDate(img.dateCreated),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      img.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),

                    // Description
                    if (img.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _expanded = !_expanded),
                        child: Text(
                          img.description,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.7,
                          ),
                          maxLines: _expanded ? 100 : 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_expanded && img.description.length > 200)
                        GestureDetector(
                          onTap: () => setState(() => _expanded = true),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Show More',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentPurple,
                              ),
                            ),
                          ),
                        ),
                    ],

                    // Keywords
                    if (img.keywords.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: img.keywords.take(8).map((k) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              k,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Floating top bar over image ──
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.back,
                        color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _shareImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.share,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
