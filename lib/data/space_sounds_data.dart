import 'package:flutter/material.dart';

class SpaceSound {
  final String id;
  final String name;
  final String description;
  final String category;
  final String audioUrl;
  final IconData icon;
  final Color color;
  final String duration;
  final String source;

  const SpaceSound({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.audioUrl,
    required this.icon,
    required this.color,
    required this.duration,
    required this.source,
  });
}

const allSpaceSounds = <SpaceSound>[
  // ── Planets ──
  SpaceSound(
    id: 'jupiter_lightning',
    name: 'Jupiter Lightning',
    description: 'Lightning strikes in Jupiter\'s atmosphere captured by Juno. Powerful storms thousands of times stronger than Earth\'s.',
    category: 'Planets',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/juno-jupiter-lightning-1.wav',
    icon: Icons.flash_on_rounded,
    color: Color(0xFFFF6B35),
    duration: '0:12',
    source: 'NASA Juno',
  ),
  SpaceSound(
    id: 'saturn_radio',
    name: 'Saturn Radio Emissions',
    description: 'Radio emissions from Saturn converted to audible sound. Eerie tones from charged particles in Saturn\'s magnetosphere.',
    category: 'Planets',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/saturn-radio-emissions.wav',
    icon: Icons.radio_rounded,
    color: Color(0xFFDAA520),
    duration: '0:23',
    source: 'NASA Cassini',
  ),
  SpaceSound(
    id: 'mars_wind',
    name: 'Mars Wind',
    description: 'The first sounds ever recorded on the surface of Mars by NASA\'s InSight lander. A low rumble of Martian wind.',
    category: 'Planets',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/mars-insight-wind.wav',
    icon: Icons.air_rounded,
    color: Color(0xFFD4522A),
    duration: '0:10',
    source: 'NASA InSight',
  ),

  // ── Black Holes ──
  SpaceSound(
    id: 'black_hole_perseus',
    name: 'Black Hole Sound',
    description: 'First-ever sonification of a black hole. Sound waves from the Perseus galaxy cluster, pitched up 57 octaves.',
    category: 'Black Holes',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/black-hole-remix.wav',
    icon: Icons.dark_mode_rounded,
    color: Color(0xFF7B5BFF),
    duration: '0:34',
    source: 'NASA Chandra',
  ),

  // ── Stars ──
  SpaceSound(
    id: 'pulsar',
    name: 'Pulsar Rotation',
    description: 'The rhythmic signal of a rapidly rotating neutron star. This dead star spins hundreds of times per second.',
    category: 'Stars',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/vela-pulsar.wav',
    icon: Icons.star_rounded,
    color: Color(0xFF00D4FF),
    duration: '0:08',
    source: 'NASA',
  ),
  SpaceSound(
    id: 'sun_vibrations',
    name: 'Sun Vibrations',
    description: 'Solar oscillations converted to sound. The Sun vibrates like a bell at frequencies too low for human hearing.',
    category: 'Stars',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/sun-sonification.wav',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFD700),
    duration: '0:15',
    source: 'NASA SDO',
  ),

  // ── Spacecraft ──
  SpaceSound(
    id: 'shuttle_launch',
    name: 'Space Shuttle Launch',
    description: 'The thunderous roar of a Space Shuttle launch. 7 million pounds of thrust as it breaks free from Earth.',
    category: 'Spacecraft',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/space-shuttle-launch.wav',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFFFF4D6A),
    duration: '0:30',
    source: 'NASA',
  ),
  SpaceSound(
    id: 'apollo_liftoff',
    name: 'Apollo 11 Liftoff',
    description: '"10, 9, 8... All engines running. Liftoff!" The historic moment humanity first headed to the Moon.',
    category: 'Spacecraft',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/apollo11-liftoff.wav',
    icon: Icons.flight_takeoff_rounded,
    color: Color(0xFFFF9933),
    duration: '0:15',
    source: 'NASA Apollo',
  ),

  // ── Earth ──
  SpaceSound(
    id: 'earth_chorus',
    name: 'Earth Chorus',
    description: 'Electromagnetic waves in Earth\'s magnetosphere that sound like a chorus of birds. Created by electrons in radiation belts.',
    category: 'Earth',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/earth-chorus.wav',
    icon: Icons.public_rounded,
    color: Color(0xFF00E096),
    duration: '0:19',
    source: 'NASA EMFISIS',
  ),
  SpaceSound(
    id: 'lightning_whistler',
    name: 'Lightning Whistler',
    description: 'Radio signals from lightning that travel along Earth\'s magnetic field lines, creating a descending whistle sound.',
    category: 'Earth',
    audioUrl: 'https://www.nasa.gov/wp-content/uploads/2023/10/lightning-whistler.wav',
    icon: Icons.bolt_rounded,
    color: Color(0xFF4A90D9),
    duration: '0:06',
    source: 'NASA',
  ),
];
