import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/bookmark_controller.dart';
import '../../models/bookmark_model.dart';
import '../../theme/app_colors.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _bmCtrl = Get.find<BookmarkController>();
  String _filter = 'All';

  static const _filters = ['All', 'article', 'image', 'apod', 'glossary'];
  static const _filterLabels = ['All', 'Articles', 'Images', 'APOD', 'Glossary'];

  List<BookmarkModel> get _filtered {
    if (_filter == 'All') return _bmCtrl.bookmarks;
    return _bmCtrl.getByType(_filter);
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'article': return 'Article';
      case 'image': return 'NASA Image';
      case 'apod': return 'APOD';
      case 'glossary': return 'Glossary';
      case 'lesson': return 'Lesson';
      default: return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'article': return CupertinoIcons.news;
      case 'image': return CupertinoIcons.photo;
      case 'apod': return CupertinoIcons.star;
      case 'glossary': return CupertinoIcons.book;
      case 'lesson': return CupertinoIcons.lightbulb;
      default: return CupertinoIcons.bookmark;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'article': return AppColors.accentCyan;
      case 'image': return AppColors.accentPurple;
      case 'apod': return AppColors.starGold;
      case 'glossary': return AppColors.accentOrange;
      case 'lesson': return AppColors.success;
      default: return AppColors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _filterPills(),
            const SizedBox(height: 8),
            Expanded(child: Obx(() {
              final items = _filtered;
              if (items.isEmpty) return _empty();
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                itemCount: items.length,
                itemBuilder: (ctx, i) => _card(items[i], i),
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context), size: 26)),
          const SizedBox(width: 4),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Saved Items', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
            Obx(() => Text('${_bmCtrl.bookmarks.length} items saved', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context)))),
          ])),
        ],
      ),
    );
  }

  Widget _filterPills() {
    return SizedBox(
      height: 46,
      child: Obx(() => ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final sel = f == _filter;
          final count = f == 'All' ? _bmCtrl.bookmarks.length : _bmCtrl.getByType(f).length;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: sel ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]) : null,
                color: sel ? null : AppColors.glass(context),
                border: Border.all(color: sel ? Colors.transparent : AppColors.glassBorder(context)),
              ),
              child: Text('${_filterLabels[i]} ($count)',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.textSecondary(context))),
            ),
          );
        },
      )),
    );
  }

  Widget _card(BookmarkModel bm, int index) {
    final tc = _typeColor(bm.type);
    return Dismissible(
      key: ValueKey(bm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(CupertinoIcons.delete, color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => _bmCtrl.removeBookmark(bm.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Row(
          children: [
            // Thumbnail or icon
            if (bm.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: bm.imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                  errorWidget: (_, _, _) => _iconBox(bm.type, tc),
                ),
              )
            else
              _iconBox(bm.type, tc),
            const SizedBox(width: 12),
            // Content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bm.title, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: tc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(_typeLabel(bm.type), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: tc)),
                ),
                if (bm.subtitle.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(child: Text(bm.subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary(context)),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ]),
            ])),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 30 * index));
  }

  Widget _iconBox(String type, Color color) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_typeIcon(type), color: color, size: 24),
    );
  }

  Widget _empty() {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(CupertinoIcons.bookmark, size: 48, color: AppColors.textSecondary(context).withValues(alpha: 0.3)),
      const SizedBox(height: 16),
      Text('No saved items yet', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
      const SizedBox(height: 8),
      Text('Tap the heart icon on any article, image, or term to save it here.',
        textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary(context), height: 1.5)),
    ])));
  }
}
