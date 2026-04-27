import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Centered error-state widget: icon + title + optional message + optional retry.
///
/// Use [ErrorStateWidget.network] for the common "no internet, try again"
/// preset. For bespoke error states (custom retry CTAs, dual-button
/// layouts, RealisticAsteroid icons) keep the existing inline widget.
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String retryLabel;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = CupertinoIcons.exclamationmark_triangle,
    this.retryLabel = 'Retry',
  });

  /// Network-specific error preset (wifi-slash icon + canonical copy).
  factory ErrorStateWidget.network({
    Key? key,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return ErrorStateWidget(
      key: key,
      title: 'No internet connection',
      message: 'Check your connection and try again',
      icon: CupertinoIcons.wifi_slash,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CupertinoButton(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(12),
                onPressed: onRetry,
                child: Text(
                  retryLabel,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
