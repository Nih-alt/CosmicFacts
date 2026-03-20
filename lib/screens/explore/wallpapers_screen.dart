import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/nasa_image.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'wallpaper_preview_screen.dart';

class WallpapersScreen extends StatefulWidget {
  const WallpapersScreen({super.key});
  @override
  State<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  final _scrollCtrl = ScrollController();
  final _images = <NasaImage>[];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  String _selectedCat = 'All';

  static const _categories = ['All', 'Nebulae', 'Galaxies', 'Earth', 'Planets', 'Stars', 'Auroras'];
  static const _catQueries = {
    'All': 'hubble deep field',
    'Nebulae': 'nebula hubble',
    'Galaxies': 'galaxy deep field',
    'Earth': 'earth from space hd',
    'Planets': 'saturn jupiter planet',
    'Stars': 'star cluster milky way',
    'Auroras': 'aurora borealis space',
  };

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels > _scrollCtrl.position.maxScrollExtent - 400 && !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _page = 1; _images.clear(); });
    final query = _catQueries[_selectedCat] ?? 'hubble deep field';
    final results = await ApiService.searchNasaImages(query: query, page: 1);
    if (mounted) {
      setState(() { _images.addAll(results); _loading = false; });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    _page++;
    final query = _catQueries[_selectedCat] ?? 'hubble deep field';
    final results = await ApiService.searchNasaImages(query: query, page: _page);
    if (mounted) {
      setState(() { _images.addAll(results); _loadingMore = false; });
    }
  }

  void _selectCat(String cat) {
    if (cat == _selectedCat) return;
    _selectedCat = cat;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            _catPills(isDark),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? _shimmerGrid()
                  : _images.isEmpty
                      ? Center(child: Text('No wallpapers found', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary(context))))
                      : GridView.builder(
                          controller: _scrollCtrl,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: _images.length + (_loadingMore ? 2 : 0),
                          itemBuilder: (ctx, i) {
                            if (i >= _images.length) return _shimmerTile();
                            return _tile(_images[i], i, isDark);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back, color: AppColors.textPrimary(context), size: 26)),
          const SizedBox(width: 4),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Space Wallpapers', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
            Text('HD cosmic wallpapers', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context))),
          ])),
        ],
      ),
    );
  }

  Widget _catPills(bool isDark) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final sel = cat == _selectedCat;
          return GestureDetector(
            onTap: () => _selectCat(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: sel ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]) : null,
                color: sel ? null : AppColors.glass(ctx),
                border: Border.all(color: sel ? Colors.transparent : AppColors.glassBorder(ctx)),
              ),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textSecondary(ctx))),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(NasaImage img, int index, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => WallpaperPreviewScreen(image: img)),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: img.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => _shimmerTile(),
              errorWidget: (_, _, _) => Container(
                color: AppColors.card(context),
                child: Icon(CupertinoIcons.photo, size: 32, color: AppColors.textSecondary(context)),
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              left: 0, right: 0, bottom: 0, height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ),
            // HD badge
            Positioned(
              bottom: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('HD', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 40 * (index % 6)));
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.6,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => _shimmerTile(),
    );
  }

  Widget _shimmerTile() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
