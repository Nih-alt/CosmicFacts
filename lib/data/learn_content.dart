class TopicData {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<LessonData> lessons;

  const TopicData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.lessons,
  });
}

class LessonData {
  final String id;
  final String title;
  final int readingMinutes;
  final List<LessonBlock> blocks;

  const LessonData({
    required this.id,
    required this.title,
    required this.readingMinutes,
    required this.blocks,
  });
}

enum BlockType { paragraph, funFact }

class LessonBlock {
  final BlockType type;
  final String text;

  const LessonBlock(this.type, this.text);
  const LessonBlock.paragraph(this.text) : type = BlockType.paragraph;
  const LessonBlock.funFact(this.text) : type = BlockType.funFact;
}

const List<TopicData> allTopics = [
  // ════════════════════════════════════════
  // 1. BLACK HOLES
  // ════════════════════════════════════════
  TopicData(
    id: 'black_holes',
    name: 'Black Holes',
    emoji: '\u{1F573}\u{FE0F}',
    description: 'The most mysterious objects in the universe',
    lessons: [
      LessonData(
        id: 'bh_1',
        title: 'What is a Black Hole?',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'A black hole is a region in space where gravity is so incredibly strong that nothing \u2014 not even light \u2014 can escape once it crosses the boundary known as the event horizon. They form when massive stars, at least 20\u201325 times the mass of our Sun, exhaust their nuclear fuel and collapse under their own gravity in a catastrophic event called a supernova.',
          ),
          LessonBlock.paragraph(
            'The core that remains gets crushed into an infinitely dense point called a singularity. Black holes were first predicted by Einstein\u2019s theory of general relativity in 1915, though Einstein himself doubted they could actually exist in nature. It wasn\u2019t until the 1960s that astronomers began finding strong evidence for their existence.',
          ),
          LessonBlock.paragraph(
            'Despite their fearsome reputation, black holes don\u2019t roam around space swallowing everything. They only capture objects that venture too close. If our Sun were suddenly replaced by a black hole of the same mass, Earth would continue orbiting normally \u2014 it just wouldn\u2019t receive any light.',
          ),
          LessonBlock.funFact(
            'If you compressed Earth to the size of a marble (about 9 millimeters), it would become a black hole.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_2',
        title: 'Types of Black Holes',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Scientists have identified three main types of black holes based on their mass. Stellar black holes form from collapsed stars and have masses between 5\u2013100 times our Sun. There are an estimated 100 million of these in the Milky Way alone, silently drifting through interstellar space.',
          ),
          LessonBlock.paragraph(
            'Intermediate black holes are rarer, weighing between 100\u2013100,000 solar masses. Scientists are still debating how they form \u2014 they may result from mergers of smaller black holes or the collapse of extremely massive primordial stars.',
          ),
          LessonBlock.paragraph(
            'Supermassive black holes are the true giants \u2014 millions to billions of times the Sun\u2019s mass. One sits at the center of nearly every large galaxy. Our Milky Way\u2019s supermassive black hole, Sagittarius A*, weighs about 4 million solar masses and spans a region larger than Mercury\u2019s orbit around the Sun.',
          ),
          LessonBlock.funFact(
            'The largest known black hole, TON 618, has a mass of 66 billion Suns and an event horizon that could swallow our entire solar system several times over.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_3',
        title: 'The Event Horizon',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The event horizon is the invisible boundary around a black hole beyond which nothing can return. Think of it as the ultimate point of no return. At this boundary, the escape velocity equals the speed of light \u2014 and since nothing can travel faster than light, escape is impossible.',
          ),
          LessonBlock.paragraph(
            'For a stellar black hole of 10 solar masses, the event horizon is roughly 30 kilometers across \u2014 surprisingly small. Time behaves strangely near the event horizon due to extreme gravitational time dilation. A clock near a black hole would tick slower compared to one far away.',
          ),
          LessonBlock.paragraph(
            'If you watched someone falling into a black hole, you would see them appear to slow down and freeze at the event horizon, their image becoming increasingly redshifted until they fade from view. This bizarre optical illusion is a direct consequence of Einstein\u2019s relativity.',
          ),
          LessonBlock.funFact(
            'From the falling person\u2019s perspective, they would cross the event horizon without noticing anything unusual \u2014 no wall, no barrier, just empty space.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_4',
        title: 'Spaghettification',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'One of the most bizarre effects of black holes is spaghettification \u2014 the vertical stretching and horizontal compression of objects falling into them. As you approach a black hole feet-first, the gravitational pull on your feet would be significantly stronger than on your head.',
          ),
          LessonBlock.paragraph(
            'This difference, called tidal force, would stretch you into a long thin strand like spaghetti. For stellar black holes, spaghettification occurs well before reaching the event horizon, making it a violent end. However, for supermassive black holes, the tidal forces at the event horizon are surprisingly gentle because the event horizon is so far from the singularity.',
          ),
          LessonBlock.paragraph(
            'In 2020, astronomers actually observed a star being spaghettified by a supermassive black hole 215 million light-years away. The event, called AT2019qiz, produced a bright flare visible across multiple wavelengths as the star\u2019s material spiraled inward.',
          ),
          LessonBlock.funFact(
            'The term \u201Cspaghettification\u201D was coined by Stephen Hawking in his bestselling book \u201CA Brief History of Time.\u201D',
          ),
        ],
      ),
      LessonData(
        id: 'bh_5',
        title: 'Hawking Radiation',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'In 1974, Stephen Hawking made a groundbreaking theoretical discovery: black holes are not entirely black. Due to quantum effects near the event horizon, black holes slowly emit radiation and lose mass over time. This phenomenon is now called Hawking radiation.',
          ),
          LessonBlock.paragraph(
            'It happens because virtual particle\u2013antiparticle pairs constantly pop into existence everywhere in space. Near the event horizon, one particle can fall in while the other escapes, carrying away energy. The escaping particles appear as faint thermal radiation emanating from the black hole.',
          ),
          LessonBlock.paragraph(
            'Over unimaginably long timescales, this means black holes will eventually evaporate completely. A stellar black hole would take about 10\u2076\u2077 years to evaporate \u2014 far longer than the current age of the universe (13.8 billion years). Smaller black holes evaporate faster and more violently.',
          ),
          LessonBlock.funFact(
            'A black hole the mass of a penny would evaporate in less than a second, releasing energy equivalent to a thermonuclear bomb.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_6',
        title: 'The First Black Hole Photo',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'On April 10, 2019, the Event Horizon Telescope collaboration revealed the first-ever direct image of a black hole \u2014 the supermassive black hole at the center of galaxy M87, about 55 million light-years away. The image shows a bright ring of superheated gas orbiting the black hole, with a dark shadow in the center.',
          ),
          LessonBlock.paragraph(
            'The EHT is not a single telescope but a network of eight radio telescopes across the globe, working together to create an Earth-sized virtual telescope. The data collected was so massive that it had to be shipped on hard drives rather than transferred over the internet.',
          ),
          LessonBlock.paragraph(
            'In 2022, the team also captured an image of Sagittarius A*, our own Milky Way\u2019s supermassive black hole. Imaging Sgr A* was actually harder than M87 because its smaller size means the gas orbits much faster, changing appearance within minutes.',
          ),
          LessonBlock.funFact(
            'The M87 black hole is 6.5 billion times the mass of our Sun and its shadow is larger than our entire solar system.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_7',
        title: 'Black Holes in the Milky Way',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Our Milky Way galaxy is home to an estimated 100 million stellar black holes, though most are invisible and can only be detected by their gravitational effects on nearby stars or by the X-rays emitted when they feed on material from a companion star.',
          ),
          LessonBlock.paragraph(
            'The supermassive black hole at our galaxy\u2019s center, Sagittarius A*, is located about 26,000 light-years from Earth in the constellation Sagittarius. Despite its enormous mass of 4 million Suns, it is relatively quiet compared to the active black holes in other galaxies that power brilliant quasars.',
          ),
          LessonBlock.paragraph(
            'Stars near Sagittarius A* orbit at incredible speeds. One star, S2, completes an orbit in just 16 years traveling at 3% the speed of light. Tracking these stellar orbits over decades helped prove that a supermassive black hole truly exists there \u2014 work that earned the 2020 Nobel Prize in Physics.',
          ),
          LessonBlock.funFact(
            'At 26,000 light-years away, Sagittarius A* poses zero threat to Earth. You\u2019re safer from it than from the nearest highway.',
          ),
        ],
      ),
      LessonData(
        id: 'bh_8',
        title: 'Could You Survive a Black Hole?',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The short answer is no \u2014 but the physics of what would happen is fascinating. For a stellar black hole, you would be spaghettified long before reaching the event horizon. The tidal forces would tear apart even the strongest materials known to science.',
          ),
          LessonBlock.paragraph(
            'For a supermassive black hole, you could theoretically cross the event horizon intact because the tidal forces are much weaker at that distance. But there would be no escape. Inside the event horizon, all paths through spacetime lead to the singularity \u2014 moving forward in time literally means moving toward the center.',
          ),
          LessonBlock.paragraph(
            'Some theories suggest the singularity might not be a point but could connect to a white hole in another universe via a wormhole \u2014 though this remains highly speculative. What we know for certain is that our current understanding of physics breaks down at the singularity, hinting at new laws waiting to be discovered.',
          ),
          LessonBlock.funFact(
            'Some physicists speculate that information falling into black holes might be preserved on the event horizon like a hologram \u2014 this is called the holographic principle.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 2. GALAXIES
  // ════════════════════════════════════════
  TopicData(
    id: 'galaxies',
    name: 'Galaxies',
    emoji: '\u{1F30C}',
    description: 'Island universes of stars, gas, and dark matter',
    lessons: [
      LessonData(
        id: 'gal_1',
        title: 'Types of Galaxies',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Galaxies come in three main shapes, first classified by Edwin Hubble in 1926. Spiral galaxies like our Milky Way have sweeping arms of stars, gas, and dust rotating around a central bulge. They make up about 60% of nearby galaxies and are where most new stars are born.',
          ),
          LessonBlock.paragraph(
            'Elliptical galaxies are smooth, football-shaped collections of old red and yellow stars. They range from nearly spherical to highly elongated and contain very little gas or dust, meaning star formation has largely stopped. The largest galaxies in the universe are giant ellipticals.',
          ),
          LessonBlock.paragraph(
            'Irregular galaxies have no defined shape. They\u2019re often the result of gravitational interactions or collisions between galaxies. The Large and Small Magellanic Clouds, visible from the Southern Hemisphere, are irregular galaxies orbiting the Milky Way.',
          ),
          LessonBlock.funFact(
            'There are an estimated 2 trillion galaxies in the observable universe \u2014 that\u2019s more galaxies than grains of sand on all of Earth\u2019s beaches.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_2',
        title: 'The Milky Way',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Our home galaxy, the Milky Way, is a barred spiral galaxy containing 100\u2013400 billion stars spread across a disk roughly 100,000 light-years in diameter. Our solar system sits about 26,000 light-years from the center, in a minor arm called the Orion Spur.',
          ),
          LessonBlock.paragraph(
            'The Milky Way rotates, but not like a solid wheel. Our solar system takes about 225\u2013250 million years to complete one orbit around the galactic center \u2014 a period sometimes called a \u201Cgalactic year.\u201D Since Earth formed 4.5 billion years ago, it has completed roughly 20 galactic orbits.',
          ),
          LessonBlock.paragraph(
            'The galaxy\u2019s central bar is a dense, elongated structure of stars about 27,000 light-years long. Surrounding the visible disk is a vast halo of dark matter extending hundreds of thousands of light-years, containing most of the galaxy\u2019s total mass.',
          ),
          LessonBlock.funFact(
            'The name \u201CMilky Way\u201D comes from the ancient Greek \u201Cgalaxias,\u201D meaning \u201Cmilky\u201D \u2014 the band of light visible on dark nights is us looking through the disk of our own galaxy.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_3',
        title: 'The Andromeda Collision',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The Andromeda galaxy (M31) is hurtling toward the Milky Way at about 110 kilometers per second. In roughly 4.5 billion years, the two galaxies will collide and merge into a single giant elliptical galaxy, sometimes nicknamed \u201CMilkomeda.\u201D',
          ),
          LessonBlock.paragraph(
            'Despite the dramatic name, a galaxy collision is surprisingly gentle for individual stars. The distances between stars are so vast that direct stellar collisions would be extremely rare. However, gravitational tides would reshape both galaxies, flinging some stars into intergalactic space and compressing gas clouds to trigger bursts of new star formation.',
          ),
          LessonBlock.paragraph(
            'Our Sun will still be alive during the early stages of the collision, though it will be nearing the end of its main-sequence lifetime. Any inhabitants of Earth (if it\u2019s still habitable) would see Andromeda growing larger in the night sky over millions of years until it fills the entire view.',
          ),
          LessonBlock.funFact(
            'Andromeda is the most distant object visible to the naked eye, at 2.5 million light-years away. The light you see left the galaxy before humans existed.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_4',
        title: 'Galaxy Formation',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Galaxies began forming within the first billion years after the Big Bang. Small clumps of dark matter attracted hydrogen and helium gas, which collapsed to form the first stars. These early protogalaxies were small and irregular, much smaller than today\u2019s giant galaxies.',
          ),
          LessonBlock.paragraph(
            'Over billions of years, galaxies grew through mergers and by accumulating more gas. The hierarchical model of galaxy formation describes how small galaxies merged to build larger ones \u2014 a process that continues today. The Milky Way itself has absorbed dozens of smaller galaxies over its history.',
          ),
          LessonBlock.paragraph(
            'The James Webb Space Telescope has revealed surprisingly mature galaxies existing just 300\u2013500 million years after the Big Bang, challenging our models of how quickly galaxies can form. These discoveries suggest that galaxy formation may have been more efficient in the early universe than previously thought.',
          ),
          LessonBlock.funFact(
            'The Milky Way is currently eating a small galaxy called the Sagittarius Dwarf Elliptical Galaxy, slowly stripping away its stars.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_5',
        title: 'Active Galaxies & Quasars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'When a supermassive black hole at a galaxy\u2019s center actively devours surrounding material, the galaxy becomes \u201Cactive.\u201D The infalling material forms a superheated accretion disk that can outshine all the stars in the galaxy combined. These are among the most energetic objects in the universe.',
          ),
          LessonBlock.paragraph(
            'Quasars are the most luminous type of active galaxy. First discovered in 1963, they are so bright they can be seen billions of light-years away. Some quasars produce jets of plasma traveling near the speed of light that extend thousands of light-years into space.',
          ),
          LessonBlock.paragraph(
            'Most quasars existed in the early universe when galaxies had abundant gas to feed their central black holes. As galaxies used up their gas supply, quasar activity declined. Our own Milky Way\u2019s central black hole, Sagittarius A*, was likely active as a quasar billions of years ago.',
          ),
          LessonBlock.funFact(
            'The brightest quasar ever found, J0529-4351, shines with the luminosity of 500 trillion Suns and devours a Sun\u2019s worth of material every day.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_6',
        title: 'Galaxy Clusters',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Galaxies aren\u2019t evenly scattered through space \u2014 they cluster together in groups bound by gravity. Our Milky Way belongs to the Local Group, a modest collection of about 80 galaxies spread across 10 million light-years, dominated by the Milky Way and Andromeda.',
          ),
          LessonBlock.paragraph(
            'Larger galaxy clusters can contain hundreds to thousands of galaxies. The Virgo Cluster, our nearest large cluster at 54 million light-years away, contains about 2,000 galaxies. Between the galaxies lies vast amounts of hot, X-ray-emitting gas called the intracluster medium.',
          ),
          LessonBlock.paragraph(
            'Clusters themselves group into superclusters. Our Local Group is part of the Laniakea Supercluster, which spans 520 million light-years and contains roughly 100,000 galaxies. These are among the largest known structures in the universe.',
          ),
          LessonBlock.funFact(
            'The largest known structure in the universe is the Hercules\u2013Corona Borealis Great Wall, a galaxy filament 10 billion light-years across.',
          ),
        ],
      ),
      LessonData(
        id: 'gal_7',
        title: 'Dark Matter in Galaxies',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'In the 1970s, astronomer Vera Rubin discovered that stars in the outer regions of spiral galaxies orbit just as fast as those near the center. This shouldn\u2019t happen if only visible matter provides the gravitational pull \u2014 the outer stars should orbit much slower, just as outer planets orbit the Sun more slowly.',
          ),
          LessonBlock.paragraph(
            'The explanation: galaxies are embedded in massive halos of invisible dark matter that provides the extra gravitational pull needed to explain the observed rotation. Dark matter makes up about 85% of all matter in the universe, yet it doesn\u2019t emit, absorb, or reflect light.',
          ),
          LessonBlock.paragraph(
            'We can also detect dark matter through gravitational lensing \u2014 the bending of light from distant galaxies by the gravity of a foreground cluster. The distorted images reveal the distribution of dark matter in the cluster, confirming its presence even though we cannot see it directly.',
          ),
          LessonBlock.funFact(
            'The Milky Way\u2019s dark matter halo extends to about 300,000 light-years from the center \u2014 three times the diameter of the visible disk.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 3. STARS & SUPERNOVAE
  // ════════════════════════════════════════
  TopicData(
    id: 'stars',
    name: 'Stars & Supernovae',
    emoji: '\u2B50',
    description: 'The life, death, and rebirth of stellar giants',
    lessons: [
      LessonData(
        id: 'star_1',
        title: 'Life Cycle of Stars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Every star begins as a cloud of gas and dust called a nebula. When a region of the cloud collapses under gravity, it heats up until hydrogen fusion ignites in the core \u2014 a star is born. How a star lives and dies depends almost entirely on its mass.',
          ),
          LessonBlock.paragraph(
            'Low-mass stars like red dwarfs burn fuel slowly and can shine for trillions of years. Medium-mass stars like our Sun live about 10 billion years before swelling into red giants and shedding their outer layers as planetary nebulae, leaving behind a white dwarf.',
          ),
          LessonBlock.paragraph(
            'Massive stars live fast and die young. A star 20 times the Sun\u2019s mass might exhaust its fuel in just 10 million years before exploding as a supernova, leaving behind a neutron star or black hole. The heaviest elements in your body \u2014 iron, gold, uranium \u2014 were forged in these stellar deaths.',
          ),
          LessonBlock.funFact(
            'The most common type of star in the universe is the red dwarf. They\u2019re so dim that not a single one is visible to the naked eye from Earth.',
          ),
        ],
      ),
      LessonData(
        id: 'star_2',
        title: 'How Stars Form',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Stars form inside giant molecular clouds \u2014 vast regions of gas and dust that can span hundreds of light-years. These clouds are mostly hydrogen and helium at temperatures just 10\u201320 Kelvin (\u2013253\u00B0C). A trigger like a nearby supernova shock wave or passing spiral arm can cause regions to start collapsing.',
          ),
          LessonBlock.paragraph(
            'As a gas clump contracts, it heats up and forms a protostar at its center, surrounded by a rotating disk of material. The protostar continues pulling in gas from its surroundings for about 100,000 years. When the core temperature reaches about 10 million Kelvin, hydrogen fusion begins and a true star is born.',
          ),
          LessonBlock.paragraph(
            'Stars rarely form alone. Most are born in clusters of hundreds to thousands of siblings from the same molecular cloud. Over time, these clusters disperse as stars drift apart. Our Sun was likely born in such a cluster about 4.6 billion years ago, though its siblings have long since scattered across the galaxy.',
          ),
          LessonBlock.funFact(
            'The Orion Nebula, visible to the naked eye as a fuzzy patch in Orion\u2019s sword, is an active stellar nursery forming hundreds of new stars right now.',
          ),
        ],
      ),
      LessonData(
        id: 'star_3',
        title: 'Red Giants & White Dwarfs',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'When a Sun-like star runs low on hydrogen fuel in its core, it begins fusing hydrogen in a shell around the core. This dumps extra energy into the outer layers, causing the star to swell enormously into a red giant. Our Sun will become a red giant in about 5 billion years, expanding to engulf Mercury, Venus, and possibly Earth.',
          ),
          LessonBlock.paragraph(
            'After the red giant phase, the star\u2019s outer layers drift away as a beautiful planetary nebula, while the exposed core \u2014 now a white dwarf \u2014 remains behind. White dwarfs are incredibly dense: a teaspoon of white dwarf material would weigh about 5.5 tons on Earth.',
          ),
          LessonBlock.paragraph(
            'White dwarfs no longer generate energy through fusion. They simply glow from residual heat, slowly cooling over billions of years. Eventually, they will become cold, dark objects called black dwarfs \u2014 though the universe isn\u2019t old enough for any to have formed yet.',
          ),
          LessonBlock.funFact(
            'The nearest white dwarf, Sirius B, is the companion of Sirius, the brightest star in our sky. It\u2019s about the size of Earth but has the mass of the Sun.',
          ),
        ],
      ),
      LessonData(
        id: 'star_4',
        title: 'Neutron Stars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'When a massive star (8\u201325 solar masses) explodes as a supernova, its core collapses so violently that protons and electrons merge into neutrons. The result is a neutron star \u2014 an object with 1\u20132 solar masses compressed into a sphere just 20 kilometers across, about the size of a city.',
          ),
          LessonBlock.paragraph(
            'Neutron star material is so dense that a sugar-cube-sized piece would weigh about 1 billion tons \u2014 roughly the weight of Mount Everest. The surface gravity is about 200 billion times stronger than Earth\u2019s. If you dropped an object from one meter above the surface, it would hit at about 7 million km/h.',
          ),
          LessonBlock.paragraph(
            'Neutron stars can spin incredibly fast, some rotating hundreds of times per second. They also have the strongest magnetic fields known in the universe. A special type called a magnetar has a magnetic field a quadrillion times stronger than Earth\u2019s \u2014 strong enough to warp atoms into cigar shapes.',
          ),
          LessonBlock.funFact(
            'A neutron star\u2019s surface is so smooth that the tallest \u201Cmountain\u201D would be less than a millimeter high, crushed flat by the extreme gravity.',
          ),
        ],
      ),
      LessonData(
        id: 'star_5',
        title: 'Supernovae',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'A supernova is the explosive death of a massive star. When a star heavier than about 8 solar masses exhausts its nuclear fuel, iron accumulates in the core. Unlike lighter elements, iron fusion absorbs energy rather than releasing it. The core suddenly collapses in a fraction of a second, triggering a shockwave that blasts the outer layers into space.',
          ),
          LessonBlock.paragraph(
            'During a supernova, a single star can briefly outshine an entire galaxy of hundreds of billions of stars. The explosion ejects heavy elements like oxygen, carbon, silicon, and iron into space, enriching the gas clouds from which new stars and planets will form. Almost everything on Earth heavier than hydrogen and helium was made inside a star.',
          ),
          LessonBlock.paragraph(
            'There are also Type Ia supernovae, which occur when a white dwarf in a binary system accumulates too much mass from its companion star, exceeding the Chandrasekhar limit of 1.4 solar masses. These explosions are remarkably uniform in brightness, making them invaluable \u201Cstandard candles\u201D for measuring cosmic distances.',
          ),
          LessonBlock.funFact(
            'The last supernova visible to the naked eye in our galaxy was in 1604, observed by Johannes Kepler. Astronomers are overdue for the next one.',
          ),
        ],
      ),
      LessonData(
        id: 'star_6',
        title: 'Binary Stars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Most stars in the universe are not alone \u2014 they orbit with one or more companion stars. Binary star systems, where two stars orbit their common center of mass, are incredibly common. Some estimates suggest that more than half of all Sun-like stars have at least one companion.',
          ),
          LessonBlock.paragraph(
            'Binary stars can interact dramatically. In close binaries, one star can strip material from the other, creating an accretion disk. If a white dwarf accumulates enough stolen material, it can trigger a nova explosion or even a full Type Ia supernova that destroys the white dwarf entirely.',
          ),
          LessonBlock.paragraph(
            'Binary neutron star mergers are among the most violent events in the universe. When two neutron stars spiral together and collide, they produce gravitational waves detectable on Earth, a burst of gamma rays, and forge the heaviest elements like gold and platinum. One such merger was observed in 2017, confirming the origin of these precious elements.',
          ),
          LessonBlock.funFact(
            'The gold in your jewelry was likely created billions of years ago in a neutron star collision and scattered into the gas cloud that eventually formed our solar system.',
          ),
        ],
      ),
      LessonData(
        id: 'star_7',
        title: 'Pulsars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Pulsars are rapidly spinning neutron stars that emit beams of radiation from their magnetic poles. As the star spins, these beams sweep across space like a lighthouse beacon. If one of these beams happens to point toward Earth, we detect a regular pulse of radio waves.',
          ),
          LessonBlock.paragraph(
            'The first pulsar was discovered in 1967 by Jocelyn Bell Burnell, a graduate student at Cambridge. The signal was so regular that the team initially nicknamed it \u201CLGM-1\u201D for \u201CLittle Green Men,\u201D humorously considering the possibility of alien transmissions before realizing the natural explanation.',
          ),
          LessonBlock.paragraph(
            'Millisecond pulsars spin hundreds of times per second with extraordinary precision. They are such accurate timekeepers that they rival atomic clocks on Earth. Scientists are using arrays of pulsars to detect gravitational waves by measuring tiny changes in their pulse arrival times.',
          ),
          LessonBlock.funFact(
            'The fastest known pulsar, PSR J1748-2446ad, spins 716 times per second. Its surface moves at about 24% the speed of light.',
          ),
        ],
      ),
      LessonData(
        id: 'star_8',
        title: 'Most Extreme Stars',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The universe hosts stars of staggering proportions. UY Scuti, one of the largest known stars, has a radius about 1,700 times that of our Sun. If placed at the Sun\u2019s position, its surface would extend beyond the orbit of Jupiter. Yet despite its enormous size, it\u2019s only about 30 times the Sun\u2019s mass.',
          ),
          LessonBlock.paragraph(
            'R136a1, found in the Large Magellanic Cloud, is the most massive known star at about 196 solar masses and shines with the luminosity of 6 million Suns. Stars this massive were once thought impossible, as radiation pressure should blow them apart during formation.',
          ),
          LessonBlock.paragraph(
            'At the opposite extreme, EBLM J0555-57Ab is one of the smallest known stars, barely larger than Saturn. With just 8% of the Sun\u2019s mass, it sits right at the boundary below which hydrogen fusion cannot sustain itself. Any less massive and it would be a brown dwarf \u2014 a \u201Cfailed star.\u201D',
          ),
          LessonBlock.funFact(
            'Eta Carinae, one of the most massive and luminous stars in our galaxy, is expected to explode as a supernova within the next million years. It may even become a hypernova visible in daylight.',
          ),
        ],
      ),
      LessonData(
        id: 'star_9',
        title: 'Stellar Nucleosynthesis',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Stars are the universe\u2019s element factories. In their cores, they fuse lighter elements into heavier ones through nuclear reactions. Our Sun fuses hydrogen into helium, releasing the energy that lights and warms our world. More massive stars continue fusing heavier elements in successive layers \u2014 helium into carbon, carbon into neon, and so on up to iron.',
          ),
          LessonBlock.paragraph(
            'Elements heavier than iron cannot be produced through normal stellar fusion because the process would absorb energy rather than release it. These elements \u2014 including gold, platinum, and uranium \u2014 are created in the extreme conditions of supernova explosions and neutron star mergers, through a process called rapid neutron capture (the r-process).',
          ),
          LessonBlock.paragraph(
            'The carbon in your cells, the oxygen you breathe, the calcium in your bones, and the iron in your blood were all forged inside stars that lived and died billions of years before our Sun was born. As Carl Sagan famously said, \u201CWe are made of star stuff.\u201D',
          ),
          LessonBlock.funFact(
            'Every atom of oxygen on Earth was created inside a massive star that exploded as a supernova. You are literally breathing recycled stardust.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 4. PLANETS
  // ════════════════════════════════════════
  TopicData(
    id: 'planets',
    name: 'Planets',
    emoji: '\u{1FA90}',
    description: 'Our solar system\u2019s diverse family of worlds',
    lessons: [
      LessonData(
        id: 'pl_1',
        title: 'Mercury \u2014 The Swift Planet',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Mercury is the smallest planet in our solar system and the closest to the Sun, orbiting at an average distance of just 58 million kilometers. It completes one orbit in just 88 Earth days but rotates very slowly \u2014 one Mercury day (sunrise to sunrise) lasts 176 Earth days.',
          ),
          LessonBlock.paragraph(
            'With virtually no atmosphere to trap heat, Mercury experiences the most extreme temperature swings in the solar system. Dayside temperatures can reach 430\u00B0C (hot enough to melt lead), while nightside temperatures plummet to \u2013180\u00B0C.',
          ),
          LessonBlock.paragraph(
            'Despite being the closest planet to the Sun, Mercury is not the hottest \u2014 that title belongs to Venus. Mercury\u2019s heavily cratered surface resembles our Moon, and NASA\u2019s MESSENGER spacecraft discovered water ice hiding in permanently shadowed craters near the poles.',
          ),
          LessonBlock.funFact(
            'Mercury is shrinking. As its iron core slowly cools and contracts, the planet has shrunk by about 14 kilometers in diameter over billions of years.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_2',
        title: 'Venus \u2014 Earth\u2019s Evil Twin',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Venus is often called Earth\u2019s twin because of its similar size and mass, but the resemblance ends there. Venus has a crushing atmosphere 90 times denser than Earth\u2019s, composed of 96% carbon dioxide with clouds of sulfuric acid. This extreme greenhouse effect makes it the hottest planet, with surface temperatures averaging 465\u00B0C.',
          ),
          LessonBlock.paragraph(
            'Venus rotates backwards (retrograde) compared to most planets and incredibly slowly \u2014 one Venusian day is longer than its year. A day on Venus lasts 243 Earth days, while its year is only 225 Earth days. The planet also has no moons.',
          ),
          LessonBlock.paragraph(
            'Scientists believe Venus may have once had liquid water and a mild climate for billions of years. A runaway greenhouse effect transformed it into the inferno we see today. Understanding what went wrong on Venus could help us predict Earth\u2019s own climate future.',
          ),
          LessonBlock.funFact(
            'Venus is the brightest planet in Earth\u2019s sky and has been mistaken for a UFO more than any other natural object.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_3',
        title: 'Mars \u2014 The Red Planet',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Mars gets its red color from iron oxide (rust) in its soil. It\u2019s about half the size of Earth with a thin atmosphere of mostly carbon dioxide. Surface temperatures average \u221260\u00B0C, but can range from \u2013140\u00B0C at the poles in winter to 20\u00B0C at the equator during summer.',
          ),
          LessonBlock.paragraph(
            'Mars is home to the solar system\u2019s largest volcano, Olympus Mons, standing 22 kilometers high \u2014 nearly three times the height of Mount Everest. It also has Valles Marineris, a canyon system stretching 4,000 kilometers long, dwarfing Earth\u2019s Grand Canyon.',
          ),
          LessonBlock.paragraph(
            'Evidence from rovers and orbiters strongly suggests Mars once had rivers, lakes, and possibly an ocean covering its northern hemisphere. Today, water exists mainly as ice in the polar caps and underground. This history of water makes Mars the prime target for finding evidence of past microbial life.',
          ),
          LessonBlock.funFact(
            'Mars has two tiny moons, Phobos and Deimos. Phobos is slowly spiraling inward and will either crash into Mars or break apart into a ring in about 50 million years.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_4',
        title: 'Jupiter \u2014 The Gas Giant King',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Jupiter is the largest planet in our solar system, with a mass greater than all other planets combined. It\u2019s a gas giant composed mostly of hydrogen and helium, with no solid surface. If you tried to land on Jupiter, you\u2019d simply sink deeper into increasingly dense layers of gas.',
          ),
          LessonBlock.paragraph(
            'Jupiter\u2019s most famous feature is the Great Red Spot, a massive anticyclonic storm larger than Earth that has been raging for at least 350 years. The planet also has the shortest day of any planet, rotating once every 9 hours and 56 minutes, which creates prominent bands of clouds and powerful jet streams.',
          ),
          LessonBlock.paragraph(
            'Jupiter acts as a cosmic guardian for the inner solar system. Its enormous gravity deflects many asteroids and comets that might otherwise threaten Earth. The planet has at least 95 known moons, including the four large Galilean moons discovered by Galileo in 1610.',
          ),
          LessonBlock.funFact(
            'Jupiter is so massive that it doesn\u2019t orbit the Sun \u2014 both the Sun and Jupiter orbit their common center of mass, which lies just outside the Sun\u2019s surface.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_5',
        title: 'Saturn \u2014 The Ringed Beauty',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Saturn is instantly recognizable by its stunning ring system, which extends up to 282,000 kilometers from the planet but is only about 10 meters thick on average. The rings are composed of billions of chunks of ice and rock, ranging from tiny grains to house-sized boulders, all orbiting the planet.',
          ),
          LessonBlock.paragraph(
            'Saturn is the least dense planet \u2014 it\u2019s actually less dense than water. If you could find a bathtub large enough, Saturn would float. Like Jupiter, it\u2019s a gas giant with no solid surface, composed mostly of hydrogen and helium with a possible rocky core.',
          ),
          LessonBlock.paragraph(
            'The Cassini spacecraft, which orbited Saturn from 2004 to 2017, revealed that the rings may be relatively young \u2014 perhaps only 100\u2013200 million years old, meaning they formed long after the dinosaurs appeared on Earth. Saturn\u2019s 146 known moons include Titan, with its thick atmosphere and methane lakes, and Enceladus, which shoots water geysers into space.',
          ),
          LessonBlock.funFact(
            'Saturn\u2019s north pole has a persistent hexagonal storm pattern about 30,000 kilometers across. No other planet is known to have geometric weather patterns.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_6',
        title: 'Uranus \u2014 The Tilted World',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Uranus is unique among the planets because it rotates on its side, with an axial tilt of 98 degrees. This means it essentially rolls around the Sun like a ball. Scientists believe a massive collision with an Earth-sized object early in the solar system\u2019s history knocked it over.',
          ),
          LessonBlock.paragraph(
            'As an ice giant, Uranus is composed largely of water, methane, and ammonia ices surrounding a small rocky core. Its beautiful blue-green color comes from methane in the atmosphere, which absorbs red light and reflects blue. Temperatures in the upper atmosphere drop to \u2013224\u00B0C, making it the coldest planetary atmosphere in the solar system.',
          ),
          LessonBlock.paragraph(
            'Uranus has 13 known rings (much fainter than Saturn\u2019s) and 28 known moons, all named after characters from works by Shakespeare and Alexander Pope. It was the first planet discovered with a telescope, found by William Herschel in 1781.',
          ),
          LessonBlock.funFact(
            'Due to its extreme tilt, each pole of Uranus gets around 42 years of continuous sunlight followed by 42 years of darkness.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_7',
        title: 'Neptune \u2014 The Windy Giant',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Neptune is the most distant planet in our solar system, orbiting 4.5 billion kilometers from the Sun. At that distance, sunlight takes over 4 hours to reach it, and the planet takes 165 Earth years to complete one orbit. Neptune only completed its first full orbit since discovery in 2011.',
          ),
          LessonBlock.paragraph(
            'Despite receiving very little solar energy, Neptune has the strongest winds of any planet, with gusts exceeding 2,100 km/h \u2014 faster than the speed of sound on Earth. This is puzzling because wind is usually driven by solar heating. Scientists believe internal heat from Neptune\u2019s core drives these extreme winds.',
          ),
          LessonBlock.paragraph(
            'Neptune has a large moon called Triton that orbits in the opposite direction to the planet\u2019s rotation, suggesting it was captured from the Kuiper Belt. Triton has geysers that shoot nitrogen gas 8 kilometers into the air despite surface temperatures of \u2013235\u00B0C.',
          ),
          LessonBlock.funFact(
            'Neptune was the first planet found by mathematical prediction rather than observation. Astronomers noticed irregularities in Uranus\u2019s orbit and calculated where a new planet must be.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_8',
        title: 'Dwarf Planets',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'In 2006, the International Astronomical Union redefined \u201Cplanet\u201D and created a new category: dwarf planets. These are objects massive enough for gravity to make them round but that haven\u2019t cleared their orbital neighborhoods of other debris. The five officially recognized dwarf planets are Pluto, Eris, Haumea, Makemake, and Ceres.',
          ),
          LessonBlock.paragraph(
            'Pluto, the most famous dwarf planet, was visited by NASA\u2019s New Horizons spacecraft in 2015, revealing a surprisingly complex world with nitrogen ice glaciers, mountain ranges made of water ice, and a thin atmosphere. Its heart-shaped feature, Tombaugh Regio, captured public imagination worldwide.',
          ),
          LessonBlock.paragraph(
            'Ceres is the only dwarf planet in the asteroid belt between Mars and Jupiter. NASA\u2019s Dawn spacecraft discovered bright spots on its surface that turned out to be deposits of sodium carbonate \u2014 evidence that Ceres once had a subsurface ocean that may still partially exist today.',
          ),
          LessonBlock.funFact(
            'Eris, which triggered Pluto\u2019s reclassification, is slightly less massive than Pluto but was initially thought to be larger. It orbits the Sun once every 557 years.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_9',
        title: 'How Planets Form',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Planets form from the same cloud of gas and dust that gives birth to their parent star. As a young star ignites, the leftover material settles into a rotating protoplanetary disk. Within this disk, tiny dust grains collide and stick together, gradually growing into pebbles, boulders, and eventually planetesimals kilometers across.',
          ),
          LessonBlock.paragraph(
            'Close to the star where it\u2019s hot, only rocky and metallic materials can survive, forming terrestrial planets like Earth. Beyond the \u201Csnow line\u201D where water can freeze, ice adds to the building material, allowing planets to grow large enough to capture vast amounts of hydrogen and helium, becoming gas giants.',
          ),
          LessonBlock.paragraph(
            'The entire process from dust to mature planet takes roughly 10\u2013100 million years. Telescopes like ALMA and JWST have directly imaged protoplanetary disks around young stars, revealing rings and gaps that indicate planets actively forming \u2014 giving us a front-row seat to planetary birth.',
          ),
          LessonBlock.funFact(
            'Our solar system\u2019s planets contain only about 0.14% of the total mass of the solar system. The Sun holds 99.86% of all the mass.',
          ),
        ],
      ),
      LessonData(
        id: 'pl_10',
        title: 'Planetary Atmospheres',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Each planet\u2019s atmosphere tells a unique story. Earth\u2019s nitrogen-oxygen atmosphere supports life and shields us from harmful radiation. Mars once had a thick atmosphere but lost most of it because its small size and weak magnetic field couldn\u2019t protect against the solar wind stripping it away.',
          ),
          LessonBlock.paragraph(
            'Venus demonstrates the extreme end of the greenhouse effect \u2014 its thick CO\u2082 atmosphere traps so much heat that the surface is hotter than Mercury despite being twice as far from the Sun. Jupiter and Saturn\u2019s atmospheres are thousands of kilometers deep with no clear boundary between atmosphere and interior.',
          ),
          LessonBlock.paragraph(
            'Titan, Saturn\u2019s largest moon, is the only moon with a substantial atmosphere \u2014 denser than Earth\u2019s. It\u2019s rich in nitrogen with methane playing the role that water plays on Earth, forming clouds, rain, rivers, and lakes. Studying these diverse atmospheres helps scientists understand what makes a world habitable.',
          ),
          LessonBlock.funFact(
            'On Jupiter, it rains diamonds. Lightning converts methane into carbon, which is compressed into diamonds as it falls through the atmosphere.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 5. MOONS
  // ════════════════════════════════════════
  TopicData(
    id: 'moons',
    name: 'Moons',
    emoji: '\u{1F311}',
    description: 'Fascinating worlds orbiting planets',
    lessons: [
      LessonData(
        id: 'mn_1',
        title: 'Earth\u2019s Moon',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Our Moon is the fifth-largest satellite in the solar system, about a quarter the diameter of Earth. It formed roughly 4.5 billion years ago when a Mars-sized body called Theia slammed into the young Earth. The collision ejected a massive cloud of debris that coalesced into the Moon.',
          ),
          LessonBlock.paragraph(
            'The Moon is the only celestial body beyond Earth that humans have visited. Between 1969 and 1972, twelve astronauts walked on its surface during NASA\u2019s Apollo program. They brought back 382 kilograms of lunar rocks that are still being studied today with increasingly advanced instruments.',
          ),
          LessonBlock.paragraph(
            'The Moon is tidally locked to Earth, meaning it always shows us the same face. It\u2019s slowly drifting away at about 3.8 centimeters per year. The Moon stabilizes Earth\u2019s axial tilt, which is crucial for maintaining the moderate climate that supports life.',
          ),
          LessonBlock.funFact(
            'The Moon has moonquakes. Apollo astronauts left seismometers that detected thousands of quakes, some lasting up to 10 minutes \u2014 much longer than earthquakes.',
          ),
        ],
      ),
      LessonData(
        id: 'mn_2',
        title: 'Europa \u2014 Ocean World',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Europa, one of Jupiter\u2019s four large Galilean moons, is one of the most promising places to search for extraterrestrial life. Beneath its smooth, cracked ice shell lies a global ocean of liquid water estimated to contain twice as much water as all of Earth\u2019s oceans combined.',
          ),
          LessonBlock.paragraph(
            'The ocean stays liquid despite Europa\u2019s distance from the Sun because of tidal heating. Jupiter\u2019s enormous gravity constantly flexes and squeezes Europa as it orbits, generating internal heat. The ice surface shows signs of recent geological activity, including ridges, fractures, and possible plumes of water vapor erupting into space.',
          ),
          LessonBlock.paragraph(
            'NASA\u2019s Europa Clipper mission, launched in 2024, will perform nearly 50 close flybys to study the ice shell, ocean, and composition in detail. If hydrothermal vents exist on Europa\u2019s ocean floor \u2014 similar to those on Earth\u2019s seafloor that support thriving ecosystems \u2014 life could potentially exist there.',
          ),
          LessonBlock.funFact(
            'Arthur C. Clarke\u2019s novel \u201C2010: Odyssey Two\u201D features a famous warning about Europa: \u201CAll these worlds are yours \u2014 except Europa. Attempt no landing there.\u201D',
          ),
        ],
      ),
      LessonData(
        id: 'mn_3',
        title: 'Titan \u2014 The Methane World',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Titan, Saturn\u2019s largest moon, is the only moon in the solar system with a dense atmosphere and the only body besides Earth known to have stable surface liquids. But instead of water, Titan\u2019s lakes and seas are filled with liquid methane and ethane at a chilling \u2013179\u00B0C.',
          ),
          LessonBlock.paragraph(
            'Titan\u2019s atmosphere is thicker than Earth\u2019s and rich in nitrogen with complex organic chemistry. Methane plays the same role as water does on Earth: evaporating, forming clouds, falling as rain, and flowing in rivers into seas. The largest sea, Kraken Mare, is roughly the size of the Caspian Sea.',
          ),
          LessonBlock.paragraph(
            'In 2005, the Huygens probe became the first spacecraft to land in the outer solar system when it parachuted onto Titan\u2019s surface. It transmitted images of rounded ice pebbles and evidence of recent methane rainfall. NASA\u2019s upcoming Dragonfly mission will send a drone to fly across Titan\u2019s surface, exploring its diverse terrain.',
          ),
          LessonBlock.funFact(
            'Titan\u2019s gravity is low and its atmosphere is thick enough that a human with artificial wings could fly by flapping their arms.',
          ),
        ],
      ),
      LessonData(
        id: 'mn_4',
        title: 'Io \u2014 The Volcanic Moon',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Io, Jupiter\u2019s innermost large moon, is the most volcanically active body in the solar system. It has over 400 active volcanoes that constantly reshape its colorful surface with eruptions of sulfur and silicate lava. Some volcanic plumes rise over 300 kilometers above the surface.',
          ),
          LessonBlock.paragraph(
            'This extreme volcanism is driven by tidal heating from Jupiter\u2019s massive gravitational pull, amplified by orbital resonances with fellow moons Europa and Ganymede. The constant flexing generates enormous internal heat, keeping Io\u2019s interior partially molten.',
          ),
          LessonBlock.paragraph(
            'Io\u2019s surface is a kaleidoscope of yellows, oranges, blacks, and whites from various sulfur compounds and silicate rocks. It has no impact craters because volcanic activity buries them under fresh lava so quickly. The surface is completely resurfaced every few thousand years.',
          ),
          LessonBlock.funFact(
            'Io\u2019s volcanic output is so prolific that it ejects about one ton of material into space every second, forming a donut-shaped cloud of plasma around Jupiter.',
          ),
        ],
      ),
      LessonData(
        id: 'mn_5',
        title: 'Ganymede \u2014 The Largest Moon',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Ganymede is the largest moon in the solar system \u2014 bigger than the planet Mercury, with a diameter of 5,268 kilometers. If it orbited the Sun instead of Jupiter, it would easily be classified as a planet. It\u2019s the only moon known to generate its own magnetic field.',
          ),
          LessonBlock.paragraph(
            'Ganymede\u2019s surface tells a story of two geological eras. Dark, heavily cratered regions are ancient, perhaps 4 billion years old. Lighter grooved terrain is younger and was likely formed by tectonic processes, showing that Ganymede was once geologically active.',
          ),
          LessonBlock.paragraph(
            'Like Europa, Ganymede is thought to harbor a subsurface ocean, sandwiched between layers of ice at a depth of about 200 kilometers. ESA\u2019s JUICE (Jupiter Icy Moons Explorer) mission, launched in 2023, will arrive at Jupiter in 2031 and eventually orbit Ganymede to study this intriguing world.',
          ),
          LessonBlock.funFact(
            'Ganymede\u2019s magnetic field creates miniature auroras \u2014 glowing ribbons of light at its poles, just like Earth\u2019s northern and southern lights.',
          ),
        ],
      ),
      LessonData(
        id: 'mn_6',
        title: 'Enceladus \u2014 The Geyser Moon',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Enceladus, a small moon of Saturn just 500 kilometers across, stunned scientists when the Cassini spacecraft discovered enormous geysers erupting from its south pole. These plumes shoot water ice, salts, and organic molecules hundreds of kilometers into space, some of which feeds Saturn\u2019s E ring.',
          ),
          LessonBlock.paragraph(
            'Beneath Enceladus\u2019s icy crust lies a global ocean of liquid water, kept warm by tidal heating from Saturn\u2019s gravity. Cassini flew through the plumes and detected molecular hydrogen \u2014 a potential energy source for microbial life. The ocean also contains silica nanoparticles, suggesting hydrothermal vents on the ocean floor.',
          ),
          LessonBlock.paragraph(
            'What makes Enceladus especially exciting for astrobiologists is that its ocean water is being delivered directly into space via the plumes. A future mission wouldn\u2019t even need to land or drill through the ice \u2014 it could simply fly through the plumes and sample the ocean water directly.',
          ),
          LessonBlock.funFact(
            'Enceladus is the most reflective body in the solar system, bouncing back nearly 100% of sunlight. Its fresh ice surface is as white as fresh snow.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 6. ASTEROIDS & COMETS
  // ════════════════════════════════════════
  TopicData(
    id: 'asteroids_comets',
    name: 'Asteroids & Comets',
    emoji: '\u2604\uFE0F',
    description: 'Ancient remnants from the birth of our solar system',
    lessons: [
      LessonData(
        id: 'ac_1',
        title: 'The Asteroid Belt',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The asteroid belt lies between Mars and Jupiter, containing millions of rocky bodies ranging from dust-sized particles to the dwarf planet Ceres at 950 kilometers across. Despite what movies show, the belt is mostly empty space \u2014 spacecraft pass through it without difficulty.',
          ),
          LessonBlock.paragraph(
            'The total mass of all asteroids in the belt is only about 4% of the Moon\u2019s mass. Jupiter\u2019s powerful gravity prevented this material from ever coalescing into a planet. The asteroids are remnants from the early solar system, preserved time capsules that can tell us about conditions 4.6 billion years ago.',
          ),
          LessonBlock.paragraph(
            'Asteroids come in three main types: C-type (carbonaceous, the most common), S-type (silicaceous, rocky), and M-type (metallic, containing iron and nickel). Some asteroids are solid rocks, while others are loose piles of rubble held together by gravity, called \u201Crubble piles.\u201D',
          ),
          LessonBlock.funFact(
            'If you combined all the asteroids in the belt into one body, it would be smaller than our Moon \u2014 only about 1,400 kilometers across.',
          ),
        ],
      ),
      LessonData(
        id: 'ac_2',
        title: 'Near-Earth Objects',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Near-Earth objects (NEOs) are asteroids and comets whose orbits bring them within 50 million kilometers of Earth\u2019s orbit. As of 2024, astronomers have identified over 34,000 NEOs, with about 2,400 classified as potentially hazardous \u2014 meaning they could come dangerously close to Earth.',
          ),
          LessonBlock.paragraph(
            'NASA\u2019s planetary defense program continuously monitors the sky for threatening objects. The DART mission in 2022 successfully demonstrated that a spacecraft impact could alter an asteroid\u2019s orbit, changing the trajectory of the moonlet Dimorphos by 33 minutes \u2014 humanity\u2019s first test of planetary defense technology.',
          ),
          LessonBlock.paragraph(
            'While a catastrophic asteroid impact is extremely unlikely in any given century, the consequences would be severe. Objects larger than 1 kilometer could cause global devastation. The good news: no known asteroid poses a significant threat to Earth for at least the next 100 years.',
          ),
          LessonBlock.funFact(
            'Earth is hit by about 100 tons of space debris every day, but almost all of it is dust and small particles that burn up harmlessly in the atmosphere.',
          ),
        ],
      ),
      LessonData(
        id: 'ac_3',
        title: 'Famous Comets',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Comets are icy bodies from the outer solar system that develop spectacular tails when they approach the Sun. The heat vaporizes their ice, creating a glowing coma and tails that can extend millions of kilometers. Comets have two tails: a dust tail curved by solar gravity and an ion tail pushed straight back by the solar wind.',
          ),
          LessonBlock.paragraph(
            'Halley\u2019s Comet, the most famous periodic comet, returns to the inner solar system every 75\u201376 years. It was last visible in 1986 and will return in 2061. Historical records of Halley\u2019s appearances go back to at least 240 BCE, making it one of the longest-observed objects in astronomy.',
          ),
          LessonBlock.paragraph(
            'In 2014, ESA\u2019s Rosetta spacecraft became the first to orbit a comet (67P/Churyumov\u2013Gerasimenko) and deployed the Philae lander onto its surface. The mission revealed that comets contain complex organic molecules and a type of water slightly different from Earth\u2019s, suggesting that asteroids, not comets, may have delivered most of Earth\u2019s water.',
          ),
          LessonBlock.funFact(
            'Comet tails always point away from the Sun regardless of the comet\u2019s direction of travel. A comet leaving the inner solar system actually travels tail-first.',
          ),
        ],
      ),
      LessonData(
        id: 'ac_4',
        title: 'Asteroid Mining',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Some asteroids contain enormous quantities of valuable metals. A single metallic asteroid just 1 kilometer across could contain more platinum-group metals than have ever been mined in human history. The asteroid 16 Psyche, which NASA is currently sending a mission to study, may be the exposed core of a protoplanet and could contain iron and nickel worth quintillions of dollars.',
          ),
          LessonBlock.paragraph(
            'Water-rich asteroids could be even more valuable in space than metallic ones. Water can be split into hydrogen and oxygen for rocket fuel, meaning asteroid water could serve as \u201Cgas stations\u201D for deep-space missions. Near-Earth asteroids are particularly attractive targets because some require less energy to reach than the Moon.',
          ),
          LessonBlock.paragraph(
            'While the technology for large-scale asteroid mining doesn\u2019t yet exist, several companies and space agencies are actively researching it. Japan\u2019s Hayabusa2 mission successfully returned samples from asteroid Ryugu in 2020, proving that we can reach, study, and return material from asteroids.',
          ),
          LessonBlock.funFact(
            'The asteroid 511 Davida contains enough nickel-iron to supply global demand for thousands of years.',
          ),
        ],
      ),
      LessonData(
        id: 'ac_5',
        title: 'Extinction Events',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'About 66 million years ago, an asteroid roughly 10 kilometers across slammed into what is now the Yucatan Peninsula in Mexico, creating the 180-kilometer-wide Chicxulub crater. The impact released energy equivalent to billions of nuclear bombs, triggering earthquakes, tsunamis, and fires across the globe.',
          ),
          LessonBlock.paragraph(
            'The most devastating effect was the global winter that followed. Dust and sulfur thrown into the atmosphere blocked sunlight for months to years, killing most plant life and collapsing food chains. About 75% of all species went extinct, including all non-avian dinosaurs, making way for the rise of mammals.',
          ),
          LessonBlock.paragraph(
            'Mass extinctions from impacts have happened multiple times in Earth\u2019s history. The Late Heavy Bombardment, about 3.8\u20134.1 billion years ago, saw intense asteroid and comet impacts across the inner solar system. Ironically, these early impacts may have delivered the water and organic molecules necessary for life to begin.',
          ),
          LessonBlock.funFact(
            'The Chicxulub asteroid hit at roughly 20 km/s and was traveling so fast that it punched through the entire atmosphere in about one second.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 7. TELESCOPES & MISSIONS
  // ════════════════════════════════════════
  TopicData(
    id: 'telescopes',
    name: 'Telescopes & Missions',
    emoji: '\u{1F52D}',
    description: 'Humanity\u2019s eyes on the cosmos',
    lessons: [
      LessonData(
        id: 'tm_1',
        title: 'The Hubble Space Telescope',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Launched in 1990, the Hubble Space Telescope has revolutionized our understanding of the universe for over three decades. Orbiting 547 kilometers above Earth, above the atmosphere\u2019s distortion, Hubble captures images of extraordinary clarity across ultraviolet, visible, and near-infrared wavelengths.',
          ),
          LessonBlock.paragraph(
            'Hubble\u2019s discoveries are staggering: it helped determine the age of the universe (13.8 billion years), proved that supermassive black holes exist at the centers of galaxies, observed galaxies in every stage of evolution, and provided evidence that the expansion of the universe is accelerating.',
          ),
          LessonBlock.paragraph(
            'The Hubble Deep Field images, taken by pointing the telescope at seemingly empty patches of sky for days, revealed thousands of galaxies in an area smaller than a grain of sand held at arm\u2019s length. These images showed that the universe is far more populated with galaxies than anyone had imagined.',
          ),
          LessonBlock.funFact(
            'When Hubble was first launched, its main mirror had a flaw just 1/50th the width of a human hair. Astronauts installed corrective optics in 1993, effectively giving Hubble \u201Cglasses.\u201D',
          ),
        ],
      ),
      LessonData(
        id: 'tm_2',
        title: 'James Webb Space Telescope',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The James Webb Space Telescope (JWST), launched on Christmas Day 2021, is the most powerful space telescope ever built. Its 6.5-meter gold-coated mirror is over 2.5 times larger than Hubble\u2019s and is optimized for infrared light, allowing it to peer through dust clouds and observe the most distant objects in the universe.',
          ),
          LessonBlock.paragraph(
            'JWST orbits the Sun at the second Lagrange point (L2), about 1.5 million kilometers from Earth. A tennis-court-sized sunshield keeps the telescope at \u2013233\u00B0C, cold enough for its sensitive infrared detectors to operate. Unlike Hubble, JWST is too far away for astronauts to repair.',
          ),
          LessonBlock.paragraph(
            'In its first years, JWST has already transformed astronomy: revealing galaxies that formed just 300 million years after the Big Bang, detecting carbon dioxide in an exoplanet atmosphere, and capturing unprecedented views of star-forming regions like the Pillars of Creation with breathtaking clarity and detail.',
          ),
          LessonBlock.funFact(
            'JWST\u2019s mirror is so smooth that if it were scaled up to the size of the United States, the largest bump would be only 6 centimeters tall.',
          ),
        ],
      ),
      LessonData(
        id: 'tm_3',
        title: 'The Voyager Missions',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Voyager 1 and 2, launched in 1977, are humanity\u2019s farthest-traveling emissaries. Taking advantage of a rare planetary alignment that occurs once every 175 years, they performed a grand tour of the outer planets. Voyager 2 remains the only spacecraft to have visited both Uranus and Neptune.',
          ),
          LessonBlock.paragraph(
            'Voyager 1 entered interstellar space in 2012, becoming the first human-made object to leave the solar system\u2019s protective bubble of solar wind (the heliosphere). As of 2024, it is over 24 billion kilometers from Earth, and its signals, traveling at the speed of light, take over 22 hours to reach us.',
          ),
          LessonBlock.paragraph(
            'Each Voyager carries a Golden Record \u2014 a 12-inch gold-plated phonograph record containing sounds and images of Earth, including greetings in 55 languages, music from various cultures, and the brainwaves of a person in love. They are messages in a bottle cast into the cosmic ocean.',
          ),
          LessonBlock.funFact(
            'Voyager 1\u2019s computers have less memory than a modern musical greeting card, yet they\u2019ve operated flawlessly for over 47 years.',
          ),
        ],
      ),
      LessonData(
        id: 'tm_4',
        title: 'Mars Rovers',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'NASA has sent five rovers to Mars: Sojourner (1997), Spirit and Opportunity (2004), Curiosity (2012), and Perseverance (2021). Each generation has been more capable than the last, transforming our understanding of Mars from a dead, dusty world to one with a rich geological history.',
          ),
          LessonBlock.paragraph(
            'Opportunity set an astonishing record, operating for over 14 years (originally designed for 90 days) and traveling 45 kilometers across the Martian surface. It found definitive evidence that water once flowed on Mars, including minerals that only form in water and ancient riverbeds.',
          ),
          LessonBlock.paragraph(
            'Perseverance, currently exploring Jezero Crater (an ancient lake bed), is collecting rock samples in sealed tubes for a future return mission. It also carried Ingenuity, the first helicopter to fly on another planet, which completed 72 flights before retiring \u2014 proving powered flight is possible in Mars\u2019s thin atmosphere.',
          ),
          LessonBlock.funFact(
            'Opportunity\u2019s final message before a global dust storm ended its mission was essentially \u201CMy battery is low and it\u2019s getting dark.\u201D',
          ),
        ],
      ),
      LessonData(
        id: 'tm_5',
        title: 'The Cassini Mission',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The Cassini-Huygens mission, a collaboration between NASA, ESA, and the Italian Space Agency, spent 13 years orbiting Saturn from 2004 to 2017. It was one of the most ambitious planetary missions ever undertaken, transforming our understanding of Saturn, its rings, and its moons.',
          ),
          LessonBlock.paragraph(
            'Cassini discovered that Enceladus has water geysers erupting from its south pole, revealing a subsurface ocean. It observed massive storms on Saturn, mapped Titan\u2019s methane lakes using radar, and witnessed the changing seasons as Saturn orbited the Sun. It completed 294 orbits of Saturn and 162 targeted moon flybys.',
          ),
          LessonBlock.paragraph(
            'In September 2017, with its fuel running low, Cassini was deliberately plunged into Saturn\u2019s atmosphere to prevent any chance of contaminating potentially habitable moons. During its final \u201CGrand Finale,\u201D it dove between Saturn and its rings 22 times, returning unprecedented data before burning up.',
          ),
          LessonBlock.funFact(
            'During its Grand Finale, Cassini discovered that Saturn\u2019s rings are surprisingly young \u2014 only about 100 million years old, far younger than the planet itself.',
          ),
        ],
      ),
      LessonData(
        id: 'tm_6',
        title: 'New Horizons at Pluto',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'NASA\u2019s New Horizons spacecraft flew past Pluto on July 14, 2015, after a nine-and-a-half-year journey covering 5 billion kilometers. It passed within 12,500 kilometers of Pluto\u2019s surface at 50,000 km/h, capturing the first detailed images of this distant world.',
          ),
          LessonBlock.paragraph(
            'The flyby revealed a far more complex world than anyone expected. Pluto has towering mountains of water ice up to 5 kilometers high, a vast heart-shaped nitrogen ice glacier (Sputnik Planitia), a thin atmosphere that creates blue hazes, and evidence of recent geological activity on a world once assumed to be cold and dead.',
          ),
          LessonBlock.paragraph(
            'After Pluto, New Horizons continued into the Kuiper Belt and flew past Arrokoth (formerly \u201CUltima Thule\u201D) in 2019, the most distant object ever visited by a spacecraft. Arrokoth\u2019s snowman-like shape revealed how small bodies gently merged in the early solar system.',
          ),
          LessonBlock.funFact(
            'New Horizons was so far from Earth during the Pluto flyby that its signals, traveling at light speed, took 4.5 hours to reach mission control.',
          ),
        ],
      ),
      LessonData(
        id: 'tm_7',
        title: 'The Chandra X-ray Observatory',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Launched in 1999, the Chandra X-ray Observatory sees the universe in X-rays, revealing the extremely hot and energetic side of the cosmos. X-rays are produced by gas heated to millions of degrees, often found around black holes, in supernova remnants, and in galaxy clusters.',
          ),
          LessonBlock.paragraph(
            'Chandra\u2019s angular resolution is so sharp that it could read a stop sign from 20 kilometers away (if it read visible light). It has produced iconic images of supernova remnants like Cassiopeia A, showing the detailed structure of stellar explosions, and revealed millions of previously unknown black holes across the universe.',
          ),
          LessonBlock.paragraph(
            'One of Chandra\u2019s most important discoveries was observing the Bullet Cluster, where two galaxy clusters collided. The X-ray-emitting gas separated from the dark matter, providing some of the strongest direct evidence that dark matter is a real substance and not just a modification of gravity.',
          ),
          LessonBlock.funFact(
            'Earth\u2019s atmosphere blocks X-rays from space, which is great for our health but means X-ray telescopes must be in orbit. Ground-based X-ray astronomy is impossible.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 8. SPACE EXPLORATION
  // ════════════════════════════════════════
  TopicData(
    id: 'exploration',
    name: 'Space Exploration',
    emoji: '\u{1F468}\u200D\u{1F680}',
    description: 'Humanity\u2019s greatest adventure beyond Earth',
    lessons: [
      LessonData(
        id: 'ex_1',
        title: 'The Apollo Missions',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'The Apollo program was humanity\u2019s greatest exploration achievement. On July 20, 1969, Apollo 11 astronauts Neil Armstrong and Buzz Aldrin became the first humans to walk on the Moon, while Michael Collins orbited above. Armstrong\u2019s famous words \u2014 \u201CThat\u2019s one small step for man, one giant leap for mankind\u201D \u2014 were heard by an estimated 600 million people worldwide.',
          ),
          LessonBlock.paragraph(
            'Between 1969 and 1972, six Apollo missions successfully landed on the Moon, and twelve astronauts walked on its surface. Apollo 13, though it never landed, became famous for its harrowing survival story when an oxygen tank exploded en route to the Moon, and the crew improvised their way back to Earth.',
          ),
          LessonBlock.paragraph(
            'The Apollo program cost about \$25.4 billion (roughly \$200 billion in today\u2019s dollars) and employed 400,000 people at its peak. The technology developed for Apollo led to innovations we use daily, including water purification systems, scratch-resistant lenses, and the basic architecture of modern computers.',
          ),
          LessonBlock.funFact(
            'The Apollo Guidance Computer had less processing power than a modern calculator. It had just 74 kilobytes of memory and ran at 0.043 MHz.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_2',
        title: 'The International Space Station',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The International Space Station (ISS) is the largest human-made structure in space, spanning the size of a football field and orbiting 408 kilometers above Earth. It has been continuously occupied since November 2000, making it the longest-running human presence in space.',
          ),
          LessonBlock.paragraph(
            'Built collaboratively by 15 nations, the ISS serves as a microgravity laboratory where astronauts conduct experiments in biology, physics, astronomy, and medicine. Research on the ISS has contributed to advances in cancer treatment, water purification technology, and our understanding of how the human body adapts to long-duration spaceflight.',
          ),
          LessonBlock.paragraph(
            'The ISS orbits Earth every 90 minutes at 28,000 km/h, meaning its crew sees 16 sunrises and sunsets every day. It\u2019s visible to the naked eye as a bright moving point of light in the night sky. The station is expected to operate until around 2030 before being deorbited into the Pacific Ocean.',
          ),
          LessonBlock.funFact(
            'Astronauts on the ISS drink recycled urine and sweat. The water recovery system is so efficient that it recovers about 90% of all water on the station.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_3',
        title: 'The SpaceX Revolution',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'SpaceX, founded by Elon Musk in 2002, has fundamentally changed the space industry by developing reusable rockets. Before SpaceX, every rocket was discarded after one use \u2014 like throwing away an airplane after one flight. SpaceX\u2019s Falcon 9 boosters routinely land themselves and fly again, slashing launch costs.',
          ),
          LessonBlock.paragraph(
            'The company\u2019s achievements include: the first privately funded liquid-fueled rocket to reach orbit (Falcon 1, 2008), the first private spacecraft to dock with the ISS (Dragon, 2012), and the most powerful operational rocket in the world (Falcon Heavy, 2018). SpaceX now launches more than any other provider globally.',
          ),
          LessonBlock.paragraph(
            'SpaceX\u2019s Starship, currently in testing, is designed to be the most powerful rocket ever built \u2014 capable of carrying 100+ tons to orbit and eventually transporting humans to Mars. Fully reusable, it aims to reduce the cost of space access by orders of magnitude, potentially making humanity a multi-planetary species.',
          ),
          LessonBlock.funFact(
            'A single Falcon 9 booster has flown and landed over 20 times. The record-holding booster has completed more flights than most airplanes do in a year.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_4',
        title: 'The Artemis Program',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'NASA\u2019s Artemis program aims to return humans to the Moon for the first time since Apollo 17 in 1972. The program plans to land the first woman and first person of color on the Moon, establish a sustainable presence, and use the Moon as a stepping stone for future Mars missions.',
          ),
          LessonBlock.paragraph(
            'Artemis I, an uncrewed test flight, successfully orbited the Moon in 2022 using the Space Launch System (SLS) rocket and Orion capsule. Artemis II will carry astronauts around the Moon without landing, while Artemis III will attempt the first crewed lunar landing since 1972, using SpaceX\u2019s Starship as the lunar lander.',
          ),
          LessonBlock.paragraph(
            'The long-term vision includes building the Lunar Gateway, a small space station orbiting the Moon, and establishing a base camp at the lunar south pole where water ice deposits could provide drinking water, oxygen, and rocket fuel. These capabilities will be essential rehearsals for the ultimate goal: sending humans to Mars.',
          ),
          LessonBlock.funFact(
            'The Artemis spacesuits are a massive upgrade from Apollo. They allow full mobility, fit a wider range of body sizes, and can support moonwalks lasting up to 8 hours.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_5',
        title: 'Mars Colonization',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Establishing a human settlement on Mars is one of the grandest goals in space exploration. Mars is the most Earth-like planet in our solar system, with a 24.6-hour day, seasons, polar ice caps, and evidence of past water. However, the challenges are immense: thin atmosphere, extreme cold, high radiation, and a 6\u20139 month journey each way.',
          ),
          LessonBlock.paragraph(
            'SpaceX\u2019s plan involves sending Starship vehicles to Mars during launch windows that open every 26 months when the planets align favorably. Initial missions would establish fuel production using Mars\u2019s atmospheric CO\u2082, build habitats, and develop life-support systems before permanent settlers arrive.',
          ),
          LessonBlock.paragraph(
            'Colonists would face unique challenges including growing food in Martian soil (which contains toxic perchlorates), maintaining physical health in 38% of Earth\u2019s gravity, and dealing with the psychological effects of isolation. Yet the reward could be ensuring humanity\u2019s survival as a multi-planetary species.',
          ),
          LessonBlock.funFact(
            'Communication between Earth and Mars has a delay of 4 to 24 minutes depending on planetary positions. Real-time conversation is impossible \u2014 Mars colonists would truly be on their own.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_6',
        title: 'Indian Space Program',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The Indian Space Research Organisation (ISRO) has emerged as one of the world\u2019s most capable and cost-effective space agencies. Founded in 1969, ISRO has achieved remarkable milestones including launching India\u2019s first satellite (Aryabhata, 1975) and developing a family of reliable launch vehicles.',
          ),
          LessonBlock.paragraph(
            'ISRO\u2019s Mars Orbiter Mission (Mangalyaan) in 2014 made India the first Asian nation to reach Mars orbit and the first nation to do so on its first attempt. The mission cost just \$74 million \u2014 less than the budget of the movie \u201CGravity\u201D \u2014 demonstrating ISRO\u2019s remarkable efficiency.',
          ),
          LessonBlock.paragraph(
            'In 2023, Chandrayaan-3 successfully landed near the Moon\u2019s south pole, making India the fourth country to achieve a soft lunar landing and the first to land near the south pole. The Gaganyaan program aims to send Indian astronauts to space aboard an indigenous crew vehicle, cementing India\u2019s position as a major space power.',
          ),
          LessonBlock.funFact(
            'ISRO once transported rocket parts on a bicycle and a bullock cart. Today, it launches satellites for countries around the world at a fraction of competitors\u2019 costs.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_7',
        title: 'Moon Bases',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Multiple nations and companies are planning permanent bases on the Moon. The most promising location is the lunar south pole, where permanently shadowed craters contain billions of tons of water ice. This water could supply drinking water, generate breathable oxygen, and produce hydrogen fuel for rockets.',
          ),
          LessonBlock.paragraph(
            'Living on the Moon presents unique challenges: one lunar day lasts about 29 Earth days, with two weeks of scorching sunlight followed by two weeks of frigid darkness. The south pole offers areas with near-constant sunlight on crater rims (for solar power) while keeping ice preserved in nearby shadows.',
          ),
          LessonBlock.paragraph(
            'Concepts for lunar habitats include inflatable modules, 3D-printed structures using lunar regolith (soil), and underground lava tubes that could provide natural radiation shielding. China, NASA, and ESA all have active programs targeting lunar base construction, potentially beginning in the 2030s.',
          ),
          LessonBlock.funFact(
            'The Moon\u2019s lava tubes can be enormous \u2014 some are hundreds of meters wide and could fit entire cities inside, providing ready-made shelter from radiation and micrometeorites.',
          ),
        ],
      ),
      LessonData(
        id: 'ex_8',
        title: 'Future of Space Travel',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The next century of space travel could see technologies that sound like science fiction. Ion drives, already used on some spacecraft, provide small but continuous thrust that can accelerate a craft to enormous speeds over time. Solar sails use the pressure of sunlight for propulsion, requiring no fuel at all.',
          ),
          LessonBlock.paragraph(
            'Nuclear thermal propulsion could cut Mars travel time in half by heating hydrogen fuel with a nuclear reactor to produce thrust far more efficiently than chemical rockets. NASA and DARPA are actively developing this technology with plans to test it in orbit by 2027.',
          ),
          LessonBlock.paragraph(
            'The most ambitious concept is the Breakthrough Starshot initiative, which aims to send tiny light-sail probes to the nearest star system, Alpha Centauri, at 20% the speed of light using powerful ground-based lasers. The probes would arrive in about 20 years, compared to tens of thousands of years with current rocket technology.',
          ),
          LessonBlock.funFact(
            'At 20% the speed of light, you could travel from New York to Los Angeles in about one-twentieth of a second.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 9. EARTH & CLIMATE
  // ════════════════════════════════════════
  TopicData(
    id: 'earth',
    name: 'Earth & Climate',
    emoji: '\u{1F30D}',
    description: 'Our home planet seen from the cosmic perspective',
    lessons: [
      LessonData(
        id: 'ec_1',
        title: 'Earth from Space',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Seen from space, Earth is a brilliant blue marble streaked with white clouds, unlike any other planet we\u2019ve observed. The blue comes from our vast oceans covering 71% of the surface, while the white clouds reveal a dynamic atmosphere constantly in motion. This view has profoundly changed how humanity sees itself.',
          ),
          LessonBlock.paragraph(
            'The \u201Coverview effect\u201D is a cognitive shift reported by astronauts who see Earth from space. They describe a powerful sense of the planet\u2019s fragility, the thinness of the atmosphere, and the absence of borders visible from orbit. Many return with a deepened commitment to environmental stewardship.',
          ),
          LessonBlock.paragraph(
            'Earth observation satellites provide invaluable data about our planet\u2019s health. They monitor deforestation, track hurricanes, measure ice sheet loss, detect wildfires, and observe ocean temperatures. This \u201Ceye in the sky\u201D perspective has been essential for understanding and addressing climate change.',
          ),
          LessonBlock.funFact(
            'The famous \u201CEarthrise\u201D photo taken during Apollo 8 in 1968 is widely credited with helping launch the environmental movement. It was the first time humans saw their home from deep space.',
          ),
        ],
      ),
      LessonData(
        id: 'ec_2',
        title: 'Atmosphere Layers',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Earth\u2019s atmosphere is divided into five main layers. The troposphere (0\u201312 km) is where weather happens and where we live. The stratosphere (12\u201350 km) contains the ozone layer that shields us from harmful ultraviolet radiation. The mesosphere (50\u201385 km) is where most meteors burn up.',
          ),
          LessonBlock.paragraph(
            'The thermosphere (85\u2013600 km) is where auroras occur and the ISS orbits. Despite temperatures reaching 2,500\u00B0C, you wouldn\u2019t feel warm because the air molecules are so sparse. The exosphere (600\u201310,000 km) gradually fades into the vacuum of space with no sharp boundary.',
          ),
          LessonBlock.paragraph(
            'Earth\u2019s atmosphere is remarkably thin relative to the planet \u2014 if Earth were the size of an apple, the atmosphere would be thinner than the apple\u2019s skin. Yet this thin layer provides everything needed for life: breathable air, protection from radiation, and the greenhouse effect that keeps temperatures livable.',
          ),
          LessonBlock.funFact(
            '99% of Earth\u2019s atmosphere is contained within the first 30 kilometers. Commercial jets at 10 km altitude are already above 75% of the atmosphere\u2019s mass.',
          ),
        ],
      ),
      LessonData(
        id: 'ec_3',
        title: 'Earth\u2019s Magnetic Field',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Earth\u2019s magnetic field, generated by the churning of molten iron in the outer core, extends thousands of kilometers into space, creating a protective bubble called the magnetosphere. This invisible shield deflects most of the solar wind \u2014 a constant stream of charged particles from the Sun that would otherwise strip away our atmosphere.',
          ),
          LessonBlock.paragraph(
            'When solar wind particles are funneled along magnetic field lines toward the poles, they collide with atmospheric molecules and create auroras \u2014 the northern and southern lights. These spectacular light shows appear as shimmering curtains of green, purple, and red light dancing across the polar skies.',
          ),
          LessonBlock.paragraph(
            'Earth\u2019s magnetic poles wander over time and periodically flip completely \u2014 the north magnetic pole becomes south and vice versa. The last full reversal was about 780,000 years ago. During a reversal, the field weakens significantly, potentially exposing the surface to more cosmic radiation, though life has survived every previous reversal.',
          ),
          LessonBlock.funFact(
            'Mars once had a magnetic field but lost it about 4 billion years ago. Without this protection, the solar wind stripped away most of its atmosphere, turning it from a warm, wet world into the cold desert it is today.',
          ),
        ],
      ),
      LessonData(
        id: 'ec_4',
        title: 'Climate Change from Space',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Space-based observations provide the most comprehensive view of climate change. NASA and ESA satellites have measured a consistent rise in global temperatures, with the planet warming about 1.1\u00B0C since the pre-industrial era. This warming is driven primarily by human emissions of greenhouse gases, especially carbon dioxide and methane.',
          ),
          LessonBlock.paragraph(
            'Satellite data reveals alarming trends: Arctic sea ice has declined by about 13% per decade since 1979, Greenland and Antarctic ice sheets are losing hundreds of billions of tons of ice annually, and sea levels have risen about 10 centimeters since 1993. These measurements are possible only from the vantage point of space.',
          ),
          LessonBlock.paragraph(
            'Understanding Venus\u2019s runaway greenhouse effect and Mars\u2019s loss of atmosphere provides crucial context for Earth\u2019s climate. Our sister planets show what can go wrong \u2014 Venus became too hot, Mars became too cold. Earth currently exists in a delicate balance that we must work to maintain.',
          ),
          LessonBlock.funFact(
            'Satellites can measure sea level changes with millimeter accuracy from 1,300 kilometers above Earth. This precision has been essential for confirming that sea level rise is accelerating.',
          ),
        ],
      ),
      LessonData(
        id: 'ec_5',
        title: 'The Pale Blue Dot',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'On February 14, 1990, Voyager 1 turned its camera back toward Earth from a distance of 6 billion kilometers and captured the famous \u201CPale Blue Dot\u201D photograph. In the image, Earth appears as a tiny speck of light, less than a single pixel, suspended in a sunbeam against the vastness of space.',
          ),
          LessonBlock.paragraph(
            'The photo was taken at the suggestion of Carl Sagan, who eloquently reflected on its significance: \u201CLook again at that dot. That\u2019s here. That\u2019s home. That\u2019s us. On it everyone you love, everyone you know, everyone you ever heard of, every human being who ever was, lived out their lives.\u201D',
          ),
          LessonBlock.paragraph(
            'This perspective reminds us that Earth is a tiny, fragile oasis in the cosmic void. There is no other place, at least in the near future, to which our species could migrate. The Pale Blue Dot image has become one of the most iconic photographs in history, a humbling reminder of our place in the universe.',
          ),
          LessonBlock.funFact(
            'At the distance the Pale Blue Dot was taken, the Sun\u2019s light had been traveling for about 5.5 hours. Earth occupied just 0.12 pixels in the photograph.',
          ),
        ],
      ),
      LessonData(
        id: 'ec_6',
        title: 'Earth\u2019s Future',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Earth has about 1\u20131.5 billion years of habitability remaining. As the Sun slowly gets brighter (about 10% more luminous every billion years), surface temperatures will eventually rise enough to evaporate the oceans. This process has already begun imperceptibly, and Earth is gradually losing its water to space.',
          ),
          LessonBlock.paragraph(
            'In about 5 billion years, the Sun will exhaust its hydrogen fuel and expand into a red giant, swelling to engulf Mercury, Venus, and possibly Earth. Even if Earth survives as a charred rock, conditions will be utterly inhospitable. The Sun will then shed its outer layers and become a white dwarf.',
          ),
          LessonBlock.paragraph(
            'These timescales are almost inconceivably long. Humanity, if it survives, would need to become a spacefaring civilization long before Earth becomes uninhabitable. The cosmic perspective teaches us both the urgency of protecting our current home and the importance of developing the capability to eventually leave it.',
          ),
          LessonBlock.funFact(
            'In about 250 million years, Earth\u2019s continents will merge again into a new supercontinent, sometimes called Pangaea Ultima. The interior would be a vast desert with temperatures exceeding 50\u00B0C.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 10. DARK MATTER & ENERGY
  // ════════════════════════════════════════
  TopicData(
    id: 'dark_matter',
    name: 'Dark Matter & Energy',
    emoji: '\u{1F9F2}',
    description: 'The invisible forces shaping the cosmos',
    lessons: [
      LessonData(
        id: 'dm_1',
        title: 'What is Dark Matter?',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Dark matter is one of the greatest mysteries in modern physics. It\u2019s a form of matter that doesn\u2019t emit, absorb, or reflect light, making it completely invisible to telescopes. We know it exists because of its gravitational effects on visible matter, galaxies, and the large-scale structure of the universe.',
          ),
          LessonBlock.paragraph(
            'About 27% of the universe is dark matter, compared to just 5% ordinary matter (everything we can see and touch). Dark matter acts as invisible scaffolding on which galaxies and galaxy clusters are built. Without it, galaxies wouldn\u2019t have enough gravity to hold together at the speeds they rotate.',
          ),
          LessonBlock.paragraph(
            'Despite decades of research, nobody knows what dark matter actually is. The leading candidates are hypothetical particles called WIMPs (Weakly Interacting Massive Particles) and axions. Experiments deep underground, in space, and at particle accelerators are racing to detect these elusive particles directly.',
          ),
          LessonBlock.funFact(
            'Billions of dark matter particles may be passing through your body every second, but they interact so weakly with ordinary matter that you\u2019d never notice.',
          ),
        ],
      ),
      LessonData(
        id: 'dm_2',
        title: 'Evidence for Dark Matter',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The strongest evidence for dark matter comes from galaxy rotation curves. In the 1970s, astronomer Vera Rubin showed that stars in the outer regions of spiral galaxies orbit just as fast as those near the center \u2014 impossible if only visible matter provides the gravitational pull. An invisible halo of dark matter neatly explains the observations.',
          ),
          LessonBlock.paragraph(
            'Gravitational lensing provides another compelling line of evidence. Massive galaxy clusters bend the light of more distant galaxies behind them, like a cosmic magnifying glass. The amount of bending reveals far more mass than what we can see, confirming the presence of invisible dark matter.',
          ),
          LessonBlock.paragraph(
            'The cosmic microwave background \u2014 the afterglow of the Big Bang \u2014 shows tiny temperature variations that perfectly match predictions of a universe with dark matter. Computer simulations of cosmic structure formation only reproduce the web-like distribution of galaxies we observe when dark matter is included.',
          ),
          LessonBlock.funFact(
            'The Bullet Cluster, where two galaxy clusters collided, provides the most direct evidence for dark matter. The visible matter was slowed by the collision, but the dark matter passed right through \u2014 proving they are separate substances.',
          ),
        ],
      ),
      LessonData(
        id: 'dm_3',
        title: 'Dark Energy',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'In 1998, two teams of astronomers made a shocking discovery: the expansion of the universe isn\u2019t slowing down as expected \u2014 it\u2019s accelerating. Something is pushing the universe apart faster and faster. This mysterious force was named \u201Cdark energy,\u201D and it makes up about 68% of the total energy content of the universe.',
          ),
          LessonBlock.paragraph(
            'Dark energy is fundamentally different from dark matter. While dark matter pulls things together through gravity, dark energy pushes space itself apart. The simplest explanation is Einstein\u2019s cosmological constant \u2014 a uniform energy density inherent to empty space. But other theories suggest dark energy could change over time.',
          ),
          LessonBlock.paragraph(
            'The discovery earned Saul Perlmutter, Brian Schmidt, and Adam Riess the 2011 Nobel Prize in Physics. Understanding dark energy is one of the biggest challenges in modern physics, because it determines the ultimate fate of the universe. Current observations suggest it will continue to accelerate, pushing galaxies ever farther apart.',
          ),
          LessonBlock.funFact(
            'If you add up all the matter and energy in the universe: 68% is dark energy, 27% is dark matter, and only 5% is the normal matter we\u2019re familiar with. We\u2019re the cosmic minority.',
          ),
        ],
      ),
      LessonData(
        id: 'dm_4',
        title: 'The Expanding Universe',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'In 1929, Edwin Hubble discovered that distant galaxies are moving away from us, and the farther they are, the faster they\u2019re receding. This wasn\u2019t because galaxies are flying through space, but because space itself is expanding, stretching the distances between galaxies like dots on an inflating balloon.',
          ),
          LessonBlock.paragraph(
            'The rate of expansion is described by the Hubble constant, currently measured at about 70 km/s per megaparsec. This means a galaxy 1 megaparsec (3.26 million light-years) away is moving away from us at 70 km/s. A galaxy twice as far moves at 140 km/s, and so on.',
          ),
          LessonBlock.paragraph(
            'There\u2019s a puzzling disagreement in measurements of the Hubble constant \u2014 different methods give slightly different values. This \u201CHubble tension\u201D might indicate new physics beyond our current understanding. Resolving it is one of the most active areas of cosmological research.',
          ),
          LessonBlock.funFact(
            'Galaxies beyond a certain distance are receding faster than the speed of light due to the expansion of space. Their light will never reach us, no matter how long we wait.',
          ),
        ],
      ),
      LessonData(
        id: 'dm_5',
        title: 'Fate of the Universe',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The ultimate fate of the universe depends on the nature of dark energy. If dark energy remains constant, the universe will expand forever, gradually cooling as stars burn out, galaxies drift apart, and the cosmos descends into a state called \u201Cheat death\u201D \u2014 a cold, dark, empty void of maximum entropy.',
          ),
          LessonBlock.paragraph(
            'If dark energy strengthens over time, a \u201CBig Rip\u201D scenario could occur: the expansion accelerates until it tears apart galaxy clusters, then galaxies, then solar systems, then planets, and eventually atoms themselves. This could happen tens of billions of years from now.',
          ),
          LessonBlock.paragraph(
            'A third possibility is the \u201CBig Crunch\u201D \u2014 if dark energy somehow reverses, gravity could eventually halt the expansion and pull everything back together. Some theories even suggest a cyclic universe that bounces between Big Bangs and Big Crunches eternally. Current evidence favors the heat death scenario.',
          ),
          LessonBlock.funFact(
            'In a heat death scenario, the last remaining objects would be black holes. The last one would evaporate via Hawking radiation in about 10\u00B9\u2070\u2070 years \u2014 a number so large it defies comprehension.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 11. BIG BANG & UNIVERSE
  // ════════════════════════════════════════
  TopicData(
    id: 'big_bang',
    name: 'Big Bang & Universe',
    emoji: '\u{1F4A5}',
    description: 'The origin story of everything that exists',
    lessons: [
      LessonData(
        id: 'bb_1',
        title: 'The Big Bang Theory',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The Big Bang theory describes the origin of our universe from an incredibly hot, dense state approximately 13.8 billion years ago. It\u2019s important to understand: the Big Bang was not an explosion in space, but an expansion of space itself. Every point in the universe was once the same point, and they\u2019ve been spreading apart ever since.',
          ),
          LessonBlock.paragraph(
            'The theory was first proposed by Belgian priest and physicist Georges Lema\u00EEtre in 1927, who called it the \u201Cprimeval atom.\u201D The term \u201CBig Bang\u201D was actually coined mockingly by astronomer Fred Hoyle in 1949, who favored a rival theory. Despite its humorous origin, the name stuck.',
          ),
          LessonBlock.paragraph(
            'Three key pieces of evidence support the Big Bang: the expansion of the universe (discovered by Hubble), the cosmic microwave background radiation (the afterglow of the Big Bang), and the observed abundance of light elements (hydrogen and helium) matching predictions of what should have been forged in the first few minutes.',
          ),
          LessonBlock.funFact(
            'The Big Bang theory doesn\u2019t explain what caused the Big Bang or what existed \u201Cbefore\u201D it. In fact, time itself may have begun with the Big Bang, making \u201Cbefore\u201D a meaningless concept.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_2',
        title: 'The First Moments',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'In the first fraction of a second after the Big Bang, the universe was unimaginably hot and dense. At 10\u207B\u00B3\u00B2 seconds (the Planck time), the four fundamental forces may have been unified into a single superforce. As the universe cooled, these forces separated, releasing enormous amounts of energy.',
          ),
          LessonBlock.paragraph(
            'By one microsecond, quarks combined to form protons and neutrons. During the first three minutes, nuclear fusion occurred on a cosmic scale, forging about 75% hydrogen and 25% helium by mass, with traces of lithium. This process, called Big Bang nucleosynthesis, was over in just minutes as the universe expanded and cooled below fusion temperatures.',
          ),
          LessonBlock.paragraph(
            'For the next 380,000 years, the universe was an opaque fog of plasma \u2014 free electrons scattered photons so effectively that light couldn\u2019t travel far. When the universe cooled to about 3,000 Kelvin, electrons combined with nuclei to form neutral atoms, and light was finally free to travel. This ancient light is what we see today as the cosmic microwave background.',
          ),
          LessonBlock.funFact(
            'One second after the Big Bang, the temperature of the entire universe was about 10 billion degrees Celsius \u2014 hotter than the center of any star that exists today.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_3',
        title: 'Cosmic Microwave Background',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The cosmic microwave background (CMB) is the oldest light in the universe, released about 380,000 years after the Big Bang when the universe first became transparent. This ancient light fills all of space and has been stretched by the expansion of the universe from visible light to microwave wavelengths.',
          ),
          LessonBlock.paragraph(
            'The CMB was accidentally discovered in 1965 by Arno Penzias and Robert Wilson at Bell Labs. They detected a persistent microwave \u201Chiss\u201D coming from every direction in the sky that they couldn\u2019t eliminate. They initially thought it was pigeon droppings on their antenna. Their discovery earned them the Nobel Prize.',
          ),
          LessonBlock.paragraph(
            'The CMB appears remarkably uniform at 2.725 Kelvin in every direction, but contains tiny temperature fluctuations of about 1 part in 100,000. These fluctuations are the seeds of all cosmic structure \u2014 the slightly denser regions became the galaxy clusters and cosmic web we see today.',
          ),
          LessonBlock.funFact(
            'About 1% of the static \u201Csnow\u201D on an old analog TV that\u2019s not tuned to a station is caused by the cosmic microwave background \u2014 you were watching the Big Bang\u2019s afterglow.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_4',
        title: 'Cosmic Inflation',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Cosmic inflation is the theory that in the first tiny fraction of a second (around 10\u207B\u00B3\u00B6 to 10\u207B\u00B3\u00B2 seconds), the universe underwent a period of exponential expansion, growing from smaller than an atom to larger than the observable universe today in an unimaginably brief instant.',
          ),
          LessonBlock.paragraph(
            'Inflation was proposed by physicist Alan Guth in 1980 to solve several puzzles about the Big Bang. It explains why the universe appears so flat and uniform in every direction \u2014 distant regions that appear too far apart to have ever exchanged information were actually in close contact before inflation stretched them apart.',
          ),
          LessonBlock.paragraph(
            'Inflation also explains the origin of cosmic structure. Quantum fluctuations \u2014 tiny random variations in energy at the subatomic scale \u2014 were stretched to macroscopic sizes by inflation, becoming the seeds for all the galaxies, stars, and planets that exist today. The universe\u2019s grandest structures trace back to quantum randomness.',
          ),
          LessonBlock.funFact(
            'During inflation, the universe expanded by a factor of at least 10\u00B2\u2076 in about 10\u207B\u00B3\u00B2 seconds. That\u2019s like a grain of sand expanding to the size of the observable universe almost instantaneously.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_5',
        title: 'Timeline of the Universe',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'The universe\u2019s history can be mapped as a timeline of epochs. The first second saw the formation of fundamental particles and forces. By 3 minutes, the lightest elements were forged. At 380,000 years, the universe became transparent. The cosmic \u201Cdark ages\u201D lasted until about 200 million years, when the first stars ignited.',
          ),
          LessonBlock.paragraph(
            'The first galaxies appeared within the first billion years, and the universe\u2019s star-formation rate peaked around 3 billion years. Our Sun and solar system formed about 9.2 billion years after the Big Bang (4.6 billion years ago). Life appeared on Earth almost immediately after conditions allowed it, about 3.8 billion years ago.',
          ),
          LessonBlock.paragraph(
            'Modern humans have existed for only about 300,000 years \u2014 a cosmic blink. If the universe\u2019s history were compressed into one calendar year, the Big Bang would be January 1st, our Sun would form on September 2nd, life on Earth would appear September 14th, and all of human civilization would occur in the last 14 seconds of December 31st.',
          ),
          LessonBlock.funFact(
            'The universe is about 13.8 billion years old, but the observable universe is 93 billion light-years across. This is because space itself has been expanding since the light was emitted.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_6',
        title: 'The Multiverse Theory',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The multiverse is the hypothetical idea that our universe may be just one of many \u2014 perhaps infinitely many \u2014 universes. Several legitimate physics theories suggest this possibility. Eternal inflation proposes that inflation didn\u2019t stop everywhere at once, creating \u201Cbubble universes\u201D that continually spawn from the inflationary background.',
          ),
          LessonBlock.paragraph(
            'String theory\u2019s \u201Clandscape\u201D suggests there could be 10\u2075\u2070\u2070 possible configurations of extra dimensions, each potentially giving rise to a universe with different physical constants and laws. In some of these universes, stars and atoms might not even be possible.',
          ),
          LessonBlock.paragraph(
            'The multiverse is controversial because it may be inherently untestable \u2014 we can\u2019t observe other universes. Critics argue it\u2019s not real science if it can\u2019t be falsified. Supporters counter that it naturally emerges from well-tested theories like inflation and quantum mechanics. The debate is one of the most fascinating in modern physics.',
          ),
          LessonBlock.funFact(
            'In an infinite multiverse, every possible configuration of matter would occur somewhere. There could be a universe where an exact copy of you is reading this exact text right now.',
          ),
        ],
      ),
      LessonData(
        id: 'bb_7',
        title: 'Heat Death of the Universe',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The heat death is the most likely ultimate fate of the universe, occurring when all energy is evenly distributed and no more work can be done. In this scenario, all stars will have burned out, all black holes will have evaporated, and the universe will reach maximum entropy \u2014 a state of perfect, uniform coldness.',
          ),
          LessonBlock.paragraph(
            'The timeline is staggering. In about 100 trillion years, the last red dwarf stars will burn out. Over the following eons, remaining objects will be flung from galaxies by gravitational interactions. Black holes will be the last significant objects, but even they will evaporate via Hawking radiation over timescales of 10\u00B9\u2070\u2070 years.',
          ),
          LessonBlock.paragraph(
            'After the black holes are gone, only subatomic particles will remain in an ever-expanding void at a temperature barely above absolute zero. The universe will exist in this state for eternity. While bleak, the heat death is trillions upon trillions of years in the future \u2014 plenty of time for life and intelligence to flourish.',
          ),
          LessonBlock.funFact(
            'We currently live in the Stelliferous Era, the age of stars, which represents only a tiny fraction of the universe\u2019s total lifespan. 99.99999...% of the universe\u2019s history will be dark and starless.',
          ),
        ],
      ),
    ],
  ),

  // ════════════════════════════════════════
  // 12. EXOPLANETS & ALIENS
  // ════════════════════════════════════════
  TopicData(
    id: 'exoplanets',
    name: 'Exoplanets & Aliens',
    emoji: '\u{1F6F8}',
    description: 'Worlds beyond our solar system and the search for life',
    lessons: [
      LessonData(
        id: 'xp_1',
        title: 'What are Exoplanets?',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Exoplanets are planets that orbit stars other than our Sun. The first confirmed exoplanet around a Sun-like star, 51 Pegasi b, was discovered in 1995 by Michel Mayor and Didier Queloz, earning them the 2019 Nobel Prize in Physics. Since then, over 5,600 exoplanets have been confirmed, with thousands more candidates awaiting verification.',
          ),
          LessonBlock.paragraph(
            'Exoplanets come in an astonishing variety. \u201CHot Jupiters\u201D are gas giants orbiting extremely close to their stars. \u201CSuper-Earths\u201D are rocky planets larger than Earth but smaller than Neptune. Some planets orbit two stars (circumbinary planets), just like Tatooine in Star Wars. Others are \u201Crogue planets\u201D drifting through interstellar space without any star.',
          ),
          LessonBlock.paragraph(
            'Based on data from the Kepler mission, astronomers estimate that there are more planets than stars in our galaxy. That means the Milky Way alone likely contains hundreds of billions of planets. Many of these orbit in the habitable zone of their star, where liquid water could potentially exist.',
          ),
          LessonBlock.funFact(
            'The nearest known exoplanet, Proxima Centauri b, is just 4.2 light-years away. With current technology, a spacecraft would take about 73,000 years to reach it.',
          ),
        ],
      ),
      LessonData(
        id: 'xp_2',
        title: 'Detection Methods',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'Finding exoplanets is challenging because they\u2019re incredibly faint compared to their host stars. The transit method, used by the Kepler and TESS missions, detects the tiny dimming of a star when a planet passes in front of it. Kepler discovered over 2,600 confirmed exoplanets using this technique, revolutionizing our understanding of planetary systems.',
          ),
          LessonBlock.paragraph(
            'The radial velocity method detects the subtle wobble of a star caused by an orbiting planet\u2019s gravitational tug. As the star moves toward and away from us, its light is slightly blue-shifted and red-shifted, respectively. This was the method used to discover the first exoplanet around a Sun-like star.',
          ),
          LessonBlock.paragraph(
            'Direct imaging captures actual photos of exoplanets by blocking the host star\u2019s glare. This is extremely difficult but has been achieved for a few large, young, hot planets far from their stars. The James Webb Space Telescope is pushing this technique further, even analyzing the atmospheres of distant worlds.',
          ),
          LessonBlock.funFact(
            'Detecting an Earth-like planet transiting a Sun-like star is comparable to spotting a moth crossing a searchlight from thousands of kilometers away.',
          ),
        ],
      ),
      LessonData(
        id: 'xp_3',
        title: 'The Habitable Zone',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'The habitable zone (also called the \u201CGoldilocks zone\u201D) is the range of distances from a star where conditions could allow liquid water to exist on a planet\u2019s surface. Not too hot, not too cold \u2014 just right. For our Sun, this zone extends roughly from Venus\u2019s orbit to just past Mars\u2019s orbit.',
          ),
          LessonBlock.paragraph(
            'However, being in the habitable zone doesn\u2019t guarantee habitability. Venus is at the inner edge and is a scorching hellscape due to its runaway greenhouse effect. Mars is at the outer edge and is a frozen desert because it lost most of its atmosphere. A planet also needs the right atmosphere, magnetic field, and geological activity.',
          ),
          LessonBlock.paragraph(
            'The concept of habitability is also evolving. Moons like Europa and Enceladus have liquid water oceans maintained by tidal heating, far outside the traditional habitable zone. Life might exist in subsurface oceans, in atmospheric clouds, or in conditions very different from Earth. Our definition of \u201Chabitable\u201D may be too narrow.',
          ),
          LessonBlock.funFact(
            'About 1 in 5 Sun-like stars in the Milky Way is estimated to have an Earth-sized planet in the habitable zone. That\u2019s roughly 11 billion potentially habitable worlds in our galaxy alone.',
          ),
        ],
      ),
      LessonData(
        id: 'xp_4',
        title: 'The TRAPPIST-1 System',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'TRAPPIST-1 is a remarkable planetary system located 40 light-years away in the constellation Aquarius. It has seven Earth-sized rocky planets orbiting an ultra-cool red dwarf star, with three of them in the habitable zone. It\u2019s the most Earth-like planetary system known and a prime target for the search for life.',
          ),
          LessonBlock.paragraph(
            'The TRAPPIST-1 planets are packed incredibly close together \u2014 all seven orbit closer to their star than Mercury orbits our Sun. From the surface of one planet, neighboring planets would appear larger than the Moon does in Earth\u2019s sky. Years on these worlds last only 1.5 to 19 Earth days.',
          ),
          LessonBlock.paragraph(
            'The James Webb Space Telescope is analyzing the atmospheres of TRAPPIST-1 planets, searching for biosignature gases like oxygen, methane, and ozone. However, red dwarf stars produce intense flares that could strip away planetary atmospheres, making habitability uncertain. Early JWST results suggest some of the inner planets may indeed lack atmospheres.',
          ),
          LessonBlock.funFact(
            'TRAPPIST-1 is so small and cool that it will burn for 12 trillion years \u2014 over 800 times the current age of the universe. If life exists there, it has an extraordinarily long future ahead.',
          ),
        ],
      ),
      LessonData(
        id: 'xp_5',
        title: 'Kepler\u2019s Legacy',
        readingMinutes: 3,
        blocks: [
          LessonBlock.paragraph(
            'NASA\u2019s Kepler Space Telescope, launched in 2009, was specifically designed to answer one question: how common are Earth-like planets? By staring at a single patch of sky containing 150,000 stars for four years, it detected the tiny brightness dips caused by planets crossing in front of their stars.',
          ),
          LessonBlock.paragraph(
            'Kepler\u2019s results were revolutionary: it confirmed over 2,600 exoplanets and showed that planets are ubiquitous in our galaxy. It found planets in surprising configurations \u2014 systems packed tighter than anyone expected, planets orbiting binary stars, and worlds unlike anything in our solar system.',
          ),
          LessonBlock.paragraph(
            'After a mechanical failure in 2013, engineers repurposed the telescope for the K2 mission using solar wind pressure for stabilization \u2014 an ingenious engineering fix. Kepler finally ran out of fuel and was retired in 2018. Its successor, TESS, is surveying nearly the entire sky and has already found over 400 confirmed exoplanets.',
          ),
          LessonBlock.funFact(
            'Kepler observed its target patch for so long that it could have detected alien civilizations dimming their own star for energy. No such signals were found, but it constrained the possibilities.',
          ),
        ],
      ),
      LessonData(
        id: 'xp_6',
        title: 'Are We Alone?',
        readingMinutes: 4,
        blocks: [
          LessonBlock.paragraph(
            'The question of whether we\u2019re alone in the universe is one of humanity\u2019s most profound. The Drake Equation, formulated by Frank Drake in 1961, attempts to estimate the number of communicable civilizations in our galaxy by considering factors like star formation rate, fraction of stars with planets, and probability of life evolving intelligence.',
          ),
          LessonBlock.paragraph(
            'The Fermi Paradox highlights a troubling contradiction: if the conditions for life are so common, where is everybody? With hundreds of billions of potentially habitable planets in our galaxy alone, and billions of years for civilizations to arise, we should see evidence of alien civilizations. Yet we don\u2019t \u2014 leading to numerous proposed explanations.',
          ),
          LessonBlock.paragraph(
            'SETI (Search for Extraterrestrial Intelligence) has been scanning the skies for alien signals since 1960. While no confirmed alien signals have been detected, the search continues with increasingly powerful instruments. Future telescopes may detect biosignature gases in exoplanet atmospheres, potentially providing the first indirect evidence that we are not alone.',
          ),
          LessonBlock.funFact(
            'In 1977, the Big Ear radio telescope detected a strong, unexplained signal from the direction of Sagittarius. Astronomer Jerry Ehman wrote \u201CWow!\u201D next to the data. The signal has never been explained or repeated.',
          ),
        ],
      ),
    ],
  ),
];
