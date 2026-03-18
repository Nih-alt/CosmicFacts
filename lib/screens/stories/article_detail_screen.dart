import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/space_article.dart';
import '../../theme/app_colors.dart';

// ═════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════

LinearGradient _sourceBadgeGradient(String source) {
  final s = source.toLowerCase();
  if (s.contains('nasa')) return const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)]);
  if (s.contains('isro')) return const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF6F00)]);
  if (s.contains('spacex')) return const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0097A7)]);
  if (s.contains('esa')) return const LinearGradient(colors: [Color(0xFF00E096), Color(0xFF00A86B)]);
  return const LinearGradient(colors: [Color(0xFF7B5BFF), Color(0xFF5B3FD4)]);
}

String _sourceDescription(String source) {
  final s = source.toLowerCase();
  if (s.contains('nasa')) return 'National Aeronautics and Space Administration — America\'s space agency';
  if (s.contains('spacenews')) return 'Leading source for space industry news and analysis';
  if (s.contains('esa')) return 'European Space Agency — Europe\'s gateway to space';
  if (s.contains('spacex')) return 'SpaceX — Designing, manufacturing, and launching rockets and spacecraft';
  if (s.contains('isro')) return 'Indian Space Research Organisation — India\'s space agency';
  if (s.contains('space.com')) return 'Space.com — Your source for the latest astronomy news';
  return '$source — Space news and coverage';
}

String _sourceWebsite(String source, String fallbackUrl) {
  final s = source.toLowerCase();
  if (s.contains('nasa')) return 'https://www.nasa.gov';
  if (s.contains('spacenews')) return 'https://spacenews.com';
  if (s.contains('esa')) return 'https://www.esa.int';
  if (s.contains('space.com')) return 'https://www.space.com';
  if (s.contains('isro')) return 'https://www.isro.gov.in';
  if (s.contains('spacex')) return 'https://www.spacex.com';
  return fallbackUrl;
}

String _formatDate(DateTime dt) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

int _estimateReadTime(String text) {
  final words = text.split(RegExp(r'\s+')).length;
  return (words / 200).ceil().clamp(1, 30);
}

// ═════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════

class ArticleDetailScreen extends StatefulWidget {
  final SpaceArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final _isBookmarked = false.obs;

  SpaceArticle get article => widget.article;

  void _launchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open link',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: AppColors.surface(context),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.surface(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _shareStory() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              '${article.title}\n\nRead more: ${article.articleUrl}\n\nShared via Cosmic Facts 🌌',
        ),
      );
    } catch (_) {
      // Ignore share cancellation
    }
  }

  void _toggleBookmark() {
    _isBookmarked.value = !_isBookmarked.value;
    final msg =
        _isBookmarked.value ? 'Story bookmarked!' : 'Bookmark removed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.surface(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readTime = _estimateReadTime(article.summary);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background(context),
            leading: CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: const Icon(CupertinoIcons.back,
                    size: 18, color: Colors.white),
              ),
            ),
            actions: [
              // Bookmark
              Obx(() => CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: _toggleBookmark,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: Icon(
                        _isBookmarked.value
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        size: 17,
                        color: _isBookmarked.value
                            ? AppColors.starGold
                            : Colors.white,
                      ),
                    ),
                  )),
              // Share
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                onPressed: _shareStory,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  child: const Icon(CupertinoIcons.share,
                      size: 17, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase(context),
                        highlightColor: AppColors.shimmerHighlight(context),
                        child: Container(color: AppColors.shimmerBase(context)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.accentPurple.withValues(alpha: 0.2),
                            AppColors.backgroundDark,
                          ]),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentPurple.withValues(alpha: 0.25),
                            AppColors.accentCyan.withValues(alpha: 0.1),
                            AppColors.backgroundDark,
                          ],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundDark.withValues(alpha: 0.8),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Article content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & date row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: _sourceBadgeGradient(article.newsSite),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.newsSite,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(article.publishedAt),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary(context)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$readTime min read',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Article body
                  Text(
                    article.summary,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textPrimary(context).withValues(alpha: 0.9),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.divider(context),
                  ),

                  const SizedBox(height: 24),

                  // Source label
                  Text(
                    'Source: ${article.newsSite}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About the Source card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.glass(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.glassBorder(context)),
                          boxShadow: AppColors.cardShadow(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About the Source',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _sourceDescription(article.newsSite),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _launchUrl(
                                _sourceWebsite(
                                    article.newsSite, article.articleUrl),
                              ),
                              child: Text(
                                'Visit Website',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Read Original Article button
                  GestureDetector(
                    onTap: () => _launchUrl(article.articleUrl),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              AppColors.accentPurple.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'Read Original Article ↗',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Share button
                  GestureDetector(
                    onTap: _shareStory,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple
                                .withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Share This Story',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
