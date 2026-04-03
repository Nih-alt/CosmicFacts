// DISCLAIMER: This app is unofficial. Not affiliated with NASA, ISRO, ESA, CNSA or any space agency.
// Agency names are used as informational data labels only — no official logos or emblems are used.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/active_missions_data.dart';
import '../../theme/app_colors.dart';

// ─── Accent palette ───────────────────────────────────────────
const _kAccent = Color(0xFF6C63FF);
const _kGold = Color(0xFFFFB800);
const _kGreen = Color(0xFF00E676);
const _kCyan = Color(0xFF00E5FF);
const _kCardDark = Color(0xFF141438);
const _kBgDark = Color(0xFF0A0A1A);

class ActiveMissionsScreen extends StatefulWidget {
  const ActiveMissionsScreen({super.key});

  @override
  State<ActiveMissionsScreen> createState() => _ActiveMissionsScreenState();
}

class _ActiveMissionsScreenState extends State<ActiveMissionsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedDest = 'All';
  String _selectedAgency = 'All';
  String _sortBy = 'distance';
  int _expandedIndex = -1;
  final Set<int> _bookmarked = {};
  late AnimationController _pulseCtrl;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _destFilters = [
    'All',
    'Mars',
    'Moon',
    'Deep Space',
    'Sun',
    'Earth Orbit',
    'En Route',
  ];

  static const _agencyFilters = [
    'All',
    'NASA',
    'ISRO',
    'ESA',
    'CNSA',
    'Multi-Agency',
  ];

  // ─── lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── filtering + sorting ────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    var list = List<Map<String, dynamic>>.from(activeMissions);

    // destination filter
    if (_selectedDest != 'All') {
      if (_selectedDest == 'En Route') {
        list = list.where((m) => m['status'] == 'En Route').toList();
      } else {
        list = list.where((m) => m['destination'] == _selectedDest).toList();
      }
    }

    // agency filter (AND with destination)
    if (_selectedAgency != 'All') {
      if (_selectedAgency == 'Multi-Agency') {
        list = list
            .where(
                (m) => (m['agency'] as String).contains('/'))
            .toList();
      } else {
        list =
            list.where((m) => m['agency'] == _selectedAgency).toList();
      }
    }

    // sort
    switch (_sortBy) {
      case 'distance':
        list.sort((a, b) =>
            (b['distanceKm'] as num).compareTo(a['distanceKm'] as num));
      case 'launch':
        list.sort((a, b) =>
            (b['launchYear'] as int).compareTo(a['launchYear'] as int));
      case 'agency':
        list.sort((a, b) =>
            (a['agency'] as String).compareTo(b['agency'] as String));
      case 'name':
        list.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    return list;
  }

  // ─── helpers ────────────────────────────────────────────────
  String _destOf(Map<String, dynamic> m) {
    if (m['status'] == 'En Route') return 'En Route';
    return m['destination'] as String;
  }

  IconData _destIcon(String dest) {
    switch (dest) {
      case 'Mars':
        return Icons.public;
      case 'Moon':
        return Icons.dark_mode;
      case 'Deep Space':
        return Icons.auto_awesome;
      case 'Sun':
        return Icons.wb_sunny;
      case 'Earth Orbit':
        return Icons.satellite_alt;
      case 'En Route':
        return Icons.rocket_launch;
      default:
        return Icons.explore;
    }
  }

  Color _destTint(String dest) {
    switch (dest) {
      case 'Mars':
        return const Color(0xFFFF6B35);
      case 'Moon':
        return const Color(0xFF78909C);
      case 'Deep Space':
        return const Color(0xFF7B5BFF);
      case 'Sun':
        return _kGold;
      case 'Earth Orbit':
        return _kCyan;
      case 'En Route':
        return const Color(0xFF448AFF);
      default:
        return _kAccent;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return _kGreen;
      case 'En Route':
        return _kCyan;
      case 'Extended Mission':
        return _kGold;
      case 'Completed':
        return const Color(0xFF78909C);
      default:
        return _kAccent;
    }
  }

  String _formatDistance(num km) {
    if (km >= 1e9) return '${(km / 1e9).toStringAsFixed(0)} billion km';
    if (km >= 1e6) return '${(km / 1e6).toStringAsFixed(0)} million km';
    if (km >= 1e3) return '${(km / 1e3).toStringAsFixed(0)} thousand km';
    if (km >= 1) return '${km.toStringAsFixed(0)} km';
    return '${(km * 1000).toStringAsFixed(0)} m';
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _isDark ? _kBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(filtered.length)),
            SliverToBoxAdapter(child: _buildDestFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildAgencyFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildHeroCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildMissionCard(filtered[i], i),
                  childCount: filtered.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context), size: 26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Missions',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Exploring the cosmos right now',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _kAccent.withValues(alpha: 0.15),
            ),
            child: Text('$count missions',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kAccent)),
          ),
          const SizedBox(width: 4),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showSortSheet,
            child: Icon(CupertinoIcons.sort_down,
                color: AppColors.textPrimary(context), size: 24),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER PILLS
  // ═══════════════════════════════════════════════════════════

  Widget _buildFilterPill(
      String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? _kAccent
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? _kAccent
                : (_isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary(context))),
      ),
    );
  }

  Widget _buildDestFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _destFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _buildFilterPill(
          _destFilters[i],
          _destFilters[i] == _selectedDest,
          () => setState(() => _selectedDest = _destFilters[i]),
        ),
      ),
    );
  }

  Widget _buildAgencyFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _agencyFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _buildFilterPill(
          _agencyFilters[i],
          _agencyFilters[i] == _selectedAgency,
          () => setState(() => _selectedAgency = _agencyFilters[i]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HERO CARD — Voyager 1 (always dark — space aesthetic)
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroCard() {
    final voyager =
        activeMissions.firstWhere((m) => m['name'] == 'Voyager 1');
    final years = DateTime.now().year - (voyager['launchYear'] as int);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A3A), _kBgDark],
          ),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('FARTHEST MISSION',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: _kGold)),
                ),
                // Pulsing signal dot
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          _kGreen.withValues(alpha: 0.3),
                          _kGreen,
                          _pulseCtrl.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _kGreen.withValues(
                                alpha: 0.5 * _pulseCtrl.value),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text('SIGNAL ACTIVE',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kGreen)),
              ],
            ),
            const SizedBox(height: 14),
            Text('Voyager 1',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('24 billion km from Earth',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _kGold)),
            const SizedBox(height: 4),
            Text(
                'Launched 1977 \u2014 still communicating after $years years',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 10),
            Text(
                '${voyager['agencyFlag']} ${voyager['agency']} \u2022 ${voyager['target']} \u2022 ${voyager['type']}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5))),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // MISSION CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildMissionCard(Map<String, dynamic> m, int index) {
    final isExpanded = _expandedIndex == index;
    final dest = _destOf(m);
    final status = m['status'] as String;
    final sColor = _statusColor(status);
    final tint = _destTint(dest);

    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isDark ? _kCardDark : Colors.white,
          boxShadow: _isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isExpanded
                ? tint.withValues(alpha: 0.35)
                : (_isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04)),
          ),
        ),
        child: Column(
          children: [
            // ── Main row ──
            Row(
              children: [
                // Left icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint.withValues(alpha: 0.15),
                  ),
                  child: Icon(_destIcon(dest), color: tint, size: 22),
                ),
                const SizedBox(width: 12),
                // Centre text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'] as String,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context))),
                      const SizedBox(height: 2),
                      Text('${m['agencyFlag']} ${m['agency']}',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary(context))),
                      Text(
                          '${m['target']} \u2022 ${m['type']}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary(context))),
                    ],
                  ),
                ),
                // Right: status pill + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: sColor.withValues(alpha: 0.15),
                      ),
                      child: Text(status,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sColor)),
                    ),
                    const SizedBox(height: 6),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(CupertinoIcons.chevron_right,
                          size: 14,
                          color: AppColors.textTertiary(context)),
                    ),
                  ],
                ),
              ],
            ),

            // ── Expanded ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpanded(m),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
        duration: 350.ms, delay: Duration(milliseconds: 40 * index));
  }

  // ═══════════════════════════════════════════════════════════
  // EXPANDED CONTENT
  // ═══════════════════════════════════════════════════════════

  Widget _buildExpanded(Map<String, dynamic> m) {
    final distKm = m['distanceKm'] as num;
    final tint = _destTint(_destOf(m));

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(m['description'] as String,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 14),

          // 🔬 Key Discovery — purple callout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isDark
                  ? const Color(0xFF2A1F5F)
                  : _kAccent.withValues(alpha: 0.08),
              border: Border.all(
                  color: _kAccent.withValues(alpha: _isDark ? 0.25 : 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\u{1F52C} Key Discovery',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kAccent)),
                const SizedBox(height: 6),
                Text(m['keyDiscovery'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textPrimary(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 📡 Current Activity — dark card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border.all(
                color: _isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\u{1F4E1} Current Activity',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                const SizedBox(height: 6),
                Text(m['currentActivity'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 📏 Distance visual bar
          _buildDistanceBar(distKm, tint),
          const SizedBox(height: 14),

          // Launch year chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.calendar,
                    size: 13, color: AppColors.textTertiary(context)),
                const SizedBox(width: 6),
                Text('Launched ${m['launchYear']}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bottom row: website + bookmark
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  color: _kAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => launchUrl(
                    Uri.parse(m['officialUrl'] as String),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                      '\u{1F310} Visit Official Page \u2192',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kAccent)),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  final key = m['name'].hashCode;
                  setState(() {
                    if (_bookmarked.contains(key)) {
                      _bookmarked.remove(key);
                    } else {
                      _bookmarked.add(key);
                    }
                  });
                },
                child: Icon(
                  _bookmarked.contains((m['name'] as String).hashCode)
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color:
                      _bookmarked.contains((m['name'] as String).hashCode)
                          ? _kAccent
                          : AppColors.textTertiary(context),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DISTANCE BAR (logarithmic scale)
  // ═══════════════════════════════════════════════════════════

  Widget _buildDistanceBar(num distKm, Color tint) {
    // Logarithmic scale: 0.4 km (ISS) → 24,000,000,000 km (Voyager 1)
    const minKm = 0.4;
    const maxKm = 24000000000.0;
    final clamped = distKm.toDouble().clamp(minKm, maxKm);
    final logMin = log(minKm);
    final logMax = log(maxKm);
    final fraction =
        ((log(clamped) - logMin) / (logMax - logMin)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('\u{1F4CF} Distance from Earth',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context))),
        const SizedBox(height: 8),
        SizedBox(
          height: 22,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barW = constraints.maxWidth;
              final pos = fraction * (barW - 14);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Filled
                  Positioned(
                    top: 9,
                    left: 0,
                    child: Container(
                      height: 4,
                      width: pos + 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                            colors: [_kGreen, tint]),
                      ),
                    ),
                  ),
                  // Earth dot
                  Positioned(
                    top: 6,
                    left: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGreen,
                      ),
                    ),
                  ),
                  // Mission marker with glow
                  Positioned(
                    top: 4,
                    left: pos,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tint,
                        boxShadow: [
                          BoxShadow(
                            color: tint.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Earth',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textTertiary(context))),
            Text(_formatDistance(distKm),
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kGold)),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SORT BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════

  void _showSortSheet() {
    final options = [
      ('distance', 'Distance (farthest first)', CupertinoIcons.arrow_up_right),
      ('launch', 'Launch date (newest first)', CupertinoIcons.calendar),
      ('agency', 'Agency (A-Z)', CupertinoIcons.building_2_fill),
      ('name', 'Name (A-Z)', CupertinoIcons.textformat),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          decoration: BoxDecoration(
            color: _isDark ? _kCardDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Sort missions by',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _isDark
                          ? Colors.white
                          : const Color(0xFF0A1628))),
              const SizedBox(height: 16),
              ...options.map((o) {
                final selected = _sortBy == o.$1;
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() => _sortBy = o.$1);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? _kAccent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? _kAccent.withValues(alpha: 0.3)
                            : (_isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(o.$3,
                            size: 18,
                            color: selected
                                ? _kAccent
                                : (_isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : const Color(0xFF5A7A9A))),
                        const SizedBox(width: 12),
                        Text(o.$2,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? _kAccent
                                    : (_isDark
                                        ? Colors.white
                                        : const Color(0xFF0A1628)))),
                        const Spacer(),
                        if (selected)
                          Icon(CupertinoIcons.checkmark_alt,
                              size: 18, color: _kAccent),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
