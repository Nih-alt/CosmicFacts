// Cosmic Facts UI Philosophy: Cupertino-first for premium iOS-like feel on both Android & iOS
// Use CupertinoButton, CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoActionSheet, CupertinoPageRoute, CupertinoTabBar, CupertinoSliverNavigationBar.

import 'dart:async' show unawaited;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/achievement_controller.dart';
import 'controllers/bookmark_controller.dart';
import 'controllers/explore_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/launches_controller.dart';
import 'controllers/theme_controller.dart';
import 'models/observation_log.dart';
import 'screens/splash_screen.dart';

import 'services/firebase_notification_service.dart';
import 'services/notification_service.dart';
import 'services/smart_notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before anything else so ApiKeys is ready
  // by the time any service reads it. Non-fatal on failure — ApiKeys
  // falls back to DEMO_KEY.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load failed (falling back to DEMO_KEY): $e');
  }

  PaintingBinding.instance.imageCache.maximumSizeBytes =
      80 * 1024 * 1024; // 80 MB

  // Early diagnostic error handler — replaced below with Crashlytics once
  // Firebase is initialized. Until then we still want some visibility into
  // errors that occur during startup (Hive / box opening).
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  // Initialize Hive
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ObservationLogAdapter());
    }
  } catch (e) {
    debugPrint('FATAL: Hive init failed: $e');
  }

  // Open all boxes in parallel (each one has its own error recovery).
  await Future.wait([
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

  debugPrint('MAIN: All boxes opened');

  // Initialize Firebase + Crashlytics + Analytics
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');

    // Crashlytics — forward uncaught errors.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught Flutter (framework) errors to Crashlytics.
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught async errors that aren't handled by Flutter.
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Anonymous install-based user identifier so crash reports group by
    // device (no PII). Persisted in the `settings` Hive box.
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

    // Analytics — touch the singleton so it initializes early.
    FirebaseAnalytics.instance;
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize controllers safely
  try {
    final initialTheme = ThemeController.initialFromHive();
    Get.put(ThemeController(initialTheme), permanent: true);
  } catch (e) {
    debugPrint('Theme controller error: $e');
    Get.put(ThemeController(ThemeMode.dark), permanent: true);
  }

  try {
    Get.put(HomeController(), permanent: true);
  } catch (e) {
    debugPrint('Home ctrl error: $e');
  }
  try {
    Get.lazyPut(() => ExploreController(), fenix: true);
  } catch (e) {
    debugPrint('Explore ctrl error: $e');
  }
  try {
    Get.lazyPut(() => LaunchesController(), fenix: true);
  } catch (e) {
    debugPrint('Launches ctrl error: $e');
  }
  try {
    Get.put(BookmarkController(), permanent: true);
  } catch (e) {
    debugPrint('Bookmark ctrl error: $e');
  }
  try {
    Get.put(AchievementController(), permanent: true);
  } catch (e) {
    debugPrint('Achievement ctrl error: $e');
  }

  debugPrint('MAIN: Controllers ready');

  // Non-blocking — run notification init in background so it doesn't delay first frame.
  unawaited(NotificationService.init().then((_) {
    return NotificationService.scheduleFromPrefs();
  }).catchError((e) {
    debugPrint('Notification init/schedule error: $e');
  }));

  // FCM setup (token fetch hits the network) — also non-blocking.
  unawaited(Future(() async {
    try {
      await FirebaseNotificationService.init();
    } catch (e) {
      debugPrint('Firebase notification init error: $e');
    }
  }));

  // Smart notifications — launch alerts, asteroid warnings, event reminders
  try {
    SmartNotificationService.checkAndSchedule();
  } catch (e) {
    debugPrint('Smart notification error: $e');
  }

  // Enable edge-to-edge display mode (SDK 36+ compliance)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  debugPrint('MAIN: Running app');
  runApp(const CosmicFactsApp());
}

Future<void> _openBox(String name) async {
  try {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  } catch (e) {
    debugPrint('Failed to open box $name: $e');
    // Try deleting corrupted box and reopening
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
          navigatorObservers: [analyticsObserver],
          home: const SplashScreen(),
        );
      }
    });
  }
}
