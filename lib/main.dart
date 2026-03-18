// Cosmic Facts UI Philosophy: Cupertino-first for premium iOS-like feel on both Android & iOS
// Use CupertinoButton, CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoActionSheet, CupertinoPageRoute, CupertinoTabBar, CupertinoSliverNavigationBar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/explore_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/launches_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive — open all boxes before app renders
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('learn_progress');
  await Hive.openBox('news_cache');
  await Hive.openBox('apod_cache');
  await Hive.openBox('launches_cache');

  // Read saved theme synchronously before anything renders
  final initialTheme = ThemeController.initialFromHive();

  // Initialize global controllers
  Get.put(ThemeController(initialTheme));
  Get.put(HomeController());
  Get.put(ExploreController());
  Get.put(LaunchesController());

  // Prefer edge-to-edge, immersive status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const CosmicFactsApp());
}

class CosmicFactsApp extends StatelessWidget {
  const CosmicFactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
          title: 'Cosmic Facts',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode.value,

          // Entry point
          home: const SplashScreen(),
        ));
  }
}
