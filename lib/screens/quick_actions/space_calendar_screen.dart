import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/api_endpoints.dart';
import '../../data/calendar_events_data.dart';
import '../../theme/app_colors.dart';

// ═════════════════════════════════════════════
// SPACE CALENDAR SCREEN
// ═════════════════════════════════════════════

class SpaceCalendarScreen extends StatefulWidget {
  const SpaceCalendarScreen({super.key});

  @override
  State<SpaceCalendarScreen> createState() => _SpaceCalendarScreenState();
}

class _SpaceCalendarScreenState extends State<SpaceCalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  late List<CalendarEvent> _allEvents;
  String _filterType = 'all';
  int _navDirection = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _weekDayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static const _filters = <(String, String, String)>[
    ('all', 'All', '✨'),
    ('launch', 'Launches', '🚀'),
    ('eclipse', 'Eclipses', '🌑'),
    ('meteor', 'Meteors', '☄️'),
    ('planet', 'Planets', '🪐'),
    ('moon', 'Moon', '🌙'),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _allEvents = getAllCalendarEvents();
  }

  // ─── Navigation ───

  void _prevMonth() {
    setState(() {
      _navDirection = -1;
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _navDirection = 1;
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _navDirection = 0;
      _currentMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _jumpTo(int year, int month, {int? day}) {
    setState(() {
      final candidate = DateTime(year, month);
      _navDirection = candidate.isAfter(_currentMonth)
          ? 1
          : candidate.isBefore(_currentMonth)
              ? -1
              : 0;
      _currentMonth = candidate;
      _selectedDate = day != null ? DateTime(year, month, day) : null;
    });
  }

  // ─── Derived ───

  List<CalendarEvent> get _filteredEvents =>
      _filterType == 'all' ? _allEvents : _allEvents.where((e) => e.type == _filterType).toList();

  List<CalendarEvent> get _selectedDayEvents => _selectedDate == null
      ? const []
      : getEventsForDate(_filteredEvents, _selectedDate!);

  CalendarEvent? get _nextUpcomingEvent {
    final today = _todayMidnight();
    CalendarEvent? next;
    for (final e in _filteredEvents) {
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      if (!eDate.isBefore(today)) {
        if (next == null || e.date.isBefore(next.date)) next = e;
      }
    }
    return next;
  }

  List<CalendarEvent> get _next3Upcoming {
    final today = _todayMidnight();
    final list = _filteredEvents.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list.take(3).toList();
  }

  Map<String, int> get _monthStats {
    final stats = <String, int>{};
    for (final e in _allEvents) {
      if (e.date.year == _currentMonth.year && e.date.month == _currentMonth.month) {
        stats[e.type] = (stats[e.type] ?? 0) + 1;
      }
    }
    return stats;
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _buildHeroCard(),
              ),
            ),
            SliverToBoxAdapter(child: _buildMonthNav()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final dx = _navDirection >= 0 ? 0.06 : -0.06;
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(begin: Offset(dx, 0), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(
                        '${_currentMonth.year}-${_currentMonth.month}-$_filterType'),
                    child: _buildCalendarGrid(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildSelectedDayHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: _buildEventsList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context)),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Space Calendar',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  'Never miss a cosmic event',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _goToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.location_fill, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ─── Hero card ───

  Widget _buildHeroCard() {
    final today = _todayMidnight();
    final todayEvents = getEventsForDate(_allEvents, today);

    CalendarEvent? hero;
    bool isToday = false;
    int daysAway = 0;

    if (todayEvents.isNotEmpty) {
      hero = todayEvents.first;
      isToday = true;
    } else {
      final upcoming = _allEvents.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isBefore(today);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      if (upcoming.isNotEmpty) {
        final candidate = upcoming.first;
        final diff = DateTime(candidate.date.year, candidate.date.month, candidate.date.day)
            .difference(today)
            .inDays;
        if (diff <= 7) {
          hero = candidate;
          daysAway = diff;
        }
      }
    }

    if (hero == null) return _buildQuietCosmosCard();
    return _buildHighlightCard(hero, isToday, daysAway);
  }

  Widget _buildHighlightCard(CalendarEvent event, bool isToday, int daysAway) {
    final gradient = _gradientForType(event.type);
    final emoji = _eventEmoji(event.type);
    final typeLabel = _typeLabel(event.type);
    final dateStr = '${_monthsShort[event.date.month - 1]} ${event.date.day}';
    final dayName = _weekDayNames[event.date.weekday - 1];

    final timing = isToday
        ? 'TODAY'
        : daysAway == 1
            ? 'TOMORROW'
            : 'IN $daysAway DAYS';

    return GestureDetector(
      onTap: () => _jumpTo(event.date.year, event.date.month, day: event.date.day),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      typeLabel.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '$dateStr · $dayName',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          timing,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.08,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildQuietCosmosCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? const [Color(0xFF0F0E2A), Color(0xFF1B1442)]
              : const [Color(0xFFEDEAFE), Color(0xFFD7E3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(painter: _StarfieldPainter(isDark: _isDark)),
            ),
          ),
          Row(
            children: [
              const Text('🌌', style: TextStyle(fontSize: 44)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The cosmos is quiet today',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perfect for stargazing — find a dark spot and look up.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
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
    ).animate().fadeIn(duration: 500.ms);
  }

  // ─── Month nav ───

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: CupertinoIcons.chevron_left, onTap: _prevMonth),
          GestureDetector(
            onTap: _showMonthPicker,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_months[_currentMonth.month - 1]} ${_currentMonth.year}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          _NavArrow(icon: CupertinoIcons.chevron_right, onTap: _nextMonth),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    int pickerYear = _currentMonth.year;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Container(
          height: 360,
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.glassBorder(context))),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavArrow(
                        icon: CupertinoIcons.chevron_left,
                        onTap: () => setSheet(() => pickerYear -= 1),
                      ),
                      Text(
                        '$pickerYear',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      _NavArrow(
                        icon: CupertinoIcons.chevron_right,
                        onTap: () => setSheet(() => pickerYear += 1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.7,
                      ),
                      itemCount: 12,
                      itemBuilder: (_, i) {
                        final month = i + 1;
                        final isCurrent = pickerYear == _currentMonth.year &&
                            month == _currentMonth.month;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(sheetCtx).pop();
                            _jumpTo(pickerYear, month);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  isCurrent ? AppColors.primaryGradient : null,
                              color: isCurrent ? null : AppColors.glass(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.transparent
                                    : AppColors.glassBorder(context),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _monthsShort[i],
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? Colors.white
                                    : AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Filter chips ───

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (type, label, emoji) = _filters[i];
          final selected = _filterType == type;
          return GestureDetector(
            onTap: () => setState(() {
              _filterType = type;
              _navDirection = 0;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : AppColors.glass(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.glassBorder(context),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Calendar grid ───

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun = 0
    final today = _todayMidnight();
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          children: List.generate(_weekDays.length, (i) {
            final isWeekend = i == 0 || i == 6;
            return Expanded(
              child: Center(
                child: Text(
                  _weekDays[i],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isWeekend
                        ? AppColors.starGold
                        : AppColors.textSecondary(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        ...List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                if (cellIndex < startWeekday ||
                    cellIndex >= startWeekday + daysInMonth) {
                  return const Expanded(child: SizedBox(height: 60));
                }
                final day = cellIndex - startWeekday + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final isToday = date.isAtSameMomentAs(today);
                final isSelected = _selectedDate != null &&
                    date.year == _selectedDate!.year &&
                    date.month == _selectedDate!.month &&
                    date.day == _selectedDate!.day;
                final isPast = date.isBefore(today);
                final dayEvents = getEventsForDate(_filteredEvents, date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    behavior: HitTestBehavior.opaque,
                    child: _CalendarCell(
                      day: day,
                      isToday: isToday,
                      isSelected: isSelected,
                      isPast: isPast,
                      events: dayEvents,
                      isDark: _isDark,
                      eventEmoji: _eventEmoji,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  // ─── Stats row ───

  Widget _buildStatsRow() {
    final stats = _monthStats;
    final total = stats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final monthShort = _monthsShort[_currentMonth.month - 1];
    final chips = <Widget>[
      _statChip(
        '$monthShort: $total Event${total == 1 ? '' : 's'}',
        '📅',
        AppColors.accentBlue,
      ),
      if ((stats['launch'] ?? 0) > 0)
        _statChip(
          '${stats['launch']} Launch${stats['launch']! == 1 ? '' : 'es'}',
          '🚀',
          AppColors.accentBlue,
        ),
      if ((stats['moon'] ?? 0) > 0)
        _statChip(
          '${stats['moon']} Moon Phase${stats['moon']! == 1 ? '' : 's'}',
          '🌙',
          const Color(0xFFC0C0C0),
        ),
      if ((stats['eclipse'] ?? 0) > 0)
        _statChip(
          '${stats['eclipse']} Eclipse${stats['eclipse']! == 1 ? '' : 's'}',
          '🌑',
          AppColors.starGold,
        ),
      if ((stats['meteor'] ?? 0) > 0)
        _statChip(
          '${stats['meteor']} Meteor${stats['meteor']! == 1 ? '' : 's'}',
          '☄️',
          AppColors.accentOrange,
        ),
      if ((stats['planet'] ?? 0) > 0)
        _statChip(
          '${stats['planet']} Planet${stats['planet']! == 1 ? '' : 's'}',
          '🪐',
          const Color(0xFF4A90D9),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => chips[i],
        ),
      ),
    );
  }

  Widget _statChip(String label, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Selected day header ───

  Widget _buildSelectedDayHeader() {
    if (_selectedDate == null) {
      final next = _nextUpcomingEvent;
      if (next == null) return const SizedBox.shrink();
      return Text(
        'Next: ${_monthsShort[next.date.month - 1]} ${next.date.day}',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      );
    }

    final d = _selectedDate!;
    final dateStr = '${_months[d.month - 1]} ${d.day}, ${d.year}';
    final dayName = _weekDayNames[d.weekday - 1];
    final eventCount = _selectedDayEvents.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient
                    .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                blendMode: BlendMode.srcIn,
                child: Text(
                  dateStr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Text(
                dayName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        if (eventCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$eventCount event${eventCount == 1 ? '' : 's'}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Events list / empty state ───

  Widget _buildEventsList() {
    final events = _selectedDayEvents;

    if (events.isEmpty && _selectedDate != null) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    if (events.isEmpty) {
      final next = _nextUpcomingEvent;
      if (next == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverToBoxAdapter(child: _buildEventCard(next, 0));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(events[index], index),
        ),
        childCount: events.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    final upcoming = _next3Upcoming;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.glass(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder(context)),
              boxShadow: AppColors.cardShadow(context),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(painter: _StarfieldPainter(isDark: _isDark)),
                  ),
                ),
                Column(
                  children: [
                    const Text('🌌', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 10),
                    Text(
                      'No cosmic events today',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check upcoming dates →',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NEXT UP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...upcoming.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildUpcomingChip(e),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingChip(CalendarEvent e) {
    final dateStr = '${_monthsShort[e.date.month - 1]} ${e.date.day}';
    return GestureDetector(
      onTap: () => _jumpTo(e.date.year, e.date.month, day: e.date.day),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: e.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Text(_eventEmoji(e.type), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: e.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event, int index) {
    final today = _todayMidnight();
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = eventDate.difference(today).inDays;
    final isPast = diff < 0;
    final isToday = diff == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: event.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.color.withValues(alpha: _isDark ? 0.20 : 0.12),
                          border: Border.all(color: event.color.withValues(alpha: 0.40)),
                        ),
                        child: Center(
                          child: Text(_eventEmoji(event.type), style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: event.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _typeLabel(event.type).toUpperCase(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: event.color,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'TODAY',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  )
                                else if (isPast)
                                  Text(
                                    'Passed',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isPast
                                    ? AppColors.textSecondary(context)
                                    : AppColors.textPrimary(context),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                                height: 1.4,
                              ),
                            ),
                            if (!isPast) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _addToCalendar(event),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        event.color.withValues(alpha: 0.20),
                                        event.color.withValues(alpha: 0.10),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: event.color.withValues(alpha: 0.40)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.bell_fill, size: 12, color: event.color),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Add reminder',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: event.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: 350.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  void _addToCalendar(CalendarEvent event) {
    final start = event.date.toIso8601String().replaceAll('-', '').split('T')[0];
    final uri = Uri.parse(
        '${ApiEndpoints.googleCalRender}?action=TEMPLATE'
        '&text=${Uri.encodeComponent(event.name)}'
        '&dates=$start/$start'
        '&details=${Uri.encodeComponent(event.description)}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ─── Type helpers ───

  String _eventEmoji(String type) {
    switch (type) {
      case 'launch':
        return '🚀';
      case 'eclipse':
        return '🌑';
      case 'meteor':
        return '☄️';
      case 'planet':
        return '🪐';
      case 'moon':
        return '🌙';
      case 'iss':
        return '🛰';
      default:
        return '✨';
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'launch':
        return 'Launch';
      case 'eclipse':
        return 'Eclipse';
      case 'meteor':
        return 'Meteor';
      case 'planet':
        return 'Planet';
      case 'moon':
        return 'Moon';
      case 'iss':
        return 'ISS';
      default:
        return 'Event';
    }
  }

  List<Color> _gradientForType(String type) {
    switch (type) {
      case 'launch':
        return const [Color(0xFF0D2A4F), Color(0xFF00B4D8)];
      case 'eclipse':
        return const [Color(0xFFE07A1A), Color(0xFF8B1A0E)];
      case 'meteor':
        return const [Color(0xFF4A1E6E), Color(0xFFC2185B)];
      case 'planet':
        return const [Color(0xFF0F1B5E), Color(0xFF1A47A0)];
      case 'moon':
        return const [Color(0xFF5C5C70), Color(0xFFCD9038)];
      case 'iss':
        return const [Color(0xFF0D2A4F), Color(0xFF00B4D8)];
      default:
        return const [Color(0xFF1A1F3D), Color(0xFF6C63FF)];
    }
  }
}

// ═════════════════════════════════════════════
// CALENDAR CELL
// ═════════════════════════════════════════════

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isPast;
  final List<CalendarEvent> events;
  final bool isDark;
  final String Function(String) eventEmoji;

  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isPast,
    required this.events,
    required this.isDark,
    required this.eventEmoji,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) return _wrapSelected(context);
    if (isToday) return _wrapToday(context);
    return _wrapPlain(context);
  }

  Widget _wrapSelected(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 60,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: _content(context, dateColor: Colors.white, indicatorOnSolid: true),
    );
  }

  Widget _wrapToday(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(13),
        ),
        child: _content(
          context,
          dateColor: AppColors.textPrimary(context),
          gradientText: true,
        ),
      ),
    );
  }

  Widget _wrapPlain(BuildContext context) {
    final hasEvents = events.isNotEmpty;
    final primary = hasEvents ? events.first.color : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 60,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: hasEvents
            ? primary!.withValues(alpha: isDark ? 0.10 : 0.07)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: hasEvents
            ? Border.all(color: primary!.withValues(alpha: 0.25))
            : null,
      ),
      child: _content(
        context,
        dateColor: isPast
            ? AppColors.textSecondary(context).withValues(alpha: 0.55)
            : AppColors.textPrimary(context),
      ),
    );
  }

  Widget _content(
    BuildContext context, {
    required Color dateColor,
    bool gradientText = false,
    bool indicatorOnSolid = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gradientText)
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Colors.white, Color(0xFF00B4D8)],
            ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
            blendMode: BlendMode.srcIn,
            child: Text(
              '$day',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          )
        else
          Text(
            '$day',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
              color: dateColor,
            ),
          ),
        if (events.isNotEmpty) ...[
          const SizedBox(height: 2),
          _indicators(context, indicatorOnSolid),
        ],
      ],
    );
  }

  Widget _indicators(BuildContext context, bool onSolid) {
    final seen = <String>{};
    final uniqueTypes = <String>[];
    for (final e in events) {
      if (seen.add(e.type)) uniqueTypes.add(e.type);
    }
    final visible = uniqueTypes.take(2).toList();
    final extra = uniqueTypes.length - visible.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visible.map(
          (t) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(eventEmoji(t), style: const TextStyle(fontSize: 11)),
          ),
        ),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              '+$extra',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: onSolid ? Colors.white : AppColors.textSecondary(context),
              ),
            ),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// NAV ARROW
// ═════════════════════════════════════════════

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      onPressed: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glass(context),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary(context)),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STARFIELD PAINTER (one-shot, no animation)
// ═════════════════════════════════════════════

class _StarfieldPainter extends CustomPainter {
  final bool isDark;
  _StarfieldPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.4;
      final paint = Paint()
        ..color = (isDark ? Colors.white : const Color(0xFF6B6BB5))
            .withValues(alpha: 0.20 + rng.nextDouble() * 0.45);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => old.isDark != isDark;
}
