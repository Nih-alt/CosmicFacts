// Cosmic Facts UI Philosophy: Cupertino-first for premium iOS-like feel on both Android & iOS
// Use CupertinoButton, CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoActionSheet, CupertinoPageRoute, CupertinoTabBar, CupertinoSliverNavigationBar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/explore_controller.dart';
import 'controllers/home_controller.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Initialize global controllers
  Get.put(HomeController());
  Get.put(ExploreController());

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
    return GetMaterialApp(
      title: 'Cosmic Facts',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Entry point
      home: const SplashScreen(),
    );
  }
}
