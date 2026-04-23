import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/launches_controller.dart';
import '../../models/launch_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/launch_branding.dart';
import 'launch_detail_screen.dart';

class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> {
  LaunchesController get _ctrl => Get.find<LaunchesController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Launches',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  Obx(() {
                    final hasFilter = _ctrl.selectedProvider.value !=
                        LaunchesController.allProvidersLabel;
                    return GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: hasFilter
                              ? AppColors.accentBlue.withValues(alpha: 0.15)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasFilter
                                ? AppColors.accentBlue
                                    .withValues(alpha: 0.5)
                                : AppColors.cardBorder(context),
                          ),
                          boxShadow: AppColors.cardShadow(context),
                        ),
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 18,
                          color: hasFilter
                              ? AppColors.accentBlue
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _ctrl.selectedTab.value,
                    backgroundColor: AppColors.card(context),
                    thumbColor: AppColors.accentBlue,
                    onValueChanged: (v) {
                      if (v != null) _ctrl.selectedTab.value = v;
                    },
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text(
                          'Upcoming',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ctrl.selectedTab.value == 0
                                ? Colors.white
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text(
                          'Past',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ctrl.selectedTab.value == 1
                                ? Colors.white
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    },
                  ),
                );
              }),
            ),

            // Active filter chip (only when a provider filter is active)
            Obx(() {
              if (_ctrl.selectedProvider.value ==
                  LaunchesController.allProvidersLabel) {
                return const SizedBox(height: 16);
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    _ActiveFilterChip(
                      provider: _ctrl.selectedProvider.value,
                      onClear: _ctrl.clearProviderFilter,
                    ),
                  ],
                ),
              );
            }),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (_ctrl.hasError.value &&
          _ctrl.upcomingLaunches.isEmpty &&
          _ctrl.pastLaunches.isEmpty) {
        return _buildError();
      }
      if (_ctrl.isLoading.value &&
          _ctrl.upcomingLaunches.isEmpty &&
          _ctrl.pastLaunches.isEmpty) {
        return _ShimmerList();
      }

      final isUpcoming = _ctrl.selectedTab.value == 0;
      // Touch selectedProvider so Obx rebuilds when the filter changes.
      final _ = _ctrl.selectedProvider.value;
      final launches =
          isUpcoming ? _ctrl.filteredUpcoming : _ctrl.filteredPast;

      if (launches.isEmpty) {
        final isFiltered = _ctrl.selectedProvider.value !=
            LaunchesController.allProvidersLabel;
        return _buildEmpty(isUpcoming, isFiltered: isFiltered);
      }

      return RefreshIndicator(
        onRefresh: _ctrl.loadLaunches,
        color: AppColors.accentBlue,
        backgroundColor: AppColors.surface(context),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          cacheExtent: 500,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount:
              isUpcoming ? launches.length : launches.length,
          itemBuilder: (context, index) {
            // Hero card for first upcoming launch
            if (isUpcoming && index == 0) {
              return _HeroLaunchCard(launch: launches[0])
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  );
            }

            final launch = launches[index];
            return _LaunchCard(
              launch: launch,
              isUpcoming: isUpcoming,
            )
                .animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 50 * (index.clamp(0, 10))),
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 400.ms,
                  delay: Duration(milliseconds: 50 * (index.clamp(0, 10))),
                );
          },
        ),
      );
    });
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.wifi_slash,
              size: 48, color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text("Couldn't load launches",
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: _ctrl.loadLaunches,
            child: Text('Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isUpcoming, {bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isFiltered ? '\u{1F50D}' : (isUpcoming ? '\u{1F680}' : '\u{1F4CB}'),
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            isFiltered
                ? 'No matching launches'
                : (isUpcoming ? 'No upcoming launches' : 'No past launches'),
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context)),
          ),
          const SizedBox(height: 4),
          Text(
              isFiltered
                  ? 'Try a different provider filter.'
                  : 'Check back soon!',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary(context))),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(12),
              onPressed: _ctrl.clearProviderFilter,
              child: Text('Clear filter',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // FILTER BOTTOM SHEET
  // ═══════════════════════════════════════
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        selected: _ctrl.selectedProvider.value,
        onPick: (v) {
          _ctrl.setProviderFilter(v);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// =============================================
// ACTIVE FILTER CHIP
// =============================================

class _ActiveFilterChip extends StatelessWidget {
  final String provider;
  final VoidCallback onClear;
  const _ActiveFilterChip({
    required this.provider,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? LaunchBranding.providerColorOnDark(provider)
        : LaunchBranding.providerColor(provider);
    final emoji = LaunchBranding.providerEmoji(provider);
    return GestureDetector(
      onTap: onClear,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              provider,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.xmark_circle_fill,
                size: 14, color: color.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

// =============================================
// FILTER BOTTOM SHEET
// =============================================

class _FilterSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onPick;
  const _FilterSheet({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Filter by Provider',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            ...LaunchesController.providerOptions.map((option) {
              final isSelected = option == selected;
              final emoji = option == LaunchesController.allProvidersLabel
                  ? '\u{1F30C}'
                  : (option == 'Other'
                      ? '\u{1F6F0}'
                      : LaunchBranding.providerEmoji(option));
              final color = option == LaunchesController.allProvidersLabel
                  ? AppColors.accentBlue
                  : (isDark
                      ? LaunchBranding.providerColorOnDark(option)
                      : LaunchBranding.providerColor(option));
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPick(option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.5)
                          : AppColors.cardBorder(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? color
                                : AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(CupertinoIcons.checkmark_alt,
                            size: 18, color: color),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =============================================
// HERO LAUNCH CARD (first upcoming launch)
// =============================================

class _HeroLaunchCard extends StatefulWidget {
  final LaunchModel launch;
  const _HeroLaunchCard({required this.launch});

  @override
  State<_HeroLaunchCard> createState() => _HeroLaunchCardState();
}

class _HeroLaunchCardState extends State<_HeroLaunchCard> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final diff = widget.launch.launchDate.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = diff);
    }
  }

  bool get _isUpcoming => widget.launch.launchDate.isAfter(DateTime.now());

  String _formatLaunchDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final launch = widget.launch;
    final accent = LaunchBranding.providerColorOnDark(launch.provider);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => LaunchDetailScreen(launch: launch),
        ),
      ),
      child: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (launch.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: launch.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 700,
                placeholder: (_, _) =>
                    Container(color: AppColors.card(context)),
                errorWidget: (_, _, _) =>
                    _gradientFallback(),
              )
            else
              _gradientFallback(),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Provider-colored left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: accent),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider badge (on dark hero overlay)
                  _ProviderBadge(provider: launch.provider, onDark: true),

                  const Spacer(),

                  // Countdown or Launched badge
                  if (!_isUpcoming)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.success
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Text('LAUNCHED',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatLaunchDate(launch.launchDate),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    )
                  else
                    _CountdownRow(remaining: _remaining),

                  const SizedBox(height: 16),

                  // Rocket + Mission
                  Text(
                    launch.rocketName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (launch.missionName.isNotEmpty)
                    Text(
                      launch.missionName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0040),
            const Color(0xFF002040),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.rocket_launch,
            size: 64, color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }
}

// =============================================
// COUNTDOWN ROW (4 glassmorphism boxes)
// =============================================

class _CountdownRow extends StatelessWidget {
  final Duration remaining;
  const _CountdownRow({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountdownUnit(value: days, label: 'DAYS'),
        const SizedBox(width: 8),
        _CountdownUnit(value: hours, label: 'HRS'),
        const SizedBox(width: 8),
        _CountdownUnit(value: minutes, label: 'MIN'),
        const SizedBox(width: 8),
        _CountdownUnit(value: seconds, label: 'SEC'),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;
  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================
// LAUNCH LIST CARD
// =============================================

class _LaunchCard extends StatelessWidget {
  final LaunchModel launch;
  final bool isUpcoming;
  const _LaunchCard({required this.launch, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final dt = launch.launchDate.toLocal();
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? LaunchBranding.providerColorOnDark(launch.provider)
        : LaunchBranding.providerColor(launch.provider);
    final emoji = LaunchBranding.providerEmoji(launch.provider);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => LaunchDetailScreen(launch: launch),
        ),
      ),
      child: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.glassBorder(context)),
                boxShadow: AppColors.cardShadow(context),
              ),
              child: Row(
                children: [
                  // Provider-colored 4px left accent
                  Container(width: 4, color: accent),
                  const SizedBox(width: 10),
                  // Date column
                  SizedBox(
                    width: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          months[dt.month - 1],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        Text(
                          dt.day.toString(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider(context),
                  ),

                  const SizedBox(width: 14),

                  // Info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          launch.rocketName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (launch.missionName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            launch.missionName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '$emoji ${launch.provider}${launch.padLocation.isNotEmpty ? ' \u2022 ${launch.padLocation}' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Status / countdown badge
                  _buildBadge(context),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Launched';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  Widget _buildBadge(BuildContext context) {
    final isFuture = launch.launchDate.isAfter(DateTime.now());

    if (isUpcoming && isFuture) {
      // Future upcoming: show relative time
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Text(
          _relativeTime(launch.launchDate),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentBlue,
          ),
        ),
      );
    }

    // Past / already launched — show status badge
    Color badgeColor;
    String label;
    if (launch.isSuccess) {
      badgeColor = AppColors.success;
      label = '\u2713 Success';
    } else if (launch.isFailure) {
      badgeColor = AppColors.error;
      label = '\u2717 Failed';
    } else if (launch.isPartial) {
      badgeColor = AppColors.accentOrange;
      label = '\u26A0 Partial';
    } else {
      badgeColor = AppColors.textSecondary(context);
      label = launch.status;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}

// =============================================
// PROVIDER BADGE
// =============================================

class _ProviderBadge extends StatelessWidget {
  final String provider;
  final bool onDark;
  const _ProviderBadge({required this.provider, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final isDark = onDark || Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? LaunchBranding.providerColorOnDark(provider)
        : LaunchBranding.providerColor(provider);
    final emoji = LaunchBranding.providerEmoji(provider);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: onDark ? 0.25 : 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            provider,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// SHIMMER LIST
// =============================================

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Hero shimmer
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase(context),
          highlightColor: AppColors.shimmerHighlight(context),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase(context),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // List shimmers
        ...List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBase(context),
              highlightColor: AppColors.shimmerHighlight(context),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase(context),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
