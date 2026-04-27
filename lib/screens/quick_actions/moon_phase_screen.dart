import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

const double _lunarCycle = 29.53058770576;

const String _moonAssetPath = 'assets/moon_full.jpg';

double _getMoonPhase([DateTime? date]) {
  final now = date ?? DateTime.now();
  final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
  final daysSince = now.difference(knownNewMoon).inHours / 24.0;
  return (daysSince % _lunarCycle) / _lunarCycle;
}

String _getPhaseName(double phase) {
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

String _getPhaseEmoji(double phase) {
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

double _getIllumination(double phase) => (1 - cos(phase * 2 * pi)) / 2 * 100;

double _getPhaseAge(double phase) => phase * _lunarCycle;

DateTime _getNextFullMoon(DateTime from) {
  final phase = _getMoonPhase(from);
  final daysToFull = phase < 0.5
      ? (0.5 - phase) * _lunarCycle
      : (1.5 - phase) * _lunarCycle;
  return from.add(Duration(hours: (daysToFull * 24).round()));
}

DateTime _getNextNewMoon(DateTime from) {
  final phase = _getMoonPhase(from);
  final daysToNew = (1 - phase) * _lunarCycle;
  return from.add(Duration(hours: (daysToNew * 24).round()));
}

// Coarse moonrise/set approximation. At new moon the Moon rises with the Sun
// (~06:00); at full moon it rises near sunset (~18:00). Linear interp is good
// enough for a "tonight at a glance" hint without relying on a location.
({String rise, String set, String best}) _moonTimes(double phase) {
  final riseHours = (6 + phase * 24) % 24;
  final setHours = (riseHours + 12) % 24;
  final bestStart = (riseHours + 3) % 24;
  final bestEnd = (riseHours + 8) % 24;
  return (
    rise: _fmtHM(riseHours),
    set: _fmtHM(setHours),
    best: '${_fmtHM(bestStart)} – ${_fmtHM(bestEnd)}',
  );
}

String _fmtHM(double hours) {
  final h = hours.floor();
  final m = ((hours - h) * 60).round();
  final hh = (h % 24).toString().padLeft(2, '0');
  final mm = (m % 60).toString().padLeft(2, '0');
  return '$hh:$mm';
}

// ═══════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════

class MoonPhaseScreen extends StatefulWidget {
  const MoonPhaseScreen({super.key});

  @override
  State<MoonPhaseScreen> createState() => _MoonPhaseScreenState();
}

class _MoonPhaseScreenState extends State<MoonPhaseScreen> {
  int _selectedDayOffset = 0;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final selectedDate = today.add(Duration(days: _selectedDayOffset));
    final phase = _getMoonPhase(selectedDate);
    final phaseName = _getPhaseName(phase);
    final illumination = _getIllumination(phase);
    final age = _getPhaseAge(phase);
    final nextFull = _getNextFullMoon(today);
    final nextNew = _getNextNewMoon(today);
    final times = _moonTimes(phase);

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

          // Hero moon
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _MoonHero(phase: phase),
                  const SizedBox(height: 24),
                  _PhaseGradientLabel(phaseName: phaseName),
                  const SizedBox(height: 16),
                  _IlluminationBar(percent: illumination),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
          ),

          // Tonight's Sky
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildTonightCard(context, times.rise, times.set, times.best, phaseName),
            ).animate().fadeIn(duration: 500.ms, delay: 80.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 80.ms),
          ),

          // Existing details card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildDetailsCard(context, age, nextFull, nextNew, months),
            ).animate().fadeIn(duration: 500.ms, delay: 140.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 140.ms),
          ),

          // Calendar header
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
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 7,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = today.add(Duration(days: index));
                  final dayPhase = _getMoonPhase(date);
                  final isToday = index == 0;
                  final isSelected = index == _selectedDayOffset;
                  return _buildDayCard(
                    context,
                    isToday ? 'Today' : days[date.weekday - 1],
                    date.day,
                    dayPhase,
                    isSelected,
                    () => setState(() => _selectedDayOffset = index),
                  );
                },
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
          ),

          // Moon facts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
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

          // Did you know
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _DidYouKnowCard(),
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ─── Tonight's Sky card ───

  Widget _buildTonightCard(BuildContext context, String rise, String set, String best, String phaseName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('\u{1F319}', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tonight's Sky",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.starGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      phaseName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.starGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTonightRow(context, '\u{1F305}', 'Moonrise', rise),
              const SizedBox(height: 10),
              _buildTonightRow(context, '\u{1F307}', 'Moonset', set),
              const SizedBox(height: 10),
              _buildTonightRow(context, '⭐', 'Best viewing', best),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTonightRow(BuildContext context, String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  // ─── Details card (kept) ───

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
              _buildDetailRow(context, CupertinoIcons.location_solid, 'Distance from Earth', '384,400 km'),
              const SizedBox(height: 14),
              _buildDetailRow(context, CupertinoIcons.time, 'Phase age', '${age.toStringAsFixed(1)} days'),
              const SizedBox(height: 14),
              _buildDetailRow(context, CupertinoIcons.circle_fill, 'Next Full Moon',
                  '${months[nextFull.month - 1]} ${nextFull.day}'),
              const SizedBox(height: 14),
              _buildDetailRow(context, CupertinoIcons.circle, 'Next New Moon',
                  '${months[nextNew.month - 1]} ${nextNew.day}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.starGold),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context))),
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

  // ─── Day card ───

  Widget _buildDayCard(
    BuildContext context,
    String dayLabel,
    int dayNumber,
    double phase,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 78,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFD96B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD96B).withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? null : Border.all(color: AppColors.glassBorder(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.starGold : AppColors.textSecondary(context),
                ),
              ),
              Text(
                dayNumber.toString().padLeft(2, '0'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(_getPhaseEmoji(phase), style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 2),
              Text(
                _getPhaseName(phase).split(' ').first,
                style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Facts grid ───

  Widget _buildFactsGrid(BuildContext context) {
    const facts = <(String, String, String)>[
      ('\u{1F30D}', 'Distance', '384,400 km avg'),
      ('⏱️', 'Day length', '27.3 Earth days'),
      ('\u{1F321}️', 'Temperature', '−173°C to 127°C'),
      ('\u{1F680}', 'First landing', 'Jul 20, 1969'),
      ('\u{1F468}‍\u{1F680}', 'Total walkers', '12 humans'),
      ('\u{1F311}', 'Diameter', '3,474 km'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final (emoji, label, value) = facts[index];
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
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
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
// HERO MOON
// ═══════════════════════════════════════════

class _MoonHero extends StatelessWidget {
  final double phase;
  const _MoonHero({required this.phase});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFF1B8).withValues(alpha: isDark ? 0.18 : 0.30),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Static moon photo
          ClipOval(
            child: Image.asset(
              _moonAssetPath,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          // Phase shadow overlay (sun-relative, fixed in viewer's frame)
          IgnorePointer(
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _MoonPhaseShadowPainter(phase: phase),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// PHASE LABEL + ILLUMINATION BAR
// ═══════════════════════════════════════════

class _PhaseGradientLabel extends StatelessWidget {
  final String phaseName;
  const _PhaseGradientLabel({required this.phaseName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [Colors.white, Color(0xFFFFE9A8)]
        : const [Color(0xFF1A1F3D), Color(0xFFB68C2E)];
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(
        phaseName,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _IlluminationBar extends StatelessWidget {
  final double percent;
  const _IlluminationBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F3D) : const Color(0xFFE8EAF0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (percent / 100).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (_, value, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFD96B)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD96B).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percent.toStringAsFixed(0)}% illuminated',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// DID YOU KNOW (rotates every 6s, isolated state)
// ═══════════════════════════════════════════

class _DidYouKnowCard extends StatefulWidget {
  const _DidYouKnowCard();

  @override
  State<_DidYouKnowCard> createState() => _DidYouKnowCardState();
}

class _DidYouKnowCardState extends State<_DidYouKnowCard> {
  static const _facts = <String>[
    'The Moon drifts away from Earth by about 3.8 cm every year.',
    'A single lunar day spans roughly 29.5 Earth days from sunrise to sunrise.',
    'The same side of the Moon always faces Earth — a result of tidal locking.',
    'Moonquakes can last over half an hour because the lunar interior is dry.',
    'Apollo footprints could last millions of years — there is no wind to erase them.',
    "The Moon's gravity drives most of Earth's ocean tides.",
  ];

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = Random().nextInt(_facts.length);
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _facts.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('\u{1F4A1}', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DID YOU KNOW?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.starGold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        _facts[_index],
                        key: ValueKey(_index),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary(context),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// PHASE SHADOW PAINTER (overlay, not the moon)
// ═══════════════════════════════════════════

class _MoonPhaseShadowPainter extends CustomPainter {
  final double phase;
  _MoonPhaseShadowPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final illum = (1 - cos(2 * pi * phase)) / 2;
    if (illum > 0.985) {
      // Effectively full moon — leave the photo unshaded.
      _drawRim(canvas, center, radius);
      return;
    }

    final isWaxing = phase < 0.5;
    final isGibbous = illum > 0.5;

    final ellipseHalfWidth =
        (radius * cos(2 * pi * phase).abs()).clamp(0.5, radius);
    final ellipseRect = Rect.fromCenter(
      center: center,
      width: ellipseHalfWidth * 2,
      height: radius * 2,
    );

    final shadowPath = Path()..moveTo(center.dx, center.dy - radius);

    if (isWaxing) {
      // Lit on right; shadow covers moon's left semicircle plus the
      // appropriate half of the terminator ellipse.
      shadowPath.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        -pi,
        false,
      );
      if (isGibbous) {
        // Terminator bulges into the dark side (left) — use ellipse left half.
        shadowPath.arcTo(ellipseRect, pi / 2, pi, false);
      } else {
        // Terminator bulges into the lit side (right) — use ellipse right half.
        shadowPath.arcTo(ellipseRect, pi / 2, -pi, false);
      }
    } else {
      // Lit on left; shadow on the right side.
      shadowPath.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        pi,
        false,
      );
      if (isGibbous) {
        shadowPath.arcTo(ellipseRect, pi / 2, -pi, false);
      } else {
        shadowPath.arcTo(ellipseRect, pi / 2, pi, false);
      }
    }
    shadowPath.close();

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.82)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(shadowPath, shadowPaint);

    canvas.restore();

    _drawRim(canvas, center, radius);
  }

  void _drawRim(Canvas canvas, Offset center, double radius) {
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPhaseShadowPainter old) => old.phase != phase;
}
