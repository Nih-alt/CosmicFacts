import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class AsteroidDetailScreen extends StatefulWidget {
  final Map<String, dynamic> asteroid;
  const AsteroidDetailScreen({super.key, required this.asteroid});

  @override
  State<AsteroidDetailScreen> createState() => _AsteroidDetailScreenState();
}

class _AsteroidDetailScreenState extends State<AsteroidDetailScreen> {
  Map<String, dynamic>? _detail;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = widget.asteroid['id']?.toString() ??
        widget.asteroid['neo_reference_id']?.toString();
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _loadingDetail = false);
      return;
    }
    final d = await ApiService.getAsteroidDetail(id);
    if (!mounted) return;
    setState(() {
      _detail = d;
      _loadingDetail = false;
    });
  }

  // ═══════════════════════════════════════════
  // DATA HELPERS
  // ═══════════════════════════════════════════

  Map<String, dynamic>? get _closestApproach {
    final approaches =
        widget.asteroid['close_approach_data'] as List<dynamic>?;
    if (approaches == null || approaches.isEmpty) return null;
    return Map<String, dynamic>.from(approaches.first as Map);
  }

  double _d(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  double get _missKm => _d(_closestApproach?['miss_distance']?['kilometers']);
  double get _missAU =>
      _d(_closestApproach?['miss_distance']?['astronomical']);
  double get _missLunar => _d(_closestApproach?['miss_distance']?['lunar']);
  double get _velKmS =>
      _d(_closestApproach?['relative_velocity']?['kilometers_per_second']);
  double get _velKmH =>
      _d(_closestApproach?['relative_velocity']?['kilometers_per_hour']);
  String get _orbitingBody =>
      _closestApproach?['orbiting_body']?.toString() ?? '—';
  String get _approachDateFull =>
      _closestApproach?['close_approach_date_full']?.toString() ??
      _closestApproach?['close_approach_date']?.toString() ??
      '';

  double get _diameterMin => _d(widget
      .asteroid['estimated_diameter']?['meters']?['estimated_diameter_min']);
  double get _diameterMax => _d(widget
      .asteroid['estimated_diameter']?['meters']?['estimated_diameter_max']);
  double get _absMagnitude => _d(widget.asteroid['absolute_magnitude_h']);
  bool get _hazardous =>
      widget.asteroid['is_potentially_hazardous_asteroid'] == true;
  String get _name => widget.asteroid['name']?.toString() ?? 'Unknown';
  String? get _jplUrl => widget.asteroid['nasa_jpl_url']?.toString();

  String _formatApproachDate() {
    if (_approachDateFull.isEmpty) return '—';
    try {
      // API format is typically "2026-Apr-24 12:34"
      final parsed = DateFormat('yyyy-MMM-dd HH:mm').parseLoose(
        _approachDateFull,
      );
      return '${DateFormat('EEE, MMM d y · HH:mm').format(parsed)} UTC';
    } catch (_) {
      return _approachDateFull;
    }
  }

  (String, String) _sizeComparison(double avg) {
    if (avg < 10) return ('🚗', 'Like a car');
    if (avg < 30) return ('🏠', 'Like a house');
    if (avg < 100) return ('✈️', 'Like an airplane');
    if (avg < 500) return ('🗼', 'Like the Eiffel Tower');
    return ('🏙️', 'Like a city block');
  }

  Future<void> _openJpl() async {
    final raw = _jplUrl;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _showLaunchError();
    } catch (_) {
      if (mounted) _showLaunchError();
    }
  }

  void _showLaunchError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't open NASA JPL link",
          style: GoogleFonts.inter(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(isDark),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatGrid().animate().fadeIn(duration: 400.ms).slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                    ),
                const SizedBox(height: 14),
                _buildApproachCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                      delay: 80.ms,
                    ),
                const SizedBox(height: 14),
                _buildSizeComparisonCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 160.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                      delay: 160.ms,
                    ),
                const SizedBox(height: 14),
                _buildHazardAssessmentCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 240.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                      delay: 240.ms,
                    ),
                const SizedBox(height: 14),
                _buildOrbitalInfoCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 320.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                      delay: 320.ms,
                    ),
                const SizedBox(height: 18),
                if (_jplUrl != null && _jplUrl!.isNotEmpty)
                  _buildJplButton()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SLIVER APP BAR with hero image + gradient title
  // ═══════════════════════════════════════════

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      backgroundColor: AppColors.background(context),
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding:
            const EdgeInsetsDirectional.only(start: 56, end: 56, bottom: 14),
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            _name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/asteroid_hero.jpg',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 54,
              right: 14,
              child: _hazardBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hazardBadge() {
    final color = _hazardous ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _hazardous ? '⚠️' : '🟢',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            _hazardous ? 'Hazardous' : 'Safe',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 2x2 STAT GRID
  // ═══════════════════════════════════════════

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                '🌍',
                'Distance',
                '${(_missKm / 1e6).toStringAsFixed(2)} M km',
                '${_missAU.toStringAsFixed(4)} AU',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                '📏',
                'Diameter',
                '${_diameterMin.toStringAsFixed(0)}–'
                    '${_diameterMax.toStringAsFixed(0)} m',
                'estimated',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                '⚡',
                'Velocity',
                '${_velKmS.toStringAsFixed(1)} km/s',
                '${NumberFormat.decimalPattern().format(_velKmH.round())} km/h',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                '☄️',
                'Magnitude',
                _absMagnitude == 0
                    ? '—'
                    : 'H = ${_absMagnitude.toStringAsFixed(2)}',
                'absolute',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, String subtitle) {
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
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
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
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // APPROACH DETAILS CARD
  // ═══════════════════════════════════════════

  Widget _buildApproachCard() {
    return _sectionCard(
      title: 'Approach Details',
      icon: CupertinoIcons.calendar,
      child: Column(
        children: [
          _infoRow(
            icon: CupertinoIcons.time,
            label: 'Closest approach',
            value: _formatApproachDate(),
          ),
          _infoRow(
            icon: CupertinoIcons.moon_stars,
            label: 'Miss distance',
            value: _missLunar == 0
                ? '—'
                : '${_missLunar.toStringAsFixed(2)} × Moon distance',
            subValue: _missKm == 0
                ? null
                : '${NumberFormat.decimalPattern().format(_missKm.round())} km',
          ),
          _infoRow(
            icon: CupertinoIcons.globe,
            label: 'Orbiting body',
            value: _orbitingBody,
          ),
          _infoRow(
            icon: CupertinoIcons.bolt,
            label: 'Relative velocity',
            value: '${_velKmS.toStringAsFixed(2)} km/s',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SIZE COMPARISON CARD
  // ═══════════════════════════════════════════

  Widget _buildSizeComparisonCard() {
    final avg = (_diameterMin + _diameterMax) / 2;
    final (emoji, label) = _sizeComparison(avg);
    return _sectionCard(
      title: 'Size Comparison',
      icon: CupertinoIcons.resize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated ~${avg.toStringAsFixed(0)} m average',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HAZARD ASSESSMENT CARD
  // ═══════════════════════════════════════════

  Widget _buildHazardAssessmentCard() {
    final color = _hazardous ? AppColors.error : AppColors.success;
    final titleText =
        _hazardous ? 'Potentially Hazardous' : 'Safe Passage';
    final body = _hazardous
        ? 'This asteroid is classified as Potentially Hazardous because it '
            "comes within 7.5 million km of Earth's orbit AND is at least "
            '140 m in diameter. This classification is precautionary — it '
            'does not mean impact is likely.'
        : 'This asteroid will safely pass Earth at a comfortable distance. '
            'There is no risk of impact on this approach.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              color.withValues(alpha: 0.1),
              AppColors.glass(context),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Icon(
                  _hazardous
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : CupertinoIcons.checkmark_shield_fill,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textPrimary(context),
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

  // ═══════════════════════════════════════════
  // ORBITAL INFO CARD
  // ═══════════════════════════════════════════

  Widget _buildOrbitalInfoCard() {
    if (_loadingDetail) {
      return _sectionCard(
        title: 'Orbital Info',
        icon: CupertinoIcons.arrow_2_circlepath,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CupertinoActivityIndicator(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      );
    }

    final orbital = _detail?['orbital_data'] as Map?;
    if (orbital == null) {
      return _sectionCard(
        title: 'Orbital Info',
        icon: CupertinoIcons.arrow_2_circlepath,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Orbital data unavailable for this asteroid.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      );
    }

    final orbitClass = orbital['orbit_class'] as Map?;
    final orbitClassType = orbitClass?['orbit_class_type']?.toString();
    final orbitClassDesc = orbitClass?['orbit_class_description']?.toString();

    final period = _d(orbital['orbital_period']);
    final periodYears = period > 0 ? (period / 365.25) : 0;

    return _sectionCard(
      title: 'Orbital Info',
      icon: CupertinoIcons.arrow_2_circlepath,
      child: Column(
        children: [
          if (orbitClassType != null)
            _infoRow(
              icon: CupertinoIcons.circle_grid_hex,
              label: 'Orbit class',
              value: orbitClassType,
              subValue: orbitClassDesc,
            ),
          if (period > 0)
            _infoRow(
              icon: CupertinoIcons.clock,
              label: 'Orbital period',
              value: '${period.toStringAsFixed(1)} days',
              subValue: '${periodYears.toStringAsFixed(2)} years',
            ),
          _infoRowIfValue(
            icon: CupertinoIcons.eye,
            label: 'First observation',
            value: orbital['first_observation_date']?.toString(),
          ),
          _infoRowIfValue(
            icon: CupertinoIcons.eye_fill,
            label: 'Last observation',
            value: orbital['last_observation_date']?.toString(),
          ),
          _infoRowIfValue(
            icon: CupertinoIcons.chart_bar,
            label: 'Observations used',
            value: orbital['observations_used']?.toString(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // NASA JPL LINK BUTTON
  // ═══════════════════════════════════════════

  Widget _buildJplButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(14),
        onPressed: _openJpl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.link,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'View on NASA JPL Database',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SHARED BUILDING BLOCKS
  // ═══════════════════════════════════════════

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  Icon(icon, size: 18, color: AppColors.accentCyan),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary(context)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (subValue != null && subValue.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subValue,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowIfValue({
    required IconData icon,
    required String label,
    required String? value,
    bool isLast = false,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return _infoRow(
      icon: icon,
      label: label,
      value: value,
      isLast: isLast,
    );
  }
}
