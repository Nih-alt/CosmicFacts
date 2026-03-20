import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/glossary_data.dart';
import '../../theme/app_colors.dart';

class SpaceGlossaryScreen extends StatefulWidget {
  const SpaceGlossaryScreen({super.key});
  @override
  State<SpaceGlossaryScreen> createState() => _SpaceGlossaryScreenState();
}

class _SpaceGlossaryScreenState extends State<SpaceGlossaryScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  String _selCat = 'All';
  int? _expanded;
  Timer? _debounce;

  static const _cats = ['All', 'Astronomy', 'Physics', 'Cosmology', 'Technology', 'Biology'];

  List<GlossaryTerm> get _filtered {
    var t = List<GlossaryTerm>.from(allGlossaryTerms);
    if (_selCat != 'All') {
      t = t.where((e) => e.category == _selCat).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      t = t.where((e) =>
          e.term.toLowerCase().contains(q) ||
          e.definition.toLowerCase().contains(q)).toList();
    }
    t.sort((a, b) => a.term.compareTo(b.term));
    return t;
  }

  Map<String, List<GlossaryTerm>> get _grouped {
    final m = <String, List<GlossaryTerm>>{};
    for (final t in _filtered) {
      m.putIfAbsent(t.term[0].toUpperCase(), () => []).add(t);
    }
    return m;
  }

  Color _catColor(String category) {
    switch (category) {
      case 'Astronomy': return const Color(0xFF00D4FF);
      case 'Physics': return const Color(0xFF7B5BFF);
      case 'Cosmology': return const Color(0xFFFFB800);
      case 'Technology': return const Color(0xFF00E096);
      case 'Biology': return const Color(0xFFFF5BDB);
      default: return const Color(0xFF7B5BFF);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final letters = grouped.keys.toList()..sort();
    final items = <_Item>[];
    for (final l in letters) {
      items.add(_Item.hdr(l));
      for (final t in grouped[l]!) {
        items.add(_Item.trm(t));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topBar(),
                _searchBar(),
                _catPills(),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? _empty()
                      : ListView.builder(
                          controller: _scrollCtrl,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 36, 30),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final it = items[i];
                            if (it.isHdr) return _sectionHeader(it.letter!);
                            return _termCard(it.glossaryTerm!, i);
                          },
                        ),
                ),
              ],
            ),
            if (_query.isEmpty)
              Positioned(
                right: 2, top: 180, bottom: 20,
                child: _alphaStrip(letters),
              ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context), size: 26),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Space Glossary',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('${allGlossaryTerms.length} space terms explained',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ──
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: CupertinoTextField(
        controller: _searchCtrl,
        placeholder: 'Search terms... e.g. Redshift, Nebula',
        onChanged: _onSearch,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(CupertinoIcons.search,
              size: 18, color: AppColors.accentPurple),
        ),
        suffix: _query.isNotEmpty
            ? CupertinoButton(
                padding: const EdgeInsets.only(right: 10),
                minimumSize: Size.zero,
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
                child: Icon(CupertinoIcons.xmark_circle_fill,
                    size: 18, color: AppColors.textSecondary(context)),
              )
            : null,
        decoration: BoxDecoration(
          color: AppColors.searchBar(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        style: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textPrimary(context)),
        placeholderStyle: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textSecondary(context)),
      ),
    );
  }

  // ── Category pills ──
  Widget _catPills() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final sel = cat == _selCat;
          return GestureDetector(
            onTap: () => setState(() {
              _selCat = cat;
              _expanded = null;
            }),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: sel
                    ? const LinearGradient(
                        colors: [AppColors.accentPurple, AppColors.accentCyan])
                    : null,
                color: sel ? null : AppColors.glass(context),
                border: Border.all(
                    color: sel
                        ? Colors.transparent
                        : AppColors.glassBorder(context)),
              ),
              child: Text(cat,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? Colors.white
                          : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  // ── Section header (A, B, C...) ──
  Widget _sectionHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Text(letter,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentPurple)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Term card — uses Row with left accent strip instead of non-uniform Border ──
  Widget _termCard(GlossaryTerm term, int index) {
    final isExpanded = _expanded == index;
    final cc = _catColor(term.category);

    return GestureDetector(
      onTap: () => setState(() => _expanded = isExpanded ? null : index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isExpanded
              ? AppColors.surface(context)
              : AppColors.card(context),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: _isDark
              ? []
              : [
                  BoxShadow(
                      color: cc.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3)),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored left accent strip
              Container(width: 4, color: cc.withValues(alpha: 0.7)),
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(term.term,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cc.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(term.category,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: cc)),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(CupertinoIcons.chevron_down,
                                size: 14,
                                color: AppColors.textSecondary(context)),
                          ),
                        ],
                      ),
                      // Expanded content
                      if (isExpanded) ...[
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                              height: 1,
                              color: AppColors.divider(context)),
                        ),
                        Text(term.definition,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _isDark
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : const Color(0xFF444460),
                                height: 1.7)),
                        if (term.relatedTerms.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text('Related Terms',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.textSecondary(context))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: term.relatedTerms
                                .map((r) => GestureDetector(
                                      onTap: () => _jump(r),
                                      child: Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: _isDark
                                              ? AppColors.surfaceDark
                                              : const Color(0xFFF0F0FA),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(r,
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors
                                                    .accentPurple)),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Alphabet strip ──
  Widget _alphaStrip(List<String> available) {
    const all = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final avSet = available.toSet();
    return SizedBox(
      width: 18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: all.split('').map((l) {
          final has = avSet.contains(l);
          return GestureDetector(
            onTap: has ? () => _scrollTo(l) : null,
            child: SizedBox(
              height: 18,
              child: Center(
                child: Text(l,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: has
                            ? AppColors.accentPurple
                            : AppColors.textSecondary(context)
                                .withValues(alpha: 0.2))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Empty state ──
  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48,
              color: AppColors.textSecondary(context).withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No terms found for "$_query"',
              style: GoogleFonts.inter(
                  fontSize: 15, color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  void _jump(String t) {
    _searchCtrl.text = t;
    setState(() {
      _query = t;
      _selCat = 'All';
      _expanded = null;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      final f = _filtered;
      final idx = f.indexWhere(
          (e) => e.term.toLowerCase() == t.toLowerCase());
      if (idx >= 0 && mounted) {
        setState(() => _expanded = idx + 1);
      }
    });
  }

  void _scrollTo(String l) {
    final g = _grouped;
    final ls = g.keys.toList()..sort();
    int off = 0;
    for (final k in ls) {
      if (k == l) break;
      off += 1 + g[k]!.length;
    }
    _scrollCtrl.animateTo(
      (off * 65.0).clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _Item {
  final String? letter;
  final GlossaryTerm? glossaryTerm;
  bool get isHdr => letter != null;
  const _Item.hdr(this.letter) : glossaryTerm = null;
  const _Item.trm(this.glossaryTerm) : letter = null;
}
