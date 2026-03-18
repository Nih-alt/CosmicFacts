import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _themeCtrl = Get.find<ThemeController>();
  bool _notificationsOn = false;
  int _lessonsDone = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final settings = Hive.box('settings');
    _notificationsOn =
        settings.get('notifications', defaultValue: false) == true;
    final progressBox = await Hive.openBox('learn_progress');
    int count = 0;
    for (final key in progressBox.keys) {
      if (progressBox.get(key) == true) count++;
    }
    if (mounted) setState(() => _lessonsDone = count);
  }

  // Rank based on lessons
  (String emoji, String title) get _rank {
    if (_lessonsDone >= 50) return ('\u{1F52D}', 'Cosmic Legend');
    if (_lessonsDone >= 31) return ('\u{1F30C}', 'Galaxy Master');
    if (_lessonsDone >= 16) return ('\u2B50', 'Star Navigator');
    if (_lessonsDone >= 6) return ('\u{1F680}', 'Space Explorer');
    return ('\u{1F331}', 'Space Seedling');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildHero()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              _buildStatsRow()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, delay: 100.ms),
              const SizedBox(height: 20),
              _buildJourney()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideY(begin: 0.05, end: 0, delay: 150.ms),
              const SizedBox(height: 24),
              _buildSection('Preferences', [
                _buildThemeRow(),
                _divider(),
                _buildIconRow(Icons.notifications_outlined, const Color(0xFF00D4FF),
                    'Push Notifications', trailing: _notificationSwitch()),
                _divider(),
                _buildIconRow(Icons.favorite_outline, const Color(0xFFE040FB),
                    'My Interests', onTap: _showInterestsSheet),
              ]).animate().fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, delay: 200.ms),
              const SizedBox(height: 20),
              _buildSection('About', [
                _buildIconRow(Icons.star_outline, AppColors.starGold,
                    'Rate Cosmic Facts', onTap: _showRateDialog),
                _divider(),
                _buildIconRow(Icons.share_outlined, AppColors.success,
                    'Share with Friends', onTap: _shareApp),
                _divider(),
                _buildIconRow(Icons.shield_outlined, const Color(0xFF4A90D9),
                    'Privacy Policy', onTap: _openPrivacy),
                _divider(),
                _buildIconRow(Icons.info_outline, AppColors.accentPurple,
                    'About Cosmic Facts', onTap: _showAboutDialog),
              ]).animate().fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.05, end: 0, delay: 300.ms),
              const SizedBox(height: 20),
              _buildSection('Data', [
                _buildIconRow(Icons.delete_outline, AppColors.accentOrange,
                    'Clear Cache', onTap: _confirmClearCache),
                _divider(),
                _buildIconRow(Icons.refresh, AppColors.error,
                    'Reset App', onTap: _confirmReset),
              ]).animate().fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.05, end: 0, delay: 400.ms),
              const SizedBox(height: 28),
              _buildFooter(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════

  Widget _buildHero() {
    final rank = _rank;
    return Column(
      children: [
        // Avatar with glow ring
        Container(
          width: 92, height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20, spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background(context),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Space Explorer',
            style: GoogleFonts.spaceGrotesk(fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context))),
        const SizedBox(height: 4),
        Text('Exploring since March 2026',
            style: GoogleFonts.inter(fontSize: 13,
                color: AppColors.textSecondary(context))),
        const SizedBox(height: 10),
        // Rank badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.25),
                blurRadius: 8, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('${rank.$1} ${rank.$2}',
              style: GoogleFonts.inter(fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white)),
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
      ],
    );
  }

  // ═══════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('\u{1F4F0}', '24', 'Articles Read', const Color(0xFF4A90D9))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('\u{1F4DA}', '$_lessonsDone', 'Lessons Done', AppColors.accentPurple)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('\u{1F525}', '7', 'Day Streak', AppColors.starGold)),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color accent) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: _isDark
            ? Border.all(color: AppColors.glassBorder(context))
            : Border(top: BorderSide(color: accent, width: 3)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.spaceGrotesk(fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 10,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // JOURNEY MILESTONES
  // ═══════════════════════════════════════

  Widget _buildJourney() {
    final milestones = [
      ('Joined', true),
      ('1st Lesson', _lessonsDone >= 1),
      ('10 Lessons', _lessonsDone >= 10),
      ('All Topics', _lessonsDone >= 30),
      ('Legend', _lessonsDone >= 50),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Journey',
              style: GoogleFonts.spaceGrotesk(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context))),
          const SizedBox(height: 14),
          Row(
            children: List.generate(milestones.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connecting line
                final done = milestones[(i ~/ 2) + 1].$2;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? AppColors.accentPurple
                        : AppColors.divider(context),
                  ),
                );
              }
              final idx = i ~/ 2;
              final done = milestones[idx].$2;
              final label = milestones[idx].$1;
              return Column(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.accentPurple : Colors.transparent,
                      border: Border.all(
                        color: done
                            ? AppColors.accentPurple
                            : AppColors.textSecondary(context).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(label,
                      style: GoogleFonts.inter(fontSize: 9,
                          fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                          color: done
                              ? AppColors.textPrimary(context)
                              : AppColors.textSecondary(context))),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // SECTION CARD
  // ═══════════════════════════════════════

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(title,
                  style: GoogleFonts.spaceGrotesk(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary(context))),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPurple.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder(context)),
            boxShadow: AppColors.cardShadow(context),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.divider(context),
      );

  // ═══════════════════════════════════════
  // ICON ROW (with colored circle)
  // ═══════════════════════════════════════

  Widget _buildIconRow(IconData icon, Color iconColor, String label,
      {VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: _isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(fontSize: 15,
                      color: AppColors.textPrimary(context))),
            ),
            if (trailing != null)
              trailing
            else
              Icon(CupertinoIcons.chevron_right, size: 16,
                  color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // THEME ROW
  // ═══════════════════════════════════════

  Widget _buildThemeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: _isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.dark_mode_outlined,
                color: AppColors.accentPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Theme',
              style: GoogleFonts.inter(fontSize: 15,
                  color: AppColors.textPrimary(context))),
          const Spacer(),
          Obx(() {
            final mode = _themeCtrl.currentModeString;
            return CupertinoSlidingSegmentedControl<String>(
              groupValue: mode,
              backgroundColor: _isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF0ECF8),
              thumbColor: AppColors.accentPurple,
              children: {
                'dark': _segmentLabel('Dark'),
                'system': _segmentLabel('Auto'),
                'light': _segmentLabel('Light'),
              },
              onValueChanged: (val) {
                if (val != null) _themeCtrl.setTheme(val);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _segmentLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(text,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context))),
    );
  }

  Widget _notificationSwitch() {
    return CupertinoSwitch(
      value: _notificationsOn,
      activeTrackColor: AppColors.accentPurple,
      onChanged: (val) {
        setState(() => _notificationsOn = val);
        Hive.box('settings').put('notifications', val);
        if (val) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Notifications'),
              content: const Text('Push notifications will be available in the next update!'),
              actions: [
                CupertinoDialogAction(isDefaultAction: true,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK')),
              ],
            ),
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════
  // FOOTER
  // ═══════════════════════════════════════

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentPurple.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text('Cosmic Facts',
              style: GoogleFonts.spaceGrotesk(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
          const SizedBox(width: 6),
          Text('v1.0.0 \u2022 Made with \u2764\uFE0F in India \u{1F1EE}\u{1F1F3}',
              style: GoogleFonts.inter(fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════

  void _shareApp() {
    try {
      SharePlus.instance.share(ShareParams(
        text: '\u{1F30C} Cosmic Facts \u2014 Explore the Universe!\n\n'
            'Daily space news, NASA images, rocket launches, and 84 space lessons!\n\n'
            'Download: https://play.google.com/store/apps/details?id=com.cosmicfacts.app',
      ));
    } catch (_) {}
  }

  void _openPrivacy() => launchUrl(
        Uri.parse('https://nih-alt.github.io/cosmic-facts-privacy/'),
        mode: LaunchMode.externalApplication,
      );

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cosmic Facts \u{1F30C}'),
        content: const Text(
          'Version 1.0.0\n\n'
          'Your daily companion for space knowledge and discovery.\n\n'
          'Explore the universe with daily news, stunning NASA images, '
          'rocket launch tracking, and 84 educational lessons across '
          '12 space topics.\n\n'
          'Made with \u2764\uFE0F in India \u{1F1EE}\u{1F1F3}',
        ),
        actions: [
          CupertinoDialogAction(isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  void _showRateDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Rate Us! \u2B50'),
        content: const Text('Enjoying Cosmic Facts? Rate us on the Play Store!'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              launchUrl(
                Uri.parse('https://play.google.com/store/apps/details?id=com.cosmicfacts.app'),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
            'This will clear cached news and images. Your lesson progress won\u2019t be affected.'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              for (final name in ['news_cache', 'apod_cache', 'launches_cache']) {
                final box = await Hive.openBox(name);
                await box.clear();
              }
              if (mounted) {
                Get.showSnackbar(const GetSnackBar(
                    message: 'Cache cleared successfully!',
                    duration: Duration(seconds: 2)));
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Reset Everything?'),
        content: const Text(
            'This will delete ALL your data including lesson progress, interests, and preferences. This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              for (final name in [
                'settings', 'learn_progress', 'news_cache', 'apod_cache', 'launches_cache',
              ]) {
                final box = await Hive.openBox(name);
                await box.clear();
              }
              if (mounted) {
                Get.offAll(() => const OnboardingScreen(),
                    transition: Transition.cupertino);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showInterestsSheet() {
    final settings = Hive.box('settings');
    final saved = List<String>.from(
        settings.get('interests', defaultValue: <String>[]) as List);
    final selected = <String>{...saved};

    const allInterests = [
      'Planets', 'Black Holes', 'Galaxies', 'Rocket Launches',
      'ISRO', 'NASA', 'Asteroids', 'Stars',
      'Dark Matter', 'Exoplanets', 'Space Exploration', 'Moons',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.divider(context),
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Your Interests',
                    style: GoogleFonts.spaceGrotesk(fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: allInterests.map((interest) {
                    final active = selected.contains(interest);
                    return GestureDetector(
                      onTap: () => setSheetState(() {
                        active ? selected.remove(interest) : selected.add(interest);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accentPurple.withValues(alpha: 0.2)
                              : AppColors.glass(context),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: active
                              ? AppColors.accentPurple
                              : AppColors.glassBorder(context)),
                        ),
                        child: Text(interest,
                            style: GoogleFonts.inter(fontSize: 14,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                color: active
                                    ? AppColors.accentPurple
                                    : AppColors.textSecondary(context))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    settings.put('interests', selected.toList());
                    Navigator.pop(ctx);
                    Get.showSnackbar(const GetSnackBar(
                        message: 'Interests updated!',
                        duration: Duration(seconds: 2)));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Save',
                          style: GoogleFonts.inter(fontSize: 16,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
