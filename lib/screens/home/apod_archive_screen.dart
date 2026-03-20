import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:get/get.dart';

import '../../constants/api_keys.dart';
import '../../controllers/bookmark_controller.dart';
import '../../models/bookmark_model.dart';
import '../../theme/app_colors.dart';

class ApodArchiveScreen extends StatefulWidget {
  final String? initialDate;
  const ApodArchiveScreen({super.key, this.initialDate});

  @override
  State<ApodArchiveScreen> createState() => _ApodArchiveScreenState();
}

class _ApodArchiveScreenState extends State<ApodArchiveScreen> {
  late DateTime _date;
  Map<String, dynamic>? _apod;
  bool _loading = true;
  bool _error = false;

  static final _minDate = DateTime(1995, 6, 16);
  static final _dateFmt = DateFormat('MMMM d, yyyy');
  static final _apiFmt = DateFormat('yyyy-MM-dd');

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  /// NASA APOD is published on US Eastern Time (UTC-5).
  /// This returns the current date in that timezone so Indian users
  /// (UTC+5:30) don't request a date that hasn't been published yet.
  static DateTime _nasaCurrentDate() {
    final utcNow = DateTime.now().toUtc();
    final usEastern = utcNow.subtract(const Duration(hours: 5));
    return DateTime(usEastern.year, usEastern.month, usEastern.day);
  }

  bool get _canGoForward => _date.isBefore(_nasaCurrentDate());

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _date = DateTime.tryParse(widget.initialDate!) ?? _nasaCurrentDate();
    } else {
      // Start 2 days behind NASA date — guaranteed to be published
      _date = _nasaCurrentDate().subtract(const Duration(days: 2));
    }
    _fetchApod(_date);
  }

  /// Fetch APOD with automatic fallback — on ANY failure, try the previous
  /// day automatically (up to 3 attempts) so the user always sees content.
  Future<void> _fetchApod(DateTime date, {int retryCount = 0}) async {
    if (!mounted) return;
    if (retryCount > 3) {
      setState(() { _error = true; _loading = false; });
      return;
    }

    setState(() { _loading = true; _error = false; });

    final dateStr = _apiFmt.format(date);
    final url =
        'https://api.nasa.gov/planetary/apod?api_key=${ApiKeys.nasaApiKey}&date=$dateStr';

    debugPrint('APOD: requesting $dateStr (attempt ${retryCount + 1})');

    try {
      final resp =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      debugPrint('APOD: status ${resp.statusCode} for $dateStr');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data != null && data['title'] != null) {
          debugPrint('APOD: loaded "${data['title']}"');
          setState(() {
            _apod = data as Map<String, dynamic>;
            _date = date;
            _loading = false;
          });
          return;
        }
      }

      // Any non-200 or invalid data → try previous day
      debugPrint('APOD: failed for $dateStr, trying previous day');
      _fetchApod(date.subtract(const Duration(days: 1)), retryCount: retryCount + 1);
    } catch (e) {
      debugPrint('APOD: exception for $dateStr: $e');
      _fetchApod(date.subtract(const Duration(days: 1)), retryCount: retryCount + 1);
    }
  }

  void _changeDate(int delta) {
    final next = _date.add(Duration(days: delta));
    if (next.isBefore(_minDate) || next.isAfter(_nasaCurrentDate())) return;
    _fetchApod(next);
  }

  void _goToDate(DateTime d) => _fetchApod(d);

  void _randomDate() {
    // Use one day before NASA date to guarantee it exists
    final safeMax = _nasaCurrentDate().subtract(const Duration(days: 1));
    final range = safeMax.difference(_minDate).inDays;
    if (range <= 0) return;
    final random = _minDate.add(Duration(days: Random().nextInt(range)));
    _goToDate(random);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            if (d.primaryVelocity == null) return;
            if (d.primaryVelocity! < -200 && _canGoForward) {
              _changeDate(1);
            } else if (d.primaryVelocity! > 200) {
              _changeDate(-1);
            }
          },
          child: Column(
            children: [
              _topBar(),
              _datePicker(),
              Expanded(
                child: _loading
                    ? _shimmer()
                    : _error
                        ? _errorView()
                        : _apod != null
                            ? _content()
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                Text('APOD Archive',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text('Daily space photos since 1995',
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

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              _arrowBtn(
                CupertinoIcons.chevron_left,
                !_date.isAtSameMomentAs(_minDate)
                    ? () => _changeDate(-1)
                    : null,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showDatePicker,
                  child: Text(
                    _dateFmt.format(_date),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context)),
                  ),
                ),
              ),
              _arrowBtn(
                CupertinoIcons.chevron_right,
                _canGoForward ? () => _changeDate(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('(NASA US Eastern Time)',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _quickBtn('Today', () => _goToDate(_nasaCurrentDate())),
              const SizedBox(width: 10),
              _quickBtn('Random', _randomDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glass(context),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: Icon(icon,
            size: 16,
            color: enabled
                ? AppColors.textPrimary(context)
                : AppColors.textSecondary(context).withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _quickBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentPurple)),
      ),
    );
  }

  void _showDatePicker() {
    DateTime tempDate = _date;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.surface(ctx),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textSecondary(ctx)
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary(ctx))),
                        onPressed: () => Navigator.pop(ctx)),
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Done',
                            style: GoogleFonts.inter(
                                color: AppColors.accentPurple,
                                fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _goToDate(tempDate);
                        }),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                      brightness:
                          _isDark ? Brightness.dark : Brightness.light),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _date,
                    minimumDate: _minDate,
                    maximumDate: _nasaCurrentDate(),
                    onDateTimeChanged: (d) => tempDate = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final a = _apod!;
    final title = a['title'] as String? ?? '';
    final explanation = a['explanation'] as String? ?? '';
    final imageUrl = a['url'] as String? ?? '';
    final hdUrl = a['hdurl'] as String? ?? '';
    final mediaType = a['media_type'] as String? ?? 'image';
    final date = a['date'] as String? ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: mediaType == 'image' && imageUrl.isNotEmpty
                ? InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                      placeholder: (_, _) => _shimmerBox(300),
                      errorWidget: (_, _, _) => Container(
                          height: 300,
                          color: AppColors.card(context),
                          child: Icon(CupertinoIcons.photo,
                              size: 48,
                              color: AppColors.textSecondary(context))),
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.play_circle,
                            size: 48, color: AppColors.accentPurple),
                        const SizedBox(height: 8),
                        Text('Video APOD',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary(context))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _openUrl(imageUrl),
                          child: Text('Watch on YouTube',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentPurple)),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 4),
          Text(date,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPurple)),
          const SizedBox(height: 16),

          // Explanation
          Text(explanation,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary(context),
                  height: 1.7)),
          const SizedBox(height: 20),

          // HD button
          if (hdUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _openUrl(hdUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.glass(context),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.glassBorder(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.arrow_up_right_square,
                          size: 16, color: AppColors.accentCyan),
                      const SizedBox(width: 8),
                      Text('View HD Version',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentCyan)),
                    ],
                  ),
                ),
              ),
            ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [
                      AppColors.accentPurple,
                      AppColors.accentCyan
                    ]),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(14),
                    onPressed: () {
                      if (hdUrl.isNotEmpty) {
                        _openUrl(hdUrl);
                      } else if (imageUrl.isNotEmpty) {
                        _openUrl(imageUrl);
                      }
                    },
                    child: Text('Download HD',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48, width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.glass(context),
                  border: Border.all(color: AppColors.glassBorder(context)),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    text: '$title\n\nNASA Astronomy Picture of the Day ($date)\n$imageUrl\n\nvia Cosmic Facts',
                  )),
                  child: Icon(CupertinoIcons.share, size: 20, color: AppColors.textPrimary(context)),
                ),
              ),
              const SizedBox(width: 8),
              // Bookmark
              Obx(() {
                final bmCtrl = Get.find<BookmarkController>();
                final bmId = 'apod_$date';
                final saved = bmCtrl.isBookmarked(bmId);
                return Container(
                  height: 48, width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.glass(context),
                    border: Border.all(color: AppColors.glassBorder(context)),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => bmCtrl.toggleBookmark(BookmarkModel(
                      id: bmId, type: 'apod', title: title,
                      subtitle: date, imageUrl: imageUrl,
                      data: jsonEncode(_apod), savedAt: DateTime.now(),
                    )),
                    child: Icon(saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 20, color: saved ? AppColors.error : AppColors.textPrimary(context)),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase(context),
        highlightColor: AppColors.shimmerHighlight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 16),
            Container(height: 24, width: 250, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 120, color: Colors.white),
            const SizedBox(height: 16),
            Container(
                height: 14,
                width: double.infinity,
                color: Colors.white),
            const SizedBox(height: 6),
            Container(
                height: 14,
                width: double.infinity,
                color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 14, width: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Container(height: h, color: Colors.white),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            Text("Couldn't load this photo",
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 8),
            Text(
                "NASA may not have published this date's photo yet.\nTry a previous date or check your connection.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Try yesterday
                GestureDetector(
                  onTap: () {
                    final prev = _date.subtract(const Duration(days: 1));
                    _fetchApod(prev);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.accentPurple,
                        AppColors.accentCyan,
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Try Yesterday',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                // Retry
                GestureDetector(
                  onTap: () => _fetchApod(_date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.accentPurple),
                    ),
                    child: Text('Retry',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentPurple)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
