import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  late final List<_Star> _backgroundStars;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // 12 twinkling background stars at random positions
    _backgroundStars = List.generate(12, (_) {
      return _Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1.5 + _random.nextDouble() * 2,
        delay: Duration(milliseconds: _random.nextInt(1500)),
      );
    });

    // 7 floating particles expanding outward from center
    _particles = List.generate(7, (i) {
      final angle = (2 * pi / 7) * i + _random.nextDouble() * 0.5;
      return _Particle(
        angle: angle,
        distance: 80 + _random.nextDouble() * 60,
        size: 2 + _random.nextDouble() * 2,
        delay: Duration(milliseconds: 400 + _random.nextInt(600)),
      );
    });

    // Navigate after splash duration
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    final box = Hive.box('settings');
    final onboardingDone = box.get('onboarding_complete', defaultValue: false);

    if (onboardingDone == true) {
      Get.offAll(() => const HomeScreen(), transition: Transition.cupertino);
    } else {
      Get.offAll(() => const OnboardingScreen(),
          transition: Transition.cupertino);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Twinkling stars ──
          ..._backgroundStars.map((star) {
            return Positioned(
              left: star.x * size.width,
              top: star.y * size.height,
              child: Container(
                width: star.size,
                height: star.size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    delay: star.delay,
                  )
                  .fadeIn(duration: 600.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
            );
          }),

          // ── Center content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cosmic glow circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentPurple.withValues(alpha: 0.4),
                            AppColors.accentCyan.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          duration: 1200.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 800.ms),

                    // Saturn-like planet icon
                    Icon(
                      Icons.public,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.95),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                          delay: 200.ms,
                        )
                        .rotate(
                          begin: -0.1,
                          end: 0,
                          duration: 800.ms,
                          delay: 200.ms,
                        ),

                    // Floating particles around icon
                    ..._particles.map((p) {
                      return Transform.translate(
                        offset: Offset.zero,
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(delay: p.delay)
                            .fadeIn(duration: 400.ms)
                            .move(
                              begin: Offset.zero,
                              end: Offset(
                                cos(p.angle) * p.distance,
                                sin(p.angle) * p.distance,
                              ),
                              duration: 1400.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeOut(delay: 1000.ms, duration: 400.ms),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 40),

                // App name
                Text(
                  'Cosmic Facts',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      duration: 700.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 700.ms, delay: 400.ms),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'EXPLORE THE UNIVERSE',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
              ],
            ),
          ),

          // ── Bottom loading bar ──
          Positioned(
            left: 40,
            right: 40,
            bottom: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            )
                .animate()
                .scaleX(
                  begin: 0,
                  end: 1,
                  alignment: Alignment.centerLeft,
                  duration: 2200.ms,
                  delay: 300.ms,
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: 400.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }
}

// ── Data models for stars & particles ──

class _Star {
  final double x;
  final double y;
  final double size;
  final Duration delay;

  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Duration delay;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}
