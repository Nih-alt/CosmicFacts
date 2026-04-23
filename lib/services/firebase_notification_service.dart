import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

/// Background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Check if app opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          'App opened from notification: ${initialMessage.notification?.title}');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request FCM notification permission, then fetch token and subscribe to topics.
  /// Called only after onboarding so the OS dialog doesn't appear on first launch.
  static Future<void> requestPermissionAndSubscribe() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    try {
      final box = Hive.box('settings');
      box.put('fcm_token', token);
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }

    await subscribeToTopics();
  }

  /// Subscribe to topic-based notifications based on user preferences.
  static Future<void> subscribeToTopics() async {
    try {
      final box = Hive.box('settings');
      final notificationsEnabled =
          box.get('notifications_enabled', defaultValue: false);

      if (notificationsEnabled) {
        await _messaging.subscribeToTopic('all_users');
        await _messaging.subscribeToTopic('daily_facts');
        debugPrint('FCM: Subscribed to base topics');
      }

      // Check individual preferences
      final launchAlerts =
          box.get('notify_launches', defaultValue: true) == true;
      final newsAlerts = box.get('notify_news', defaultValue: true) == true;
      final asteroidAlerts =
          box.get('notify_asteroids', defaultValue: true) == true;
      final eventAlerts =
          box.get('notify_events', defaultValue: true) == true;

      if (launchAlerts) {
        await _messaging.subscribeToTopic('launches');
      } else {
        await _messaging.unsubscribeFromTopic('launches');
      }

      if (newsAlerts) {
        await _messaging.subscribeToTopic('breaking_news');
      } else {
        await _messaging.unsubscribeFromTopic('breaking_news');
      }

      if (asteroidAlerts) {
        await _messaging.subscribeToTopic('asteroid_alerts');
      } else {
        await _messaging.unsubscribeFromTopic('asteroid_alerts');
      }

      if (eventAlerts) {
        await _messaging.subscribeToTopic('events');
      } else {
        await _messaging.unsubscribeFromTopic('events');
      }
    } catch (e) {
      debugPrint('FCM topic subscription error: $e');
    }
  }

  /// Unsubscribe from all topics.
  static Future<void> unsubscribeFromAll() async {
    try {
      await _messaging.unsubscribeFromTopic('all_users');
      await _messaging.unsubscribeFromTopic('launches');
      await _messaging.unsubscribeFromTopic('breaking_news');
      await _messaging.unsubscribeFromTopic('daily_facts');
      await _messaging.unsubscribeFromTopic('asteroid_alerts');
      await _messaging.unsubscribeFromTopic('events');
      debugPrint('FCM: Unsubscribed from all topics');
    } catch (e) {
      debugPrint('FCM unsubscribe error: $e');
    }
  }

  /// Show foreground notification using local notifications plugin.
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'firebase_push',
          'Push Notifications',
          channelDescription: 'Notifications from Cosmic Facts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation:
              BigTextStyleInformation(notification.body ?? ''),
        ),
      ),
    );
  }

  /// Handle notification tap — navigate based on data payload.
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    debugPrint('Notification tap type: $type');
    debugPrint('Notification data: $data');
  }
}
