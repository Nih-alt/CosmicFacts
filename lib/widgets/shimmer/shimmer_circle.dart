import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Circular shimmer placeholder. Used for circular avatars and the
/// EPIC planet hero placeholder. Pass [overlay]=true for shimmer
/// rendered over dark imagery.
class ShimmerCircle extends StatelessWidget {
  final double size;
  final bool overlay;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = overlay
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.shimmerBase(context);
    final highlight = overlay
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.shimmerHighlight(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
