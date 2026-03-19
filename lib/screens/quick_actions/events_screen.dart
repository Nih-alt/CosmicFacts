import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ═══════════════════════════════════════════
// EVENT MODEL
// ═══════════════════════════════════════════

enum EventType { launch, eclipse, meteorShower, planet, supermoon, issPass, event }

class SpaceEvent {
  final DateTime date;
  final String name;
  final EventType type;
  final String description;

  const SpaceEvent({
    required this.date,
    required this.name,
    required this.type,
    required this.description,
  });

  Color get color {
    switch (type) {
      case EventType.launch:
        return AppColors.accentCyan;
      case EventType.eclipse:
        return AppColors.starGold;
      case EventType.meteorShower:
        return AppColors.accentOrange;
      case EventType.planet:
        return AppColors.accentPurple;
      case EventType.supermoon:
        return const Color(0xFFC0C0C0);
      case EventType.issPass:
        return AppColors.success;
      case EventType.event:
        return AppColors.accentPurple;
    }
  }

  String get emoji {
    switch (type) {
      case EventType.launch:
        return '\u{1F680}';
      case EventType.eclipse:
        return '\u{1F311}';
      case EventType.meteorShower:
        return '\u{1F320}';
      case EventType.planet:
        return '\u{1FA90}';
      case EventType.supermoon:
        return '\u{1F315}';
      case EventType.issPass:
        return '\u{1F6F0}';
      case EventType.event:
        return '\u{2728}';
    }
  }

  String get typeLabel {
    switch (type) {
      case EventType.launch:
        return 'Launch';
      case EventType.eclipse:
        return 'Eclipse';
      case EventType.meteorShower:
        return 'Meteor Shower';
      case EventType.planet:
        return 'Planet';
      case EventType.supermoon:
        return 'Supermoon';
      case EventType.issPass:
        return 'ISS Pass';
      case EventType.event:
        return 'Event';
    }
  }
}

final List<SpaceEvent> _allEvents = [
  SpaceEvent(date: DateTime(2026, 3, 29), name: 'Total Lunar Eclipse', type: EventType.eclipse, description: 'Visible from Americas, Europe, Africa'),
  SpaceEvent(date: DateTime(2026, 4, 22), name: 'Lyrids Meteor Shower Peak', type: EventType.meteorShower, description: 'Up to 20 meteors per hour'),
  SpaceEvent(date: DateTime(2026, 5, 1), name: 'Mercury at Greatest Elongation', type: EventType.planet, description: 'Best time to view Mercury'),
  SpaceEvent(date: DateTime(2026, 6, 21), name: 'Summer Solstice', type: EventType.event, description: 'Longest day of the year in Northern Hemisphere'),
  SpaceEvent(date: DateTime(2026, 8, 12), name: 'Perseids Meteor Shower Peak', type: EventType.meteorShower, description: 'Up to 100 meteors per hour, best shower of the year'),
  SpaceEvent(date: DateTime(2026, 8, 12), name: 'Annular Solar Eclipse', type: EventType.eclipse, description: 'Visible from Arctic, Greenland, parts of Europe and Asia'),
  SpaceEvent(date: DateTime(2026, 9, 22), name: 'Autumn Equinox', type: EventType.event, description: 'Day and night are equal length'),
  SpaceEvent(date: DateTime(2026, 10, 21), name: 'Orionids Meteor Shower', type: EventType.meteorShower, description: 'Debris from Halley\'s Comet'),
  SpaceEvent(date: DateTime(2026, 11, 17), name: 'Leonids Meteor Shower', type: EventType.meteorShower, description: 'Up to 15 meteors per hour'),
  SpaceEvent(date: DateTime(2026, 12, 13), name: 'Geminids Meteor Shower', type: EventType.meteorShower, description: 'Best meteor shower of the year, up to 150 per hour'),
  SpaceEvent(date: DateTime(2026, 12, 21), name: 'Winter Solstice', type: EventType.event, description: 'Shortest day of the year in Northern Hemisphere'),
  SpaceEvent(date: DateTime(2026, 12, 26), name: 'Mercury Greatest Elongation', type: EventType.planet, description: 'Visible in evening sky'),
];

// ═══════════════════════════════════════════
// EVENTS SCREEN
// ═══════════════════════════════════════════

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Calendar
  late DateTime _calendarMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  List<SpaceEvent> get _sortedEvents {
    final events = List<SpaceEvent>.from(_allEvents)
      ..sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          // App bar
          SafeArea(
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
                      'Space Events',
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

          // Tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Row(
                children: [
                  _buildTab('Upcoming', 0),
                  _buildTab('Calendar', 1),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0 ? _buildUpcomingTab() : _buildCalendarTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── UPCOMING TAB ──

  Widget _buildUpcomingTab() {
    final events = _sortedEvents;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildEventCard(events[index]),
        ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 50 + index * 40),
        ).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 50 + index * 40),
        );
      },
    );
  }

  Widget _buildEventCard(SpaceEvent event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = eventDate.difference(today).inDays;

    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final isPast = diff < 0;
    final isToday = diff == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.glassBorder(context),
            ),
          ),
          child: Row(
            children: [
              // Date column
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      months[event.date.month - 1],
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: event.color,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${event.date.day}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isPast
                            ? AppColors.textSecondary(context)
                            : AppColors.textPrimary(context),
                      ),
                    ),
                  ],
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
                    const SizedBox(height: 4),
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
              // Right: type badge + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${event.emoji} ${event.typeLabel}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: event.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(isPast, isToday, diff),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPast, bool isToday, int daysAway) {
    if (isPast) {
      return Text(
        'Passed',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary(context),
        ),
      );
    }
    if (isToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Today!',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'In $daysAway days',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accentPurple,
        ),
      ),
    );
  }

  // ── CALENDAR TAB ──

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                      _calendarMonth.year,
                      _calendarMonth.month - 1,
                    );
                    _selectedDate = null;
                  });
                },
                child: Icon(CupertinoIcons.chevron_left, size: 20, color: AppColors.textPrimary(context)),
              ),
              Text(
                _monthYearString(_calendarMonth),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                      _calendarMonth.year,
                      _calendarMonth.month + 1,
                    );
                    _selectedDate = null;
                  });
                },
                child: Icon(CupertinoIcons.chevron_right, size: 20, color: AppColors.textPrimary(context)),
              ),
            ],
          ),
        ),

        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildCalendarGrid(),
        ),

        // Selected date events
        if (_selectedDate != null) ...[
          const SizedBox(height: 12),
          Expanded(child: _buildSelectedDateEvents()),
        ] else
          const Spacer(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    // Monday = 1
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun
    final offset = startWeekday - 1;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: offset + daysInMonth,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();
        final day = index - offset + 1;
        final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
        final eventsOnDay = _allEvents.where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day).toList();
        final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
        final isSelected = _selectedDate != null &&
            date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.accentPurple.withValues(alpha: 0.2)
                  : isToday
                      ? AppColors.accentPurple.withValues(alpha: 0.1)
                      : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4))
                  : isSelected
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
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (eventsOnDay.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: eventsOnDay.take(3).map((e) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 2, left: 1, right: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.color,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateEvents() {
    final events = _allEvents.where((e) =>
        e.date.year == _selectedDate!.year &&
        e.date.month == _selectedDate!.month &&
        e.date.day == _selectedDate!.day).toList();

    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events on this date',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context)),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildEventCard(events[index]),
        );
      },
    );
  }

  String _monthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
