import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/space_quotes_data.dart';
import '../../theme/app_colors.dart';

// ═════════════════════════════════════════════
// CATEGORY DATA
// ═════════════════════════════════════════════

class _QuoteCategory {
  final String label;
  final Color color;
  const _QuoteCategory(this.label, this.color);
}

const _categories = [
  _QuoteCategory('All', AppColors.accentPurple),
  _QuoteCategory('Exploration', AppColors.accentCyan),
  _QuoteCategory('Universe', AppColors.accentPurple),
  _QuoteCategory('Science', AppColors.starGold),
  _QuoteCategory('India', Color(0xFFFF9933)),
  _QuoteCategory('Humanity', AppColors.success),
];

Color _categoryColor(String category) {
  switch (category) {
    case 'Exploration':
      return AppColors.accentCyan;
    case 'Universe':
      return AppColors.accentPurple;
    case 'Science':
      return AppColors.starGold;
    case 'India':
      return const Color(0xFFFF9933);
    case 'Humanity':
      return AppColors.success;
    default:
      return AppColors.accentPurple;
  }
}

// ═════════════════════════════════════════════
// DAILY QUOTE LOGIC
// ═════════════════════════════════════════════

SpaceQuote getDailyQuote() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return allSpaceQuotes[dayOfYear % allSpaceQuotes.length];
}

// ═════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════

class SpaceQuotesScreen extends StatefulWidget {
  const SpaceQuotesScreen({super.key});

  @override
  State<SpaceQuotesScreen> createState() => _SpaceQuotesScreenState();
}

class _SpaceQuotesScreenState extends State<SpaceQuotesScreen> {
  String _selectedCategory = 'All';
  final _bookmarked = <int>{};

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<SpaceQuote> get _filteredQuotes {
    if (_selectedCategory == 'All') return allSpaceQuotes;
    return allSpaceQuotes.where((q) => q.category == _selectedCategory).toList();
  }

  void _shareQuote(SpaceQuote quote) {
    try {
      SharePlus.instance.share(ShareParams(
        text: '\u201C${quote.quote}\u201D \u2014 ${quote.author} \u{1F30C}\n\nDiscover more on Cosmic Facts',
      ));
    } catch (_) {}
  }

  void _showFullScreenQuote(SpaceQuote quote) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenQuote(quote: quote),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuote = getDailyQuote();
    final filtered = _filteredQuotes;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Quote of the Day hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeroCard(dailyQuote),
              ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.97, 0.97),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
            ),

            // Category pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildCategoryPills(),
              ),
            ),

            // Quotes list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final quote = filtered[index];
                    final globalIndex = allSpaceQuotes.indexOf(quote);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuoteCard(quote, globalIndex, index),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(context)),
              ),
              child: Icon(CupertinoIcons.back, size: 18,
                  color: AppColors.textPrimary(context)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Space Quotes',
                    style: GoogleFonts.spaceGrotesk(fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Words that inspired the cosmos',
                    style: GoogleFonts.inter(fontSize: 13,
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO CARD (Quote of the Day)
  // ═══════════════════════════════════════

  Widget _buildHeroCard(SpaceQuote quote) {
    return GestureDetector(
      onTap: () => _showFullScreenQuote(quote),
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A1060), Color(0xFF0A0A30), Color(0xFF061040)],
                )
              : null,
          color: _isDark ? null : Colors.white,
          boxShadow: _isDark
              ? [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8))]
              : [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            // Star dots (dark mode only)
            if (_isDark)
              ...List.generate(12, (i) {
                final rng = Random(i * 17);
                return Positioned(
                  left: rng.nextDouble() * 340,
                  top: rng.nextDouble() * 240,
                  child: Container(
                    width: 1.5 + rng.nextDouble(),
                    height: 1.5 + rng.nextDouble(),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3 + rng.nextDouble() * 0.3),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true),
                      delay: Duration(milliseconds: rng.nextInt(2000)))
                      .fadeIn(duration: Duration(milliseconds: 1200 + rng.nextInt(1200)))
                      .then()
                      .fadeOut(duration: Duration(milliseconds: 1200 + rng.nextInt(1200))),
                );
              }),

            // Large quote mark
            Positioned(
              left: 20,
              top: 16,
              child: Text(
                '\u201C',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentPurple.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Quote of the Day',
                        style: GoogleFonts.inter(fontSize: 11,
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: Text(
                        quote.quote,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _isDark ? Colors.white : const Color(0xFF1A1A2E),
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u2014 ${quote.author}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _categoryColor(quote.category).withValues(alpha: _isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      quote.role,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _categoryColor(quote.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Share button
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () => _shareQuote(quote),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.accentPurple.withValues(alpha: 0.1),
                  ),
                  child: Icon(CupertinoIcons.share, size: 16,
                      color: _isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.accentPurple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CATEGORY PILLS
  // ═══════════════════════════════════════

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat.label;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : (_isDark ? const Color(0xFF141438) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFEEECF5),
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 8)]
                    : AppColors.cardShadow(context),
              ),
              child: Text(
                cat.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (_isDark ? Colors.white : const Color(0xFF1A1A2E)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // QUOTE CARD
  // ═══════════════════════════════════════

  Widget _buildQuoteCard(SpaceQuote quote, int globalIndex, int animIndex) {
    final catColor = _categoryColor(quote.category);
    final isBookmarked = _bookmarked.contains(globalIndex);

    return GestureDetector(
      onTap: () => _showFullScreenQuote(quote),
      child: Container(
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF141438) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFEEECF5),
          ),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Stack(
                  children: [
                    // Background quote marks
                    Positioned(
                      right: 16,
                      top: 12,
                      child: Text(
                        '\u201C',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: catColor.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.quote,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary(context),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quote.author,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      quote.role,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isBookmarked) {
                                      _bookmarked.remove(globalIndex);
                                    } else {
                                      _bookmarked.add(globalIndex);
                                    }
                                  });
                                },
                                child: Icon(
                                  isBookmarked
                                      ? CupertinoIcons.bookmark_fill
                                      : CupertinoIcons.bookmark,
                                  size: 18,
                                  color: isBookmarked
                                      ? AppColors.starGold
                                      : AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _shareQuote(quote),
                                child: Icon(
                                  CupertinoIcons.share,
                                  size: 18,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 350.ms,
      delay: Duration(milliseconds: 40 * (animIndex.clamp(0, 10))),
    );
  }
}

// ═════════════════════════════════════════════
// FULL SCREEN QUOTE (poster mode)
// ═════════════════════════════════════════════

class _FullScreenQuote extends StatelessWidget {
  final SpaceQuote quote;
  const _FullScreenQuote({required this.quote});

  bool _isDarkOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkOf(context);
    final catColor = _categoryColor(quote.category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background stars (dark only)
          if (isDark)
            ...List.generate(25, (i) {
              final rng = Random(i * 31);
              final size = MediaQuery.sizeOf(context);
              return Positioned(
                left: rng.nextDouble() * size.width,
                top: rng.nextDouble() * size.height,
                child: Container(
                  width: 1.5 + rng.nextDouble(),
                  height: 1.5 + rng.nextDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4 + rng.nextDouble() * 0.4),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true),
                    delay: Duration(milliseconds: rng.nextInt(2000)))
                    .fadeIn(duration: Duration(milliseconds: 1000 + rng.nextInt(1500)))
                    .then()
                    .fadeOut(duration: Duration(milliseconds: 1000 + rng.nextInt(1500))),
              );
            }),

          // Large decorative quote mark
          Positioned(
            left: 30,
            top: MediaQuery.of(context).size.height * 0.15,
            child: Text(
              '\u201C',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 120,
                fontWeight: FontWeight.w700,
                color: catColor.withValues(alpha: isDark ? 0.1 : 0.08),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          child: Icon(CupertinoIcons.xmark, size: 18,
                              color: AppColors.textPrimary(context)),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          try {
                            SharePlus.instance.share(ShareParams(
                              text: '\u201C${quote.quote}\u201D \u2014 ${quote.author} \u{1F30C}\n\nDiscover more on Cosmic Facts',
                            ));
                          } catch (_) {}
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.accentPurple.withValues(alpha: 0.1),
                          ),
                          child: Icon(CupertinoIcons.share, size: 18,
                              color: isDark ? Colors.white : AppColors.accentPurple),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          quote.quote,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0),

                        const SizedBox(height: 28),

                        Container(
                          width: 40, height: 2,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms)
                            .scaleX(begin: 0, end: 1, delay: 200.ms),

                        const SizedBox(height: 20),

                        Text(
                          quote.author,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            quote.role,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: catColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ShaderMask(
                    shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                    child: Text('Cosmic Facts',
                        style: GoogleFonts.spaceGrotesk(fontSize: 14,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
