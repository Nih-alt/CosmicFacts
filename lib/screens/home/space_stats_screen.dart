import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../../constants/api_keys.dart';
import '../../theme/app_colors.dart';

class SpaceStatsScreen extends StatefulWidget {
  const SpaceStatsScreen({super.key});

  @override
  State<SpaceStatsScreen> createState() => _SpaceStatsScreenState();
}

class _SpaceStatsScreenState extends State<SpaceStatsScreen> {
  Timer? _tickTimer;
  Timer? _apiTimer;
  DateTime _now = DateTime.now();

  // Live data
  int? _peopleInSpace;
  int? _asteroidsToday;
  bool _loadingApi = true;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _fetchLiveData();
    _apiTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchLiveData();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _apiTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveData() async {
    // People in space
    try {
      final resp = await http
          .get(Uri.parse('http://api.open-notify.org/astros.json'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (mounted) setState(() => _peopleInSpace = data['number'] as int?);
      }
    } catch (_) {}

    // Asteroids today
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final resp = await http
          .get(Uri.parse(
              'https://api.nasa.gov/neo/rest/v1/feed?start_date=$today&end_date=$today&api_key=${ApiKeys.nasaApiKey}'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final count = data['element_count'] as int?;
        if (mounted) setState(() => _asteroidsToday = count);
      }
    } catch (_) {}

    if (mounted) setState(() => _loadingApi = false);
  }

  // ── Calculations ──

  String get _universeAge {
    // Big Bang: ~13.8 billion years ago
    const bigBangYears = 13800000000;
    final now = _now;
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays;
    final hours = now.hour;
    final minutes = now.minute;
    final seconds = now.second;
    return '$bigBangYears years, $dayOfYear days, $hours h, $minutes m, $seconds s';
  }

  double get _moonDistance {
    // Simplified: average 384,400 km, varies ~25,100 km
    final phase = _getMoonPhase();
    final variation = 25100 * cos(phase * 2 * pi);
    return 384400 + variation;
  }

  double get _sunDistance {
    // Perihelion Jan 3: ~147.1M km, Aphelion Jul 4: ~152.1M km
    final dayOfYear =
        _now.difference(DateTime(_now.year, 1, 1)).inDays;
    return 149.598 + 2.5 * cos((dayOfYear - 3) * 2 * pi / 365.25);
  }

  double _getMoonPhase() {
    // Simplified moon phase 0-1 based on synodic month
    const synodicMonth = 29.53059;
    final known = DateTime(2000, 1, 6, 18, 14); // known new moon
    final diff = _now.difference(known).inHours / 24.0;
    return (diff % synodicMonth) / synodicMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _buildUniverseAge(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildListDelegate(_buildStatCards()),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text('Fun Comparisons',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
              ),
            ),
            SliverToBoxAdapter(child: _buildComparisons()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow(context),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary(context), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Space Statistics',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('The universe in numbers \u2014 live',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // UNIVERSE AGE HERO
  // ═══════════════════════════════════════

  Widget _buildUniverseAge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1060), Color(0xFF0A0A30), Color(0xFF061030)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Star particles
          ...List.generate(6, (i) {
            final rng = Random(i * 17);
            return Positioned(
              left: rng.nextDouble() * 300,
              top: rng.nextDouble() * 100,
              child: Container(
                width: 1.5 + rng.nextDouble() * 2,
                height: 1.5 + rng.nextDouble() * 2,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.3 + rng.nextDouble() * 0.4),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      delay: Duration(milliseconds: rng.nextInt(2000)))
                  .fadeIn(
                      duration:
                          Duration(milliseconds: 1200 + rng.nextInt(1500)))
                  .then()
                  .fadeOut(
                      duration:
                          Duration(milliseconds: 1200 + rng.nextInt(1500))),
            );
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('\u{1F30C}', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text('Age of the Universe',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 14),
              Text('13,800,000,000',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(_universeAge,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Text('and counting...',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
        begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }

  // ═══════════════════════════════════════
  // STAT CARDS GRID
  // ═══════════════════════════════════════

  List<Widget> _buildStatCards() {
    final moonDist = _moonDistance.round();
    final sunDist = _sunDistance.toStringAsFixed(1);

    return [
      _statCard(
        emoji: '\u{1F6F0}\uFE0F',
        label: 'ISS Speed',
        value: '27,600 km/h',
        subtitle: 'Orbiting Earth every 90 min',
        accent: AppColors.accentCyan,
        isLive: false,
        index: 0,
      ),
      _statCard(
        emoji: '\u{1F30D}',
        label: 'ISS Altitude',
        value: '408 km',
        subtitle: 'Above Earth\'s surface',
        accent: const Color(0xFF4A90D9),
        isLive: false,
        index: 1,
      ),
      _statCard(
        emoji: '\u{1F9D1}\u200D\u{1F680}',
        label: 'People in Space',
        value: _loadingApi
            ? '...'
            : (_peopleInSpace?.toString() ?? '?'),
        subtitle: 'Right now aboard ISS & Tiangong',
        accent: AppColors.success,
        isLive: true,
        index: 2,
      ),
      _statCard(
        emoji: '\u2604\uFE0F',
        label: 'Asteroids Today',
        value: _loadingApi
            ? '...'
            : (_asteroidsToday?.toString() ?? '?'),
        subtitle: 'Near-Earth objects today',
        accent: AppColors.accentOrange,
        isLive: true,
        index: 3,
      ),
      _statCard(
        emoji: '\u{1F319}',
        label: 'Moon Distance',
        value: '${_formatNumber(moonDist)} km',
        subtitle: 'Current approx. distance',
        accent: const Color(0xFFB0B0C0),
        isLive: false,
        index: 4,
      ),
      _statCard(
        emoji: '\u2600\uFE0F',
        label: 'Earth-Sun Distance',
        value: '$sunDist M km',
        subtitle: 'Earth to Sun right now',
        accent: AppColors.starGold,
        isLive: false,
        index: 5,
      ),
      _statCard(
        emoji: '\u{1F52D}',
        label: 'Known Exoplanets',
        value: '5,800+',
        subtitle: 'Confirmed planets beyond our Sun',
        accent: AppColors.accentBlue,
        isLive: false,
        index: 6,
      ),
      _statCard(
        emoji: '\u{1F30C}',
        label: 'Observable Universe',
        value: '93B light-years',
        subtitle: 'Diameter of observable universe',
        accent: const Color(0xFF5B3FBF),
        isLive: false,
        index: 7,
      ),
    ];
  }

  Widget _statCard({
    required String emoji,
    required String label,
    required String value,
    required String subtitle,
    required Color accent,
    required bool isLive,
    required int index,
  }) {
    final isLoading = isLive && _loadingApi;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 3)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 16))),
              ),
              const Spacer(),
              if (isLive)
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1000.ms)
                    .then()
                    .fadeOut(duration: 1000.ms),
            ],
          ),
          const Spacer(),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: AppColors.shimmerBase(context),
              highlightColor: AppColors.shimmerHighlight(context),
              child: Container(
                width: 80, height: 22,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase(context),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            )
          else
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary(context))),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    )
        .animate()
        .fadeIn(
            duration: 400.ms, delay: Duration(milliseconds: 60 * index))
        .slideY(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 60 * index));
  }

  // ═══════════════════════════════════════
  // FUN COMPARISONS
  // ═══════════════════════════════════════

  Widget _buildComparisons() {
    const comparisons = [
      ('\u{1F3C3}', 'Running to Moon',
          'It would take 9.3 years of non-stop running'),
      ('\u2708\uFE0F', 'Flying to Sun',
          '17 years on a commercial airplane'),
      ('\u{1F697}', 'Driving to Mars',
          '~228 years at highway speed'),
      ('\u{1F4A1}', 'Light to Nearest Star',
          '4.24 years to Proxima Centauri'),
      ('\u{1F9EE}', 'Stars vs Grains',
          '~10x more stars than sand grains on Earth'),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: comparisons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (emoji, title, desc) = comparisons[i];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(14),
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
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(desc,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                  duration: 350.ms,
                  delay: Duration(milliseconds: 60 * i));
        },
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
