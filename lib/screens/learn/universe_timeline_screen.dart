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
  final _scrollCtrl = ScrollController();
  int? _expandedIndex;

  static const _eras = [
    'The Beginning',
    'First Stars & Galaxies',
    'Our Solar System',
    'Life on Earth',
    'Human Space Age',
  ];

  static const _eraJumpLabels = [
    'Big Bang',
    'First Stars',
    'Solar System',
    'Life',
    'Space Age',
  ];

  static const _events = <_TimelineEvent>[
    // ERA 0 — THE BEGINNING
    _TimelineEvent(
      era: 0,
      time: '13.8 Billion Years Ago',
      title: 'The Big Bang \u{1F4A5}',
      description: 'The universe begins from an infinitely dense, hot singularity. All matter, energy, space, and time emerge in an instant.',
      funFact: 'The entire observable universe was smaller than an atom.',
    ),
    _TimelineEvent(
      era: 0,
      time: '13.8 BYA (10\u207B\u00B3\u2076 seconds)',
      title: 'Cosmic Inflation',
      description: 'The universe expands faster than light, growing from subatomic to cosmic size in a trillionth of a trillionth of a trillionth of a second.',
      funFact: 'Inflation explains why the universe appears so uniform in every direction.',
    ),
    _TimelineEvent(
      era: 0,
      time: '13.8 BYA (3 minutes)',
      title: 'First Atoms Form',
      description: 'Protons and neutrons combine to form hydrogen and helium nuclei in Big Bang nucleosynthesis. The universe is a hot plasma soup.',
      funFact: 'About 75% hydrogen, 25% helium \u2014 still the universe\'s main ingredients.',
    ),
    _TimelineEvent(
      era: 0,
      time: '13.5 BYA (380,000 years)',
      title: 'Light Breaks Free \u2728',
      description: 'The universe cools enough for electrons to combine with nuclei, making it transparent. This light is now the Cosmic Microwave Background.',
      funFact: 'This ancient light fills the entire universe and can be detected today with radio telescopes.',
    ),

    // ERA 1 — FIRST STARS & GALAXIES
    _TimelineEvent(
      era: 1,
      time: '13.3 Billion Years Ago',
      title: 'First Stars Ignite \u2B50',
      description: 'The first massive stars form from hydrogen clouds, ending the cosmic dark ages. These giants are hundreds of times more massive than our Sun.',
      funFact: 'These first stars lived fast and died young \u2014 exploding as supernovae after just a few million years.',
    ),
    _TimelineEvent(
      era: 1,
      time: '13.2 BYA',
      title: 'First Galaxies Form \u{1F30C}',
      description: 'Small irregular galaxies begin assembling from merging star clusters, seeded by dark matter concentrations in the cosmic web.',
      funFact: 'JWST has captured images of galaxies from this era \u2014 13+ billion light-years away.',
    ),
    _TimelineEvent(
      era: 1,
      time: '12 BYA',
      title: 'Milky Way Begins Forming',
      description: 'Our home galaxy starts taking shape through mergers of smaller galaxies and gas clouds, a process that continues for billions of years.',
      funFact: 'The Milky Way has cannibalized dozens of smaller galaxies throughout its history.',
    ),
    _TimelineEvent(
      era: 1,
      time: '10 BYA',
      title: 'Heavy Elements Spread',
      description: 'Generations of stars have lived and died, forging and scattering heavy elements like carbon, oxygen, and iron throughout galaxies.',
      funFact: 'Every atom of carbon in your body was made inside a star that exploded.',
    ),

    // ERA 2 — OUR SOLAR SYSTEM
    _TimelineEvent(
      era: 2,
      time: '4.6 Billion Years Ago',
      title: 'Sun Is Born \u2600\uFE0F',
      description: 'A cloud of gas and dust collapses, igniting nuclear fusion and creating our star. The remaining material forms a disk that will become the planets.',
      funFact: 'The Sun contains 99.86% of all mass in our solar system.',
    ),
    _TimelineEvent(
      era: 2,
      time: '4.5 BYA',
      title: 'Earth Forms \u{1F30D}',
      description: 'Rocky debris in the inner solar system collides and merges over millions of years of violent impacts, building our planet.',
      funFact: 'Early Earth was a molten hellscape with no atmosphere or oceans.',
    ),
    _TimelineEvent(
      era: 2,
      time: '4.5 BYA',
      title: 'Moon Is Created \u{1F319}',
      description: 'A Mars-sized body called Theia collides with early Earth. The debris from this giant impact coalesces to form our Moon.',
      funFact: 'The Moon was originally much closer \u2014 it\'s been slowly drifting away at 3.8 cm/year.',
    ),
    _TimelineEvent(
      era: 2,
      time: '4.4 BYA',
      title: 'First Oceans Appear \u{1F30A}',
      description: 'Earth cools enough for water vapor to condense, creating the first oceans. Comets and asteroids deliver additional water.',
      funFact: 'Some of the water in your glass may have been delivered by comets billions of years ago.',
    ),

    // ERA 3 — LIFE ON EARTH
    _TimelineEvent(
      era: 3,
      time: '3.8 Billion Years Ago',
      title: 'First Life Appears \u{1F9A0}',
      description: 'Simple single-celled organisms emerge in Earth\'s oceans, beginning the story of life. These are likely chemotrophs living near hydrothermal vents.',
      funFact: 'Life appeared remarkably quickly \u2014 within a few hundred million years of Earth forming.',
    ),
    _TimelineEvent(
      era: 3,
      time: '2.4 BYA',
      title: 'Great Oxidation Event',
      description: 'Cyanobacteria produce oxygen through photosynthesis, transforming Earth\'s atmosphere from reducing to oxidizing over millions of years.',
      funFact: 'This was a mass extinction for anaerobic organisms \u2014 oxygen was poison to them!',
    ),
    _TimelineEvent(
      era: 3,
      time: '540 Million Years Ago',
      title: 'Cambrian Explosion \u{1F41A}',
      description: 'An explosive diversification of complex multicellular life occurs in the oceans. Most modern animal phyla appear in a geologically brief period.',
      funFact: 'In just 20 million years, life went from simple to spectacularly diverse.',
    ),
    _TimelineEvent(
      era: 3,
      time: '230 MYA',
      title: 'First Dinosaurs \u{1F995}',
      description: 'Dinosaurs emerge during the Triassic period and will dominate Earth for over 160 million years, diversifying into thousands of species.',
      funFact: 'Dinosaurs existed for so long that T. rex lived closer in time to us than to Stegosaurus.',
    ),
    _TimelineEvent(
      era: 3,
      time: '66 MYA',
      title: 'Dinosaur Extinction \u2604\uFE0F',
      description: 'A 10 km asteroid strikes the Yucat\u00E1n Peninsula, creating the Chicxulub crater and triggering mass extinction. Mammals survive and diversify.',
      funFact: 'The impact had the energy of 10 billion nuclear bombs and caused a global "impact winter."',
    ),

    // ERA 4 — HUMAN SPACE AGE
    _TimelineEvent(
      era: 4,
      time: '300,000 Years Ago',
      title: 'Homo Sapiens \u{1F9D1}',
      description: 'Modern humans appear in Africa. For hundreds of thousands of years, they look up at the stars and wonder about their place in the cosmos.',
      funFact: 'If the universe\'s age were one year, humans appeared at 11:59 PM on December 31.',
    ),
    _TimelineEvent(
      era: 4,
      time: '~3000 BCE',
      title: 'First Astronomers',
      description: 'Ancient civilizations in Babylon, Egypt, and China begin systematic observation and recording of celestial events, eclipses, and planetary motions.',
      funFact: 'The ancient Egyptians aligned the pyramids with remarkable astronomical precision.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1543',
      title: 'Copernicus: Sun-Centered Model',
      description: 'Nicolaus Copernicus proposes that Earth and planets revolve around the Sun, displacing Earth from the center of the universe.',
      funFact: 'His book was published just before his death \u2014 he saw the first copy on his deathbed.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1609',
      title: 'Galileo\'s Telescope \u{1F52D}',
      description: 'Galileo Galilei uses a telescope to observe Jupiter\'s moons, Saturn\'s rings, and lunar craters, providing evidence for the heliocentric model.',
      funFact: 'Galileo was placed under house arrest by the Church for supporting heliocentrism.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1687',
      title: 'Newton\'s Gravity',
      description: 'Isaac Newton publishes Principia, describing the law of universal gravitation and the three laws of motion that explain planetary orbits.',
      funFact: 'The story of the falling apple is likely true \u2014 Newton himself told it to several people.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1915',
      title: 'Einstein\'s General Relativity',
      description: 'Albert Einstein reveals that gravity is the curvature of spacetime caused by mass, transforming our understanding of the universe.',
      funFact: 'Einstein\'s theory was confirmed during a 1919 solar eclipse, making him world-famous overnight.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1957',
      title: 'Sputnik 1 \u{1F6F0}\uFE0F',
      description: 'The Soviet Union launches the first artificial satellite, beginning the Space Age and the Space Race with the United States.',
      funFact: 'Sputnik\'s "beep beep" signal could be picked up by amateur radio operators worldwide.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1961',
      title: 'First Human in Space \u{1F468}\u200D\u{1F680}',
      description: 'Soviet cosmonaut Yuri Gagarin orbits Earth aboard Vostok 1, becoming the first human to journey into outer space.',
      funFact: 'Gagarin\'s entire flight lasted just 108 minutes. He ejected and parachuted separately.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1969',
      title: 'Moon Landing \u{1F319}',
      description: 'Neil Armstrong and Buzz Aldrin walk on the Moon during Apollo 11. "One small step for man, one giant leap for mankind."',
      funFact: 'Armstrong\'s footprint could last millions of years \u2014 the Moon has no wind or water.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1975',
      title: 'ISRO Founded \u{1F1EE}\u{1F1F3}',
      description: 'The Indian Space Research Organisation is established, beginning India\'s remarkable journey in space exploration and satellite technology.',
      funFact: 'ISRO\'s first rockets were so small they were transported on bicycles!',
    ),
    _TimelineEvent(
      era: 4,
      time: '1990',
      title: 'Hubble Telescope Launched \u{1F52D}',
      description: 'The Hubble Space Telescope is deployed in orbit, revolutionizing astronomy with stunning deep-space images for over 30 years.',
      funFact: 'Hubble was initially blurry \u2014 astronauts installed corrective "glasses" in 1993.',
    ),
    _TimelineEvent(
      era: 4,
      time: '1998',
      title: 'ISS Construction Begins \u{1F6F0}\uFE0F',
      description: 'The International Space Station begins assembly in orbit, becoming the largest human-made structure in space at 109 meters long.',
      funFact: 'The ISS has been continuously occupied for over 25 years with rotating crews.',
    ),
    _TimelineEvent(
      era: 4,
      time: '2013',
      title: 'India Reaches Mars \u{1F1EE}\u{1F1F3}\u{1F680}',
      description: 'ISRO\'s Mangalyaan enters Mars orbit on first attempt, making India the first Asian nation to reach Mars \u2014 at a fraction of the cost of other missions.',
      funFact: 'Mangalyaan cost \$74 million \u2014 less than the movie Gravity!',
    ),
    _TimelineEvent(
      era: 4,
      time: '2019',
      title: 'First Black Hole Photo \u{1F573}\uFE0F',
      description: 'The Event Horizon Telescope captures the first direct image of a black hole in galaxy M87, confirming Einstein\'s predictions.',
      funFact: 'The image required data from 8 telescopes across 4 continents, combined computationally.',
    ),
    _TimelineEvent(
      era: 4,
      time: '2021',
      title: 'James Webb Telescope Launches \u{1F52D}',
      description: 'The most powerful space telescope ever built launches to observe the universe in infrared, seeing the first galaxies formed after the Big Bang.',
      funFact: 'JWST\'s mirror had to fold like origami to fit inside the rocket!',
    ),
    _TimelineEvent(
      era: 4,
      time: '2023',
      title: 'Chandrayaan-3 Lands \u{1F1EE}\u{1F1F3}\u{1F319}',
      description: 'India becomes the fourth country to land on the Moon and the first to land near the lunar south pole with Chandrayaan-3.',
      funFact: 'The Pragyan rover discovered sulfur near the Moon\'s south pole for the first time.',
    ),
    _TimelineEvent(
      era: 4,
      time: 'Present',
      title: 'You Are Here \u{1F4CD}',
      description: 'The universe is 13.8 billion years old, 93 billion light-years wide, and still expanding. You are part of this cosmic story.',
      funFact: 'Every atom in your body was forged in the heart of a star. You are literally made of stardust.',
    ),
  ];

  // Map era index to first event index
  List<int> get _eraStartIndices {
    final indices = <int>[];
    int currentEra = -1;
    for (int i = 0; i < _events.length; i++) {
      if (_events[i].era != currentEra) {
        currentEra = _events[i].era;
        indices.add(i);
      }
    }
    return indices;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _jumpToEra(int eraIndex) {
    final starts = _eraStartIndices;
    if (eraIndex >= starts.length) return;
    final itemIndex = starts[eraIndex];
    // Each item is roughly (era header ~50) + (event card ~160)
    // Approximate position
    double pos = 0;
    int currentEra = -1;
    for (int i = 0; i < itemIndex; i++) {
      if (_events[i].era != currentEra) {
        currentEra = _events[i].era;
        pos += 56; // era header
      }
      pos += 170; // event card
    }
    pos += 56; // current era header
    _scrollCtrl.animateTo(
      pos.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildEraJumps(),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
                itemCount: _events.length,
                itemBuilder: (ctx, i) => _buildEventItem(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
          Text('Universe Timeline',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }

  Widget _buildEraJumps() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: _eraJumpLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _jumpToEra(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.glass(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder(context)),
            ),
            child: Text(_eraJumpLabels[i],
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPurple)),
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(int index) {
    final event = _events[index];
    final isLeft = index % 2 == 0;
    final isExpanded = _expandedIndex == index;
    final isLast = index == _events.length - 1;

    // Check if we need an era header
    final showEraHeader = index == 0 || _events[index].era != _events[index - 1].era;

    return Column(
      children: [
        if (showEraHeader)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.12),
                    AppColors.accentCyan.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_eras[event.era],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentPurple)),
            ),
          ).animate().fadeIn(duration: 400.ms),

        // Timeline row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left card or spacer
              Expanded(
                child: isLeft ? _buildCard(event, isExpanded, index) : const SizedBox(),
              ),

              // Timeline center line + dot
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentCyan],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.4),
                            blurRadius: isLast ? 12 : 6,
                            spreadRadius: isLast ? 2 : 0,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.accentPurple.withValues(alpha: 0.4),
                                AppColors.accentCyan.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Right card or spacer
              Expanded(
                child: isLeft ? const SizedBox() : _buildCard(event, isExpanded, index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(_TimelineEvent event, bool isExpanded, int index) {
    return GestureDetector(
      onTap: () => setState(
          () => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glass(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? AppColors.accentPurple.withValues(alpha: 0.3)
                : AppColors.glassBorder(context),
          ),
          boxShadow: AppColors.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(event.time,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPurple)),
            ),
            const SizedBox(height: 8),
            Text(event.title,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 4),
            Text(event.description,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    height: 1.4),
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded ? null : TextOverflow.ellipsis),
            if (isExpanded && event.funFact.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.starGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.starGold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u{1F4A1}',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(event.funFact,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textPrimary(context),
                              fontStyle: FontStyle.italic,
                              height: 1.4)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(
        duration: 400.ms,
        delay: Duration(milliseconds: 30 * (index % 5)));
  }
}

class _TimelineEvent {
  final int era;
  final String time;
  final String title;
  final String description;
  final String funFact;

  const _TimelineEvent({
    required this.era,
    required this.time,
    required this.title,
    required this.description,
    this.funFact = '',
  });
}
