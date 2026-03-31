import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/achievements_data.dart';

class AchievementController extends GetxController {
  late final Box _box;
  final progress = RxMap<String, int>();
  final unlocked = RxSet<String>();
  final totalPoints = 0.obs;
  final newlyUnlocked = RxList<String>();

  @override
  void onInit() {
    super.onInit();
    try {
      _box = Hive.box('achievements');
      _loadProgress();
    } catch (e) {
      debugPrint('AchievementController init error: $e');
    }
  }

  void _loadProgress() {
    try {
      final savedProgress = _box.get('progress') as String?;
      if (savedProgress != null) {
        try {
          progress.value = Map<String, int>.from(json.decode(savedProgress));
        } catch (_) {}
      }
      final savedUnlocked = _box.get('unlocked') as String?;
      if (savedUnlocked != null) {
        try {
          final set = Set<String>.from(json.decode(savedUnlocked));
          unlocked.addAll(set);
        } catch (_) {}
      }
      totalPoints.value = _box.get('total_points', defaultValue: 0) as int;
    } catch (e) {
      debugPrint('Achievement load error: $e');
    }
  }

  void incrementProgress(String type, {int amount = 1}) {
    final current = progress[type] ?? 0;
    progress[type] = current + amount;
    _checkAchievements(type);
    _save();
    _showNewlyUnlocked();
  }

  void setProgress(String type, int value) {
    progress[type] = value;
    _checkAchievements(type);
    _save();
    _showNewlyUnlocked();
  }

  void _checkAchievements(String type) {
    for (final achievement in allAchievements) {
      if (unlocked.contains(achievement.id)) continue;
      if (achievement.requirementType != type && type != 'total_points') {
        continue;
      }

      final current = progress[achievement.requirementType] ?? 0;
      if (current >= achievement.requirement) {
        _unlockAchievement(achievement);
      }
    }
  }

  void _unlockAchievement(Achievement achievement) {
    unlocked.add(achievement.id);
    totalPoints.value += achievement.points;
    progress['total_points'] = totalPoints.value;
    newlyUnlocked.add(achievement.id);
    _save();

    // Check if total_points unlocked any new achievements
    if (achievement.requirementType != 'total_points') {
      _checkAchievements('total_points');
    }
  }

  void _showNewlyUnlocked() {
    for (final id in List<String>.from(newlyUnlocked)) {
      final achievement = allAchievements.firstWhereOrNull((a) => a.id == id);
      if (achievement != null) {
        showAchievementUnlocked(achievement);
      }
    }
    newlyUnlocked.clear();
  }

  bool isUnlocked(String id) => unlocked.contains(id);

  int getProgress(String type) => progress[type] ?? 0;

  double getAchievementProgress(Achievement a) {
    final current = progress[a.requirementType] ?? 0;
    return (current / a.requirement).clamp(0.0, 1.0);
  }

  void _save() {
    try {
      _box.put('progress', json.encode(progress));
      _box.put('unlocked', json.encode(unlocked.toList()));
      _box.put('total_points', totalPoints.value);
    } catch (e) {
      debugPrint('Achievement save error: $e');
    }
  }

  static void showAchievementUnlocked(Achievement achievement) {
    Get.snackbar(
      '\u{1F3C6} Achievement Unlocked!',
      '${achievement.icon} ${achievement.name} \u2014 +${achievement.points} pts',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0066CC),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(achievement.icon, style: const TextStyle(fontSize: 32)),
      ),
    );
  }
}
