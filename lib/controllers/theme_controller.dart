import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  final themeMode = ThemeMode.dark.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    final saved = box.get('theme_mode', defaultValue: 'dark') as String;
    themeMode.value = _modeFromString(saved);
    Get.changeThemeMode(themeMode.value);
  }

  void setTheme(String mode) {
    final box = Hive.box('settings');
    box.put('theme_mode', mode);
    themeMode.value = _modeFromString(mode);
    Get.changeThemeMode(themeMode.value);
  }

  static ThemeMode _modeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String get currentModeString {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
