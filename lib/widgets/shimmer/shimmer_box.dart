import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Reusable shimmer rectangle / rounded box.
///
/// Use [overlay] when shimmering ON TOP of a dark image (like the EPIC
/// Earth hero). This swaps the default themed colors for a translucent
/// white-alpha pair so the shimmer remains visible against black.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool overlay;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
    this.overlay = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final base = overlay
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.shimmerBase(context);
    final highlight = overlay
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.shimmerHighlight(context);

    final box = Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    if (margin == null) return box;
    return Padding(padding: margin!, child: box);
  }
}
