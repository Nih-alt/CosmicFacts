import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/apod_model.dart';
import '../../theme/app_colors.dart';

class ApodDetailScreen extends StatelessWidget {
  final ApodModel apod;

  const ApodDetailScreen({super.key, required this.apod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
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
                            color: AppColors.cardDark,
                            child: const Center(
                              child: CupertinoActivityIndicator(
                                color: AppColors.accentPurple,
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            height: 350,
                            color: AppColors.cardDark,
                            child: const Icon(
                              CupertinoIcons.photo,
                              size: 48,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        )
                      : Container(
                          height: 350,
                          color: AppColors.cardDark,
                          child: Center(
                            child: Text(
                              'Video content',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ),
                        ),
                ),

                // Back + share
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                          onPressed: () {},
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: const Icon(
                              CupertinoIcons.share,
                              size: 17,
                              color: Colors.white,
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
                      color: AppColors.accentPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    apod.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
