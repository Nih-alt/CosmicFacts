import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bookmark_model.dart';

class BookmarkController extends GetxController {
  final bookmarks = <BookmarkModel>[].obs;
  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('bookmarks');
    _load();
  }

  void _load() {
    final raw = _box.get('all_bookmarks') as String?;
    if (raw != null) {
      try {
        final list = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
        bookmarks.value = list.map((e) => BookmarkModel.fromJson(e)).toList();
        bookmarks.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      } catch (_) {}
    }
  }

  void addBookmark(BookmarkModel bm) {
    if (bookmarks.any((b) => b.id == bm.id)) return;
    bookmarks.insert(0, bm);
    _save();
  }

  void removeBookmark(String id) {
    bookmarks.removeWhere((b) => b.id == id);
    _save();
  }

  bool isBookmarked(String id) => bookmarks.any((b) => b.id == id);

  void toggleBookmark(BookmarkModel bm) {
    if (isBookmarked(bm.id)) {
      removeBookmark(bm.id);
    } else {
      addBookmark(bm);
    }
  }

  List<BookmarkModel> getByType(String type) =>
      bookmarks.where((b) => b.type == type).toList();

  void _save() {
    final data = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    _box.put('all_bookmarks', data);
  }
}
