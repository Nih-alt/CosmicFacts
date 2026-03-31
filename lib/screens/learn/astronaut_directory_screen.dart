import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/astronaut_data.dart';
import '../../theme/app_colors.dart';

class AstronautDirectoryScreen extends StatefulWidget {
  const AstronautDirectoryScreen({super.key});

  @override
  State<AstronautDirectoryScreen> createState() =>
      _AstronautDirectoryScreenState();
}

class _AstronautDirectoryScreenState extends State<AstronautDirectoryScreen> {
  String _search = '';
  String _selectedAgency = 'All';
  final _searchController = TextEditingController();

  static const _agencies = [
    'All', 'NASA', 'ISRO', 'ESA', 'Roscosmos', 'CNSA', 'SpaceX', 'Other',
  ];

  static const _agencyColors = <String, Color>{
    'NASA': Color(0xFF1E88E5),
    'ISRO': Color(0xFFFF9933),
    'ESA': Color(0xFF00BFA5),
    'Roscosmos': Color(0xFFFF4D6A),
    'CNSA': Color(0xFFDAA520),
    'JAXA': Color(0xFFE040FB),
    'SpaceX': AppColors.accentBlue,
    'CSA': AppColors.accentCyan,
    'MBRSC': Color(0xFF00E096),
  };

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<Astronaut> get _filtered {
    var list = allAstronauts.toList();

    if (_selectedAgency != 'All') {
      if (_selectedAgency == 'Other') {
        const mainAgencies = ['NASA', 'ISRO', 'ESA', 'Roscosmos', 'CNSA', 'SpaceX'];
        list = list.where((a) => !mainAgencies.contains(a.agency)).toList();
      } else {
        list = list.where((a) => a.agency == _selectedAgency).toList();
      }
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((a) =>
          a.name.toLowerCase().contains(q) ||
          a.country.toLowerCase().contains(q) ||
          a.agency.toLowerCase().contains(q) ||
          a.famousMission.toLowerCase().contains(q) ||
          a.achievement.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  int get _activeCount =>
      allAstronauts.where((a) => a.isActive).length;

  int get _countryCount =>
      allAstronauts.map((a) => a.country).toSet().length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterPills()),
            SliverToBoxAdapter(child: _buildStatsCards()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Astronaut list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: filtered.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmpty())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildAstronautCard(filtered[index], index),
                        childCount: filtered.length,
                      ),
                    ),
            ),
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
                Text('Astronaut Directory',
                    style: GoogleFonts.spaceGrotesk(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Heroes of space exploration',
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${allAstronauts.length}',
                style: GoogleFonts.spaceGrotesk(fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBlue)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ═══════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.searchBar(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(CupertinoIcons.search, size: 18,
                color: AppColors.textSecondary(context)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(fontSize: 14,
                    color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Search astronauts...',
                  hintStyle: GoogleFonts.inter(fontSize: 14,
                      color: AppColors.textSecondary(context)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            if (_search.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _search = '');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(CupertinoIcons.xmark_circle_fill, size: 18,
                      color: AppColors.textSecondary(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // FILTER PILLS
  // ═══════════════════════════════════════

  Widget _buildFilterPills() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _agencies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final agency = _agencies[i];
          final active = _selectedAgency == agency;
          return GestureDetector(
            onTap: () => setState(() => _selectedAgency = agency),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accentBlue
                    : _isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(color: AppColors.glassBorder(context)),
                boxShadow: active
                    ? [BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 8, offset: const Offset(0, 2))]
                    : AppColors.cardShadow(context),
              ),
              child: Text(agency,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // STATS CARDS
  // ═══════════════════════════════════════

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _statMini('\u{1F30D}', '$_countryCount', 'Countries',
              AppColors.accentCyan),
          const SizedBox(width: 10),
          _statMini('\u{1F9D1}\u200D\u{1F680}', '${allAstronauts.length}',
              'Astronauts', AppColors.accentBlue),
          const SizedBox(width: 10),
          _statMini('\u{1F7E2}', '$_activeCount', 'Active',
              AppColors.success),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _statMini(String emoji, String value, String label, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(14),
          border: _isDark
              ? Border.all(color: AppColors.glassBorder(context))
              : Border(top: BorderSide(color: accent, width: 3)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.spaceGrotesk(fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            Text(label,
                style: GoogleFonts.inter(fontSize: 10,
                    color: AppColors.textSecondary(context))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ASTRONAUT CARD
  // ═══════════════════════════════════════

  Widget _buildAstronautCard(Astronaut astronaut, int index) {
    final agencyColor =
        _agencyColors[astronaut.agency] ?? AppColors.accentBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showDetail(astronaut),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Row(
            children: [
              // Flag
              Column(
                children: [
                  Text(astronaut.flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 2),
                  Text(
                    astronaut.country.length > 6
                        ? '${astronaut.country.substring(0, 5)}..'
                        : astronaut.country,
                    style: GoogleFonts.inter(fontSize: 9,
                        color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(astronaut.name,
                        style: GoogleFonts.spaceGrotesk(fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: agencyColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(astronaut.agency,
                              style: GoogleFonts.inter(fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: agencyColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(astronaut.achievement,
                        style: GoogleFonts.inter(fontSize: 12,
                            color: AppColors.textSecondary(context)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status + chevron
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: astronaut.isActive
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.textSecondary(context)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      astronaut.isActive ? 'Active' : 'Retired',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: astronaut.isActive
                            ? AppColors.success
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(CupertinoIcons.chevron_right, size: 14,
                      color: AppColors.textSecondary(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 30 * index))
        .slideY(begin: 0.05, end: 0,
            delay: Duration(milliseconds: 30 * index));
  }

  // ═══════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('\u{1F50D}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No astronauts found',
              style: GoogleFonts.spaceGrotesk(fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 4),
          Text('Try a different search or filter',
              style: GoogleFonts.inter(fontSize: 13,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // DETAIL BOTTOM SHEET
  // ═══════════════════════════════════════

  void _showDetail(Astronaut astronaut) {
    final agencyColor =
        _agencyColors[astronaut.agency] ?? AppColors.accentBlue;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Flag + name
              Row(
                children: [
                  Text(astronaut.flag,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(astronaut.name,
                            style: GoogleFonts.spaceGrotesk(fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context))),
                        Text(astronaut.country,
                            style: GoogleFonts.inter(fontSize: 13,
                                color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: astronaut.isActive
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.textSecondary(context)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      astronaut.isActive ? 'Active' : 'Retired',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: astronaut.isActive
                            ? AppColors.success
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Agency + Role
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: agencyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(astronaut.agency,
                        style: GoogleFonts.inter(fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: agencyColor)),
                  ),
                  const SizedBox(width: 8),
                  Text(astronaut.role,
                      style: GoogleFonts.inter(fontSize: 13,
                          color: AppColors.textSecondary(context))),
                ],
              ),
              const SizedBox(height: 12),
              // Mission
              _detailRow('Mission', astronaut.famousMission),
              _detailRow('Born', astronaut.born),
              const SizedBox(height: 12),
              // Achievement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppColors.accentBlue.withValues(alpha: 0.08)
                      : const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\u{1F3C6} Achievement',
                        style: GoogleFonts.inter(fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentBlue)),
                    const SizedBox(height: 4),
                    Text(astronaut.achievement,
                        style: GoogleFonts.inter(fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Bio
              Text(astronaut.bio,
                  style: GoogleFonts.inter(fontSize: 14,
                      color: AppColors.textPrimary(context)
                          .withValues(alpha: 0.85),
                      height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.inter(fontSize: 13,
                  color: AppColors.textSecondary(context))),
          Text(value,
              style: GoogleFonts.inter(fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }
}
