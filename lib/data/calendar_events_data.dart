import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CalendarEvent {
  final DateTime date;
  final String name;
  final String description;
  final String type; // 'launch', 'eclipse', 'meteor', 'planet', 'moon', 'iss'
  final Color color;

  const CalendarEvent({
    required this.date,
    required this.name,
    required this.description,
    required this.type,
    required this.color,
  });
}

List<CalendarEvent> getAllCalendarEvents() {
  return [
    // ═══════════════════════════════════════
    // FULL MOONS 2026
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 1, 13),
        name: 'Full Moon',
        description: 'Wolf Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 2, 12),
        name: 'Full Moon',
        description: 'Snow Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 3, 14),
        name: 'Full Moon',
        description: 'Worm Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 4, 12),
        name: 'Full Moon',
        description: 'Pink Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 5, 11),
        name: 'Full Moon',
        description: 'Flower Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 6, 10),
        name: 'Full Moon',
        description: 'Strawberry Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 7, 10),
        name: 'Full Moon',
        description: 'Buck Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 8, 8),
        name: 'Full Moon',
        description: 'Sturgeon Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 9, 7),
        name: 'Full Moon',
        description: 'Harvest Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 10, 6),
        name: 'Full Moon',
        description: "Hunter's Moon",
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 11, 5),
        name: 'Full Moon',
        description: 'Beaver Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),
    CalendarEvent(
        date: DateTime(2026, 12, 4),
        name: 'Full Moon',
        description: 'Cold Moon',
        type: 'moon',
        color: const Color(0xFFC0C0C0)),

    // ═══════════════════════════════════════
    // NEW MOONS 2026
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 1, 29),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 2, 27),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 3, 29),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 4, 27),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 5, 26),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 6, 25),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 7, 24),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 8, 23),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 9, 21),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 10, 21),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 11, 19),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),
    CalendarEvent(
        date: DateTime(2026, 12, 19),
        name: 'New Moon',
        description: 'Best time for stargazing',
        type: 'moon',
        color: const Color(0xFF888888)),

    // ═══════════════════════════════════════
    // ECLIPSES 2026
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 3, 29),
        name: 'Total Lunar Eclipse',
        description: 'Visible from Americas, Europe, Africa',
        type: 'eclipse',
        color: AppColors.starGold),
    CalendarEvent(
        date: DateTime(2026, 8, 12),
        name: 'Annular Solar Eclipse',
        description: 'Visible from Arctic, Greenland, Europe, Asia',
        type: 'eclipse',
        color: AppColors.starGold),
    CalendarEvent(
        date: DateTime(2026, 9, 7),
        name: 'Partial Lunar Eclipse',
        description: 'Visible from Europe, Africa, Asia, Australia',
        type: 'eclipse',
        color: AppColors.starGold),

    // ═══════════════════════════════════════
    // METEOR SHOWERS 2026
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 1, 3),
        name: 'Quadrantids Peak',
        description: 'Up to 120 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 1, 4),
        name: 'Quadrantids Peak',
        description: 'Up to 120 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 4, 22),
        name: 'Lyrids Peak',
        description: 'Up to 20 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 4, 23),
        name: 'Lyrids Peak',
        description: 'Up to 20 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 5, 6),
        name: 'Eta Aquariids Peak',
        description: 'Up to 50 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 5, 7),
        name: 'Eta Aquariids Peak',
        description: 'Up to 50 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 7, 28),
        name: 'Delta Aquariids Peak',
        description: 'Up to 25 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 7, 29),
        name: 'Delta Aquariids Peak',
        description: 'Up to 25 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 8, 12),
        name: 'Perseids Peak',
        description: 'Up to 100 meteors per hour \u2014 best shower of the year',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 8, 13),
        name: 'Perseids Peak',
        description: 'Up to 100 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 10, 21),
        name: 'Orionids Peak',
        description: "Up to 20 meteors per hour \u2014 debris from Halley's Comet",
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 10, 22),
        name: 'Orionids Peak',
        description: 'Up to 20 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 11, 17),
        name: 'Leonids Peak',
        description: 'Up to 15 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 11, 18),
        name: 'Leonids Peak',
        description: 'Up to 15 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 12, 13),
        name: 'Geminids Peak',
        description: 'Up to 150 meteors per hour \u2014 best shower of the year',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 12, 14),
        name: 'Geminids Peak',
        description: 'Up to 150 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 12, 21),
        name: 'Ursids Peak',
        description: 'Up to 10 meteors per hour',
        type: 'meteor',
        color: AppColors.accentOrange),
    CalendarEvent(
        date: DateTime(2026, 12, 22),
        name: 'Ursids Peak',
        description: 'Up to 10 meteors per hour (second night)',
        type: 'meteor',
        color: AppColors.accentOrange),

    // ═══════════════════════════════════════
    // PLANET EVENTS & SOLSTICES/EQUINOXES
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 3, 1),
        name: 'Venus at Greatest Elongation',
        description: 'Best time to view Venus in the evening sky',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 3, 20),
        name: 'Spring Equinox',
        description: 'Day and night are equal length \u2014 start of spring',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 5, 1),
        name: 'Mercury at Greatest Elongation',
        description: 'Best time to view Mercury in morning sky',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 6, 21),
        name: 'Summer Solstice',
        description: 'Longest day of the year in Northern Hemisphere',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 9, 22),
        name: 'Autumn Equinox',
        description: 'Day and night are equal length',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 12, 21),
        name: 'Winter Solstice',
        description: 'Shortest day of the year in Northern Hemisphere',
        type: 'planet',
        color: const Color(0xFF4A90D9)),
    CalendarEvent(
        date: DateTime(2026, 12, 26),
        name: 'Mercury at Greatest Elongation',
        description: 'Visible in evening sky',
        type: 'planet',
        color: const Color(0xFF4A90D9)),

    // ═══════════════════════════════════════
    // LAUNCHES (sample from hardcoded data)
    // ═══════════════════════════════════════
    CalendarEvent(
        date: DateTime(2026, 4, 15),
        name: 'Falcon 9 \u2022 Starlink',
        description: 'Starlink Group 15-1 \u2022 SpaceX',
        type: 'launch',
        color: AppColors.accentBlue),
    CalendarEvent(
        date: DateTime(2026, 5, 20),
        name: 'GSLV Mk III \u2022 Gaganyaan',
        description: 'Gaganyaan Uncrewed \u2022 ISRO',
        type: 'launch',
        color: AppColors.accentBlue),
    CalendarEvent(
        date: DateTime(2026, 6, 5),
        name: 'Ariane 6 \u2022 Galileo L13',
        description: 'Navigation satellite \u2022 ESA',
        type: 'launch',
        color: AppColors.accentBlue),
    CalendarEvent(
        date: DateTime(2026, 7, 15),
        name: 'SLS \u2022 Artemis III',
        description: 'Lunar landing mission \u2022 NASA',
        type: 'launch',
        color: AppColors.accentBlue),
    CalendarEvent(
        date: DateTime(2026, 9, 1),
        name: 'Starship \u2022 Mars Cargo Test',
        description: 'Mars cargo test flight \u2022 SpaceX',
        type: 'launch',
        color: AppColors.accentBlue),
    CalendarEvent(
        date: DateTime(2026, 10, 10),
        name: 'PSLV \u2022 Aditya-L2',
        description: 'Solar observation mission \u2022 ISRO',
        type: 'launch',
        color: AppColors.accentBlue),
  ];
}

/// Get events for a specific date.
List<CalendarEvent> getEventsForDate(
    List<CalendarEvent> allEvents, DateTime date) {
  return allEvents
      .where((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day)
      .toList();
}

/// Get unique event type colors for a date (for dot indicators).
List<Color> getEventDotsForDate(
    List<CalendarEvent> allEvents, DateTime date) {
  final events = getEventsForDate(allEvents, date);
  final seen = <String>{};
  final dots = <Color>[];
  for (final e in events) {
    if (seen.add(e.type)) dots.add(e.color);
  }
  return dots;
}
