import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/observation_log.dart';
import '../../theme/app_colors.dart';
import 'add_observation_screen.dart';

class ObservationLogScreen extends StatefulWidget {
  const ObservationLogScreen({super.key});

  @override
  State<ObservationLogScreen> createState() => _ObservationLogScreenState();
}

class _ObservationLogScreenState extends State<ObservationLogScreen> {
  List<ObservationLog> _logs = [];
  String _filterType = 'All';
  String _sortBy = 'Newest';

  static const List<String> _filterTypes = [
    'All',
    'Planet',
    'Star',
    'Nebula',
    'Galaxy',
    'Constellation',
    'Meteor',
    'Comet',
    'Other',
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadLogs(setStateAfter: false);
  }

  void _loadLogs({bool setStateAfter = true}) {
    final box = Hive.box<ObservationLog>('observations');
    final logs = box.values.where((log) => log.isVisible).toList()
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));

    if (setStateAfter && mounted) {
      setState(() => _logs = logs);
    } else {
      _logs = logs;
    }
  }

  List<ObservationLog> get _filteredLogs {
    var list = _logs.where((log) => log.isVisible).toList();
    if (_filterType != 'All') {
      list = list.where((log) => log.objectType == _filterType).toList();
    }

    if (_sortBy == 'Newest') {
      list.sort((a, b) => b.observedAt.compareTo(a.observedAt));
    } else if (_sortBy == 'Oldest') {
      list.sort((a, b) => a.observedAt.compareTo(b.observedAt));
    } else if (_sortBy == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final filteredLogs = _filteredLogs;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF080818)
          : const Color(0xFFF2F0FF),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddScreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(isDark),
            _buildPremiumFilterPills(isDark),
            const SizedBox(height: 12),
            Expanded(
              child: filteredLogs.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return Dismissible(
                          key: ValueKey(log.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) =>
                              _showDeleteConfirm(log, isDark),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(
                                alpha: isDark ? 0.22 : 0.14,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.error.withValues(
                                  alpha: isDark ? 0.5 : 0.28,
                                ),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                          ),
                          child: _buildLogCard(log, isDark),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(ObservationLog log, bool isDark) {
    final accent = _getTypeColor(log.objectType, isDark);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF141438), Color(0xFF0D0D2E)],
              )
            : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: AppColors.surface(context).withValues(alpha: 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showDetailSheet(log, isDark),
          onLongPress: () => _showDeleteConfirm(log, isDark),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.3),
                        accent.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(log.objectType),
                      color: _getTypeColor(log.objectType, isDark),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.objectName,
                              style: GoogleFonts.spaceGrotesk(
                                color: _primaryTextColor(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (starIndex) => Icon(
                                starIndex < log.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.starGold,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                alpha: isDark ? 0.22 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.objectType,
                              style: GoogleFonts.inter(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            log.equipment,
                            style: GoogleFonts.inter(
                              color: _secondaryTextColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(log.observedAt),
                        style: GoogleFonts.inter(
                          color: _secondaryTextColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                      if (log.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          log.notes,
                          style: GoogleFonts.inter(
                            color: _secondaryTextColor(isDark),
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: _mutedIconColor(isDark),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  const Color(0xFF00B4D8).withValues(alpha: 0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.visibility_outlined,
              color: Colors.white70,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No observations yet',
            style: GoogleFonts.spaceGrotesk(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your\ncelestial discoveries',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHintStat(Icons.public, 'Planets', const Color(0xFF00E676)),
                _buildHintStat(Icons.star_outline, 'Stars', const Color(0xFFFFB800)),
                _buildHintStat(Icons.blur_circular, 'Galaxies', const Color(0xFF448AFF)),
                _buildHintStat(Icons.cloud_outlined, 'Nebulae', const Color(0xFFE040FB)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _openAddScreen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log First Observation',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF6C63FF).withValues(alpha: 0.2);
    final chipColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0D0D2E), Color(0xFF1A0A3A)]
              : const [Color(0xFFEEEEFF), Color(0xFFF5F0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: chipColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showSortSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6C63FF),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Sort',
                        style: GoogleFonts.inter(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.visibility_outlined,
                  color: Color(0xFF6C63FF), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Observation Log',
                    style: GoogleFonts.spaceGrotesk(
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '${_filteredLogs.length} celestial observation${_filteredLogs.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6C63FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFilterPills(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0D0D2E) : const Color(0xFFEEEEFF),
      child: SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: _filterTypes.map((type) {
            final isSelected = _filterType == type;
            final typeColor = type == 'All'
                ? const Color(0xFF6C63FF)
                : _getTypeColor(type, isDark);

            return GestureDetector(
              onTap: () => setState(() => _filterType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? typeColor
                        : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: typeColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getTypeIcon(type),
                        color: isSelected
                            ? Colors.white
                            : typeColor,
                        size: 14),
                    const SizedBox(width: 5),
                    Text(
                      type,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : isDark
                            ? Colors.white54
                            : const Color(0xFF444466),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHintStat(IconData icon, String label, Color color) {
    final isDark = _isDark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 9,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Future<void> _openAddScreen() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const AddObservationScreen()),
    );
    _loadLogs();
  }

  Future<void> _editLog(ObservationLog log) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => AddObservationScreen(initialLog: log)),
    );
    _loadLogs();
  }

  Future<void> _showDetailSheet(ObservationLog log, bool isDark) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context).withValues(alpha: 0),
      builder: (sheetContext) {
        final accent = _getTypeColor(log.objectType, isDark);
        return Material(
          color: AppColors.surface(sheetContext).withValues(alpha: 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: _surfaceColor(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: _borderColor(isDark)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _borderColor(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.objectName,
                              style: GoogleFonts.spaceGrotesk(
                                color: _primaryTextColor(isDark),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: isDark ? 0.22 : 0.14,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getTypeIcon(log.objectType),
                                      color: accent, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.objectType,
                                    style: GoogleFonts.inter(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < log.rating ? Icons.star : Icons.star_border,
                            color: AppColors.starGold,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildDetailTile(
                    isDark: isDark,
                    icon: Icons.calendar_today_outlined,
                    label: 'Observed',
                    value: _formatDate(log.observedAt),
                  ),
                  _buildDetailTile(
                    isDark: isDark,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Equipment',
                    value: log.equipment,
                  ),
                  _buildDetailTile(
                    isDark: isDark,
                    icon: Icons.cloud_outlined,
                    label: 'Sky Conditions',
                    value: log.conditions,
                  ),
                  if (log.location.isNotEmpty)
                    _buildDetailTile(
                      isDark: isDark,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: log.location,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Notes',
                    style: GoogleFonts.inter(
                      color: _secondaryTextColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.24 : 0.14),
                      ),
                    ),
                    child: Text(
                      log.notes.isEmpty ? 'No notes added.' : log.notes,
                      style: GoogleFonts.inter(
                        color: _primaryTextColor(isDark),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await _editLog(log);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.accentCyan.withValues(alpha: 0.18)
                                  : AppColors.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.accentCyan
                                    : AppColors.accentBlue,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? AppColors.accentCyan
                                      : AppColors.accentBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await _showDeleteConfirm(log, isDark);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(
                                alpha: isDark ? 0.18 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: Center(
                              child: Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.accentBlue.withValues(alpha: 0.08)
              : AppColors.accentBlue.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor(isDark)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.accentCyan : AppColors.accentBlue,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: _secondaryTextColor(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: _primaryTextColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSortSheet() async {
    final isDark = _isDark;
    final options = <(String title, String value)>[
      ('Newest First', 'Newest'),
      ('Oldest First', 'Oldest'),
      ('Best Rating', 'Rating'),
    ];
    final accent = isDark ? AppColors.accentCyan : AppColors.accentBlue;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(context).withValues(alpha: 0),
      builder: (sheetContext) {
        return Material(
          color: AppColors.surface(sheetContext).withValues(alpha: 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: _surfaceColor(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: _borderColor(isDark)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _borderColor(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sort Observations',
                    style: GoogleFonts.spaceGrotesk(
                      color: _primaryTextColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...options.map((option) {
                    final selected = _sortBy == option.$2;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _sortBy = option.$2);
                          Navigator.pop(sheetContext);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? accent.withValues(alpha: isDark ? 0.18 : 0.1)
                                : _surfaceColor(isDark),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? accent : _borderColor(isDark),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.$1,
                                  style: GoogleFonts.inter(
                                    color: selected
                                        ? accent
                                        : _primaryTextColor(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle,
                                  color: accent,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirm(ObservationLog log, bool isDark) async {
    final shouldDelete =
        await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: Text(
              'Delete this observation?',
              style: GoogleFonts.spaceGrotesk(
                color: _primaryTextColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'This entry will be removed from your visible observation diary.',
              style: GoogleFonts.inter(
                color: _secondaryTextColor(isDark),
                fontSize: 13,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return false;

    log.isVisible = false;
    await log.save();
    _loadLogs();
    return true;
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Planet':
        return Icons.public;
      case 'Star':
        return Icons.star_outline;
      case 'Nebula':
        return Icons.cloud_outlined;
      case 'Galaxy':
        return Icons.blur_circular;
      case 'Constellation':
        return Icons.auto_awesome_outlined;
      case 'Meteor':
        return Icons.north_east;
      case 'Comet':
        return Icons.trending_up;
      default:
        return Icons.visibility_outlined;
    }
  }

  Color _getTypeColor(String type, bool isDark) {
    switch (type) {
      case 'Planet':
        return isDark ? AppColors.accentGreen : AppColors.success;
      case 'Star':
        return AppColors.starGold;
      case 'Nebula':
        return AppColors.legacyPurple;
      case 'Galaxy':
        return isDark ? AppColors.accentCyan : AppColors.accentBlueLight;
      case 'Constellation':
        return isDark ? AppColors.accentBlueLight : AppColors.accentBlue;
      case 'Meteor':
        return AppColors.accentOrange;
      case 'Comet':
        return isDark ? AppColors.accentGreen : AppColors.accentCyan;
      default:
        return isDark ? AppColors.accentCyan : AppColors.accentBlue;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} \u2022 $hour:$minute $ampm';
  }

  Color _surfaceColor(bool isDark) =>
      isDark ? AppColors.cardDark : AppColors.surfaceLight;

  Color _borderColor(bool isDark) =>
      isDark ? AppColors.glassBorder(context) : AppColors.divider(context);

  Color _primaryTextColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color _secondaryTextColor(bool isDark) =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color _mutedIconColor(bool isDark) =>
      isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight;
}
