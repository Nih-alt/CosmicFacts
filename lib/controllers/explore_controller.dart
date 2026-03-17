import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/nasa_image.dart';
import '../services/api_service.dart';

class ExploreController extends GetxController {
  final images = <NasaImage>[].obs;
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
      result = await ApiService.searchNasaImages(
        query: selectedCategory.value,
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

  void filterByCategory(String category) {
    selectedCategory.value = category;
    searchTextController.clear();
    isSearching.value = false;
    _currentPage = 1;

    if (category == 'All') {
      loadTrendingImages();
    } else {
      searchImages(category);
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
