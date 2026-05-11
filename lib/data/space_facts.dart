/// Pool of daily space facts for notifications.
///
/// Rotated by day-of-year in [NotificationService.scheduleDailyFact], so a
/// pool size around 120 means the same fact only repeats every ~4 months.
class SpaceFact {
  final String text;
  final String emoji;
  final String category;

  const SpaceFact({
    required this.text,
    required this.emoji,
    required this.category,
  });
}

const List<SpaceFact> kSpaceFacts = [
  // ─────────────── PLANETS ───────────────
  SpaceFact(
    text: 'A day on Venus is longer than its year. Venus rotates so slowly that one rotation takes 243 Earth days, while it orbits the Sun in just 225.',
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Saturn is so low in density that, if you could find a bathtub big enough, the entire planet would float in water.',
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Jupiter's Great Red Spot is a storm wider than Earth that has been raging continuously for at least 350 years.",
    emoji: '🌀',
    category: 'planet',
  ),
  SpaceFact(
    text: "Olympus Mons on Mars is the largest volcano in the solar system — about 22 km tall, nearly three times the height of Mount Everest.",
    emoji: '🌋',
    category: 'planet',
  ),
  SpaceFact(
    text: "Earth's inner core is roughly 5,400°C — about as hot as the surface of the Sun.",
    emoji: '🌍',
    category: 'planet',
  ),
  SpaceFact(
    text: 'A year on Mercury lasts only 88 Earth days, but a single Mercury day-night cycle stretches across 176 Earth days.',
    emoji: '☄️',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Uranus rotates almost on its side, with an axial tilt of about 98° — likely the result of an ancient collision.',
    emoji: '🌐',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Neptune has the fastest winds in the solar system, reaching speeds over 2,000 km/h.',
    emoji: '💨',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Pluto is smaller than several moons in the solar system — and smaller in surface area than Russia.',
    emoji: '🥶',
    category: 'planet',
  ),
  SpaceFact(
    text: "It rains diamonds on Neptune and Uranus. Crushing pressure deep in the atmosphere splits methane and presses the carbon into solid diamond.",
    emoji: '💎',
    category: 'planet',
  ),
  SpaceFact(
    text: "The footprints left on the Moon by the Apollo astronauts could last for tens of millions of years — the Moon has no wind or water to erase them.",
    emoji: '👣',
    category: 'planet',
  ),
  SpaceFact(
    text: 'The Moon is drifting away from Earth at about 3.8 cm per year — roughly the rate at which fingernails grow.',
    emoji: '🌙',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Permanent water ice has been confirmed in shadowed craters at the Moon\'s poles by NASA\'s LCROSS and India\'s Chandrayaan missions.',
    emoji: '🌙',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Mars has two small, lumpy moons — Phobos and Deimos — that are likely captured asteroids.',
    emoji: '🔴',
    category: 'planet',
  ),
  SpaceFact(
    text: "Jupiter has 95 known moons, and four of them — Io, Europa, Ganymede, and Callisto — were first spotted by Galileo in 1610.",
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Saturn's rings are made almost entirely of water ice particles, ranging from grains of sand to chunks the size of houses.",
    emoji: '💍',
    category: 'planet',
  ),
  SpaceFact(
    text: "A year on Pluto lasts 248 Earth years. Pluto hasn't completed a single orbit since it was discovered in 1930.",
    emoji: '🥶',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Roughly 1.3 million Earths could fit inside the Sun — yet on the cosmic scale, the Sun is just an average star.',
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: "Venus is the hottest planet in the solar system — not Mercury — because its dense CO₂ atmosphere creates a runaway greenhouse effect.",
    emoji: '🔥',
    category: 'planet',
  ),
  SpaceFact(
    text: "Despite being the closest planet to the Sun, Mercury has water ice in its permanently shadowed polar craters.",
    emoji: '☄️',
    category: 'planet',
  ),
  SpaceFact(
    text: "Earth is roughly 4.54 billion years old — the same age, give or take, as the rest of the solar system.",
    emoji: '🌍',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Mars hosts the largest dust storms in the solar system. They can engulf the entire planet for weeks.',
    emoji: '🔴',
    category: 'planet',
  ),
  SpaceFact(
    text: "Jupiter is so massive that all the other planets combined could fit inside it — twice over.",
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Saturn's north pole has a strangely persistent hexagonal jet stream — a six-sided storm wider than Earth.",
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Olympus Mons is so wide that, if you stood at its base, the summit would be hidden below the Martian horizon.",
    emoji: '🏔️',
    category: 'planet',
  ),

  // ─────────────── STARS ───────────────
  SpaceFact(
    text: "Light from the Sun takes 8 minutes and 20 seconds to reach Earth — when you look at the Sun, you're seeing the past.",
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: "UY Scuti, one of the largest known stars, is so vast that around 5 billion Suns could fit inside its volume.",
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: 'A neutron star can spin up to 716 times per second — its surface moves at a significant fraction of the speed of light.',
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: 'A teaspoonful of neutron-star material would weigh roughly 6 billion tonnes on Earth.',
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: 'The Sun is a yellow dwarf — a G-type main-sequence star — fusing about 600 million tonnes of hydrogen into helium every second.',
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: 'The closest star to the Sun is Proxima Centauri, about 4.24 light-years away.',
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: "Betelgeuse is so enormous that, if it replaced the Sun, its surface would extend past the orbit of Mars.",
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: "The Sun's surface is around 5,500°C, but its core reaches roughly 15 million °C — hot enough to fuse hydrogen.",
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: "Stars don't actually twinkle — their light is just being jostled by turbulence in Earth's atmosphere on its way down.",
    emoji: '✨',
    category: 'star',
  ),
  SpaceFact(
    text: "There are estimated to be more stars in the observable universe than grains of sand on all of Earth's beaches.",
    emoji: '🌌',
    category: 'star',
  ),
  SpaceFact(
    text: 'Sirius, the brightest star in our night sky, is actually a binary system — a main-sequence star and a hidden white dwarf.',
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: 'Pulsars are rapidly rotating neutron stars whose narrow beams of radiation sweep past Earth like cosmic lighthouses.',
    emoji: '🔦',
    category: 'star',
  ),
  SpaceFact(
    text: "Polaris won't always be the North Star. Earth's axial precession means Vega will take over the role around the year 13727.",
    emoji: '⭐',
    category: 'star',
  ),
  SpaceFact(
    text: "The Sun completes one orbit around the centre of the Milky Way every 225–250 million years.",
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: 'Most stars in the Milky Way are red dwarfs — small, cool, dim stars that can shine steadily for trillions of years.',
    emoji: '🔴',
    category: 'star',
  ),
  SpaceFact(
    text: 'In about 5 billion years, the Sun will run out of hydrogen, swell into a red giant, and finally collapse into a white dwarf.',
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: "A single supernova can briefly outshine an entire galaxy of hundreds of billions of stars.",
    emoji: '💥',
    category: 'star',
  ),
  SpaceFact(
    text: "Stars don't burn — there's no oxygen in space. They glow because nuclear fusion in their cores converts mass directly into energy.",
    emoji: '⭐',
    category: 'star',
  ),

  // ─────────────── GALAXIES ───────────────
  SpaceFact(
    text: 'The Milky Way and Andromeda galaxies are heading toward each other and will merge in roughly 4.5 billion years.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'The observable universe is about 93 billion light-years across — and what we can see is only a fraction of the whole.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'The Hubble Space Telescope has photographed galaxies whose light left them more than 13 billion years ago.',
    emoji: '🔭',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'The Milky Way contains an estimated 100–400 billion stars and is around 100,000 light-years across.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'Andromeda — our nearest large galactic neighbour — likely contains around a trillion stars, more than twice as many as the Milky Way.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'Astronomers estimate there are around 2 trillion galaxies in the observable universe.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'Almost every large galaxy has a supermassive black hole at its centre — including ours, Sagittarius A*.',
    emoji: '🕳️',
    category: 'galaxy',
  ),
  SpaceFact(
    text: "When you look at Andromeda in the night sky, the light hitting your eye left the galaxy roughly 2.5 million years ago.",
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'The Milky Way is part of a larger structure called the Local Group, which is itself a member of the Virgo Supercluster.',
    emoji: '🌌',
    category: 'galaxy',
  ),
  SpaceFact(
    text: "Dark matter, an invisible substance we can't directly see or touch, makes up about 85% of the mass holding galaxies together.",
    emoji: '🌑',
    category: 'galaxy',
  ),
  SpaceFact(
    text: 'Galaxies are not evenly scattered through space — they form vast filaments and walls separated by enormous voids, a structure called the cosmic web.',
    emoji: '🕸️',
    category: 'galaxy',
  ),
  SpaceFact(
    text: "The most distant galaxies we've seen with JWST formed less than 400 million years after the Big Bang.",
    emoji: '🔭',
    category: 'galaxy',
  ),

  // ─────────────── MISSIONS ───────────────
  SpaceFact(
    text: "Voyager 1, launched in 1977, is now over 24 billion km from Earth — the most distant human-made object ever.",
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Voyager 1 carries a Golden Record — sounds and images of Earth meant for any intelligent life that might find it.',
    emoji: '💿',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The International Space Station orbits Earth at about 27,600 km/h, completing one lap every roughly 90 minutes.',
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The ISS has been continuously occupied by humans since 2 November 2000 — over 25 years of unbroken presence in space.',
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Apollo 11 landed Neil Armstrong and Buzz Aldrin on the Moon on 20 July 1969, while Michael Collins orbited above.',
    emoji: '🚀',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The James Webb Space Telescope orbits Sun-Earth Lagrange Point 2, about 1.5 million km from Earth.',
    emoji: '🔭',
    category: 'mission',
  ),
  SpaceFact(
    text: 'JWST launched on Christmas Day 2021 and unfolded its 6.5-metre gold-coated mirror in space over several weeks.',
    emoji: '🔭',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The Hubble Space Telescope launched in 1990 and continues to deliver groundbreaking science decades later.',
    emoji: '🔭',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Cassini orbited Saturn for 13 years before plunging into the planet in 2017 to protect its moons from contamination.',
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'NASA\'s Curiosity rover landed in Gale Crater on Mars on 6 August 2012 and is still exploring.',
    emoji: '🤖',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Perseverance landed on Mars on 18 February 2021 and carries a small helicopter, Ingenuity — the first aircraft to fly on another planet.',
    emoji: '🚁',
    category: 'mission',
  ),
  SpaceFact(
    text: "NASA's Parker Solar Probe has flown closer to the Sun than any spacecraft in history, reaching within about 6 million km of its surface.",
    emoji: '☀️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'New Horizons flew past Pluto on 14 July 2015, finally giving humanity sharp images of the distant dwarf planet.',
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Apollo 17 in December 1972 was the last time humans walked on the Moon — over half a century ago.',
    emoji: '🌙',
    category: 'mission',
  ),
  SpaceFact(
    text: "India's Mars Orbiter Mission (Mangalyaan) reached Mars in 2014, costing less than the Hollywood film Gravity.",
    emoji: '🇮🇳',
    category: 'mission',
  ),
  SpaceFact(
    text: "India's Chandrayaan-3 made the first-ever soft landing near the Moon's south pole on 23 August 2023.",
    emoji: '🇮🇳',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Japan\'s Hayabusa returned tiny grains from the asteroid Itokawa in 2010 — the first sample-return from an asteroid.',
    emoji: '☄️',
    category: 'mission',
  ),
  SpaceFact(
    text: "NASA's Artemis program aims to return humans to the Moon, including the first woman and first person of colour to walk on the lunar surface.",
    emoji: '🚀',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The first close-up photograph of Mars was taken by NASA\'s Mariner 4 in 1965 — and it had to be hand-coloured by anxious engineers waiting for the data.',
    emoji: '📸',
    category: 'mission',
  ),
  SpaceFact(
    text: 'Pioneer 10 was the first spacecraft to traverse the asteroid belt and the first to fly by Jupiter, in 1973.',
    emoji: '🛰️',
    category: 'mission',
  ),
  SpaceFact(
    text: 'The Event Horizon Telescope released the first image of a black hole — M87* — in April 2019.',
    emoji: '🕳️',
    category: 'mission',
  ),
  SpaceFact(
    text: "In 2022, the Event Horizon Telescope unveiled the first image of Sagittarius A*, the supermassive black hole at the centre of our galaxy.",
    emoji: '🕳️',
    category: 'mission',
  ),

  // ─────────────── TECHNOLOGY ───────────────
  SpaceFact(
    text: "The Saturn V rocket that launched Apollo missions weighed about 2,950 tonnes at lift-off and still holds records as one of the most powerful rockets ever flown.",
    emoji: '🚀',
    category: 'tech',
  ),
  SpaceFact(
    text: "SpaceX's Falcon 9 was the first orbital-class rocket to land its booster vertically and fly again.",
    emoji: '🚀',
    category: 'tech',
  ),
  SpaceFact(
    text: 'The Apollo Guidance Computer that landed humans on the Moon had less processing power than a modern pocket calculator.',
    emoji: '💻',
    category: 'tech',
  ),
  SpaceFact(
    text: "JWST's primary mirror is 6.5 m across and made of 18 hexagonal beryllium segments coated with a microscopic layer of gold.",
    emoji: '🔭',
    category: 'tech',
  ),
  SpaceFact(
    text: 'A modern spacesuit is essentially a personal spacecraft and can cost over \$12 million to build.',
    emoji: '👨‍🚀',
    category: 'tech',
  ),
  SpaceFact(
    text: "The ISS's solar arrays generate about 120 kW of electricity — enough to power roughly 40 homes on Earth.",
    emoji: '🔋',
    category: 'tech',
  ),
  SpaceFact(
    text: 'A radio signal from Mars takes anywhere between 3 and 22 minutes to reach Earth, depending on the planets\' relative positions.',
    emoji: '📡',
    category: 'tech',
  ),
  SpaceFact(
    text: 'The Voyager probes are still operating after almost 50 years, powered by slowly decaying plutonium-238 in their RTGs.',
    emoji: '🛰️',
    category: 'tech',
  ),
  SpaceFact(
    text: "To escape Earth's gravity, a spacecraft needs to reach a speed of about 11.2 km/s — over 40,000 km/h.",
    emoji: '🚀',
    category: 'tech',
  ),
  SpaceFact(
    text: 'Geostationary satellites orbit at exactly 35,786 km above the equator — the altitude where one orbit takes 24 hours.',
    emoji: '🛰️',
    category: 'tech',
  ),
  SpaceFact(
    text: "SpaceX's Starship is the largest and most powerful rocket ever built, standing about 120 m tall fully stacked.",
    emoji: '🚀',
    category: 'tech',
  ),

  // ─────────────── EXOPLANETS & BLACK HOLES ───────────────
  SpaceFact(
    text: '51 Pegasi b, discovered in 1995, was the first exoplanet found orbiting a Sun-like star.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'More than 5,500 exoplanets have been confirmed so far — and the number keeps climbing every year.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'TRAPPIST-1, just 40 light-years away, has seven Earth-sized rocky planets, three of which lie in the star\'s habitable zone.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'Proxima Centauri b, the nearest known exoplanet, sits in the habitable zone of the closest star to our Sun.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'Some "hot Jupiter" exoplanets orbit so close to their stars that a year on them lasts just a few Earth days.',
    emoji: '🔥',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'Kepler-186f, announced in 2014, was the first Earth-sized exoplanet found in the habitable zone of another star.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'The very first confirmed exoplanets were found orbiting a pulsar — PSR B1257+12 — back in 1992.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'JWST has detected water vapour, carbon dioxide and even potential clues to clouds in the atmospheres of distant exoplanets.',
    emoji: '🔭',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'The supermassive black hole at the centre of the Milky Way, Sagittarius A*, has a mass of about 4 million Suns.',
    emoji: '🕳️',
    category: 'blackhole',
  ),
  SpaceFact(
    text: "A black hole's event horizon is the boundary beyond which nothing — not even light — can escape its gravity.",
    emoji: '🕳️',
    category: 'blackhole',
  ),
  SpaceFact(
    text: 'Stellar-mass black holes form when very massive stars collapse at the end of their lives in core-collapse supernovae.',
    emoji: '🕳️',
    category: 'blackhole',
  ),
  SpaceFact(
    text: 'Supermassive black holes can be billions of times more massive than the Sun — and we still don\'t fully know how they grew so big.',
    emoji: '🕳️',
    category: 'blackhole',
  ),
  SpaceFact(
    text: "Time literally slows down near a black hole, due to a relativistic effect called gravitational time dilation.",
    emoji: '⏳',
    category: 'blackhole',
  ),
  SpaceFact(
    text: "Black holes don't actually 'suck' anything in — their gravity behaves like any other mass; objects only fall in if they get too close.",
    emoji: '🕳️',
    category: 'blackhole',
  ),
  SpaceFact(
    text: "If you could compress Earth to a black hole, its event horizon would be smaller than a grape.",
    emoji: '🍇',
    category: 'blackhole',
  ),

  // ─────────────── ASTRONAUTS & HISTORY ───────────────
  SpaceFact(
    text: 'Astronauts can grow up to 5 cm taller in microgravity as the spine elongates without gravity compressing it.',
    emoji: '👨‍🚀',
    category: 'astronaut',
  ),
  SpaceFact(
    text: 'Yuri Gagarin became the first human to reach space on 12 April 1961, completing one orbit aboard Vostok 1.',
    emoji: '🚀',
    category: 'history',
  ),
  SpaceFact(
    text: 'Valentina Tereshkova became the first woman in space in 1963 — solo, on Vostok 6 — making 48 orbits of Earth.',
    emoji: '👩‍🚀',
    category: 'history',
  ),
  SpaceFact(
    text: '"That\'s one small step for man, one giant leap for mankind." — Neil Armstrong, stepping onto the Moon in 1969.',
    emoji: '🌙',
    category: 'history',
  ),
  SpaceFact(
    text: 'Astronauts on the ISS see roughly 16 sunrises and 16 sunsets every 24 hours.',
    emoji: '🌅',
    category: 'astronaut',
  ),
  SpaceFact(
    text: 'Sputnik 1, launched by the Soviet Union on 4 October 1957, was the first artificial satellite to orbit Earth.',
    emoji: '🛰️',
    category: 'history',
  ),
  SpaceFact(
    text: 'Salyut 1, launched in 1971, was the first space station ever placed in orbit.',
    emoji: '🛰️',
    category: 'history',
  ),
  SpaceFact(
    text: 'Astronaut helmets often have a tiny strip of Velcro inside so the wearer can scratch an itchy nose.',
    emoji: '👨‍🚀',
    category: 'astronaut',
  ),
  SpaceFact(
    text: "On the ISS, there's no running water — astronauts 'shower' using rinse-less wipes and a small amount of water.",
    emoji: '🚿',
    category: 'astronaut',
  ),
  SpaceFact(
    text: 'Astronaut food is mostly dehydrated. On the ISS, water is added back to rehydrate meals before eating.',
    emoji: '🥘',
    category: 'astronaut',
  ),
  SpaceFact(
    text: 'The ISS uses Coordinated Universal Time (UTC) so the international crews can work to a single shared schedule.',
    emoji: '⏰',
    category: 'astronaut',
  ),
  SpaceFact(
    text: 'Long-duration astronauts often need months of physiotherapy back on Earth to recover bone density and muscle mass lost in microgravity.',
    emoji: '👨‍🚀',
    category: 'astronaut',
  ),

  // ─────────────── FUN & ODDITIES ───────────────
  SpaceFact(
    text: 'Space is silent — there is no air or other medium for sound waves to travel through.',
    emoji: '🔇',
    category: 'fun',
  ),
  SpaceFact(
    text: 'There are estimated to be more trees on Earth than there are stars in the entire Milky Way galaxy.',
    emoji: '🌳',
    category: 'fun',
  ),
  SpaceFact(
    text: 'A black hole the size of a coin would have far more mass than the Earth.',
    emoji: '🪙',
    category: 'fun',
  ),
  SpaceFact(
    text: "If you could drive straight up at 100 km/h, you'd cross the Kármán line into space in about an hour.",
    emoji: '🚗',
    category: 'fun',
  ),
  SpaceFact(
    text: "Earth orbits the Sun at roughly 107,000 km/h — you've already travelled hundreds of thousands of kilometres today without noticing.",
    emoji: '🌍',
    category: 'fun',
  ),
  SpaceFact(
    text: 'A single day on Mars (a "sol") is just slightly longer than an Earth day — about 24 hours and 39 minutes.',
    emoji: '🔴',
    category: 'planet',
  ),
  SpaceFact(
    text: 'There is a planet entirely covered in burning ice — Gliese 436 b, where extreme pressure keeps ice solid despite searing heat.',
    emoji: '🪐',
    category: 'exoplanet',
  ),
  SpaceFact(
    text: 'About 100 tonnes of meteoritic material falls to Earth every day — most of it as tiny dust grains you\'ll never see.',
    emoji: '☄️',
    category: 'fun',
  ),
  SpaceFact(
    text: 'Space is incredibly cold. The cosmic microwave background — the leftover heat of the Big Bang — sits at just 2.7 K above absolute zero.',
    emoji: '🥶',
    category: 'fun',
  ),
  SpaceFact(
    text: 'Some of the gold in your jewellery was likely forged in the violent collision of two neutron stars billions of years ago.',
    emoji: '💍',
    category: 'fun',
  ),
  SpaceFact(
    text: 'Every atom in your body heavier than helium was forged inside a star or in a stellar explosion. We are, quite literally, made of stardust.',
    emoji: '✨',
    category: 'fun',
  ),
  SpaceFact(
    text: "The Sun makes up about 99.86% of all the mass in our solar system. Everything else — planets, moons, asteroids — is just leftovers.",
    emoji: '☀️',
    category: 'star',
  ),
  SpaceFact(
    text: "If the Sun suddenly vanished, we'd carry on orbiting normally for about 8 minutes before noticing — that's how long its light takes to reach us.",
    emoji: '☀️',
    category: 'fun',
  ),
  SpaceFact(
    text: "There's a giant cloud of alcohol — specifically, methanol vapour — drifting through interstellar space near the constellation Aquila.",
    emoji: '🌌',
    category: 'fun',
  ),
  SpaceFact(
    text: 'Saturn\'s moon Titan has lakes and rivers — but they\'re filled with liquid methane and ethane, not water.',
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Jupiter's moon Europa is covered in ice, but beneath that crust lies a global ocean of liquid water — possibly twice the volume of Earth's oceans.",
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: 'Saturn\'s moon Enceladus jets plumes of water vapour into space from its south pole — direct evidence of a subsurface ocean.',
    emoji: '🪐',
    category: 'planet',
  ),
  SpaceFact(
    text: "Mars's atmosphere is so thin that liquid water can't exist on the surface — it would either freeze or boil away.",
    emoji: '🔴',
    category: 'planet',
  ),
];
