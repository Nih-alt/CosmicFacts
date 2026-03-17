import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/launch_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/youtube_webview.dart';

class LaunchDetailScreen extends StatefulWidget {
  final LaunchModel launch;
  const LaunchDetailScreen({super.key, required this.launch});

  @override
  State<LaunchDetailScreen> createState() => _LaunchDetailScreenState();
}

class _LaunchDetailScreenState extends State<LaunchDetailScreen> {
  String? _videoId;
  bool _isLoadingVideo = true;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  LaunchModel get launch => widget.launch;
  bool get _isUpcoming => launch.launchDate.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    // No video for upcoming launches — hasn't happened yet
    if (_isUpcoming) {
      if (mounted) setState(() => _isLoadingVideo = false);
      return;
    }

    final videoId = await ApiService.findLaunchVideo(launch);
    if (mounted) {
      setState(() {
        _videoId = videoId;
        _isLoadingVideo = false;
      });
    }
  }

  void _startCountdown() {
    if (_isUpcoming) {
      _remaining = launch.launchDate.difference(DateTime.now());
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (!mounted) return;
          setState(() {
            _remaining = launch.launchDate.difference(DateTime.now());
            if (_remaining.isNegative) _countdownTimer?.cancel();
          });
        },
      );
    }
  }

  void _openYouTubeSearch() {
    final mission =
        launch.missionName.isNotEmpty ? launch.missionName : launch.name;
    final query =
        Uri.encodeComponent('${launch.provider} $mission launch');
    launchUrl(
      Uri.parse(
          'https://www.youtube.com/results?search_query=$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _shareLaunch() {
    try {
      SharePlus.instance.share(ShareParams(
        text:
            '${launch.rocketName} \u2014 ${launch.missionName}\n'
            'Date: ${_formatDate(launch.launchDate)}\n\n'
            'Shared via Cosmic Facts \u{1F30C}',
      ));
    } catch (_) {}
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
    if (p.contains('isro')) {
      return const [Color(0xFF402000), Color(0xFF201000), Color(0xFF05051A)];
    }
    if (p.contains('spacex')) {
      return const [Color(0xFF004060), Color(0xFF002040), Color(0xFF05051A)];
    }
    if (p.contains('nasa')) {
      return const [Color(0xFF002060), Color(0xFF001040), Color(0xFF05051A)];
    }
    if (p.contains('blue origin')) {
      return const [Color(0xFF002060), Color(0xFF001040), Color(0xFF05051A)];
    }
    if (p.contains('ariane')) {
      return const [Color(0xFF403000), Color(0xFF201800), Color(0xFF05051A)];
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

  // ═══════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoSection(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // VIDEO SECTION
  // ═══════════════════════════════════════

  Widget _buildVideoSection() {
    if (_isUpcoming) return _buildUpcomingHero();

    final height = MediaQuery.sizeOf(context).height * 0.32;
    final topPad = MediaQuery.of(context).padding.top;

    // Loading
    if (_isLoadingVideo) {
      return SizedBox(
        height: height,
        child: Stack(
          children: [
            _gradientBox(height),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(color: Colors.white),
                  const SizedBox(height: 10),
                  Text('Finding launch video...',
                      style: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            _backButton(topPad),
            _badgeTopRight(topPad),
          ],
        ),
      );
    }

    // Video ready — WebView player
    if (_videoId != null) {
      return SizedBox(
        height: height,
        child: Stack(
          children: [
            YouTubeWebView(videoId: _videoId!, height: height),
            _backButton(topPad),
            _badgeTopRight(topPad),
          ],
        ),
      );
    }

    // No video fallback
    return _buildNoVideoFallback(height, topPad);
  }

  Widget _buildNoVideoFallback(double height, double topPad) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          _gradientBox(height),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _openYouTubeSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text('Watch on YouTube',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _backButton(topPad),
          _badgeTopRight(topPad),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // UPCOMING HERO
  // ═══════════════════════════════════════

  Widget _buildUpcomingHero() {
    final height = MediaQuery.sizeOf(context).height * 0.32;
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final rng = Random(42);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          _gradientBox(height),

          // Twinkling stars
          ...List.generate(20, (i) {
            final x = rng.nextDouble() * screenWidth;
            final y = rng.nextDouble() * height;
            final size = 1.5 + rng.nextDouble() * 2;
            final delay = Duration(milliseconds: rng.nextInt(2000));
            final duration =
                Duration(milliseconds: 800 + rng.nextInt(1500));
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.5 + rng.nextDouble() * 0.5),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      delay: delay)
                  .fadeIn(duration: duration)
                  .then()
                  .fadeOut(duration: duration),
            );
          }),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
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
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.7)),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: const Duration(seconds: 2),
                    ),
                const SizedBox(height: 16),
                Text(
                  'LAUNCHING SOON',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live stream will be available before launch',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _backButton(topPad),
          _badgeTopRight(topPad),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // SHARED POSITIONED WIDGETS
  // ═══════════════════════════════════════

  Widget _backButton(double topPad) {
    return Positioned(
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
    );
  }

  Widget _badgeTopRight(double topPad) {
    return Positioned(
      top: topPad + 8,
      right: 12,
      child: _providerBadgeWidget(),
    );
  }

  Widget _gradientBox(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _providerGradientColors,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _providerBadgeWidget(),
          const SizedBox(height: 12),

          Text(
            launch.rocketName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 400.ms),

          if (launch.missionName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              launch.missionName,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],

          if (_isUpcoming && !_remaining.isNegative) ...[
            const SizedBox(height: 24),
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

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: AppColors.accentPurple.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 20),

          _buildInfoRow(
                  Icons.rocket_launch, 'Provider', launch.provider)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(
                  begin: 0.05,
                  end: 0,
                  duration: 400.ms,
                  delay: 100.ms),
          _buildInfoRow(Icons.calendar_today, 'Date',
                  _formatDate(launch.launchDate))
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(
                  begin: 0.05,
                  end: 0,
                  duration: 400.ms,
                  delay: 200.ms),
          _buildInfoRow(
            Icons.location_on,
            'Location',
            launch.padLocation.isEmpty ? 'TBD' : launch.padLocation,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(
                  begin: 0.05,
                  end: 0,
                  duration: 400.ms,
                  delay: 300.ms),
          _buildInfoRow(
            Icons.info_outline,
            'Status',
            launch.status,
            valueColor: _statusColor(),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideX(
                  begin: 0.05,
                  end: 0,
                  duration: 400.ms,
                  delay: 400.ms),

          const SizedBox(height: 24),

          if (_isUpcoming)
            _gradientButton(
              'Set Reminder',
              Icons.notifications_outlined,
              () {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Coming Soon'),
                    content: const Text(
                        'Reminders will be available in a future update.'),
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
            )
          else
            _outlinedButton(
              'Share Launch',
              Icons.share,
              _shareLaunch,
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PROVIDER BADGE
  // ═══════════════════════════════════════

  Widget _providerBadgeWidget() {
    final color = _providerColor;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12)),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
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
                color: valueColor ?? Colors.white,
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
  // BUTTONS
  // ═══════════════════════════════════════

  Widget _gradientButton(
      String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedButton(
      String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: AppColors.accentPurple, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accentPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
