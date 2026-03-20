import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/space_sounds_data.dart';
import '../../theme/app_colors.dart';

class SpaceSoundsScreen extends StatefulWidget {
  const SpaceSoundsScreen({super.key});
  @override
  State<SpaceSoundsScreen> createState() => _SpaceSoundsScreenState();
}

class _SpaceSoundsScreenState extends State<SpaceSoundsScreen>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  String? _currentId;
  bool _playing = false;
  bool _loadingAudio = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _selCat = 'All';
  late AnimationController _waveCtrl;

  static const _cats = ['All', 'Planets', 'Black Holes', 'Stars', 'Spacecraft', 'Earth'];

  List<SpaceSound> get _filtered {
    if (_selCat == 'All') return allSpaceSounds;
    return allSpaceSounds.where((s) => s.category == _selCat).toList();
  }

  SpaceSound? get _currentSound {
    if (_currentId == null) return null;
    try {
      return allSpaceSounds.firstWhere((s) => s.id == _currentId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _playing = false; _currentId = null; });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  Future<void> _playSound(SpaceSound sound) async {
    // Toggle if already playing this sound
    if (_currentId == sound.id && _playing) {
      await _player.pause();
      return;
    }
    if (_currentId == sound.id && !_playing) {
      await _player.resume();
      return;
    }

    setState(() { _currentId = sound.id; _loadingAudio = true; });

    try {
      await _player.stop();
      await _player.play(UrlSource(sound.audioUrl));
      if (mounted) setState(() => _loadingAudio = false);
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadingAudio = false; _currentId = null; _playing = false; });
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Audio Unavailable'),
          content: const Text('This sound couldn\'t be loaded. Would you like to listen on NASA\'s website?'),
          actions: [
            CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
            CupertinoDialogAction(child: const Text('Open NASA'), onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('https://www.nasa.gov/audio-and-ringtones/'), mode: LaunchMode.externalApplication);
            }),
          ],
        ),
      );
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
            _catPills(),
            // Now playing bar
            if (_currentId != null) _nowPlaying(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _soundCard(_filtered[i], i),
              ),
            ),
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
            Text('Space Sounds', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
            Text('Real sounds from the cosmos', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context))),
          ])),
          Icon(Icons.volume_up_rounded, color: AppColors.accentPurple, size: 24),
        ],
      ),
    );
  }

  Widget _catPills() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final sel = cat == _selCat;
          return GestureDetector(
            onTap: () => setState(() => _selCat = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: sel ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]) : null,
                color: sel ? null : AppColors.glass(context),
                border: Border.all(color: sel ? Colors.transparent : AppColors.glassBorder(context)),
              ),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textSecondary(context))),
            ),
          );
        },
      ),
    );
  }

  Widget _nowPlaying() {
    final sound = _currentSound;
    if (sound == null) return const SizedBox.shrink();
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [
          AppColors.accentPurple.withValues(alpha: 0.15),
          AppColors.accentCyan.withValues(alpha: 0.08),
        ]),
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Waveform bars
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, _) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (i) {
                final h = _playing
                    ? 8.0 + (sin(_waveCtrl.value * pi + i * 1.2) + 1) * 8
                    : 6.0;
                return Container(
                  width: 3, height: h,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [AppColors.accentPurple, AppColors.accentCyan],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Now Playing', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentPurple)),
            Text(sound.name, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.divider(context),
                valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
              ),
            ),
          ])),
          const SizedBox(width: 10),
          // Play/Pause
          GestureDetector(
            onTap: () => _playSound(sound),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]),
              ),
              child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _soundCard(SpaceSound sound, int index) {
    final isThis = _currentId == sound.id;
    final isPlaying = isThis && _playing;
    final isLoading = isThis && _loadingAudio;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isThis
            ? sound.color.withValues(alpha: 0.3)
            : AppColors.glassBorder(context)),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sound.color.withValues(alpha: 0.12),
              border: Border.all(color: sound.color.withValues(alpha: 0.2)),
            ),
            child: Icon(sound.icon, color: sound.color, size: 22),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sound.name, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
            const SizedBox(height: 2),
            Text(sound.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary(context), height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${sound.source} \u2022 ${sound.duration}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary(context))),
          ])),
          const SizedBox(width: 10),
          // Play button
          GestureDetector(
            onTap: () => _playSound(sound),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isPlaying ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentCyan]) : null,
                color: isPlaying ? null : Colors.transparent,
                border: isPlaying ? null : Border.all(color: AppColors.glassBorder(context), width: 1.5),
              ),
              child: isLoading
                  ? const CupertinoActivityIndicator()
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isPlaying ? Colors.white : AppColors.textPrimary(context),
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 40 * index));
  }
}
