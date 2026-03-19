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

class AsteroidsScreen extends StatefulWidget {
  const AsteroidsScreen({super.key});

  @override
  State<AsteroidsScreen> createState() => _AsteroidsScreenState();
}

class _AsteroidsScreenState extends State<AsteroidsScreen> {
  List<Map<String, dynamic>> _asteroids = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAsteroids();
  }

  Future<void> _loadAsteroids() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Check cache first (6 hours)
    try {
      final box = await Hive.openBox('asteroids_cache');
      final cachedAt = box.get('cached_at') as int?;
      if (cachedAt != null) {
        final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
        if (age < 6 * 60 * 60 * 1000) {
          final cached = box.get('data');
          if (cached != null) {
            setState(() {
              _asteroids = List<Map<String, dynamic>>.from(
                (cached as List).map((e) => Map<String, dynamic>.from(e as Map)),
              );
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    final data = await ApiService.getNearEarthAsteroids();
    if (!mounted) return;

    if (data.isEmpty) {
      setState(() {
        _hasError = _asteroids.isEmpty;
        _isLoading = false;
      });
      return;
    }

    // Sort by closest approach distance
    data.sort((a, b) {
      final aClose = _getMissDistanceKm(a);
      final bClose = _getMissDistanceKm(b);
      return aClose.compareTo(bClose);
    });

    // Cache
    try {
      final box = await Hive.openBox('asteroids_cache');
      await box.put('data', data);
      await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
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

  bool _isHazardous(Map<String, dynamic> asteroid) {
    return asteroid['is_potentially_hazardous_asteroid'] == true;
  }

  @override
  Widget build(BuildContext context) {
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
          ),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildShimmer(i == 0 ? 200 : 90),
                  )),
                ),
              ),
            )
          else if (_hasError)
            SliverToBoxAdapter(child: _buildErrorState())
          else ...[
            // Date header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Today — ${DateFormat('MMMM d, y').format(DateTime.now())}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_asteroids.length} asteroids',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Danger indicator hero — closest asteroid
            if (_asteroids.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildDangerHero(_asteroids.first),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
              ),

            // Asteroid list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'All Asteroids Today',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 4, 20, 4),
                    child: _buildAsteroidCard(_asteroids[index]),
                  ).animate().fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 150 + index * 40),
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    delay: Duration(milliseconds: 150 + index * 40),
                  );
                },
                childCount: _asteroids.length,
              ),
            ),

            // Size comparison section
            if (_asteroids.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: _buildSizeComparisons(),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 300.ms),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildDangerHero(Map<String, dynamic> asteroid) {
    final name = asteroid['name']?.toString() ?? 'Unknown';
    final distKm = _getMissDistanceKm(asteroid);
    final distMillion = distKm / 1e6;
    final dMin = _getDiameterMin(asteroid);
    final dMax = _getDiameterMax(asteroid);
    final vel = _getVelocity(asteroid);
    final hazardous = _isHazardous(asteroid);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hazardous
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.glassBorder(context),
            ),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hazardous
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hazardous ? 'Potentially Hazardous' : 'Safe',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hazardous ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildHeroInfoRow(
                Icons.straighten,
                'Distance',
                '${distMillion.toStringAsFixed(2)} million km from Earth',
              ),
              const SizedBox(height: 10),
              _buildHeroInfoRow(
                Icons.circle_outlined,
                'Diameter',
                '${dMin.toStringAsFixed(0)} - ${dMax.toStringAsFixed(0)} meters',
              ),
              const SizedBox(height: 10),
              _buildHeroInfoRow(
                Icons.speed,
                'Velocity',
                '${vel.toStringAsFixed(1)} km/s',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentCyan),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context)),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsteroidCard(Map<String, dynamic> asteroid) {
    final name = asteroid['name']?.toString() ?? 'Unknown';
    final distKm = _getMissDistanceKm(asteroid);
    final distMillion = distKm / 1e6;
    final dMin = _getDiameterMin(asteroid);
    final dMax = _getDiameterMax(asteroid);
    final vel = _getVelocity(asteroid);
    final hazardous = _isHazardous(asteroid);

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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hazardous
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.success.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    hazardous ? '!' : '',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: hazardous ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${distMillion.toStringAsFixed(2)}M km  •  ${dMin.toStringAsFixed(0)}-${dMax.toStringAsFixed(0)}m  •  ${vel.toStringAsFixed(1)} km/s',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeComparisons() {
    // Find largest asteroid
    double largestDiameter = 0;
    for (final a in _asteroids) {
      final d = _getDiameterMax(a);
      if (d > largestDiameter) largestDiameter = d;
    }
    if (largestDiameter == 0) largestDiameter = 50;

    final comparisons = [
      ('House', 10.0),
      ('Football field', 100.0),
      ('Eiffel Tower', 330.0),
      ('Largest today', largestDiameter),
    ];

    final maxVal = [largestDiameter, 330.0].reduce((a, b) => a > b ? a : b);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Size Comparisons',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              ...comparisons.map((item) {
                final (label, size) = item;
                final fraction = (size / maxVal).clamp(0.05, 1.0);
                final isAsteroid = label == 'Largest today';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label (${size.toStringAsFixed(0)}m)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isAsteroid
                              ? AppColors.accentOrange
                              : AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 8,
                            width: constraints.maxWidth * fraction,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: isAsteroid
                                  ? const LinearGradient(colors: [AppColors.accentOrange, AppColors.starGold])
                                  : AppColors.primaryGradient,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.wifi_slash, size: 48, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            Text(
              'Could not fetch asteroid data',
              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              color: AppColors.accentPurple,
              borderRadius: BorderRadius.circular(12),
              onPressed: _loadAsteroids,
              child: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
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
