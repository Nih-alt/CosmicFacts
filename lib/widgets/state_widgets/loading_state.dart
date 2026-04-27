import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Centered loading indicator with optional message.
///
/// Defaults to `CupertinoActivityIndicator` (the pattern used by most
/// of the app). For screens that explicitly use Material's
/// `CircularProgressIndicator` (quiz, learn, explore lists) pass
/// [useMaterial]=true so the visual is preserved during migration.
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool useMaterial;
  final double indicatorSize;
  final Color? indicatorColor;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.useMaterial = false,
    this.indicatorSize = 32,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = indicatorColor ?? AppColors.textSecondary(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useMaterial)
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: indicatorColor ?? AppColors.accentBlue,
              ),
            )
          else
            CupertinoActivityIndicator(
              radius: indicatorSize / 2.5,
              color: color,
            ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
