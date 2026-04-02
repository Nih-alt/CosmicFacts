import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/firebase_notification_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool _masterEnabled;
  late bool _dailyFact;
  late bool _apod;
  late bool _quiz;
  late bool _launchAlerts;
  late bool _newsAlerts;
  late bool _asteroidAlerts;
  late bool _eventAlerts;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    final settings = Hive.box('settings');
    _masterEnabled =
        settings.get('notifications_enabled', defaultValue: false) == true;
    _dailyFact = settings.get('notif_daily_fact', defaultValue: true) == true;
    _apod = settings.get('notif_apod', defaultValue: true) == true;
    _quiz = settings.get('notif_quiz', defaultValue: true) == true;
    _launchAlerts =
        settings.get('notify_launches', defaultValue: true) == true;
    _newsAlerts = settings.get('notify_news', defaultValue: true) == true;
    _asteroidAlerts =
        settings.get('notify_asteroids', defaultValue: true) == true;
    _eventAlerts = settings.get('notify_events', defaultValue: true) == true;
  }

  Future<void> _saveLocal() async {
    final settings = Hive.box('settings');
    await settings.put('notifications_enabled', _masterEnabled);
    await settings.put('notif_daily_fact', _dailyFact);
    await settings.put('notif_apod', _apod);
    await settings.put('notif_quiz', _quiz);
    await settings.put('notifications', _masterEnabled);

    await NotificationService.cancelAll();
    if (_masterEnabled) {
      if (_dailyFact) await NotificationService.scheduleDailyFact();
      if (_apod) await NotificationService.scheduleApodReminder();
      if (_quiz) await NotificationService.scheduleQuizReminder();
    }
  }

  Future<void> _savePush() async {
    final settings = Hive.box('settings');
    await settings.put('notify_launches', _launchAlerts);
    await settings.put('notify_news', _newsAlerts);
    await settings.put('notify_asteroids', _asteroidAlerts);
    await settings.put('notify_events', _eventAlerts);

    if (_masterEnabled) {
      await FirebaseNotificationService.subscribeToTopics();
    } else {
      await FirebaseNotificationService.unsubscribeFromAll();
    }
  }

  Future<void> _toggleMaster(bool val) async {
    setState(() => _masterEnabled = val);
    final settings = Hive.box('settings');
    await settings.put('notifications_enabled', val);
    await settings.put('notifications', val);

    if (val) {
      // Re-enable everything
      await _saveLocal();
      await FirebaseNotificationService.subscribeToTopics();
    } else {
      // Disable everything
      await NotificationService.cancelAll();
      await FirebaseNotificationService.unsubscribeFromAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(CupertinoIcons.back,
                        color: AppColors.textPrimary(context)),
                  ),
                  Expanded(
                    child: Text(
                      'Notification Settings',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Choose what alerts you receive.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Master toggle
                    _buildToggleCard(
                      icon: Icons.notifications_active_outlined,
                      iconColor: AppColors.accentBlue,
                      title: 'Enable All Notifications',
                      subtitle: 'Master toggle for all notifications',
                      value: _masterEnabled,
                      onChanged: _toggleMaster,
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 24),

                    // ─── Local Reminders ───
                    _buildSectionHeader('Local Reminders'),
                    const SizedBox(height: 12),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _masterEnabled ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: !_masterEnabled,
                        child: Column(
                          children: [
                            _buildToggleCard(
                              icon: Icons.auto_awesome,
                              iconColor: AppColors.accentCyan,
                              title: 'Daily Space Fact',
                              subtitle:
                                  'A new fascinating fact every morning at 8 AM',
                              value: _dailyFact,
                              onChanged: (val) {
                                setState(() => _dailyFact = val);
                                _saveLocal();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 100.ms),
                            const SizedBox(height: 12),
                            _buildToggleCard(
                              icon: Icons.photo_library_outlined,
                              iconColor: AppColors.starGold,
                              title: 'Daily Space Photo Alert',
                              subtitle:
                                  'When new astronomy photo is available at 7 AM',
                              value: _apod,
                              onChanged: (val) {
                                setState(() => _apod = val);
                                _saveLocal();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 200.ms),
                            const SizedBox(height: 12),
                            _buildToggleCard(
                              icon: Icons.quiz_outlined,
                              iconColor: AppColors.accentOrange,
                              title: 'Quiz Reminder',
                              subtitle:
                                  'Evening reminder at 8 PM to keep your streak',
                              value: _quiz,
                              onChanged: (val) {
                                setState(() => _quiz = val);
                                _saveLocal();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 300.ms),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Push Alerts ───
                    _buildSectionHeader('Push Alerts'),
                    const SizedBox(height: 12),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _masterEnabled ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: !_masterEnabled,
                        child: Column(
                          children: [
                            _buildToggleCard(
                              icon: Icons.rocket_launch_outlined,
                              iconColor: AppColors.accentBlue,
                              title: 'Launch Alerts',
                              subtitle:
                                  'Get notified before rocket launches',
                              value: _launchAlerts,
                              onChanged: (val) {
                                setState(() => _launchAlerts = val);
                                _savePush();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 350.ms),
                            const SizedBox(height: 12),
                            _buildToggleCard(
                              icon: Icons.newspaper_outlined,
                              iconColor: const Color(0xFFE040FB),
                              title: 'Breaking Space News',
                              subtitle:
                                  'Important space news and discoveries',
                              value: _newsAlerts,
                              onChanged: (val) {
                                setState(() => _newsAlerts = val);
                                _savePush();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 400.ms),
                            const SizedBox(height: 12),
                            _buildToggleCard(
                              icon: Icons.warning_amber_outlined,
                              iconColor: AppColors.error,
                              title: 'Asteroid Alerts',
                              subtitle:
                                  'When hazardous asteroids approach Earth',
                              value: _asteroidAlerts,
                              onChanged: (val) {
                                setState(() => _asteroidAlerts = val);
                                _savePush();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 450.ms),
                            const SizedBox(height: 12),
                            _buildToggleCard(
                              icon: Icons.event_outlined,
                              iconColor: AppColors.starGold,
                              title: 'Space Events',
                              subtitle:
                                  'Eclipses, meteor showers, planet events',
                              value: _eventAlerts,
                              onChanged: (val) {
                                setState(() => _eventAlerts = val);
                                _savePush();
                              },
                            ).animate().fadeIn(
                                duration: 400.ms, delay: 500.ms),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? AppColors.accentBlue
                                .withValues(alpha: 0.08)
                            : AppColors.background(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accentBlue
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18,
                              color: AppColors.accentBlue
                                  .withValues(alpha: 0.7)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Local reminders are scheduled on your device. Push alerts are sent from our server for real-time events.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(duration: 400.ms, delay: 550.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentBlue.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glass(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  iconColor.withValues(alpha: _isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.accentBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
