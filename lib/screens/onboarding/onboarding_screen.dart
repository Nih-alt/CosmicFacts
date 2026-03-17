import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../theme/app_colors.dart';
import '../home/home_screen.dart';

// ═════════════════════════════════════════════
// CARD COLOR THEME
// ═════════════════════════════════════════════

class _CardColorTheme {
  final Color gradientStart;
  final Color gradientEnd;

  const _CardColorTheme(this.gradientStart, this.gradientEnd);

  Color get primary => gradientStart;
}

const _cardThemes = <_CardColorTheme>[
  // Planets — Deep Blue
  _CardColorTheme(Color(0xFF1E88E5), Color(0xFF0D47A1)),
  // Black Holes — Deep Purple
  _CardColorTheme(Color(0xFF7B1FA2), Color(0xFF4A148C)),
  // Galaxies — Pink/Magenta
  _CardColorTheme(Color(0xFFE040FB), Color(0xFFAA00FF)),
  // Rocket Launches — Orange/Red
  _CardColorTheme(Color(0xFFFF6B35), Color(0xFFD84315)),
  // ISRO — Saffron Orange
  _CardColorTheme(Color(0xFFFF9933), Color(0xFFFF6F00)),
  // NASA — Cyan/Teal
  _CardColorTheme(Color(0xFF00D4FF), Color(0xFF0097A7)),
  // Asteroids — Grey/Silver
  _CardColorTheme(Color(0xFF90A4AE), Color(0xFF546E7A)),
  // Stars — Gold
  _CardColorTheme(Color(0xFFFFD700), Color(0xFFFFA000)),
];

// ═════════════════════════════════════════════
// CONTROLLER
// ═════════════════════════════════════════════

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final selectedInterests = <String>{}.obs;

  static const List<String> interests = [
    'Planets',
    'Black Holes',
    'Galaxies',
    'Launches',
    'ISRO',
    'NASA',
    'Asteroids',
    'Stars',
  ];

  static const List<IconData> interestIcons = [
    Icons.public,
    Icons.dark_mode,
    Icons.blur_circular,
    Icons.rocket_launch,
    Icons.flag,
    Icons.language,
    Icons.brightness_3,
    Icons.star,
  ];

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void skipToInterests() {
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  Future<void> _completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboarding_complete', true);
    await box.put('interests', selectedInterests.toList());
    Get.offAll(() => const HomeScreen(), transition: Transition.cupertino);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

// ═════════════════════════════════════════════
// MAIN SCREEN
// ═════════════════════════════════════════════

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Starfield — behind everything ──
          const _Starfield(),

          // ── Foreground content ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Skip button (step 1 only) ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(() {
                        if (controller.currentPage.value != 0) {
                          return const SizedBox(height: 44);
                        }
                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          onPressed: controller.skipToInterests,
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // ── PageView ──
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => controller.currentPage.value = i,
                    children: const [
                      _StepDiscover(),
                      _StepUpdated(),
                      _StepInterests(),
                    ],
                  ),
                ),

                // ── Custom dot indicator ──
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Obx(() => _CosmicDots(
                        current: controller.currentPage.value,
                        count: 3,
                      )),
                ),

                // ── Continue button ──
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPad + 24),
                  child: Obx(() {
                    final isLast = controller.currentPage.value == 2;
                    return _GradientButton(
                      label: isLast ? 'Launch into Space! 🚀' : 'Continue',
                      onTap: controller.nextPage,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STARFIELD — 45 twinkling stars
// ═════════════════════════════════════════════

class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rng = Random(42); // fixed seed for consistent layout

    return Stack(
      children: List.generate(45, (i) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final starSize = 1.0 + rng.nextDouble() * 2.0;
        final delay = Duration(milliseconds: rng.nextInt(2000));
        // Varying twinkle speed: 300ms–2000ms
        final twinkleDuration =
            Duration(milliseconds: 300 + rng.nextInt(1700));
        // Some stars drift slightly
        final drifts = i % 5 == 0;

        Widget star = Container(
          width: starSize,
          height: starSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7 + rng.nextDouble() * 0.3),
            shape: BoxShape.circle,
            boxShadow: starSize > 2.0
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
        );

        // Twinkle animation
        star = star
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
              delay: delay,
            )
            .fadeIn(duration: twinkleDuration)
            .then()
            .fadeOut(duration: twinkleDuration);

        // Subtle drift for every 5th star
        if (drifts) {
          star = star
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
                delay: delay,
              )
              .moveY(
                begin: 0,
                end: -6,
                duration: const Duration(seconds: 4),
                curve: Curves.easeInOut,
              );
        }

        return Positioned(left: x, top: y, child: star);
      }),
    );
  }
}

// ═════════════════════════════════════════════
// NEBULA GLOW — 3 overlapping blurred circles
// ═════════════════════════════════════════════

class _NebulaGlow extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Color color3;

  const _NebulaGlow({
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle 1 — largest, centered
          Positioned(
            top: 10,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color1.withValues(alpha: 0.15),
                    color1.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 0.95,
                  end: 1.05,
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeInOut,
                ),
          ),
          // Circle 2 — offset right
          Positioned(
            right: 20,
            top: 40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color2.withValues(alpha: 0.12),
                    color2.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 1.0,
                  end: 1.08,
                  duration: const Duration(seconds: 5),
                  curve: Curves.easeInOut,
                ),
          ),
          // Circle 3 — offset left
          Positioned(
            left: 20,
            top: 50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color3.withValues(alpha: 0.08),
                    color3.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 1.0,
                  end: 1.06,
                  duration: 3500.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// ORBIT RINGS — double ring rotating around icon
// ═════════════════════════════════════════════

class _OrbitRings extends StatelessWidget {
  final Widget child;

  const _OrbitRings({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring — slow clockwise
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: const Duration(seconds: 10)),

          // Inner ring — counter-clockwise
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(begin: 0, end: -1, duration: const Duration(seconds: 8)),

          // Small orbiting dot on outer ring
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.accentCyan,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: const Duration(seconds: 10)),

          child,
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// FLOATING PARTICLES — drift upward
// ═════════════════════════════════════════════

class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles();

  @override
  Widget build(BuildContext context) {
    final rng = Random(99);
    return SizedBox(
      width: 200,
      height: 120,
      child: Stack(
        children: List.generate(5, (i) {
          final x = 30.0 + rng.nextDouble() * 140;
          final size = 2.0 + rng.nextDouble() * 3;
          final delay = Duration(milliseconds: i * 400);
          return Positioned(
            left: x,
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(),
                  delay: delay,
                )
                .fadeIn(duration: 800.ms)
                .moveY(begin: 0, end: -80, duration: 2500.ms)
                .fadeOut(delay: 1800.ms, duration: 700.ms),
          );
        }),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STEP 1 — Discover the Cosmos
// ═════════════════════════════════════════════

class _StepDiscover extends StatelessWidget {
  const _StepDiscover();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Nebula + orbit + icon stack
          Stack(
            alignment: Alignment.center,
            children: [
              const _NebulaGlow(
                color1: AppColors.accentPurple,
                color2: AppColors.accentCyan,
                color3: Color(0xFFFF5BDB),
              ),
              _OrbitRings(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  blendMode: BlendMode.srcIn,
                  child:
                      const Icon(Icons.public, size: 100, color: Colors.white),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 600.ms),
            ],
          ),

          const SizedBox(height: 4),
          const _FloatingParticles(),

          const SizedBox(height: 16),

          // Title
          Text(
            'Discover the Cosmos',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
              height: 1.15,
            ),
          )
              .animate()
              .slideY(begin: 0.3, end: 0, duration: 550.ms, delay: 200.ms)
              .fadeIn(duration: 550.ms, delay: 200.ms),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Daily space facts, news, and stunning images\nfrom across the universe',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryDark,
              height: 1.55,
            ),
          )
              .animate()
              .slideY(begin: 0.25, end: 0, duration: 500.ms, delay: 350.ms)
              .fadeIn(duration: 500.ms, delay: 350.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STEP 2 — Stay Updated
// ═════════════════════════════════════════════

class _RocketFlameTrail extends StatelessWidget {
  const _RocketFlameTrail();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final size = 8.0 - i * 2;
        final delay = Duration(milliseconds: i * 180);
        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentOrange.withValues(alpha: 0.9 - i * 0.25),
                  AppColors.starGold.withValues(alpha: 0.4 - i * 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
                delay: delay,
              )
              .scaleXY(begin: 0.7, end: 1.3, duration: 400.ms)
              .fadeIn(duration: 300.ms)
              .then()
              .fadeOut(duration: 300.ms),
        );
      }),
    );
  }
}

class _StepUpdated extends StatelessWidget {
  const _StepUpdated();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          Stack(
            alignment: Alignment.center,
            children: [
              const _NebulaGlow(
                color1: AppColors.accentOrange,
                color2: AppColors.accentCyan,
                color3: AppColors.starGold,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OrbitRings(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accentOrange, AppColors.accentCyan],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      blendMode: BlendMode.srcIn,
                      child: const Icon(Icons.rocket_launch,
                          size: 100, color: Colors.white),
                    ),
                  ),
                  const _RocketFlameTrail(),
                ],
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 600.ms),
            ],
          ),

          const SizedBox(height: 4),
          const _FloatingParticles(),

          const SizedBox(height: 16),

          Text(
            'Stay Updated',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
              height: 1.15,
            ),
          )
              .animate()
              .slideY(begin: 0.3, end: 0, duration: 550.ms, delay: 200.ms)
              .fadeIn(duration: 550.ms, delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'Track rocket launches, ISS location, asteroids,\nand breaking space news in real-time',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryDark,
              height: 1.55,
            ),
          )
              .animate()
              .slideY(begin: 0.25, end: 0, duration: 500.ms, delay: 350.ms)
              .fadeIn(duration: 500.ms, delay: 350.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// STEP 3 — Your Interests
// ═════════════════════════════════════════════

class _StepInterests extends StatelessWidget {
  const _StepInterests();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Gradient title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            blendMode: BlendMode.srcIn,
            child: Text(
              'Your Interests',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          )
              .animate()
              .slideY(begin: 0.3, end: 0, duration: 500.ms)
              .fadeIn(duration: 500.ms),

          const SizedBox(height: 8),

          Text(
            'Select what fascinates you most',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryDark,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

          const SizedBox(height: 28),

          // Interest cards grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: OnboardingController.interests.length,
              itemBuilder: (context, index) {
                final interest = OnboardingController.interests[index];
                final icon = OnboardingController.interestIcons[index];
                final colorTheme = _cardThemes[index];
                return Obx(() {
                  final selected =
                      controller.selectedInterests.contains(interest);
                  return _PremiumInterestCard(
                    label: interest,
                    icon: icon,
                    selected: selected,
                    showFlag: interest == 'ISRO',
                    colorTheme: colorTheme,
                    onTap: () => controller.toggleInterest(interest),
                  );
                })
                    .animate()
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      delay: Duration(milliseconds: 80 + index * 50),
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 80 + index * 50),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// PREMIUM INTEREST CARD
// ═════════════════════════════════════════════

class _PremiumInterestCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool showFlag;
  final _CardColorTheme colorTheme;
  final VoidCallback onTap;

  const _PremiumInterestCard({
    required this.label,
    required this.icon,
    required this.selected,
    this.showFlag = false,
    required this.colorTheme,
    required this.onTap,
  });

  @override
  State<_PremiumInterestCard> createState() => _PremiumInterestCardState();
}

class _PremiumInterestCardState extends State<_PremiumInterestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    final ct = widget.colorTheme;
    final radius = BorderRadius.circular(18);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _tapScale,
        builder: (context, child) => Transform.scale(
          scale: _tapScale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          transform: Matrix4.diagonal3Values(
            sel ? 1.02 : 1.0,
            sel ? 1.02 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.08),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 72,
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: radius,
                  border: Border.all(
                    color: sel
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.10),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Icon circle with topic's unique gradient
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: sel
                              ? [ct.gradientStart, ct.gradientEnd]
                              : [
                                  ct.gradientStart.withValues(alpha: 0.35),
                                  ct.gradientEnd.withValues(alpha: 0.25),
                                ],
                        ),
                      ),
                      child: Center(
                        child: widget.showFlag
                            ? Text(
                                '🇮🇳',
                                style: GoogleFonts.inter(fontSize: 18),
                              )
                            : Icon(widget.icon, size: 22, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Label
                    Expanded(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Checkmark
                    AnimatedOpacity(
                      opacity: sel ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// CUSTOM DOT INDICATOR
// ═════════════════════════════════════════════

class _CosmicDots extends StatelessWidget {
  final int current;
  final int count;

  const _CosmicDots({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: active ? AppColors.primaryGradient : null,
            color: active ? null : Colors.white.withValues(alpha: 0.12),
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════
// GRADIENT BUTTON
// ═════════════════════════════════════════════

class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
