// Cosmic Facts UI Philosophy: Cupertino-first for premium iOS-like feel on both Android & iOS
// Use CupertinoButton, CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoActionSheet, CupertinoPageRoute, CupertinoTabBar, CupertinoSliverNavigationBar.

import 'dart:async' show unawaited;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_bindings.dart';
import 'controllers/theme_controller.dart';
import 'models/observation_log.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_notification_service.dart';
import 'services/notification_service.dart';
import 'services/smart_notification_service.dart';
import 'theme/app_theme.dart';

/// Startup goal: render the splash screen within ~100 ms of process launch.
///
/// Pre-runApp work is restricted to the bare minimum — Hive boxes,
/// `Firebase.initializeApp` (so widgets that look up `FirebaseAnalytics` /
/// `FirebaseCrashlytics` during the very first build don't crash with
/// `[core/no-app]`), and `ThemeController` (so frame 1 picks the right theme).
///
/// Crashlytics setup, FCM token fetch, and notification scheduling — all of
/// which hit the network — run in [_initializeBackgroundServices] after the
/// first frame paints.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Diagnostic error handler used until Crashlytics takes over in the
  // post-frame callback. Without this, framework errors raised during startup
  // would be silent.
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  // Image cache headroom for high-res NASA imagery.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 80 * 1024 * 1024;

  // .env load — small local file, falls back to DEMO_KEY in ApiKeys.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load failed (falling back to DEMO_KEY): $e');
  }

  // Hive must be initialized before any box opens.
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ObservationLogAdapter());
    }
  } catch (e) {
    debugPrint('FATAL: Hive init failed: $e');
  }

  // Open every box in parallel — controllers and the theme reader need them
  // before the first frame.
  await Future.wait<void>([
    _openBox('settings'),
    _openBox('news_cache'),
    _openBox('apod_cache'),
    _openBox('launches_cache'),
    _openBox('learn_progress'),
    _openBox('quiz_stats'),
    _openBox('bookmarks'),
    _openBox('achievements'),
    _openTypedBox<ObservationLog>('observations'),
  ]);

  // ━━━ Firebase core platform handle — fast (~50 ms), MUST be before runApp.
  // The first frame builds `FirebaseAnalyticsObserver(FirebaseAnalytics.instance)`
  // and any plugin that touches Firebase will throw `[core/no-app]` if the
  // default app hasn't been registered yet. The slow, network-bound setup
  // (Crashlytics flag, install_id, FCM token) lives in the post-frame
  // callback below.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // ThemeController is the only eager controller registration: every screen
  // reads the current theme on first build to avoid a flash of the wrong
  // theme. Constructing it just reads one Hive key — no network, no I/O.
  try {
    final initialTheme = ThemeController.initialFromHive();
    Get.put(ThemeController(initialTheme), permanent: true);
  } catch (e) {
    debugPrint('Theme controller error: $e');
    Get.put(ThemeController(ThemeMode.dark), permanent: true);
  }

  // Edge-to-edge display (SDK 36+ compliance). Cheap platform call.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const CosmicFactsApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeBackgroundServices());
  });
}

/// Open a Hive box with corruption recovery — if the file is unreadable we
/// delete it and retry once so a single bad write doesn't brick the app.
Future<void> _openBox(String name) async {
  try {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  } catch (e) {
    debugPrint('Failed to open box $name: $e');
    try {
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox(name);
      debugPrint('Recovered box $name after corruption');
    } catch (e2) {
      debugPrint('FATAL: Cannot recover box $name: $e2');
    }
  }
}

Future<void> _openTypedBox<T>(String name) async {
  try {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<T>(name);
    }
  } catch (e) {
    debugPrint('Failed to open typed box $name: $e');
    try {
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<T>(name);
      debugPrint('Recovered typed box $name after corruption');
    } catch (e2) {
      debugPrint('FATAL: Cannot recover typed box $name: $e2');
    }
  }
}

/// Heavyweight / network-bound work that runs AFTER the first frame paints.
/// `Firebase.initializeApp` has already completed in [main], so every block
/// here can safely touch Firebase services. Each block is independently
/// guarded so one failure can't take down the others.
Future<void> _initializeBackgroundServices() async {
  try {
    // Pipe framework + uncaught async errors into Crashlytics now that
    // Firebase is up. `recordFlutterError` reports non-fatals so the app
    // stays alive; the platform handler still flags async errors as fatal.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Don't ship debug-build crashes to the dashboard.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Stable per-install identifier so crash reports group by device (no PII).
    try {
      final settings = Hive.box('settings');
      final existingId =
          settings.get('install_id', defaultValue: '') as String;
      if (existingId.isEmpty) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        await settings.put('install_id', newId);
        await FirebaseCrashlytics.instance.setUserIdentifier(newId);
      } else {
        await FirebaseCrashlytics.instance.setUserIdentifier(existingId);
      }
    } catch (e) {
      debugPrint('Crashlytics user-id error: $e');
    }

    // Touch the singleton so screen_view auto-logging is wired up.
    FirebaseAnalytics.instance;

    // Local notifications.
    unawaited(NotificationService.init().then((_) {
      return NotificationService.scheduleFromPrefs();
    }).catchError((Object e) {
      debugPrint('Notification init/schedule error: $e');
    }));

    // FCM — token fetch hits the network.
    unawaited(Future(() async {
      try {
        await FirebaseNotificationService.init();
      } catch (e) {
        debugPrint('Firebase notification init error: $e');
      }
    }));

    // Smart notifications — launch alerts, asteroid warnings, event reminders.
    try {
      SmartNotificationService.checkAndSchedule();
    } catch (e) {
      debugPrint('Smart notification error: $e');
    }

    debugPrint('Background services initialized');
  } catch (e) {
    debugPrint('Background services error: $e');
  }
}

class CosmicFactsApp extends StatelessWidget {
  const CosmicFactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Single observer instance — auto-logs screen_view on every push/pop.
    final analyticsObserver = FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

    return Obx(() {
      try {
        final themeCtrl = Get.find<ThemeController>();
        return GetMaterialApp(
          title: 'Cosmic Facts',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode.value,
          initialBinding: AppBindings(),
          navigatorObservers: [analyticsObserver],
          home: const SplashScreen(),
        );
      } catch (e) {
        debugPrint('App build error: $e');
        return GetMaterialApp(
          title: 'Cosmic Facts',
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          initialBinding: AppBindings(),
          navigatorObservers: [analyticsObserver],
          home: const SplashScreen(),
        );
      }
    });
  }
}
