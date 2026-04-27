import 'package:flutter/material.dart';

import '../screens/explore/exoplanet_explorer_screen.dart';
import '../screens/explore/nasa_gallery_screen.dart';
import '../screens/explore/solar_system_screen.dart';
import '../screens/explore/wallpapers_screen.dart';
import '../screens/home/apod_archive_screen.dart';
import '../screens/home/earth_from_space_screen.dart';
import '../screens/home/orbital_mechanics_screen.dart';
import '../screens/home/space_stats_screen.dart';
import '../screens/learn/active_missions_screen.dart';
import '../screens/learn/astronaut_directory_screen.dart';
import '../screens/learn/constellation_guide_screen.dart';
import '../screens/learn/planet_comparator_screen.dart';
import '../screens/learn/space_calculator_screen.dart';
import '../screens/quick_actions/asteroids_screen.dart';
import '../screens/quick_actions/iss_tracker_screen.dart';
import '../screens/quick_actions/moon_phase_screen.dart';
import '../screens/quick_actions/space_calendar_screen.dart';
import '../screens/tools/stargazing_forecast_screen.dart';
import '../screens/weather/space_weather_screen.dart';

class CosmicTool {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String category;
  final Widget Function() screenBuilder;
  final String? badge;

  const CosmicTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.category,
    required this.screenBuilder,
    this.badge,
  });
}

abstract final class CosmicTools {
  static const Color liveAccent      = Color(0xFF00E5FF);
  static const Color calcAccent      = Color(0xFF9D7BFF);
  static const Color imageryAccent   = Color(0xFF4A90E2);
  static const Color exploreAccent   = Color(0xFFFFB74D);
  static const Color directoryAccent = Color(0xFF4ADE80);

  static final List<CosmicTool> all = [
    CosmicTool(
      id: 'iss_tracker',
      title: 'ISS Tracker',
      subtitle: 'Track the space station live',
      icon: Icons.satellite_alt,
      accentColor: liveAccent,
      category: 'live',
      badge: 'LIVE',
      screenBuilder: () => const ISSTrackerScreen(),
    ),
    CosmicTool(
      id: 'mission_control',
      title: 'Mission Control',
      subtitle: 'Real-time cosmic statistics',
      icon: Icons.bar_chart,
      accentColor: liveAccent,
      category: 'live',
      badge: 'LIVE',
      screenBuilder: () => const SpaceStatsScreen(),
    ),
    CosmicTool(
      id: 'asteroids',
      title: 'Asteroids',
      subtitle: 'Near-Earth objects today',
      icon: Icons.public_off,
      accentColor: const Color(0xFFFF6B35),
      category: 'live',
      badge: 'LIVE',
      screenBuilder: () => const AsteroidsScreen(),
    ),
    CosmicTool(
      id: 'space_weather',
      title: 'Space Weather',
      subtitle: 'Solar storms & aurora forecast',
      icon: Icons.flare,
      accentColor: const Color(0xFFFFA726),
      category: 'live',
      badge: 'LIVE',
      screenBuilder: () => const SpaceWeatherScreen(),
    ),
    CosmicTool(
      id: 'missions',
      title: 'Active Missions',
      subtitle: '20 ongoing space missions',
      icon: Icons.satellite_alt,
      accentColor: liveAccent,
      category: 'live',
      badge: 'LIVE',
      screenBuilder: () => const ActiveMissionsScreen(),
    ),
    CosmicTool(
      id: 'stargazing',
      title: 'Stargazing Tonight',
      subtitle: 'Sky forecast & visibility',
      icon: Icons.nights_stay,
      accentColor: liveAccent,
      category: 'live',
      screenBuilder: () => const StargazingForecastScreen(),
    ),

    CosmicTool(
      id: 'orbital_mechanics',
      title: 'Orbital Mechanics',
      subtitle: '4 interactive physics calculators',
      icon: Icons.scatter_plot,
      accentColor: calcAccent,
      category: 'calc',
      badge: 'NEW',
      screenBuilder: () => const OrbitalMechanicsScreen(),
    ),
    CosmicTool(
      id: 'space_calculator',
      title: 'Space Calculator',
      subtitle: 'Distance, gravity & velocity tools',
      icon: Icons.calculate,
      accentColor: calcAccent,
      category: 'calc',
      screenBuilder: () => const SpaceCalculatorScreen(),
    ),
    CosmicTool(
      id: 'comparator',
      title: 'Planet Comparator',
      subtitle: 'Compare worlds side-by-side',
      icon: Icons.compare_arrows,
      accentColor: calcAccent,
      category: 'calc',
      screenBuilder: () => const PlanetComparatorScreen(),
    ),

    CosmicTool(
      id: 'earth_from_space',
      title: 'Earth from Space',
      subtitle: 'Daily photos from 1 million miles',
      icon: Icons.public,
      accentColor: imageryAccent,
      category: 'imagery',
      screenBuilder: () => const EarthFromSpaceScreen(),
    ),
    CosmicTool(
      id: 'apod_archive',
      title: 'APOD Archive',
      subtitle: "NASA's astronomy picture daily",
      icon: Icons.photo_library,
      accentColor: imageryAccent,
      category: 'imagery',
      screenBuilder: () => const ApodArchiveScreen(),
    ),
    CosmicTool(
      id: 'nasa_gallery',
      title: 'NASA Gallery',
      subtitle: 'Curated space imagery collection',
      icon: Icons.collections,
      accentColor: imageryAccent,
      category: 'imagery',
      screenBuilder: () => const NasaGalleryScreen(),
    ),
    CosmicTool(
      id: 'wallpapers',
      title: 'Wallpapers',
      subtitle: 'HD cosmic wallpapers',
      icon: Icons.wallpaper,
      accentColor: imageryAccent,
      category: 'imagery',
      screenBuilder: () => const WallpapersScreen(),
    ),

    CosmicTool(
      id: 'solar_system',
      title: 'Solar System',
      subtitle: 'Explore planets in 3D',
      icon: Icons.brightness_7,
      accentColor: exploreAccent,
      category: 'explore',
      badge: '3D',
      screenBuilder: () => const SolarSystemScreen(),
    ),
    CosmicTool(
      id: 'exoplanet_explorer',
      title: 'Exoplanet Explorer',
      subtitle: 'Browse 6,000+ confirmed worlds',
      icon: Icons.travel_explore,
      accentColor: exploreAccent,
      category: 'explore',
      screenBuilder: () => const ExoplanetExplorerScreen(),
    ),
    CosmicTool(
      id: 'moon_phase',
      title: 'Moon Phase',
      subtitle: 'Lunar calendar & illumination',
      icon: Icons.brightness_2,
      accentColor: exploreAccent,
      category: 'explore',
      screenBuilder: () => const MoonPhaseScreen(),
    ),
    CosmicTool(
      id: 'space_calendar',
      title: 'Space Calendar',
      subtitle: 'Upcoming celestial events',
      icon: Icons.event,
      accentColor: exploreAccent,
      category: 'explore',
      screenBuilder: () => const SpaceCalendarScreen(),
    ),
    CosmicTool(
      id: 'constellations',
      title: 'Constellations',
      subtitle: '30 star patterns & guides',
      icon: Icons.auto_awesome,
      accentColor: exploreAccent,
      category: 'explore',
      screenBuilder: () => const ConstellationGuideScreen(),
    ),

    CosmicTool(
      id: 'astronauts',
      title: 'Astronaut Directory',
      subtitle: '50 space heroes profiled',
      icon: Icons.people,
      accentColor: directoryAccent,
      category: 'directory',
      screenBuilder: () => const AstronautDirectoryScreen(),
    ),
  ];

  static const List<String> categoryOrder = [
    'live',
    'calc',
    'imagery',
    'explore',
    'directory',
  ];

  static const Map<String, String> categoryNames = {
    'live':      'LIVE DATA & TRACKING',
    'calc':      'CALCULATORS',
    'imagery':   'IMAGERY & GALLERIES',
    'explore':   'EXPLORERS',
    'directory': 'DIRECTORY',
  };

  static const Map<String, IconData> categoryIcons = {
    'live':      Icons.sensors,
    'calc':      Icons.calculate_outlined,
    'imagery':   Icons.image_outlined,
    'explore':   Icons.explore_outlined,
    'directory': Icons.people_outline,
  };

  static const Map<String, Color> categoryAccents = {
    'live':      liveAccent,
    'calc':      calcAccent,
    'imagery':   imageryAccent,
    'explore':   exploreAccent,
    'directory': directoryAccent,
  };

  static Map<String, List<CosmicTool>> get grouped {
    final map = <String, List<CosmicTool>>{
      for (final c in categoryOrder) c: <CosmicTool>[],
    };
    for (final t in all) {
      map[t.category]?.add(t);
    }
    return map;
  }
}
