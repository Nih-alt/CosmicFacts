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
      color: AppColors.backgroundDark,
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(CupertinoIcons.slider_horizontal_3,
                      size: 22, color: AppColors.textSecondaryDark),
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
                    backgroundColor: AppColors.cardDark,
                    thumbColor: AppColors.accentPurple,
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
                                : AppColors.textSecondaryDark,
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
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

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
        return const _ShimmerList();
      }

      final isUpcoming = _ctrl.selectedTab.value == 0;
      final launches =
          isUpcoming ? _ctrl.upcomingLaunches : _ctrl.pastLaunches;

      if (launches.isEmpty) {
        return _buildEmpty(isUpcoming);
      }

      return RefreshIndicator(
        onRefresh: _ctrl.loadLaunches,
        color: AppColors.accentPurple,
        backgroundColor: AppColors.surfaceDark,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
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
          const Icon(CupertinoIcons.wifi_slash,
              size: 48, color: AppColors.textSecondaryDark),
          const SizedBox(height: 16),
          Text("Couldn't load launches",
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.accentPurple,
            borderRadius: BorderRadius.circular(12),
            onPressed: _ctrl.loadLaunches,
            child: Text('Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isUpcoming ? '\u{1F680}' : '\u{1F4CB}',
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            isUpcoming ? 'No upcoming launches' : 'No past launches',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text('Check back soon!',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondaryDark)),
        ],
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
              color: AppColors.accentPurple.withValues(alpha: 0.2),
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
                placeholder: (_, _) =>
                    Container(color: AppColors.cardDark),
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

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider badge
                  _ProviderBadge(provider: launch.provider),

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0040),
            Color(0xFF002040),
            Color(0xFF05051A),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
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
                            color: AppColors.accentPurple,
                          ),
                        ),
                        Text(
                          dt.day.toString(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.08),
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
                            color: Colors.white,
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
                              color: AppColors.textSecondaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '${launch.provider}${launch.padLocation.isNotEmpty ? ' \u2022 ${launch.padLocation}' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Status / countdown badge
                  _buildBadge(),
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

  Widget _buildBadge() {
    final isFuture = launch.launchDate.isAfter(DateTime.now());

    if (isUpcoming && isFuture) {
      // Future upcoming: show relative time
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.3)),
        ),
        child: Text(
          _relativeTime(launch.launchDate),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentPurple,
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
      badgeColor = AppColors.textSecondaryDark;
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
  const _ProviderBadge({required this.provider});

  Color get _color {
    final p = provider.toLowerCase();
    if (p.contains('spacex')) return AppColors.accentCyan;
    if (p.contains('nasa')) return const Color(0xFF4A90D9);
    if (p.contains('isro')) return const Color(0xFFFF9933);
    if (p.contains('ula')) return AppColors.success;
    if (p.contains('rocket lab')) return AppColors.accentPurple;
    if (p.contains('ariane')) return AppColors.starGold;
    return AppColors.accentPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        provider,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
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
          baseColor: AppColors.cardDark,
          highlightColor: const Color(0xFF1E1E4A),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
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
              baseColor: AppColors.cardDark,
              highlightColor: const Color(0xFF1E1E4A),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
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
