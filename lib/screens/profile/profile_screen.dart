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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 24),
              _buildStatsRow()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, delay: 100.ms),
              const SizedBox(height: 28),
              _buildSection('Preferences', [
                _buildThemeRow(),
                _divider(),
                _buildToggleRow(
                  Icons.notifications_outlined,
                  'Push Notifications',
                  _notificationsOn,
                  (val) {
                    setState(() => _notificationsOn = val);
                    Hive.box('settings').put('notifications', val);
                    if (val) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Notifications'),
                          content: const Text(
                            'Push notifications will be available in the next update!',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                _divider(),
                _buildNavRow(
                  Icons.favorite_outline,
                  'My Interests',
                  onTap: _showInterestsSheet,
                ),
              ])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, delay: 200.ms),
              const SizedBox(height: 20),
              _buildSection('About', [
                _buildNavRow(
                  Icons.star_outline,
                  'Rate Cosmic Facts',
                  iconColor: AppColors.starGold,
                  onTap: _showRateDialog,
                ),
                _divider(),
                _buildNavRow(
                  Icons.share_outlined,
                  'Share with Friends',
                  onTap: () {
                    try {
                      SharePlus.instance.share(ShareParams(
                        text:
                            '\u{1F30C} Cosmic Facts \u2014 Explore the Universe!\n\n'
                            'Daily space news, NASA images, rocket launches, and 84 space lessons!\n\n'
                            'Download: https://play.google.com/store/apps/details?id=com.cosmicfacts.app',
                      ));
                    } catch (_) {}
                  },
                ),
                _divider(),
                _buildNavRow(
                  Icons.shield_outlined,
                  'Privacy Policy',
                  onTap: () => launchUrl(
                    Uri.parse('https://nih-alt.github.io/cosmic-facts-privacy/'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _divider(),
                _buildNavRow(
                  Icons.info_outline,
                  'About Cosmic Facts',
                  onTap: _showAboutDialog,
                ),
              ])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.05, end: 0, delay: 300.ms),
              const SizedBox(height: 20),
              _buildSection('Data', [
                _buildNavRow(
                  Icons.delete_outline,
                  'Clear Cache',
                  iconColor: AppColors.accentOrange,
                  onTap: _confirmClearCache,
                ),
                _divider(),
                _buildNavRow(
                  Icons.refresh,
                  'Reset App',
                  iconColor: AppColors.error,
                  onTap: _confirmReset,
                ),
              ])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.05, end: 0, delay: 400.ms),
              const SizedBox(height: 32),
              Text(
                'Cosmic Facts v1.0.0',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Made with \u2764\uFE0F in India \u{1F1EE}\u{1F1F3}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondaryDark),
              ),
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
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child:
              const Icon(Icons.person, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 14),
        Text(
          'Space Explorer',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Exploring since March 2026',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('24', 'Articles\nRead')),
        const SizedBox(width: 8),
        Expanded(child: _statCard('$_lessonsDone', 'Lessons\nDone')),
        const SizedBox(width: 8),
        Expanded(child: _statCard('7', 'Day\nStreak')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryDark,
              height: 1.2,
            ),
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
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.06),
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
          Icon(Icons.dark_mode_outlined,
              color: AppColors.accentPurple, size: 22),
          const SizedBox(width: 12),
          Text(
            'Theme',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Obx(() {
            final mode = _themeCtrl.currentModeString;
            return CupertinoSlidingSegmentedControl<String>(
              groupValue: mode,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
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
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TOGGLE ROW
  // ═══════════════════════════════════════

  Widget _buildToggleRow(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.accentPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // NAV ROW
  // ═══════════════════════════════════════

  Widget _buildNavRow(
    IconData icon,
    String label, {
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor ?? AppColors.accentPurple, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style:
                    GoogleFonts.inter(fontSize: 15, color: Colors.white),
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                size: 16, color: AppColors.textSecondaryDark),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // DIALOGS & SHEETS
  // ═══════════════════════════════════════

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
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Rate Us! \u2B50'),
        content: const Text(
          'Enjoying Cosmic Facts? Rate us on the Play Store!',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              launchUrl(
                Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.cosmicfacts.app'),
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
          'This will clear cached news and images. Your lesson progress won\u2019t be affected.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              for (final name in [
                'news_cache',
                'apod_cache',
                'launches_cache',
              ]) {
                final box = await Hive.openBox(name);
                await box.clear();
              }
              if (mounted) {
                Get.showSnackbar(const GetSnackBar(
                  message: 'Cache cleared successfully!',
                  duration: Duration(seconds: 2),
                ));
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
          'This will delete ALL your data including lesson progress, interests, and preferences. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              // Clear all boxes
              for (final name in [
                'settings',
                'learn_progress',
                'news_cache',
                'apod_cache',
                'launches_cache',
              ]) {
                final box = await Hive.openBox(name);
                await box.clear();
              }
              if (mounted) {
                Get.offAll(
                  () => const OnboardingScreen(),
                  transition: Transition.cupertino,
                );
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
    final saved =
        List<String>.from(settings.get('interests', defaultValue: <String>[]) as List);
    final selected = <String>{...saved};

    const allInterests = [
      'Planets',
      'Black Holes',
      'Galaxies',
      'Rocket Launches',
      'ISRO',
      'NASA',
      'Asteroids',
      'Stars',
      'Dark Matter',
      'Exoplanets',
      'Space Exploration',
      'Moons',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Interests',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allInterests.map((interest) {
                    final active = selected.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (active) {
                            selected.remove(interest);
                          } else {
                            selected.add(interest);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accentPurple.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: active
                                ? AppColors.accentPurple
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400,
                            color: active
                                ? AppColors.accentPurple
                                : Colors.white70,
                          ),
                        ),
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
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
