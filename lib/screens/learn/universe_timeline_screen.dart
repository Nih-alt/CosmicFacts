import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class UniverseTimelineScreen extends StatefulWidget {
  const UniverseTimelineScreen({super.key});
  @override
  State<UniverseTimelineScreen> createState() => _UniverseTimelineScreenState();
}

class _UniverseTimelineScreenState extends State<UniverseTimelineScreen> {
  final _sc = ScrollController();
  int? _exp;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  static const _eraNames = [
    'The Beginning', 'First Stars & Galaxies', 'Our Solar System',
    'Life on Earth', 'Human Space Age',
  ];
  static const _eraJumps = ['Big Bang', 'First Stars', 'Solar System', 'Life', 'Space Age'];
  static const _eraIcons = [
    Icons.flare_rounded, Icons.auto_awesome, Icons.wb_sunny_rounded,
    Icons.eco_rounded, Icons.rocket_launch_rounded,
  ];
  static const _eraGradients = <List<Color>>[
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFF0D47A1), Color(0xFF1565C0)],
    [Color(0xFFE65100), Color(0xFFF57C00)],
    [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    [Color(0xFF006064), Color(0xFF00838F)],
  ];
  static const _eraBorderColors = [
    Color(0xFF9C27B0), Color(0xFF42A5F5), Color(0xFFFFA726),
    Color(0xFF66BB6A), Color(0xFF26C6DA),
  ];

  static const _events = <_Ev>[
    _Ev(0, '13.8 Billion Years Ago', 'The Big Bang', 'The universe begins from an infinitely dense, hot singularity. All matter, energy, space, and time emerge in an instant.', 'The entire observable universe was smaller than an atom.'),
    _Ev(0, '13.8 BYA (10\u207B\u00B3\u2076s)', 'Cosmic Inflation', 'The universe expands faster than light, growing from subatomic to cosmic size in a trillionth of a trillionth of a trillionth of a second.', 'Inflation explains why the universe appears so uniform in every direction.'),
    _Ev(0, '13.8 BYA (3 min)', 'First Atoms Form', 'Protons and neutrons combine to form hydrogen and helium nuclei in Big Bang nucleosynthesis.', 'About 75% hydrogen, 25% helium \u2014 still the universe\'s main ingredients.'),
    _Ev(0, '380,000 Years After', 'Light Breaks Free', 'The universe cools enough for electrons to combine with nuclei, making it transparent. This light is now the Cosmic Microwave Background.', 'This ancient light fills the entire universe and can be detected today.'),
    _Ev(1, '13.3 Billion Years Ago', 'First Stars Ignite', 'The first massive stars form from hydrogen clouds, ending the cosmic dark ages. These giants are hundreds of times more massive than our Sun.', 'These first stars lived fast and died young \u2014 exploding after just a few million years.'),
    _Ev(1, '13.2 BYA', 'First Galaxies Form', 'Small irregular galaxies begin assembling from merging star clusters, seeded by dark matter in the cosmic web.', 'JWST has captured images of galaxies from this era \u2014 13+ billion light-years away.'),
    _Ev(1, '12 BYA', 'Milky Way Begins', 'Our home galaxy starts taking shape through mergers of smaller galaxies and gas clouds over billions of years.', 'The Milky Way has cannibalized dozens of smaller galaxies throughout its history.'),
    _Ev(1, '10 BYA', 'Heavy Elements Spread', 'Generations of stars have lived and died, forging and scattering carbon, oxygen, and iron throughout galaxies.', 'Every atom of carbon in your body was made inside a star that exploded.'),
    _Ev(2, '4.6 Billion Years Ago', 'Sun Is Born', 'A cloud of gas and dust collapses, igniting nuclear fusion and creating our star. Remaining material forms a protoplanetary disk.', 'The Sun contains 99.86% of all mass in our solar system.'),
    _Ev(2, '4.5 BYA', 'Earth Forms', 'Rocky debris in the inner solar system collides and merges over millions of years of violent impacts, building our planet.', 'Early Earth was a molten hellscape with no atmosphere or oceans.'),
    _Ev(2, '4.5 BYA', 'Moon Is Created', 'A Mars-sized body called Theia collides with early Earth. Debris from this giant impact coalesces to form our Moon.', 'The Moon was originally much closer \u2014 it\'s been drifting away at 3.8 cm/year.'),
    _Ev(2, '4.4 BYA', 'First Oceans Appear', 'Earth cools enough for water vapor to condense, creating the first oceans. Comets deliver additional water.', 'Some water in your glass may have been delivered by comets billions of years ago.'),
    _Ev(3, '3.8 Billion Years Ago', 'First Life Appears', 'Simple single-celled organisms emerge in Earth\'s oceans near hydrothermal vents, beginning the story of life.', 'Life appeared remarkably quickly \u2014 within a few hundred million years of Earth forming.'),
    _Ev(3, '2.4 BYA', 'Great Oxidation Event', 'Cyanobacteria produce oxygen through photosynthesis, transforming Earth\'s atmosphere over millions of years.', 'This was a mass extinction for anaerobic organisms \u2014 oxygen was poison to them!'),
    _Ev(3, '540 Million Years Ago', 'Cambrian Explosion', 'An explosive diversification of complex multicellular life occurs in the oceans over a geologically short period.', 'In just 20 million years, life went from simple to spectacularly diverse.'),
    _Ev(3, '230 MYA', 'First Dinosaurs', 'Dinosaurs emerge during the Triassic period and will dominate Earth for over 160 million years.', 'T. rex lived closer in time to us than to Stegosaurus.'),
    _Ev(3, '66 MYA', 'Dinosaur Extinction', 'A 10 km asteroid strikes the Yucat\u00E1n Peninsula, causing mass extinction. Mammals survive and diversify.', 'The impact had the energy of 10 billion nuclear bombs.'),
    _Ev(4, '300,000 Years Ago', 'Homo Sapiens', 'Modern humans appear in Africa. For hundreds of thousands of years, they look up at the stars and wonder.', 'If the universe\'s age were one year, humans appeared at 11:59 PM on December 31.'),
    _Ev(4, '~3000 BCE', 'First Astronomers', 'Ancient civilizations begin systematic observation and recording of celestial events, eclipses, and planetary motions.', 'The ancient Egyptians aligned the pyramids with remarkable astronomical precision.'),
    _Ev(4, '1543', 'Copernicus: Heliocentric Model', 'Nicolaus Copernicus proposes that Earth and planets revolve around the Sun, revolutionizing astronomy.', 'His book was published just before his death \u2014 he saw the first copy on his deathbed.'),
    _Ev(4, '1609', 'Galileo\'s Telescope', 'Galileo uses a telescope to observe Jupiter\'s moons, Saturn\'s rings, and lunar craters, confirming the heliocentric model.', 'Galileo was placed under house arrest for supporting heliocentrism.'),
    _Ev(4, '1687', 'Newton\'s Gravity', 'Isaac Newton publishes Principia, describing universal gravitation and three laws of motion explaining planetary orbits.', 'The falling apple story is likely true \u2014 Newton himself told it to several people.'),
    _Ev(4, '1915', 'Einstein\'s General Relativity', 'Albert Einstein reveals gravity as the curvature of spacetime caused by mass, transforming our understanding of the universe.', 'Confirmed during a 1919 solar eclipse, making Einstein world-famous overnight.'),
    _Ev(4, '1957', 'Sputnik 1 Launches', 'The Soviet Union launches the first artificial satellite, beginning the Space Age and the Space Race.', 'Sputnik\'s "beep beep" signal could be picked up by amateur radio operators worldwide.'),
    _Ev(4, '1961', 'First Human in Space', 'Soviet cosmonaut Yuri Gagarin orbits Earth aboard Vostok 1, becoming the first human in outer space.', 'Gagarin\'s entire flight lasted just 108 minutes.'),
    _Ev(4, '1969', 'Moon Landing', 'Neil Armstrong and Buzz Aldrin walk on the Moon during Apollo 11. "One small step for man, one giant leap for mankind."', 'Armstrong\'s footprint could last millions of years \u2014 the Moon has no wind or water.'),
    _Ev(4, '1975', 'ISRO Founded', 'Indian Space Research Organisation is established, beginning India\'s remarkable space journey.', 'ISRO\'s first rockets were so small they were transported on bicycles!'),
    _Ev(4, '1990', 'Hubble Telescope Launched', 'The Hubble Space Telescope is deployed, revolutionizing astronomy with stunning deep-space images for over 30 years.', 'Hubble was initially blurry \u2014 astronauts installed corrective "glasses" in 1993.'),
    _Ev(4, '2019', 'First Black Hole Photo', 'The Event Horizon Telescope captures the first direct image of a black hole in galaxy M87.', 'The image required data from 8 telescopes across 4 continents.'),
    _Ev(4, '2021', 'James Webb Telescope', 'The most powerful space telescope ever built launches to observe the universe in infrared, peering back 13.5 billion years.', 'JWST\'s mirror had to fold like origami to fit inside the rocket!'),
    _Ev(4, '2023', 'Chandrayaan-3 Lands', 'India becomes the fourth country to land on the Moon and the first to land near the lunar south pole.', 'The Pragyan rover discovered sulfur near the Moon\'s south pole for the first time.'),
    _Ev(4, 'Present', 'You Are Here', 'The universe is 13.8 billion years old, 93 billion light-years wide, and still expanding. Your story is part of this cosmic journey.', 'Every atom in your body was forged in the heart of a star. You are literally made of stardust.'),
  ];

  List<int> get _eraStarts {
    final r = <int>[];
    int cur = -1;
    for (int i = 0; i < _events.length; i++) {
      if (_events[i].era != cur) {
        cur = _events[i].era;
        r.add(i);
      }
    }
    return r;
  }

  void _jumpEra(int ei) {
    final s = _eraStarts;
    if (ei >= s.length) return;
    double pos = 0;
    int cur = -1;
    for (int i = 0; i < s[ei]; i++) {
      if (_events[i].era != cur) {
        cur = _events[i].era;
        pos += 60;
      }
      pos += 170;
    }
    pos += 60;
    _sc.animateTo(
      pos.clamp(0, _sc.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _jumpBtns(),
            Expanded(
              child: ListView.builder(
                controller: _sc,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
                itemCount: _events.length,
                itemBuilder: (_, i) => _buildItem(i),
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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.back,
                color: AppColors.textPrimary(context), size: 26),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Universe Timeline',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context))),
              Text('13.8 billion years of cosmic history',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _jumpBtns() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _eraJumps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _jumpEra(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [
                _eraGradients[i][0].withValues(alpha: 0.2),
                _eraGradients[i][1].withValues(alpha: 0.1),
              ]),
              border: Border.all(
                  color: _eraBorderColors[i].withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_eraIcons[i], size: 14, color: _eraBorderColors[i]),
                const SizedBox(width: 6),
                Text(_eraJumps[i],
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _eraBorderColors[i])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i) {
    final ev = _events[i];
    final isLeft = i % 2 == 0;
    final exp = _exp == i;
    final isLast = i == _events.length - 1;
    final showEra = i == 0 || _events[i].era != _events[i - 1].era;
    final eraColor = _eraBorderColors[ev.era];

    return Column(
      children: [
        if (showEra)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _eraGradients[ev.era]),
                boxShadow: [
                  BoxShadow(
                      color:
                          _eraGradients[ev.era][0].withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_eraIcons[ev.era], color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(_eraNames[ev.era],
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

        // Timeline row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: isLeft
                      ? _card(ev, exp, i, eraColor)
                      : const SizedBox()),
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          _eraGradients[ev.era][0],
                          _eraGradients[ev.era][1],
                        ]),
                        boxShadow: [
                          BoxShadow(
                              color: eraColor.withValues(
                                  alpha: isLast ? 0.5 : 0.3),
                              blurRadius: isLast ? 14 : 6,
                              spreadRadius: isLast ? 3 : 0),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: _isDark ? 2.5 : 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                eraColor.withValues(
                                    alpha: _isDark ? 0.35 : 0.25),
                                eraColor.withValues(
                                    alpha: _isDark ? 0.15 : 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                  child: isLeft
                      ? const SizedBox()
                      : _card(ev, exp, i, eraColor)),
            ],
          ),
        ),
      ],
    );
  }

  /// Event card — uses ClipRRect + Row with left accent strip
  /// instead of non-uniform Border (which breaks with borderRadius).
  Widget _card(_Ev ev, bool exp, int i, Color eraColor) {
    final isLast = i == _events.length - 1;

    return GestureDetector(
      onTap: () => setState(() => _exp = exp ? null : i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card(context),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: _isDark
              ? [BoxShadow(color: eraColor.withValues(alpha: 0.05), blurRadius: 12)]
              : [
                  BoxShadow(
                      color: eraColor.withValues(alpha: 0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 4)),
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored left accent strip
              Container(width: 4, color: eraColor.withValues(alpha: 0.6)),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(colors: [
                            eraColor.withValues(alpha: 0.15),
                            eraColor.withValues(alpha: 0.05),
                          ]),
                        ),
                        child: Text(ev.time,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: eraColor)),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(ev.title,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context))),
                      const SizedBox(height: 4),
                      // Description
                      Text(ev.desc,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                              height: 1.5),
                          maxLines: exp ? null : 3,
                          overflow:
                              exp ? null : TextOverflow.ellipsis),
                      // Fun fact (expanded)
                      if (exp && ev.fact.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.starGold
                                .withValues(alpha: 0.08),
                            border: Border.all(
                                color: AppColors.starGold
                                    .withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(CupertinoIcons.lightbulb_fill,
                                  size: 14,
                                  color: AppColors.starGold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(ev.fact,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textPrimary(
                                            context),
                                        fontStyle: FontStyle.italic,
                                        height: 1.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // "You Are Here" special ending
                      if (isLast) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [
                              AppColors.accentPurple,
                              AppColors.accentCyan,
                            ]),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.accentPurple
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'The universe is still writing its story \u2014 and so are you.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(
            duration: 400.ms,
            delay: Duration(milliseconds: 30 * (i % 5)))
        .slideX(
            begin: (i % 2 == 0) ? -0.05 : 0.05,
            end: 0,
            duration: 400.ms,
            delay: Duration(milliseconds: 30 * (i % 5)));
  }
}

class _Ev {
  final int era;
  final String time, title, desc, fact;
  const _Ev(this.era, this.time, this.title, this.desc, this.fact);
}
