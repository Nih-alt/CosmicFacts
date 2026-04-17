import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode;

  ThemeController(ThemeMode initial) : themeMode = Rx<ThemeMode>(initial);

  void setTheme(String mode) {
    final newMode = _modeFromString(mode);
    themeMode.value = newMode;
    Get.changeThemeMode(newMode);

    try {
      final box = Hive.box('settings');
      box.put('theme_mode', mode);
    } catch (e) {
      debugPrint('Theme save error: $e');
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

  @override
  void onClose() {
    themeMode.close();
    super.onClose();
  }

  static ThemeMode initialFromHive() {
    try {
      final box = Hive.box('settings');
      final saved = box.get('theme_mode', defaultValue: 'dark') as String;
      return _modeFromString(saved);
    } catch (e) {
      debugPrint('Theme read error: $e');
      return ThemeMode.dark;
    }
  }
}
