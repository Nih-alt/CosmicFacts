import 'package:get/get.dart';

import '../models/launch_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class LaunchesController extends GetxController {
  static const String allProvidersLabel = 'All Providers';
  static const List<String> providerOptions = [
    allProvidersLabel,
    'SpaceX',
    'NASA',
    'ISRO',
    'Blue Origin',
    'Arianespace',
    'ULA',
    'Rocket Lab',
    'Other',
  ];

  final upcomingLaunches = <LaunchModel>[].obs;
  final pastLaunches = <LaunchModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final selectedTab = 0.obs;
  final selectedProvider = allProvidersLabel.obs;

  bool _matchesSelectedProvider(LaunchModel l) {
    final filter = selectedProvider.value;
    if (filter == allProvidersLabel) return true;
    final p = l.provider.toLowerCase();
    if (filter == 'Other') {
      const known = [
        'spacex',
        'nasa',
        'isro',
        'blue origin',
        'arianespace',
        'ula',
        'united launch',
        'rocket lab',
      ];
      return !known.any(p.contains);
    }
    if (filter == 'ULA') {
      return p.contains('ula') || p.contains('united launch');
    }
    return p.contains(filter.toLowerCase());
  }

  List<LaunchModel> get filteredUpcoming =>
      upcomingLaunches.where(_matchesSelectedProvider).toList();

  List<LaunchModel> get filteredPast =>
      pastLaunches.where(_matchesSelectedProvider).toList();

  void setProviderFilter(String provider) {
    selectedProvider.value = provider;
  }

  void clearProviderFilter() {
    selectedProvider.value = allProvidersLabel;
  }

  @override
  void onInit() {
    super.onInit();
    loadLaunches();
  }

  Future<void> loadLaunches() async {
    isLoading.value = true;
    hasError.value = false;

    final now = DateTime.now();

    // ── Cache first — show instantly ──
    final cachedUpcoming = await CacheService.getCachedLaunches('upcoming');
    final cachedPast = await CacheService.getCachedLaunches('past');

    if (cachedUpcoming != null) {
      final parsed = cachedUpcoming
          .map((e) => LaunchModel.fromJson(e))
          .where((l) => l.launchDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.launchDate.compareTo(b.launchDate));
      upcomingLaunches.assignAll(parsed);
    }
    if (cachedPast != null) {
      final parsed = cachedPast
          .map((e) => LaunchModel.fromJson(e))
          .where((l) => l.launchDate.isBefore(now))
          .toList()
        ..sort((a, b) => b.launchDate.compareTo(a.launchDate));
      pastLaunches.assignAll(parsed);
    }

    // Stop loading spinner if we have cached data
    if (upcomingLaunches.isNotEmpty || pastLaunches.isNotEmpty) {
      isLoading.value = false;
    }

    // ── Refresh from API in background ──
    final results = await Future.wait([
      ApiService.getUpcomingLaunches(),
      ApiService.getPastLaunches(),
    ]);

    final freshUpcoming = results[0]
        .where((l) => l.launchDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.launchDate.compareTo(b.launchDate));

    final freshPast = results[1]
        .where((l) => l.launchDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.launchDate.compareTo(a.launchDate));

    if (freshUpcoming.isNotEmpty) {
      upcomingLaunches.assignAll(freshUpcoming);
      await CacheService.cacheLaunches(
        'upcoming',
        freshUpcoming.map((e) => e.toJson()).toList(),
      );
    }

    if (freshPast.isNotEmpty) {
      pastLaunches.assignAll(freshPast);
      await CacheService.cacheLaunches(
        'past',
        freshPast.map((e) => e.toJson()).toList(),
      );
    }

    // Only show error if we have absolutely nothing
    if (upcomingLaunches.isEmpty && pastLaunches.isEmpty) {
      hasError.value = true;
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    upcomingLaunches.close();
    pastLaunches.close();
    super.onClose();
  }
}
