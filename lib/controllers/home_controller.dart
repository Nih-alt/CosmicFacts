import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/apod_model.dart';
import '../models/space_article.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/smart_notification_service.dart';

class HomeController extends GetxController {
  final stories = <SpaceArticle>[].obs;
  final todayApod = Rx<ApodModel?>(null);
  final isLoading = true.obs;
  final isLoadingApod = true.obs;
  final isLoadingMore = false.obs;
  final hasApodError = false.obs;
  final hasError = false.obs;
  final isOffline = false.obs;

  int _offset = 0;
  static const _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    // Re-check smart notifications when home screen loads
    SmartNotificationService.checkAndSchedule();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    isLoadingApod.value = true;
    hasApodError.value = false;
    hasError.value = false;
    isOffline.value = false;

    // STEP 1: Load from cache first (instant)
    try {
      final cachedArticles = await CacheService.getCachedNews();
      final cachedApod = await CacheService.getCachedApod();

      if (cachedArticles != null) {
        stories.assignAll(
          cachedArticles.map((e) => SpaceArticle.fromJson(e)).toList(),
        );
        _offset = cachedArticles.length;
        isLoading.value = false; // Show cached data immediately
      }
      if (cachedApod != null) {
        todayApod.value = ApodModel.fromJson(cachedApod);
        isLoadingApod.value = false;
      }
    } catch (e) {
      debugPrint('Cache load error: $e');
    }

    // STEP 2: Fetch fresh data in background (non-blocking for UI)
    _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    final apodFuture = loadApod(forceLoading: todayApod.value == null);

    try {
      final newArticles =
          await ApiService.getSpaceNews(limit: _pageSize, offset: 0);

      if (newArticles != null && newArticles.isNotEmpty) {
        stories.assignAll(newArticles);
        _offset = _pageSize;
        // Cache for next time
        try {
          CacheService.cacheNews(
              newArticles.map((e) => e.toJson()).toList());
        } catch (e) {
          debugPrint('Cache write error: $e');
        }
      } else if (newArticles == null && stories.isEmpty) {
        hasError.value = true;
      } else if (newArticles == null && stories.isNotEmpty) {
        isOffline.value = true;
      }
    } catch (_) {
      if (stories.isEmpty) {
        hasError.value = true;
      } else {
        isOffline.value = true;
      }
    }

    isLoading.value = false;
    await apodFuture;
  }

  Future<void> loadApod({bool forceLoading = true}) async {
    if (forceLoading) {
      isLoadingApod.value = true;
    }
    hasApodError.value = false;

    try {
      final newApod = await ApiService.getApodWithFallback();
      if (newApod != null) {
        todayApod.value = newApod;
        try {
          CacheService.cacheApod(newApod.toJson());
        } catch (e) {
          debugPrint('APOD cache write error: $e');
        }
      } else if (todayApod.value == null) {
        hasApodError.value = true;
      }
    } catch (e) {
      debugPrint('APOD load error: $e');
      if (todayApod.value == null) {
        hasApodError.value = true;
      }
    }

    isLoadingApod.value = false;
  }

  Future<void> loadMoreStories() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      final articles = await ApiService.getSpaceNews(
        limit: _pageSize,
        offset: _offset,
      );

      if (articles != null && articles.isNotEmpty) {
        stories.addAll(articles);
        _offset += _pageSize;
      }
    } catch (e) {
      debugPrint('Load more stories error: $e');
    }

    isLoadingMore.value = false;
  }

  Future<void> refreshData() async {
    _offset = 0;
    isOffline.value = false;
    await loadInitialData();
  }

  void dismissOfflineBanner() => isOffline.value = false;
}
