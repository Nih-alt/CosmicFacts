import 'package:get/get.dart';

import '../models/apod_model.dart';
import '../models/space_article.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class HomeController extends GetxController {
  final stories = <SpaceArticle>[].obs;
  final todayApod = Rx<ApodModel?>(null);
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final isOffline = false.obs;

  int _offset = 0;
  static const _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;
    isOffline.value = false;

    // STEP 1: Load from cache first (instant)
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
    }

    // STEP 2: Fetch fresh data in background
    await _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    try {
      final results = await Future.wait<Object?>([
        ApiService.getSpaceNews(limit: _pageSize, offset: 0),
        ApiService.getApod(),
      ]);

      final newArticles = results[0] as List<SpaceArticle>?;
      final newApod = results[1] as ApodModel?;

      if (newArticles != null && newArticles.isNotEmpty) {
        stories.assignAll(newArticles);
        _offset = _pageSize;
        // Cache for next time
        CacheService.cacheNews(newArticles.map((e) => e.toJson()).toList());
      } else if (newArticles == null && stories.isEmpty) {
        hasError.value = true;
      } else if (newArticles == null && stories.isNotEmpty) {
        isOffline.value = true;
      }

      if (newApod != null) {
        todayApod.value = newApod;
        CacheService.cacheApod(newApod.toJson());
      }
    } catch (_) {
      if (stories.isEmpty) {
        hasError.value = true;
      } else {
        isOffline.value = true;
      }
    }

    isLoading.value = false;
  }

  Future<void> loadMoreStories() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    final articles = await ApiService.getSpaceNews(
      limit: _pageSize,
      offset: _offset,
    );

    if (articles != null && articles.isNotEmpty) {
      stories.addAll(articles);
      _offset += _pageSize;
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
