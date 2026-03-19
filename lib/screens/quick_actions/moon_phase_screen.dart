import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class MoonPhaseScreen extends StatelessWidget {
  const MoonPhaseScreen({super.key});

  static const double _lunarCycle = 29.53058770576;

  static double _getMoonPhase([DateTime? date]) {
    final now = date ?? DateTime.now();
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final daysSince = now.difference(knownNewMoon).inHours / 24.0;
    final phase = (daysSince % _lunarCycle) / _lunarCycle;
    return phase;
  }

  static String _getPhaseName(double phase) {
    if (phase < 0.0625) return 'New Moon';
    if (phase < 0.1875) return 'Waxing Crescent';
    if (phase < 0.3125) return 'First Quarter';
    if (phase < 0.4375) return 'Waxing Gibbous';
    if (phase < 0.5625) return 'Full Moon';
    if (phase < 0.6875) return 'Waning Gibbous';
    if (phase < 0.8125) return 'Last Quarter';
    if (phase < 0.9375) return 'Waning Crescent';
    return 'New Moon';
  }

  static String _getPhaseEmoji(double phase) {
    if (phase < 0.0625) return '\u{1F311}';
    if (phase < 0.1875) return '\u{1F312}';
    if (phase < 0.3125) return '\u{1F313}';
    if (phase < 0.4375) return '\u{1F314}';
    if (phase < 0.5625) return '\u{1F315}';
    if (phase < 0.6875) return '\u{1F316}';
    if (phase < 0.8125) return '\u{1F317}';
    if (phase < 0.9375) return '\u{1F318}';
    return '\u{1F311}';
  }

  static double _getIllumination(double phase) {
    // 0 = new moon (0%), 0.5 = full moon (100%)
    return (1 - cos(phase * 2 * pi)) / 2 * 100;
  }

  static double _getPhaseAge(double phase) {
    return phase * _lunarCycle;
  }

  static DateTime _getNextFullMoon() {
    final now = DateTime.now();
    final phase = _getMoonPhase(now);
    double daysToFull;
    if (phase < 0.5) {
      daysToFull = (0.5 - phase) * _lunarCycle;
    } else {
      daysToFull = (1.5 - phase) * _lunarCycle;
    }
    return now.add(Duration(hours: (daysToFull * 24).round()));
  }

  static DateTime _getNextNewMoon() {
    final now = DateTime.now();
    final phase = _getMoonPhase(now);
    final daysToNew = (1 - phase) * _lunarCycle;
    return now.add(Duration(hours: (daysToNew * 24).round()));
  }

  @override
  Widget build(BuildContext context) {
    final phase = _getMoonPhase();
    final phaseName = _getPhaseName(phase);
    final illumination = _getIllumination(phase);
    final age = _getPhaseAge(phase);
    final nextFull = _getNextFullMoon();
    final nextNew = _getNextNewMoon();

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context)),
                    ),
                    Expanded(
                      child: Text(
                        'Moon',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),

          // Hero moon visual
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Moon with glow
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: const Size(220, 220),
                      painter: _MoonPainter(
                        phase: phase,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    phaseName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${illumination.toStringAsFixed(0)}% illuminated',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
          ),

          // Moon details card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildDetailsCard(context, age, nextFull, nextNew, months),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 100.ms),
          ),

          // Lunar calendar — next 7 days
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Next 7 Days',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 7,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final dayPhase = _getMoonPhase(date);
                  final dayName = days[date.weekday - 1];
                  final isToday = index == 0;
                  return _buildDayCard(context, dayName, date.day, dayPhase, isToday);
                },
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
          ),

          // Moon facts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Moon Facts',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFactsGrid(context),
            ).animate().fadeIn(duration: 500.ms, delay: 350.ms)
                .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 350.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    double age,
    DateTime nextFull,
    DateTime nextNew,
    List<String> months,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context,
                CupertinoIcons.location_solid,
                'Distance from Earth',
                '384,400 km',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                context,
                CupertinoIcons.time,
                'Phase age',
                '${age.toStringAsFixed(1)} days',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                context,
                CupertinoIcons.circle_fill,
                'Next Full Moon',
                '${months[nextFull.month - 1]} ${nextFull.day}',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                context,
                CupertinoIcons.circle,
                'Next New Moon',
                '${months[nextNew.month - 1]} ${nextNew.day}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.starGold),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String dayName,
    int dayNumber,
    double phase,
    bool isToday,
  ) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? AppColors.accentPurple.withValues(alpha: 0.6)
              : AppColors.glassBorder(context),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Today' : dayName,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? AppColors.accentPurple : AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getPhaseEmoji(phase),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            _getPhaseName(phase).split(' ').first,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFactsGrid(BuildContext context) {
    const facts = [
      ('Distance: 384,400 km from Earth', CupertinoIcons.globe),
      ('Travel time: 3 days by rocket', CupertinoIcons.rocket),
      ('Orbit: 27.3 days around Earth', CupertinoIcons.timer),
      ('Temp: -173\u00b0C to 127\u00b0C', CupertinoIcons.thermometer),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final (text, icon) = facts[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: AppColors.starGold),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
// MOON PHASE PAINTER
// ═══════════════════════════════════════════

class _MoonPainter extends CustomPainter {
  final double phase;
  final bool isDark;

  _MoonPainter({required this.phase, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Moon shadow base
    final shadowPaint = Paint()
      ..color = isDark ? const Color(0xFF333344) : const Color(0xFFBBBBCC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, shadowPaint);

    // Lit portion
    final litPaint = Paint()
      ..color = isDark ? const Color(0xFFF5F0E0) : const Color(0xFFFFF8E8)
      ..style = PaintingStyle.fill;

    // Surface detail (subtle craters)
    final craterPaint = Paint()
      ..color = (isDark ? const Color(0xFFD8D0B8) : const Color(0xFFE8E0D0))
      ..style = PaintingStyle.fill;

    // Draw lit portion using path
    final path = Path();

    // The terminator is determined by the phase
    // phase 0 = new moon (all dark), 0.5 = full moon (all lit)
    // We draw the lit half and clip with the terminator

    if (phase < 0.5) {
      // Waxing: right side is lit
      // Draw full right semicircle
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        pi,
      );

      // Terminator edge
      final terminatorFraction = 1 - phase * 4; // 1 at new moon, -1 at half
      final terminatorX = radius * terminatorFraction;

      // Close with elliptical curve for terminator
      path.arcTo(
        Rect.fromCenter(
          center: center,
          width: terminatorX.abs() * 2,
          height: radius * 2,
        ),
        pi / 2,
        terminatorFraction >= 0 ? pi : -pi,
        false,
      );

      path.close();
      canvas.drawPath(path, litPaint);

      // Add some crater detail on the lit portion
      if (phase > 0.1) {
        canvas.drawCircle(
          Offset(center.dx + radius * 0.2, center.dy - radius * 0.2),
          radius * 0.08,
          craterPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + radius * 0.4, center.dy + radius * 0.3),
          radius * 0.06,
          craterPaint,
        );
      }
    } else {
      // Waning: left side is lit
      // Draw full left semicircle
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        pi / 2,
        pi,
      );

      final terminatorFraction = (phase - 0.5) * 4 - 1; // -1 at half, 1 at new
      final terminatorX = radius * terminatorFraction;

      path.arcTo(
        Rect.fromCenter(
          center: center,
          width: terminatorX.abs() * 2,
          height: radius * 2,
        ),
        -pi / 2,
        terminatorFraction >= 0 ? pi : -pi,
        false,
      );

      path.close();
      canvas.drawPath(path, litPaint);

      // Crater details
      if (phase < 0.9) {
        canvas.drawCircle(
          Offset(center.dx - radius * 0.25, center.dy - radius * 0.15),
          radius * 0.08,
          craterPaint,
        );
        canvas.drawCircle(
          Offset(center.dx - radius * 0.35, center.dy + radius * 0.35),
          radius * 0.05,
          craterPaint,
        );
      }
    }

    // Subtle border
    final borderPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) =>
      old.phase != phase || old.isDark != isDark;
}
