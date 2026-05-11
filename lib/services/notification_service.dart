import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../data/space_facts.dart';
import 'api_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    // Resolve user's local timezone. Without this, tz.local defaults to UTC
    // and "8 AM" scheduling fires at 8 AM UTC (1:30 PM IST).
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Local timezone detection failed: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleTap,
    );
  }

  /// Persist the tap intent to Hive. The home screen reads
  /// `pending_notification_route` on its next build and routes accordingly —
  /// keeps this service free of UI/widget imports.
  static void _handleTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final box = Hive.box('settings');
      box.put('pending_notification_route', payload);
    } catch (e) {
      debugPrint('Failed to persist notification payload: $e');
    }
  }

  /// Request Android 13+ POST_NOTIFICATIONS permission.
  /// Called only after onboarding so the OS dialog doesn't appear on first launch.
  static Future<bool?> requestPermission() async {
    return _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule daily fact notification at 8 AM local time.
  ///
  /// The body is fixed at scheduling time — `matchDateTimeComponents.time`
  /// repeats the same payload daily until cancelled, so the home screen
  /// reschedules this on each app open to rotate to the next day's fact.
  static Future<void> scheduleDailyFact() async {
    final fact = kSpaceFacts[_dayOfYear() % kSpaceFacts.length];
    final body = '${fact.emoji} ${fact.text}';
    await _plugin.zonedSchedule(
      0,
      '\u{1F30C} Daily Space Fact',
      body,
      _nextInstanceOfTime(8, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_fact',
          'Daily Space Facts',
          channelDescription: 'Get a fascinating space fact every morning',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'fact',
    );
  }

  /// Schedule APOD notification at 7 AM local time, with the actual photo
  /// title pulled from the live API (or cached fallback).
  static Future<void> scheduleApodReminder() async {
    String body =
        "Today's daily astronomy photo is ready. Tap to explore.";
    try {
      final apod = await ApiService.getApodWithFallback();
      if (apod != null && apod.title.isNotEmpty) {
        body = "${apod.title}\n\nTap to view today's photo.";
      }
    } catch (e) {
      debugPrint('APOD title fetch failed (using generic body): $e');
    }

    await _plugin.zonedSchedule(
      1,
      '\u{1F52D} New Astronomy Photo!',
      body,
      _nextInstanceOfTime(7, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'apod_reminder',
          'APOD Reminders',
          channelDescription: 'Daily astronomy picture alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'apod',
    );
  }

  /// Schedule quiz streak reminder at 8 PM.
  static Future<void> scheduleQuizReminder() async {
    await _plugin.zonedSchedule(
      2,
      "\u{1F9E0} Don't break your streak!",
      "Complete today's Daily Challenge to keep your streak alive! \u{1F525}",
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quiz_reminder',
          'Quiz Reminders',
          channelDescription: 'Daily quiz streak reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule all enabled notifications based on saved preferences.
  static Future<void> scheduleFromPrefs() async {
    final settings = Hive.box('settings');
    final enabled =
        settings.get('notifications_enabled', defaultValue: false) == true;
    if (!enabled) return;

    final dailyFact =
        settings.get('notif_daily_fact', defaultValue: true) == true;
    final apod = settings.get('notif_apod', defaultValue: true) == true;
    final quiz = settings.get('notif_quiz', defaultValue: true) == true;

    if (dailyFact) await scheduleDailyFact();
    if (apod) await scheduleApodReminder();
    if (quiz) await scheduleQuizReminder();
  }

  /// Schedule a custom notification at a specific time (used by SmartNotificationService).
  static Future<void> scheduleCustomNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'smart_alerts',
            'Smart Alerts',
            channelDescription:
                'Launch alerts, asteroid warnings, event reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancelById(int id) async {
    await _plugin.cancel(id);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static int _dayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
  }
}
