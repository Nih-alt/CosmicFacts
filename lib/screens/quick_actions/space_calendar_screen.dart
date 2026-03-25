import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _allEvents = getAllCalendarEvents();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  List<CalendarEvent> get _selectedDayEvents {
    if (_selectedDate == null) return [];
    return getEventsForDate(_allEvents, _selectedDate!);
  }

  // Find next upcoming event from today if no events today
  CalendarEvent? get _nextUpcomingEvent {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    CalendarEvent? next;
    for (final e in _allEvents) {
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      if (eDate.isAfter(todayNorm) || eDate.isAtSameMomentAs(todayNorm)) {
        if (next == null ||
            e.date.isBefore(next.date)) {
          next = e;
        }
      }
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Month navigation
                  SliverToBoxAdapter(child: _buildMonthNav()),

                  // Calendar grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCalendarGrid(),
                    ),
                  ),

                  // Legend
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _buildLegend(),
                    ),
                  ),

                  // Selected day events
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
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context)),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Space Calendar',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Never miss a cosmic event',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _goToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Today',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // MONTH NAVIGATION
  // ═══════════════════════════════════════

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _prevMonth,
            child: Icon(CupertinoIcons.chevron_left,
                size: 22, color: AppColors.textPrimary(context)),
          ),
          Text(
            '${_months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _nextMonth,
            child: Icon(CupertinoIcons.chevron_right,
                size: 22, color: AppColors.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // CALENDAR GRID
  // ═══════════════════════════════════════

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Day headers
        Row(
          children: _weekDays.map((d) {
            return Expanded(
              child: Center(
                child: Text(d,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        // Date cells
        ...List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              if (cellIndex < startWeekday || cellIndex >= startWeekday + daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }
              final day = cellIndex - startWeekday + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isToday = date.isAtSameMomentAs(today);
              final isSelected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final isPast = date.isBefore(today);
              final dots = getEventDotsForDate(_allEvents, date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday && !isSelected
                          ? AppColors.accentPurple
                          : isSelected
                              ? AppColors.accentPurple.withValues(alpha: 0.2)
                              : Colors.transparent,
                      border: isSelected && !isToday
                          ? Border.all(color: AppColors.accentPurple)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? Colors.white
                                : isPast
                                    ? AppColors.textSecondary(context)
                                        .withValues(alpha: 0.5)
                                    : AppColors.textPrimary(context),
                          ),
                        ),
                        if (dots.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: dots.take(3).map((c) {
                                return Container(
                                  width: 5,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════
  // LEGEND
  // ═══════════════════════════════════════

  Widget _buildLegend() {
    const items = [
      (AppColors.accentPurple, 'Launch'),
      (AppColors.starGold, 'Eclipse'),
      (AppColors.accentOrange, 'Meteor'),
      (Color(0xFF4A90D9), 'Planet'),
      (Color(0xFFC0C0C0), 'Moon'),
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.$1,
              ),
            ),
            const SizedBox(width: 4),
            Text(item.$2,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary(context))),
          ],
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════
  // SELECTED DAY HEADER
  // ═══════════════════════════════════════

  Widget _buildSelectedDayHeader() {
    if (_selectedDate == null) {
      // Show next upcoming event label
      final next = _nextUpcomingEvent;
      if (next == null) {
        return Text('No upcoming events',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context)));
      }
      return Text(
        'Next: ${_months[next.date.month - 1]} ${next.date.day}',
        style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context)),
      );
    }

    final d = _selectedDate!;
    return Text(
      '${_months[d.month - 1]} ${d.day}, ${d.year}',
      style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context)),
    );
  }

  // ═══════════════════════════════════════
  // EVENTS LIST
  // ═══════════════════════════════════════

  Widget _buildEventsList() {
    final events = _selectedDayEvents;

    if (events.isEmpty && _selectedDate != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Column(
              children: [
                Icon(CupertinoIcons.calendar,
                    size: 36, color: AppColors.textSecondary(context)),
                const SizedBox(height: 10),
                Text('No events on this date',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ),
      );
    }

    // If no date selected, show next upcoming event
    if (events.isEmpty) {
      final next = _nextUpcomingEvent;
      if (next == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverToBoxAdapter(
        child: _buildEventCard(next, 0),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildEventCard(events[index], index),
          );
        },
        childCount: events.length,
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event, int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = eventDate.difference(today).inDays;
    final isPast = diff < 0;
    final isToday = diff == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF141438) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppColors.error.withValues(alpha: 0.4)
              : (_isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFEEECF5)),
        ),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Row(
        children: [
          // Color circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: event.color.withValues(alpha: _isDark ? 0.2 : 0.12),
            ),
            child: Center(
              child: Text(
                _eventEmoji(event.type),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isPast
                        ? AppColors.textSecondary(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  event.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status + Add to calendar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _typeLabel(event.type),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: event.color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (isToday)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Today!',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                )
              else if (isPast)
                Text('Passed',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary(context)))
              else ...[
                GestureDetector(
                  onTap: () => _addToCalendar(event),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 10, color: AppColors.accentPurple),
                        const SizedBox(width: 4),
                        Text('Add',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentPurple)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 350.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  void _addToCalendar(CalendarEvent event) {
    // Use Google Calendar intent URL
    final start = event.date.toIso8601String().replaceAll('-', '').split('T')[0];
    final uri = Uri.parse(
        'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(event.name)}'
        '&dates=$start/$start'
        '&details=${Uri.encodeComponent(event.description)}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _eventEmoji(String type) {
    switch (type) {
      case 'launch':
        return '\u{1F680}';
      case 'eclipse':
        return '\u{1F311}';
      case 'meteor':
        return '\u{1F320}';
      case 'planet':
        return '\u{1FA90}';
      case 'moon':
        return '\u{1F315}';
      case 'iss':
        return '\u{1F6F0}\uFE0F';
      default:
        return '\u2728';
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
}
