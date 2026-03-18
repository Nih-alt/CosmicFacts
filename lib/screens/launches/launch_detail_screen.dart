import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/launch_model.dart';
import '../../theme/app_colors.dart';

class LaunchDetailScreen extends StatefulWidget {
  final LaunchModel launch;
  const LaunchDetailScreen({super.key, required this.launch});

  @override
  State<LaunchDetailScreen> createState() => _LaunchDetailScreenState();
}

class _LaunchDetailScreenState extends State<LaunchDetailScreen> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  LaunchModel get launch => widget.launch;
  bool get _isUpcoming => launch.launchDate.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (_isUpcoming) {
      _remaining = launch.launchDate.difference(DateTime.now());
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (!mounted) return;
          final newRemaining = launch.launchDate.difference(DateTime.now());
          setState(() {
            _remaining = newRemaining;
            if (newRemaining.isNegative) {
              _countdownTimer?.cancel();
              // UI will auto-rebuild — _isUpcoming becomes false
              // "Watch on YouTube" button will appear automatically
              // Countdown will hide, "Set Reminder" will hide
            }
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHero(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _providerBadgeWidget(),
                  const SizedBox(height: 12),
                  Text(
                    launch.rocketName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  if (launch.missionName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      launch.missionName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                  if (_isUpcoming && !_remaining.isNegative) ...[
                    const SizedBox(height: 28),
                    Text(
                      'T-minus',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentPurple,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCountdown(),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    color: AppColors.divider(context),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.rocket_launch, 'Provider', launch.provider)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
                  _buildInfoRow(Icons.calendar_today, 'Date', _formatDate(launch.launchDate))
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 200.ms),
                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    launch.padLocation.isEmpty ? 'TBD' : launch.padLocation,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 300.ms),
                  _buildInfoRow(
                    Icons.info_outline,
                    'Status',
                    launch.status,
                    valueColor: _statusColor(),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 400.ms),
                  const SizedBox(height: 24),

                  // Watch on YouTube — past launches only
                  if (!_isUpcoming) _buildWatchButton(),

                  const SizedBox(height: 12),

                  // Share button — always visible
                  _buildShareButton(),

                  // Set Reminder — upcoming only
                  if (_isUpcoming) ...[
                    const SizedBox(height: 12),
                    _buildReminderButton(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOP HERO
  // ═══════════════════════════════════════

  Widget _buildTopHero() {
    final height = MediaQuery.sizeOf(context).height * 0.35;
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _providerGradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Mission patch image if available
          if (launch.imageUrl.isNotEmpty)
            Center(
              child: CachedNetworkImage(
                imageUrl: launch.imageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentPurple.withValues(alpha: 0.2),
                          AppColors.accentCyan.withValues(alpha: 0.2),
                        ],
                      ),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Icon(Icons.rocket_launch,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.6)),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: const Duration(seconds: 2),
                      ),
                  const SizedBox(height: 14),
                  if (_isUpcoming)
                    Text(
                      'LAUNCHING SOON',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                ],
              ),
            ),

          // Twinkling stars overlay
          ...List.generate(15, (i) {
            final starRng = Random(i * 7);
            final delay = Duration(milliseconds: starRng.nextInt(2000));
            final duration =
                Duration(milliseconds: 800 + starRng.nextInt(1500));
            return Positioned(
              left: starRng.nextDouble() * screenWidth,
              top: starRng.nextDouble() * height,
              child: Container(
                width: 1.5 + starRng.nextDouble() * 2,
                height: 1.5 + starRng.nextDouble() * 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                      alpha: 0.3 + starRng.nextDouble() * 0.5),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                      onPlay: (c) => c.repeat(reverse: true), delay: delay)
                  .fadeIn(duration: duration)
                  .then()
                  .fadeOut(duration: duration),
            );
          }),

          // Back button — top left
          Positioned(
            top: topPad + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.54),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),

          // Provider badge — top right
          Positioned(
            top: topPad + 8,
            right: 12,
            child: _providerBadgeWidget(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════

  Widget _buildWatchButton() {
    return GestureDetector(
      onTap: () {
        final query = Uri.encodeComponent(
          '${launch.provider} ${launch.rocketName} ${launch.missionName} launch',
        );

        if (launch.videoUrl.isNotEmpty) {
          launchUrl(Uri.parse(launch.videoUrl),
              mode: LaunchMode.externalApplication);
        } else {
          launchUrl(
            Uri.parse('https://www.youtube.com/results?search_query=$query'),
            mode: LaunchMode.externalApplication,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0000).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              'Watch Launch on YouTube',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        try {
          SharePlus.instance.share(ShareParams(
            text: '${launch.rocketName} \u2014 ${launch.missionName}\n'
                'Provider: ${launch.provider}\n'
                'Date: ${_formatDate(launch.launchDate)}\n\n'
                'Shared via Cosmic Facts \u{1F30C}\u{1F680}',
          ));
        } catch (_) {}
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, color: AppColors.accentPurple, size: 20),
            const SizedBox(width: 10),
            Text(
              'Share This Launch',
              style: GoogleFonts.inter(
                color: AppColors.accentPurple,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderButton() {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Coming Soon'),
            content: const Text(
                'Launch reminders will be available in the next update!'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              'Set Launch Reminder',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // PROVIDER BADGE
  // ═══════════════════════════════════════

  Widget _providerBadgeWidget() {
    final color = _providerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        launch.provider,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // COUNTDOWN
  // ═══════════════════════════════════════

  Widget _buildCountdown() {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _countdownUnit(days, 'DAYS'),
        _countdownSeparator(),
        _countdownUnit(hours, 'HRS'),
        _countdownSeparator(),
        _countdownUnit(minutes, 'MIN'),
        _countdownSeparator(),
        _countdownUnit(seconds, 'SEC'),
      ],
    );
  }

  Widget _countdownUnit(int value, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countdownSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // INFO ROWS
  // ═══════════════════════════════════════

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════

  Color get _providerColor {
    final p = launch.provider.toLowerCase();
    if (p.contains('spacex')) return AppColors.accentCyan;
    if (p.contains('nasa')) return const Color(0xFF4A90D9);
    if (p.contains('isro')) return const Color(0xFFFF9933);
    if (p.contains('ula')) return AppColors.success;
    if (p.contains('rocket lab')) return AppColors.accentPurple;
    if (p.contains('ariane')) return AppColors.starGold;
    if (p.contains('blue origin')) return const Color(0xFF2196F3);
    return AppColors.accentPurple;
  }

  List<Color> get _providerGradientColors {
    final p = launch.provider.toLowerCase();
    if (p.contains('spacex')) {
      return const [Color(0xFF004060), Color(0xFF002040), Color(0xFF05051A)];
    }
    if (p.contains('isro')) {
      return const [Color(0xFF402000), Color(0xFF201000), Color(0xFF05051A)];
    }
    if (p.contains('nasa')) {
      return const [Color(0xFF002060), Color(0xFF001040), Color(0xFF05051A)];
    }
    if (p.contains('blue origin')) {
      return const [Color(0xFF002040), Color(0xFF001020), Color(0xFF05051A)];
    }
    if (p.contains('ariane')) {
      return const [Color(0xFF203000), Color(0xFF102000), Color(0xFF05051A)];
    }
    return const [Color(0xFF1A0040), Color(0xFF0A0020), Color(0xFF05051A)];
  }

  Color _statusColor() {
    final s = launch.status.toLowerCase();
    if (s.contains('success')) return const Color(0xFF00E096);
    if (s.contains('failure')) return const Color(0xFFFF4D6A);
    if (s.contains('upcoming')) return const Color(0xFF7B5BFF);
    if (s.contains('partial')) return AppColors.accentOrange;
    return const Color(0xFF7878AA);
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year} at $h:$m';
  }
}
