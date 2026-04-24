import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'asteroid_detail_screen.dart';

class AsteroidsScreen extends StatefulWidget {
  const AsteroidsScreen({super.key});

  @override
  State<AsteroidsScreen> createState() => _AsteroidsScreenState();
}

class _AsteroidsScreenState extends State<AsteroidsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _asteroids = [];
  bool _isLoading = true;
  bool _hasError = false;
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
    _loadAsteroids();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // DATA
  // ═══════════════════════════════════════════

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _loadAsteroids() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _asteroids = [];
    });

    final cacheDataKey = 'data_$_dateKey';
    final cacheTimeKey = 'cached_at_$_dateKey';

    try {
      final box = Hive.isBoxOpen('asteroids_cache')
          ? Hive.box('asteroids_cache')
          : await Hive.openBox('asteroids_cache');
      final cachedAt = box.get(cacheTimeKey) as int?;
      if (cachedAt != null) {
        final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
        if (age < 6 * 60 * 60 * 1000) {
          final cached = box.get(cacheDataKey);
          if (cached != null) {
            setState(() {
              _asteroids = List<Map<String, dynamic>>.from(
                (cached as List).map(
                  (e) => Map<String, dynamic>.from(e as Map),
                ),
              );
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    final data = await ApiService.getNearEarthAsteroids(date: _selectedDate);
    if (!mounted) return;

    if (data.isEmpty) {
      setState(() {
        // Empty list is valid: maybe no approaches that date. Only treat as
        // error if we never loaded anything before and the request failed.
        _hasError = false;
        _asteroids = [];
        _isLoading = false;
      });
      return;
    }

    data.sort((a, b) {
      final aClose = _getMissDistanceKm(a);
      final bClose = _getMissDistanceKm(b);
      return aClose.compareTo(bClose);
    });

    try {
      final box = Hive.isBoxOpen('asteroids_cache')
          ? Hive.box('asteroids_cache')
          : await Hive.openBox('asteroids_cache');
      await box.put(cacheDataKey, data);
      await box.put(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}

    setState(() {
      _asteroids = data;
      _isLoading = false;
    });
  }

  double _getMissDistanceKm(Map<String, dynamic> asteroid) {
    final approaches = asteroid['close_approach_data'] as List<dynamic>?;
    if (approaches == null || approaches.isEmpty) return double.infinity;
    return double.tryParse(
          approaches[0]['miss_distance']?['kilometers']?.toString() ?? '',
        ) ??
        double.infinity;
  }

  double _getDiameterMin(Map<String, dynamic> asteroid) {
    return double.tryParse(
          asteroid['estimated_diameter']?['meters']?['estimated_diameter_min']
                  ?.toString() ??
              '',
        ) ??
        0;
  }

  double _getDiameterMax(Map<String, dynamic> asteroid) {
    return double.tryParse(
          asteroid['estimated_diameter']?['meters']?['estimated_diameter_max']
                  ?.toString() ??
              '',
        ) ??
        0;
  }

  double _getVelocity(Map<String, dynamic> asteroid) {
    final approaches = asteroid['close_approach_data'] as List<dynamic>?;
    if (approaches == null || approaches.isEmpty) return 0;
    return double.tryParse(
          approaches[0]['relative_velocity']?['kilometers_per_second']
                  ?.toString() ??
              '',
        ) ??
        0;
  }

  bool _isHazardous(Map<String, dynamic> asteroid) =>
      asteroid['is_potentially_hazardous_asteroid'] == true;

  int get _safeCount =>
      _asteroids.where((a) => !_isHazardous(a)).length;

  int get _hazardCount =>
      _asteroids.where((a) => _isHazardous(a)).length;

  // ═══════════════════════════════════════════
  // DATE SELECTOR
  // ═══════════════════════════════════════════

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _selectedIsToday => _isSameDay(_selectedDate, DateTime.now());

  void _changeDate(int deltaDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
    });
    _loadAsteroids();
  }

  void _openDetail(Map<String, dynamic> asteroid) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => AsteroidDetailScreen(asteroid: asteroid),
      ),
    );
  }

  void _pickDate() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime temp = _selectedDate;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: AppColors.surface(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 44,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider(context)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                    Text(
                      'Select date',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() => _selectedDate = temp);
                        _loadAsteroids();
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    minimumDate: DateTime(2015, 1, 1),
                    maximumDate: DateTime.now().add(const Duration(days: 7)),
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildShimmer(i == 0 ? 240 : 90),
                    ),
                  ),
                ),
              ),
            )
          else if (_hasError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(),
            )
          else ...[
            SliverToBoxAdapter(
              child: _buildDateHeader().animate().fadeIn(duration: 400.ms),
            ),

            if (_asteroids.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildHero(_asteroids.first),
                ).animate().fadeIn(duration: 500.ms).slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 500.ms,
                    ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: _buildStatsRow(),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'All Asteroids Today',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final asteroid = _asteroids[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        index == 0 ? 0 : 6,
                        16,
                        6,
                      ),
                      child: _PressScale(
                        onTap: () => _openDetail(asteroid),
                        child: _buildAsteroidCard(asteroid),
                      ),
                    ).animate().fadeIn(
                          duration: 380.ms,
                          delay: Duration(milliseconds: 180 + index * 50),
                        ).slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 380.ms,
                          delay: Duration(milliseconds: 180 + index * 50),
                        );
                  },
                  childCount: _asteroids.length,
                ),
              ),
            ],
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Icon(
                  CupertinoIcons.back,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Expanded(
                child: Text(
                  'Near-Earth Asteroids',
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
    );
  }

  // ═══════════════════════════════════════════
  // DATE HEADER (prev · tappable label · next · count)
  // ═══════════════════════════════════════════

  Widget _buildDateHeader() {
    final label = _selectedIsToday
        ? 'Today — ${DateFormat('MMM d, y').format(_selectedDate)}'
        : DateFormat('EEE, MMM d, y').format(_selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _arrowButton(CupertinoIcons.chevron_left, () => _changeDate(-1)),
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _arrowButton(
            CupertinoIcons.chevron_right,
            // allow advancing up to +7d as per API cap
            () => _changeDate(1),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_asteroids.length} asteroids',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(32),
      onPressed: onTap,
      child: Icon(icon, size: 20, color: AppColors.textSecondary(context)),
    );
  }

  // ═══════════════════════════════════════════
  // STATS ROW (3 chips)
  // ═══════════════════════════════════════════

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statChip(
            '🟢',
            '$_safeCount',
            'Safe',
            AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            '🔴',
            '$_hazardCount',
            'Hazard',
            AppColors.error,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            '☄️',
            '${_asteroids.length}',
            'Total',
            AppColors.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _statChip(String emoji, String count, String label, Color accent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                count,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HERO CARD
  // ═══════════════════════════════════════════

  Widget _buildHero(Map<String, dynamic> asteroid) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = asteroid['name']?.toString() ?? 'Unknown';
    final distKm = _getMissDistanceKm(asteroid);
    final distMillion = distKm / 1e6;
    final dMin = _getDiameterMin(asteroid);
    final dMax = _getDiameterMax(asteroid);
    final vel = _getVelocity(asteroid);
    final hazardous = _isHazardous(asteroid);
    final asteroidSize =
        MediaQuery.of(context).size.width < 380 ? 140.0 : 160.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StarfieldPainter(isDark: isDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0A1E36).withValues(alpha: 0.82),
                        const Color(0xFF05081A).withValues(alpha: 0.82),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.78),
                        const Color(0xFFE8F0FB).withValues(alpha: 0.78),
                      ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: hazardous
                    ? AppColors.error.withValues(alpha: 0.35)
                    : AppColors.glassBorder(context),
              ),
              boxShadow: AppColors.cardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'CLOSEST APPROACH',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 6),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: asteroidSize,
                      height: asteroidSize,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (hazardous
                                            ? AppColors.error
                                            : AppColors.accentCyan)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: isDark ? 0.55 : 0.22),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: RepaintBoundary(
                                child: RotationTransition(
                                  turns: _rotationController,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: (hazardous
                                                ? AppColors.error
                                                : AppColors.accentCyan)
                                            .withValues(alpha: 0.45),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/asteroid_hero.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: hazardous
                                    ? AppColors.error
                                    : AppColors.success,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (hazardous
                                            ? AppColors.error
                                            : AppColors.success)
                                        .withValues(alpha: 0.45),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                hazardous ? 'HAZARD' : 'SAFE',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _heroDistanceVisual(distMillion),
                const SizedBox(height: 12),
                _heroDiameterVisual(dMin, dMax),
                const SizedBox(height: 12),
                _heroVelocityVisual(vel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroDistanceVisual(double distMillion) {
    return Row(
      children: [
        const Text('🌍', style: TextStyle(fontSize: 20)),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentCyan.withValues(alpha: 0.25),
                  AppColors.accentOrange,
                ],
              ),
            ),
          ),
        ),
        const Text('☄️', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          '${distMillion.toStringAsFixed(2)}M km',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _heroDiameterVisual(double dMin, double dMax) {
    final avg = (dMin + dMax) / 2;
    final (compEmoji, compLabel) = _sizeComparison(avg);
    return Row(
      children: [
        Icon(
          CupertinoIcons.circle_grid_hex,
          size: 18,
          color: AppColors.accentCyan,
        ),
        const SizedBox(width: 8),
        Text(
          '${dMin.toStringAsFixed(0)}–${dMax.toStringAsFixed(0)} m',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$compEmoji $compLabel',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _heroVelocityVisual(double vel) {
    // Typical NEO velocities are 5–30 km/s; use 40 as max for visual scale.
    final fraction = (vel / 40.0).clamp(0.05, 1.0);
    return Row(
      children: [
        Icon(
          CupertinoIcons.bolt_fill,
          size: 18,
          color: AppColors.accentOrange,
        ),
        const SizedBox(width: 8),
        Text(
          '${vel.toStringAsFixed(1)} km/s',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, c) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context)
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: c.maxWidth * fraction,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentCyan,
                          AppColors.accentOrange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  (String, String) _sizeComparison(double diameter) {
    if (diameter < 5) return ('🚗', 'smaller than a car');
    if (diameter < 15) return ('🚌', 'size of a bus');
    if (diameter < 40) return ('✈️', 'size of an airplane');
    if (diameter < 100) return ('🏢', 'size of a building');
    if (diameter < 330) return ('🗼', 'nearly Eiffel-Tower tall');
    if (diameter < 830) return ('🗼', 'bigger than the Eiffel Tower');
    return ('⛰️', 'the size of a mountain');
  }

  // ═══════════════════════════════════════════
  // LIST CARD
  // ═══════════════════════════════════════════

  Widget _buildAsteroidCard(Map<String, dynamic> asteroid) {
    final name = asteroid['name']?.toString() ?? 'Unknown';
    final distKm = _getMissDistanceKm(asteroid);
    final distMillion = distKm / 1e6;
    final dMin = _getDiameterMin(asteroid);
    final dMax = _getDiameterMax(asteroid);
    final vel = _getVelocity(asteroid);
    final hazardous = _isHazardous(asteroid);
    final accent = hazardous ? AppColors.error : AppColors.success;
    // Card tint per hazard per spec: safe green-ish, hazard red-ish.
    final cardTint = hazardous
        ? const Color(0xFFFF5050).withValues(alpha: 0.10)
        : const Color(0xFF00FF96).withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color.alphaBlend(cardTint, AppColors.glass(context)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _listIcon(hazardous),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: AppColors.textSecondary(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${distMillion.toStringAsFixed(2)}M km · '
                      '${dMin.toStringAsFixed(0)}–${dMax.toStringAsFixed(0)} m · '
                      '${vel.toStringAsFixed(1)} km/s',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _listStatusPill(hazardous),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listIcon(bool hazardous) {
    final tint = hazardous ? AppColors.error : AppColors.success;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint.withValues(alpha: hazardous ? 0.14 : 0.12),
        border: Border.all(color: tint.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Icon(
        hazardous
            ? CupertinoIcons.exclamationmark_triangle_fill
            : CupertinoIcons.sparkles,
        size: 22,
        color: tint,
      ),
    );
  }

  Widget _listStatusPill(bool hazardous) {
    final tint = hazardous ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hazardous ? '⚠️' : '🟢',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            hazardous ? 'Hazardous' : 'Safe',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tint,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // EMPTY / ERROR / SHIMMER
  // ═══════════════════════════════════════════

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: RealisticAsteroid(
              seed: 'empty-state-$_dateKey',
              hazardous: false,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No close approaches today 🌍',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Earth is safe!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: RealisticAsteroid(
              seed: 'error-state',
              hazardous: true,
              isDark: isDark,
              cracked: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Couldn't fetch asteroid data",
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(12),
            onPressed: _loadAsteroids,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase(context),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REALISTIC ASTEROID — 3D-look sphere via RadialGradient + craters
// Uses stock widgets (DecoratedBox + CustomPaint). Texture cached per seed.
// ═══════════════════════════════════════════════════════════════

class RealisticAsteroid extends StatelessWidget {
  final String seed;
  final bool hazardous;
  final bool isDark;
  final bool cracked;

  const RealisticAsteroid({
    super.key,
    required this.seed,
    required this.hazardous,
    required this.isDark,
    this.cracked = false,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = hazardous
        ? const Color(0xFFC27A6B)
        : const Color(0xFFA8896B);
    final midColor = hazardous
        ? const Color(0xFF8B4543)
        : const Color(0xFF7A6248);
    final darkColor = hazardous
        ? const Color(0xFF3D1815)
        : const Color(0xFF3D2F22);

    return ClipOval(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: 3D-lit base sphere (light off-center at top-left).
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 1.05,
                colors: [lightColor, midColor, darkColor],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Layer 2: crater texture (cached per seed).
          CustomPaint(
            painter: _AsteroidTexturePainter(
              seed: seed,
              cracked: cracked,
            ),
          ),
          // Layer 3: inner rim shadow — fake depth at bottom-right.
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.45, 0.45),
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          // Layer 4: specular highlight at top-left.
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.45, -0.5),
                radius: 0.6,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.22 : 0.3),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AsteroidTextureSpec {
  final double angle;
  final double dist;
  final double radius;
  _AsteroidTextureSpec(this.angle, this.dist, this.radius);
}

class _AsteroidTexturePainter extends CustomPainter {
  final String seed;
  final bool cracked;

  _AsteroidTexturePainter({required this.seed, this.cracked = false});

  // Crater specs cached per seed — each asteroid's texture built once.
  static final Map<String, List<_AsteroidTextureSpec>> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy);
    final craters = _cache.putIfAbsent(seed, () => _build(seed));

    for (final c in craters) {
      final pos = Offset(
        cx + cos(c.angle) * c.dist * r * 0.78,
        cy + sin(c.angle) * c.dist * r * 0.78,
      );
      final cr = c.radius * r * 0.13;

      // Crater rim: slightly brighter lip.
      final rimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08);
      canvas.drawCircle(pos, cr * 1.25, rimPaint);

      // Crater depression (dark center).
      final depthPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.32);
      canvas.drawCircle(pos, cr, depthPaint);

      // Interior shadow for subtle depth.
      final innerShadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.22);
      canvas.drawCircle(
        Offset(pos.dx + cr * 0.2, pos.dy + cr * 0.2),
        cr * 0.55,
        innerShadow,
      );
    }

    if (cracked) {
      final crack = Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - r * 0.9, cy - r * 0.3),
        Offset(cx + r * 0.5, cy + r * 0.7),
        crack,
      );
      canvas.drawLine(
        Offset(cx - r * 0.2, cy - r * 0.8),
        Offset(cx + r * 0.3, cy + r * 0.1),
        crack,
      );
    }
  }

  List<_AsteroidTextureSpec> _build(String seed) {
    final rng = Random(_hashString(seed));
    final count = 10 + rng.nextInt(6); // 10..15
    return List.generate(
      count,
      (_) => _AsteroidTextureSpec(
        rng.nextDouble() * 2 * pi,
        rng.nextDouble(),
        0.45 + rng.nextDouble() * 0.65,
      ),
    );
  }

  static int _hashString(String s) {
    int h = 0;
    for (int i = 0; i < s.length; i++) {
      h = (h * 31 + s.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return h;
  }

  @override
  bool shouldRepaint(covariant _AsteroidTexturePainter old) =>
      old.seed != seed || old.cracked != cracked;
}

// ═══════════════════════════════════════════════════════════════
// STARFIELD PAINTER — deterministic; only repaints on theme flip
// ═══════════════════════════════════════════════════════════════

class _StarfieldPainter extends CustomPainter {
  final bool isDark;
  _StarfieldPainter({required this.isDark});

  static final List<(double, double, double)> _stars = () {
    final rng = Random(42);
    return List.generate(
      55,
      (_) => (rng.nextDouble(), rng.nextDouble(), 0.5 + rng.nextDouble() * 1.3),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final color = (isDark ? Colors.white : AppColors.accentBlue)
        .withValues(alpha: isDark ? 0.65 : 0.18);
    final paint = Paint()..color = color;
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(s.$1 * size.width, s.$2 * size.height),
        s.$3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) =>
      old.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════
// PRESS-SCALE — tap-down → 0.98, release → 1.0 (no controllers needed)
// ═══════════════════════════════════════════════════════════════

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _scale = 1.0;

  void _setScale(double s) {
    if (_scale != s) setState(() => _scale = s);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setScale(0.98),
      onTapCancel: () => _setScale(1.0),
      onTapUp: (_) => _setScale(1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
