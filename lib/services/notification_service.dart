import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _facts = [
    'The Sun loses 4 million tons of mass every second due to nuclear fusion! \u2600\uFE0F',
    'A day on Venus is longer than a year on Venus! \u{1FA90}',
    'Neutron stars can spin 716 times per second! \u2B50',
    "There are more stars in the universe than grains of sand on all Earth's beaches! \u{1F30C}",
    'The footprints on the Moon will last for 100 million years! \u{1F463}',
    "Saturn's density is so low, it would float in water! \u{1FA90}",
    'A spoonful of neutron star weighs about 6 billion tons! \u2B50',
    'Light from the Sun takes 8 minutes 20 seconds to reach Earth! \u2600\uFE0F',
    'The Milky Way and Andromeda galaxies will collide in about 4.5 billion years! \u{1F30C}',
    'Space is completely silent \u2014 there is no medium for sound to travel! \u{1F507}',
    'One million Earths could fit inside the Sun! \u2600\uFE0F',
    'The International Space Station travels at 27,600 km/h! \u{1F6F0}\uFE0F',
    'Mars has the largest volcano in the solar system \u2014 Olympus Mons! \u{1F30B}',
    'There are more trees on Earth than stars in the Milky Way! \u{1F30D}',
    "Jupiter's Great Red Spot is a storm that has raged for over 400 years! \u{1F534}",
    'Astronauts grow up to 2 inches taller in space! \u{1F468}\u200D\u{1F680}',
    'The observable universe is 93 billion light-years in diameter! \u{1F52D}',
    'A year on Mercury is just 88 Earth days! \u26A1',
    'Pluto is smaller than Russia! \u{1F976}',
    'The largest known star UY Scuti could fit 5 billion Suns inside it! \u2B50',
    "Water ice has been found on the Moon's poles! \u{1F319}",
    "India's Mars Orbiter Mission (Mangalyaan) cost less than the movie Gravity to make! \u{1F1EE}\u{1F1F3}",
    'The Voyager 1 spacecraft is the farthest human-made object from Earth! \u{1F6F8}',
    'A black hole the size of a coin would have more mass than Earth! \u{1F573}\uFE0F',
    'There are diamonds raining on Neptune and Uranus! \u{1F48E}',
    'The Hubble Space Telescope can see galaxies 13.4 billion light-years away! \u{1F52D}',
    "Earth's core is as hot as the surface of the Sun! \u{1F30D}",
    'The Moon is slowly drifting away from Earth at 3.8 cm per year! \u{1F319}',
    "If you could drive straight up at 100 km/h, you'd reach space in 1 hour! \u{1F697}",
    "Olympus Mons on Mars is so large, you can't see the top from the base due to Mars' curvature! \u{1F3D4}\uFE0F",
  ];

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {
        // Handle notification tap — app opens automatically
      },
    );

    // Request permission for Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule daily fact notification at 8 AM.
  static Future<void> scheduleDailyFact() async {
    final fact = _facts[DateTime.now().day % _facts.length];
    await _plugin.zonedSchedule(
      0,
      '\u{1F30C} Daily Space Fact',
      fact,
      _nextInstanceOfTime(8, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_fact',
          'Daily Space Facts',
          channelDescription: 'Get a fascinating space fact every morning',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(fact),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule APOD notification at 7 AM.
  static Future<void> scheduleApodReminder() async {
    await _plugin.zonedSchedule(
      1,
      '\u{1F52D} New Astronomy Photo!',
      "Today's daily astronomy photo from public space archives is ready. Tap to explore!",
      _nextInstanceOfTime(7, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'apod_reminder',
          'APOD Reminders',
          channelDescription: 'Daily astronomy picture alerts',
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
}
