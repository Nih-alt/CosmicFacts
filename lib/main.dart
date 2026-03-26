// Cosmic Facts UI Philosophy: Cupertino-first for premium iOS-like feel on both Android & iOS
// Use CupertinoButton, CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoActionSheet, CupertinoPageRoute, CupertinoTabBar, CupertinoSliverNavigationBar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/achievement_controller.dart';
import 'controllers/bookmark_controller.dart';
import 'controllers/explore_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/launches_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled Flutter errors
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  // Initialize Hive
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('FATAL: Hive init failed: $e');
  }

  // Open each box individually with recovery
  await _openBox('settings');
  await _openBox('news_cache');
  await _openBox('apod_cache');
  await _openBox('launches_cache');
  await _openBox('learn_progress');
  await _openBox('quiz_stats');
  await _openBox('bookmarks');
  await _openBox('achievements');

  debugPrint('MAIN: All boxes opened');

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
    Get.put(ExploreController(), permanent: true);
  } catch (e) {
    debugPrint('Explore ctrl error: $e');
  }
  try {
    Get.put(LaunchesController(), permanent: true);
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

  // Init notifications safely
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  // Schedule notifications if enabled
  try {
    await NotificationService.scheduleFromPrefs();
  } catch (e) {
    debugPrint('Notification schedule error: $e');
  }

  // Prefer edge-to-edge, immersive status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

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

class CosmicFactsApp extends StatelessWidget {
  const CosmicFactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      try {
        final themeCtrl = Get.find<ThemeController>();
        return GetMaterialApp(
          title: 'Cosmic Facts',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode.value,
          home: const SplashScreen(),
        );
      } catch (e) {
        debugPrint('App build error: $e');
        return GetMaterialApp(
          title: 'Cosmic Facts',
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        );
      }
    });
  }
}
