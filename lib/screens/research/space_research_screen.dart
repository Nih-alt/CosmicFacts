// DISCLAIMER: Paper data sourced from arXiv open-access repository (arxiv.org).
// This app is unofficial and not affiliated with arXiv, Cornell University,
// or any research institution.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/research_paper.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

// ─── Accent palette ───────────────────────────────────────────
const _kAccent = Color(0xFF6C63FF);
const _kGreen = Color(0xFF00E676);
const _kCardDark = Color(0xFF141438);
const _kBgDark = Color(0xFF0A0A1A);

// ─── Category themes ──────────────────────────────────────────
const _categoryThemes = <String, (String, Color, IconData, String)>{
  'All': ('astro-ph', _kAccent, Icons.auto_awesome, 'All Space'),
  'Planets': ('astro-ph.EP', Color(0xFF00E676), Icons.public, 'Planets & Exoplanets'),
  'Galaxies': ('astro-ph.GA', Color(0xFF448AFF), Icons.blur_circular, 'Galaxies'),
  'Black Holes': ('astro-ph.HE', Color(0xFFAA00FF), Icons.radio_button_unchecked, 'High Energy & Black Holes'),
  'Cosmology': ('astro-ph.CO', Color(0xFFFFEE58), Icons.all_inclusive, 'Cosmology'),
  'Solar & Stars': ('astro-ph.SR', Color(0xFFFFAB40), Icons.wb_sunny_outlined, 'Solar & Stars'),
  'Missions': ('astro-ph.IM', Color(0xFF00E5FF), Icons.rocket_launch_outlined, 'Instruments & Missions'),
};

Color _getCategoryColor(String category) {
  return _categoryThemes[category]?.$2 ?? _kAccent;
}

class SpaceResearchScreen extends StatefulWidget {
  const SpaceResearchScreen({super.key});

  @override
  State<SpaceResearchScreen> createState() => _SpaceResearchScreenState();
}

class _SpaceResearchScreenState extends State<SpaceResearchScreen> {
  List<ResearchPaper> _papers = [];
  List<ResearchPaper> _filteredPapers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _expandedPaperId;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  int _currentPage = 0;
  bool _hasMore = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadPapers();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMorePapers();
    }
  }

  Future<void> _loadPapers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
    });
    final arxivCat = _categoryThemes[_selectedCategory]?.$1 ?? 'astro-ph';
    final data = await ApiService.getResearchPapers(
      category: arxivCat,
      searchQuery: _searchQuery,
      start: 0,
      maxResults: 20,
    );
    if (!mounted) return;
    setState(() {
      _papers = data;
      _filteredPapers = data;
      _isLoading = false;
      _hasMore = data.length >= 20;
    });
  }

  Future<void> _loadMorePapers() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    final arxivCat = _categoryThemes[_selectedCategory]?.$1 ?? 'astro-ph';
    final data = await ApiService.getResearchPapers(
      category: arxivCat,
      searchQuery: _searchQuery,
      start: _currentPage * 20,
      maxResults: 20,
    );
    if (!mounted) return;
    setState(() {
      _papers.addAll(data);
      _filteredPapers = _papers;
      _isLoadingMore = false;
      if (data.length < 20) _hasMore = false;
    });
  }

  void _onCategoryTap(String cat) {
    setState(() {
      _selectedCategory = cat;
      _expandedPaperId = null;
    });
    _loadPapers();
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _expandedPaperId = null;
    _loadPapers();
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    if (diff < 365) return '${(diff / 30).floor()} months ago';
    return '${date.year}';
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final newPapers = _filteredPapers.where((p) => p.isNew).toList();

    return Scaffold(
      backgroundColor: _isDark ? _kBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _buildCategoryFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (!_isLoading && newPapers.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildNewThisWeekLabel()),
              SliverToBoxAdapter(child: _buildNewThisWeekRow(newPapers)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            if (_isLoading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_filteredPapers.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == _filteredPapers.length) {
                      return _buildLoadingMore();
                    }
                    return _buildPaperCard(_filteredPapers[i], i);
                  },
                  childCount:
                      _filteredPapers.length + (_isLoadingMore || _hasMore ? 1 : 0),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.back,
                  color: AppColors.textPrimary(context), size: 26),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Research Papers',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Latest from arXiv Astrophysics',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 3),
                Text('Source: arXiv.org open access',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textTertiary(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _kAccent.withValues(alpha: 0.15),
            ),
            child: Text(
                '${_filteredPapers.length} papers',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kAccent)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textPrimary(context)),
        onSubmitted: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search papers, authors, topics...',
          hintStyle: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textTertiary(context)),
          prefixIcon:
              Icon(Icons.search, color: AppColors.textTertiary(context)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _searchCtrl.clear();
                    _searchQuery = '';
                    _loadPapers();
                  },
                  child: Icon(CupertinoIcons.clear_circled_solid,
                      color: AppColors.textTertiary(context), size: 18),
                )
              : null,
          filled: true,
          fillColor: _isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CATEGORY FILTERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildCategoryFilters() {
    final cats = _categoryThemes.keys.toList();
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = cats[i];
          final color = _categoryThemes[cat]!.$2;
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategoryTap(cat),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? color
                      : (_isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white : color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(cat,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary(context))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NEW THIS WEEK
  // ═══════════════════════════════════════════════════════════

  Widget _buildNewThisWeekLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text('New This Week',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context))),
    );
  }

  Widget _buildNewThisWeekRow(List<ResearchPaper> papers) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: papers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = papers[i];
          final color = _getCategoryColor(p.category);
          return GestureDetector(
            onTap: () =>
                setState(() => _expandedPaperId = p.id),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    _kBgDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: color.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('NEW',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                      const SizedBox(width: 8),
                      Text(p.category,
                          style: GoogleFonts.inter(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(p.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            height: 1.4)),
                  ),
                  Text(p.authorsDisplay,
                      style: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
          ).animate().fadeIn(
              duration: 350.ms,
              delay: Duration(milliseconds: 60 * i));
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PAPER CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildPaperCard(ResearchPaper paper, int index) {
    final color = _getCategoryColor(paper.category);
    final isExpanded = _expandedPaperId == paper.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark ? _kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? color.withValues(alpha: 0.4)
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: category + NEW + date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(paper.category,
                              style: GoogleFonts.inter(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (paper.isNew) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('NEW',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8)),
                      ),
                    ],
                    const Spacer(),
                    Text(_formatDate(paper.published),
                        style: GoogleFonts.inter(
                            color: _isDark
                                ? Colors.white38
                                : Colors.black38,
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(paper.title,
                    maxLines: isExpanded ? null : 3,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: _isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.4)),
                const SizedBox(height: 8),
                // Authors
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13,
                        color: _isDark
                            ? Colors.white38
                            : Colors.black38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(paper.authorsDisplay,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: _isDark
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Read time + arXiv ID
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12,
                        color: _isDark
                            ? Colors.white38
                            : Colors.black38),
                    const SizedBox(width: 4),
                    Text('~${paper.readTimeMinutes} min read',
                        style: GoogleFonts.inter(
                            color: _isDark
                                ? Colors.white38
                                : Colors.black38,
                            fontSize: 11)),
                    const SizedBox(width: 12),
                    Text('arXiv:${paper.id}',
                        style: GoogleFonts.inter(
                            color: color.withValues(alpha: 0.7),
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Expanded
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _buildExpandedPaper(paper)
                : const SizedBox.shrink(),
          ),

          // Bottom action row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _expandedPaperId = isExpanded ? null : paper.id;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E1E3F)
                          : const Color(0xFFEEEEFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 14,
                          color: _kAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(isExpanded ? 'Less' : 'Abstract',
                            style: GoogleFonts.inter(
                                color: _kAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse(paper.pdfUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text('Open PDF',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
        duration: 350.ms, delay: Duration(milliseconds: 35 * index));
  }

  // ═══════════════════════════════════════════════════════════
  // EXPANDED PAPER
  // ═══════════════════════════════════════════════════════════

  Widget _buildExpandedPaper(ResearchPaper paper) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abstract
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF0E0E2E)
                  : const Color(0xFFF5F5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _kAccent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Abstract',
                    style: GoogleFonts.spaceGrotesk(
                        color: _kAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8)),
                const SizedBox(height: 8),
                Text(paper.abstract,
                    style: GoogleFonts.inter(
                        color: _isDark
                            ? Colors.white70
                            : const Color(0xFF333355),
                        fontSize: 13,
                        height: 1.7)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // All authors (if >3)
          if (paper.authors.length > 3) ...[
            Text('All Authors',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: paper.authors
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? const Color(0xFF1A1A3A)
                              : const Color(0xFFEEEEFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(a,
                            style: GoogleFonts.inter(
                                color: _isDark
                                    ? Colors.white70
                                    : const Color(0xFF333366),
                                fontSize: 11)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Paper details row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _detailChip(
                  '\u{1F4C5} Published: ${_formatDate(paper.published)}'),
              if (paper.updated != paper.published)
                _detailChip(
                    '\u{1F504} Updated: ${_formatDate(paper.updated)}'),
              _detailChip('\u{1F4CB} arXiv: ${paper.id}'),
            ],
          ),
          const SizedBox(height: 12),

          // View on arXiv
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(paper.abstractUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kAccent.withValues(alpha: 0.3)),
                color: _kAccent.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new,
                      size: 14, color: _kAccent),
                  const SizedBox(width: 6),
                  Text('View on arXiv \u2192',
                      style: GoogleFonts.inter(
                          color: _kAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary(context))),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOADING / EMPTY / PAGINATION
  // ═══════════════════════════════════════════════════════════

  Widget _buildShimmer() {
    final base = AppColors.shimmerBase(context);
    final highlight = AppColors.shimmerHighlight(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Text('\u{1F4C4}', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No papers found',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 8),
          Text('Try adjusting your search or category',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textTertiary(context))),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _kAccent,
            ),
          ),
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text('All papers loaded',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary(context))),
        ),
      );
    }
    return const SizedBox(height: 60);
  }
}
