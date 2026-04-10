import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/nasa_image.dart';
import '../services/api_service.dart';

class ExploreController extends GetxController {
  final images = <NasaImage>[].obs;
  final jwstImages = <NasaImage>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isSearching = false.obs;
  final hasError = false.obs;
  final selectedCategory = 'All'.obs;
  final searchTextController = TextEditingController();

  int _currentPage = 1;
  Timer? _debounce;

  static const categories = [
    'All', 'Galaxies', 'Nebulae', 'Planets', 'Earth',
    'Rockets', 'Astronauts', 'Moon', 'Stars', 'JWST',
  ];

  @override
  void onInit() {
    super.onInit();
    loadTrendingImages();
    _loadJWSTImages();
  }

  Future<void> _loadJWSTImages() async {
    try {
      final results = await ApiService.searchNasaImages(
        query: 'james webb telescope nebula galaxy',
        page: 1,
      );
      jwstImages.assignAll(results.take(5).toList());
    } catch (e) {
      debugPrint('JWST images error: $e');
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadTrendingImages() async {
    isLoading.value = true;
    hasError.value = false;
    _currentPage = 1;

    final result = await ApiService.getTrendingImages(page: 1);

    if (result.isNotEmpty) {
      images.assignAll(result);
    } else {
      hasError.value = true;
    }

    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    _currentPage++;

    final List<NasaImage> result;
    if (isSearching.value) {
      result = await ApiService.searchNasaImages(
        query: searchTextController.text,
        page: _currentPage,
      );
    } else if (selectedCategory.value != 'All') {
      final queries = {
        'JWST':        'james webb telescope',
        'Hubble':      'hubble space telescope nebula',
        'Nebulae':     'nebula colorful',
        'Galaxies':    'galaxy deep field spiral',
        'Planets':     'planet jupiter saturn mars',
        'Earth':       'earth from space blue marble',
        'Stars':       'star cluster nebula supernova',
        'Black Holes': 'black hole event horizon',
        'Mars':        'mars surface perseverance',
        'Launches':    'rocket launch nasa',
        'Astronauts':  'astronaut spacewalk ISS',
      };
      final q = queries[selectedCategory.value] ?? selectedCategory.value;
      result = await ApiService.searchNasaImages(
        query: q,
        page: _currentPage,
      );
    } else {
      result = await ApiService.getTrendingImages(page: _currentPage);
    }

    if (result.isNotEmpty) {
      images.addAll(result);
    }

    isLoadingMore.value = false;
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchImages(query.trim());
    });
  }

  Future<void> searchImages(String query) async {
    isSearching.value = true;
    isLoading.value = true;
    hasError.value = false;
    _currentPage = 1;

    final result = await ApiService.searchNasaImages(query: query, page: 1);

    if (result.isNotEmpty) {
      images.assignAll(result);
    } else {
      images.clear();
    }

    isLoading.value = false;
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    searchTextController.clear();
    isSearching.value = false;
    isLoading.value = true;
    _currentPage = 1;
    images.clear();

    final queries = {
      'All':         '',
      'JWST':        'james webb telescope',
      'Hubble':      'hubble space telescope nebula',
      'Nebulae':     'nebula colorful',
      'Galaxies':    'galaxy deep field spiral',
      'Planets':     'planet jupiter saturn mars',
      'Earth':       'earth from space blue marble',
      'Stars':       'star cluster nebula supernova',
      'Black Holes': 'black hole event horizon',
      'Mars':        'mars surface perseverance',
      'Launches':    'rocket launch nasa',
      'Astronauts':  'astronaut spacewalk ISS',
    };

    final q = queries[category] ?? category;

    try {
      final results = q.isEmpty
          ? await ApiService.getTrendingImages(page: 1)
          : await ApiService.searchNasaImages(query: q, page: 1);
      images.assignAll(results);
    } catch (e) {
      debugPrint('Category filter error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchTextController.clear();
    isSearching.value = false;
    _currentPage = 1;
    selectedCategory.value = 'All';
    loadTrendingImages();
  }
}
