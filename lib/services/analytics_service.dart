import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around FirebaseAnalytics for app-level events.
///
/// Every method is fire-and-forget (callers use `unawaited(...)`) and
/// wraps the underlying call in try/catch — analytics never crash
/// the app. Event names follow Firebase's `snake_case` convention.
class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> logFeatureUsed(String featureName) async {
    try {
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {'feature': featureName},
      );
    } catch (e) {
      debugPrint('Analytics logFeatureUsed error: $e');
    }
  }

  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics logScreenView error: $e');
    }
  }

  static Future<void> logSearch(String query) async {
    try {
      await _analytics.logSearch(searchTerm: query);
    } catch (e) {
      debugPrint('Analytics logSearch error: $e');
    }
  }

  static Future<void> logQuizCompleted(String mode, int score) async {
    try {
      await _analytics.logEvent(
        name: 'quiz_completed',
        parameters: {'mode': mode, 'score': score},
      );
    } catch (e) {
      debugPrint('Analytics logQuizCompleted error: $e');
    }
  }

  static Future<void> log3DModelViewed(String modelName) async {
    try {
      await _analytics.logEvent(
        name: 'model_3d_viewed',
        parameters: {'model': modelName},
      );
    } catch (e) {
      debugPrint('Analytics log3DModelViewed error: $e');
    }
  }
}
