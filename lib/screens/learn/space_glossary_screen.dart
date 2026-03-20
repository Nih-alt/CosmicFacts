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
  String _selectedCategory = 'All';
  int? _expandedIndex;
  Timer? _debounce;

  static const _categories = ['All', 'Astronomy', 'Physics', 'Cosmology', 'Technology', 'Biology'];
  static const _catColors = [
    AppColors.accentPurple, AppColors.accentCyan, AppColors.accentOrange,
    AppColors.starGold, AppColors.success, AppColors.error,
  ];

  List<GlossaryTerm> get _filteredTerms {
    var terms = List<GlossaryTerm>.from(allGlossaryTerms);
    if (_selectedCategory != 'All') {
      terms = terms.where((t) => t.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      terms = terms.where((t) =>
          t.term.toLowerCase().contains(q) ||
          t.definition.toLowerCase().contains(q)).toList();
    }
    terms.sort((a, b) => a.term.compareTo(b.term));
    return terms;
  }

  Map<String, List<GlossaryTerm>> get _grouped {
    final map = <String, List<GlossaryTerm>>{};
    for (final t in _filteredTerms) {
      final letter = t.term[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(t);
    }
    return map;
  }

  Set<String> get _availableLetters => _grouped.keys.toSet();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  Color _catColor(String cat) {
    final i = _categories.indexOf(cat);
    return i >= 0 ? _catColors[i] : AppColors.accentPurple;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final letters = grouped.keys.toList()..sort();

    // Build flat list with section headers
    final items = <_ListItem>[];
    for (final letter in letters) {
      items.add(_ListItem.header(letter));
      for (final term in grouped[letter]!) {
        items.add(_ListItem.term(term));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                _buildSearchBar(),
                _buildCategoryPills(),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          controller: _scrollCtrl,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 36, 30),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final item = items[i];
                            if (item.isHeader) return _buildSectionHeader(item.letter!);
                            return _buildTermCard(item.glossaryTerm!, i);
                          },
                        ),
                ),
              ],
            ),
            // Alphabet quick jump
            if (_query.isEmpty)
              Positioned(
                right: 2,
                top: 190,
                bottom: 20,
                child: _buildAlphabetStrip(letters),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('${allGlossaryTerms.length} space terms explained',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: CupertinoTextField(
        controller: _searchCtrl,
        placeholder: 'Search terms... e.g. Redshift, Nebula',
        onChanged: _onSearch,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(CupertinoIcons.search,
              size: 18, color: AppColors.textSecondary(context)),
        ),
        suffix: _query.isNotEmpty
            ? CupertinoButton(
                padding: const EdgeInsets.only(right: 8),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        style: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textPrimary(context)),
        placeholderStyle: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textSecondary(context)),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = cat;
              _expandedIndex = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accentPurple
                    : AppColors.glass(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.accentPurple
                      : AppColors.glassBorder(context),
                ),
              ),
              child: Text(cat,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Row(
        children: [
          Text(letter,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentPurple)),
          const SizedBox(width: 10),
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

  Widget _buildTermCard(GlossaryTerm term, int index) {
    final isExpanded = _expandedIndex == index;
    final catColor = _catColor(term.category);

    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? catColor.withValues(alpha: 0.3)
                : AppColors.glassBorder(context),
          ),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(term.category,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: catColor)),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 14,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Text(term.definition,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                      height: 1.5)),
              if (term.relatedTerms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Related:',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: term.relatedTerms.map((r) => GestureDetector(
                    onTap: () => _jumpToTerm(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(r,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentPurple)),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetStrip(List<String> letters) {
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final available = _availableLetters;

    return SizedBox(
      width: 18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: allLetters.split('').map((l) {
          final has = available.contains(l);
          return GestureDetector(
            onTap: has ? () => _scrollToLetter(l) : null,
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
                                .withValues(alpha: 0.3))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u{1F680}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No terms found for "$_query"',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  void _jumpToTerm(String termName) {
    _searchCtrl.text = termName;
    setState(() {
      _query = termName;
      _selectedCategory = 'All';
      _expandedIndex = null;
    });
    // Auto-expand if exact match
    Future.delayed(const Duration(milliseconds: 100), () {
      final filtered = _filteredTerms;
      final idx = filtered.indexWhere(
          (t) => t.term.toLowerCase() == termName.toLowerCase());
      if (idx >= 0 && mounted) {
        setState(() => _expandedIndex = idx + 1); // +1 for section header
      }
    });
  }

  void _scrollToLetter(String letter) {
    final grouped = _grouped;
    final letters = grouped.keys.toList()..sort();
    int offset = 0;
    for (final l in letters) {
      if (l == letter) break;
      offset += 1 + grouped[l]!.length; // header + terms
    }
    // Approximate scroll position
    final pos = offset * 65.0;
    _scrollCtrl.animateTo(
      pos.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _ListItem {
  final String? letter;
  final GlossaryTerm? glossaryTerm;
  bool get isHeader => letter != null;

  const _ListItem.header(this.letter) : glossaryTerm = null;
  const _ListItem.term(this.glossaryTerm) : letter = null;
}
