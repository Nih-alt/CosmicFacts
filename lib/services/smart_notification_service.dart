import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_service.dart';
import 'notification_service.dart';

class SmartNotificationService {
  static Future<void> checkAndSchedule() async {
    try {
      final settingsBox = Hive.box('settings');
      final notificationsEnabled =
          settingsBox.get('notifications_enabled', defaultValue: false);
      if (!notificationsEnabled) return;

      // Only check once every 6 hours
      final lastCheck = settingsBox.get('last_smart_check', defaultValue: 0);
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheck < 6 * 60 * 60 * 1000) return;
      settingsBox.put('last_smart_check', now);

      debugPrint('=== Smart Notifications: Checking ===');

      await _checkUpcomingLaunches();
      await _checkHazardousAsteroids();
      await _checkSpaceEvents();
      await _checkQuizStreak();

      debugPrint('=== Smart Notifications: Done ===');
    } catch (e) {
      debugPrint('Smart notification error: $e');
    }
  }

  // CHECK 1 — Upcoming launches within 24 hours
  static Future<void> _checkUpcomingLaunches() async {
    try {
      final now = DateTime.now();
      final launches = _getHardcodedLaunches();

      for (final launch in launches) {
        final diff = launch['date'].difference(now);

        if (diff.inHours > 0 && diff.inHours <= 24) {
          // Launch within 24 hours — schedule 1 hour before
          final notifyTime =
              (launch['date'] as DateTime).subtract(const Duration(hours: 1));
          if (notifyTime.isAfter(now)) {
            await _scheduleNotification(
              id: 100 + launches.indexOf(launch),
              title: '\u{1F680} Launch in 1 hour!',
              body:
                  '${launch['rocket']} \u2014 ${launch['mission']} launching from ${launch['location']}',
              scheduledTime: notifyTime,
            );
          }

          // Also 15 min before
          final notifyTime15 = (launch['date'] as DateTime)
              .subtract(const Duration(minutes: 15));
          if (notifyTime15.isAfter(now)) {
            await _scheduleNotification(
              id: 150 + launches.indexOf(launch),
              title: '\u{1F680} Launching in 15 minutes!',
              body: '${launch['rocket']} is about to lift off! Watch live!',
              scheduledTime: notifyTime15,
            );
          }
        }

        // Launch tomorrow — schedule morning reminder
        if (diff.inHours > 12 && diff.inHours <= 36) {
          final tomorrowMorning =
              DateTime(now.year, now.month, now.day + 1, 8, 0);
          if (tomorrowMorning.isAfter(now)) {
            await _scheduleNotification(
              id: 200 + launches.indexOf(launch),
              title: '\u{1F680} Launch tomorrow!',
              body:
                  '${launch['rocket']} \u2014 ${launch['mission']} launches tomorrow. Don\'t miss it!',
              scheduledTime: tomorrowMorning,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Launch notification error: $e');
    }
  }

  // CHECK 2 — Hazardous asteroids today
  static Future<void> _checkHazardousAsteroids() async {
    try {
      final asteroids = await ApiService.getNearEarthAsteroids();

      int hazardousCount = 0;
      String closestName = '';

      for (final asteroid in asteroids) {
        if (asteroid['is_potentially_hazardous_asteroid'] == true) {
          hazardousCount++;
          if (closestName.isEmpty) {
            closestName = asteroid['name']
                    ?.toString()
                    .replaceAll(RegExp(r'[()]'), '') ??
                'Unknown';
          }
        }
      }

      if (hazardousCount > 0) {
        await _scheduleNotification(
          id: 300,
          title: '\u2604\uFE0F Hazardous asteroid alert!',
          body:
              '$hazardousCount potentially hazardous asteroid${hazardousCount > 1 ? 's' : ''} passing near Earth today! Closest: $closestName',
          scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
        );
      }
    } catch (e) {
      debugPrint('Asteroid notification error: $e');
    }
  }

  // CHECK 3 — Space events today or tomorrow
  static Future<void> _checkSpaceEvents() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final events = _getSpaceEvents2026();

      for (final event in events) {
        final eventDate = DateTime(
            event['date'].year, event['date'].month, event['date'].day);

        if (eventDate == today) {
          await _scheduleNotification(
            id: 400 + events.indexOf(event),
            title: '\u{1F30C} Space event TODAY!',
            body: '${event['name']} \u2014 ${event['description']}',
            scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
          );
        } else if (eventDate == tomorrow) {
          final eveningTime =
              DateTime(now.year, now.month, now.day, 19, 0);
          if (eveningTime.isAfter(now)) {
            await _scheduleNotification(
              id: 450 + events.indexOf(event),
              title: '\u{1F30C} Space event TOMORROW!',
              body:
                  '${event['name']} \u2014 ${event['description']}. Don\'t miss it!',
              scheduledTime: eveningTime,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Event notification error: $e');
    }
  }

  // CHECK 4 — Quiz streak about to break
  static Future<void> _checkQuizStreak() async {
    try {
      final quizBox = Hive.box('quiz_stats');
      final lastQuizDate = quizBox.get('lastQuizDate', defaultValue: '');
      final currentStreak = quizBox.get('currentStreak', defaultValue: 0);

      if (currentStreak > 0 && lastQuizDate.isNotEmpty) {
        final lastDate = DateTime.tryParse(lastQuizDate);
        if (lastDate != null) {
          final daysSince = DateTime.now().difference(lastDate).inDays;

          // If haven't played today and streak > 2
          if (daysSince >= 1 && currentStreak >= 2) {
            final eveningTime = DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day, 20, 0);
            if (eveningTime.isAfter(DateTime.now())) {
              await _scheduleNotification(
                id: 500,
                title:
                    '\u{1F525} Your $currentStreak-day streak is at risk!',
                body:
                    'Complete today\'s Daily Challenge to keep your streak alive!',
                scheduledTime: eveningTime,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Quiz streak notification error: $e');
    }
  }

  // HELPER — Schedule a local notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) return;

      await NotificationService.scheduleCustomNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
      );

      debugPrint('Scheduled notification #$id: "$title" at $scheduledTime');
    } catch (e) {
      debugPrint('Failed to schedule notification #$id: $e');
    }
  }

  // Hardcoded 2026 launches for notification check
  static List<Map<String, dynamic>> _getHardcodedLaunches() {
    return [
      {
        'rocket': 'Falcon Heavy',
        'mission': 'GOES-U',
        'location': 'Kennedy Space Center',
        'date': DateTime(2026, 3, 26, 11, 19)
      },
      {
        'rocket': 'GSLV Mk III',
        'mission': 'Gaganyaan Uncrewed',
        'location': 'Sriharikota',
        'date': DateTime(2026, 4, 2, 10, 0)
      },
      {
        'rocket': 'New Glenn',
        'mission': 'Blue Ring',
        'location': 'Cape Canaveral',
        'date': DateTime(2026, 4, 7, 14, 0)
      },
      {
        'rocket': 'Ariane 6',
        'mission': 'Galileo L13',
        'location': 'Kourou',
        'date': DateTime(2026, 4, 17, 9, 0)
      },
      {
        'rocket': 'SLS',
        'mission': 'Artemis III',
        'location': 'Kennedy Space Center',
        'date': DateTime(2026, 5, 2, 12, 0)
      },
      {
        'rocket': 'Falcon 9',
        'mission': 'Starlink Group 16',
        'location': 'Vandenberg SFB',
        'date': DateTime(2026, 5, 15, 8, 30)
      },
      {
        'rocket': 'PSLV',
        'mission': 'Aditya-L1 Follow-up',
        'location': 'Sriharikota',
        'date': DateTime(2026, 6, 10, 5, 0)
      },
      {
        'rocket': 'Starship',
        'mission': 'Orbital Test 5',
        'location': 'Boca Chica',
        'date': DateTime(2026, 7, 1, 13, 0)
      },
      {
        'rocket': 'GSLV Mk III',
        'mission': 'Chandrayaan-4',
        'location': 'Sriharikota',
        'date': DateTime(2026, 8, 15, 6, 0)
      },
      {
        'rocket': 'Falcon Heavy',
        'mission': 'Europa Clipper Follow-up',
        'location': 'Kennedy Space Center',
        'date': DateTime(2026, 10, 20, 16, 0)
      },
    ];
  }

  // Hardcoded 2026 space events for notification check
  static List<Map<String, dynamic>> _getSpaceEvents2026() {
    return [
      {
        'name': 'Total Lunar Eclipse',
        'description': 'Visible from Americas, Europe, Africa',
        'date': DateTime(2026, 3, 29)
      },
      {
        'name': 'Lyrids Meteor Shower Peak',
        'description': 'Up to 20 meteors per hour',
        'date': DateTime(2026, 4, 22)
      },
      {
        'name': 'Eta Aquariids Peak',
        'description': 'Up to 50 meteors per hour',
        'date': DateTime(2026, 5, 6)
      },
      {
        'name': 'Summer Solstice',
        'description': 'Longest day of the year',
        'date': DateTime(2026, 6, 21)
      },
      {
        'name': 'Perseids Meteor Shower',
        'description': 'Up to 100 meteors per hour \u2014 best shower!',
        'date': DateTime(2026, 8, 12)
      },
      {
        'name': 'Annular Solar Eclipse',
        'description': 'Visible from Arctic, Europe, Asia',
        'date': DateTime(2026, 8, 12)
      },
      {
        'name': 'Autumn Equinox',
        'description': 'Day and night equal length',
        'date': DateTime(2026, 9, 22)
      },
      {
        'name': 'Orionids Meteor Shower',
        'description': 'Debris from Halley\'s Comet',
        'date': DateTime(2026, 10, 21)
      },
      {
        'name': 'Leonids Meteor Shower',
        'description': 'Up to 15 meteors per hour',
        'date': DateTime(2026, 11, 17)
      },
      {
        'name': 'Geminids Meteor Shower',
        'description': 'Best shower \u2014 up to 150 per hour!',
        'date': DateTime(2026, 12, 13)
      },
      {
        'name': 'Winter Solstice',
        'description': 'Shortest day of the year',
        'date': DateTime(2026, 12, 21)
      },
    ];
  }
}
