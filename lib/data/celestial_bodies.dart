import 'package:flutter/material.dart';

/// Physical and orbital constants for the bodies referenced by the
/// Orbital Mechanics calculator.
///
/// Units:
///   - mass: kg
///   - radius: km (mean equatorial)
///   - gm: km³/s² (standard gravitational parameter, μ = G·M)
///   - semiMajorAxis: km (mean distance from Sun; 0 for the Sun, 384,400
///     for the Moon — distance from Earth)
///
/// Sources: NASA planetary fact sheets (rounded to fit a single
/// significant-figure representation suitable for educational
/// approximations).
class CelestialBody {
  final String name;
  final String emoji;
  final double mass;
  final double radius;
  final double gm;
  final double semiMajorAxis;
  final Color color;

  const CelestialBody({
    required this.name,
    required this.emoji,
    required this.mass,
    required this.radius,
    required this.gm,
    required this.semiMajorAxis,
    required this.color,
  });

  /// Surface gravity in m/s² — handy display value derived from `gm` (km³/s²)
  /// converted to m³/s², divided by r² in m².
  double get surfaceGravity {
    final rMeters = radius * 1000;
    final gmMeters = gm * 1e9;
    return gmMeters / (rMeters * rMeters);
  }

  static const sun = CelestialBody(
    name: 'Sun',
    emoji: '☀️',
    mass: 1.989e30,
    radius: 696340,
    gm: 1.32712e11,
    semiMajorAxis: 0,
    color: Color(0xFFFFB800),
  );

  static const mercury = CelestialBody(
    name: 'Mercury',
    emoji: '☿',
    mass: 3.301e23,
    radius: 2439.7,
    gm: 2.2032e4,
    semiMajorAxis: 5.791e7,
    color: Color(0xFF8C7853),
  );

  static const venus = CelestialBody(
    name: 'Venus',
    emoji: '♀',
    mass: 4.867e24,
    radius: 6051.8,
    gm: 3.24859e5,
    semiMajorAxis: 1.082e8,
    color: Color(0xFFE8B86E),
  );

  static const earth = CelestialBody(
    name: 'Earth',
    emoji: '🌍',
    mass: 5.972e24,
    radius: 6371,
    gm: 3.986e5,
    semiMajorAxis: 1.496e8,
    color: Color(0xFF4A90E2),
  );

  static const moon = CelestialBody(
    name: 'Moon',
    emoji: '🌙',
    mass: 7.342e22,
    radius: 1737,
    gm: 4.9048e3,
    semiMajorAxis: 384400,
    color: Color(0xFFC0C0C0),
  );

  static const mars = CelestialBody(
    name: 'Mars',
    emoji: '♂',
    mass: 6.417e23,
    radius: 3389.5,
    gm: 4.2828e4,
    semiMajorAxis: 2.279e8,
    color: Color(0xFFE27B58),
  );

  static const jupiter = CelestialBody(
    name: 'Jupiter',
    emoji: '♃',
    mass: 1.898e27,
    radius: 69911,
    gm: 1.26687e8,
    semiMajorAxis: 7.785e8,
    color: Color(0xFFDDA15E),
  );

  static const saturn = CelestialBody(
    name: 'Saturn',
    emoji: '♄',
    mass: 5.683e26,
    radius: 58232,
    gm: 3.7931e7,
    semiMajorAxis: 1.434e9,
    color: Color(0xFFE5C99B),
  );

  static const uranus = CelestialBody(
    name: 'Uranus',
    emoji: '♅',
    mass: 8.681e25,
    radius: 25362,
    gm: 5.794e6,
    semiMajorAxis: 2.871e9,
    color: Color(0xFF76C7E8),
  );

  static const neptune = CelestialBody(
    name: 'Neptune',
    emoji: '♆',
    mass: 1.024e26,
    radius: 24622,
    gm: 6.836e6,
    semiMajorAxis: 4.495e9,
    color: Color(0xFF4A6FE2),
  );

  static const pluto = CelestialBody(
    name: 'Pluto',
    emoji: '♇',
    mass: 1.303e22,
    radius: 1188.3,
    gm: 8.71e2,
    semiMajorAxis: 5.906e9,
    color: Color(0xFFA0A0A0),
  );

  static const List<CelestialBody> all = [
    sun,
    mercury,
    venus,
    earth,
    moon,
    mars,
    jupiter,
    saturn,
    uranus,
    neptune,
    pluto,
  ];

  /// Bodies that make sense as central bodies for an orbiting satellite.
  /// (Excludes Pluto/Mercury for the orbital-period UI; keeps the list
  /// short and educational.)
  static const List<CelestialBody> orbitable = [
    earth,
    moon,
    mars,
    sun,
    jupiter,
  ];

  /// Bodies for which surface escape velocity is interesting.
  static const List<CelestialBody> escapable = [
    earth,
    moon,
    mars,
    sun,
    jupiter,
    pluto,
  ];

  /// Bodies that orbit the Sun (used as Hohmann-transfer endpoints).
  static const List<CelestialBody> heliocentric = [
    mercury,
    venus,
    earth,
    mars,
    jupiter,
    saturn,
  ];

  static CelestialBody byName(String name) {
    return all.firstWhere(
      (b) => b.name.toLowerCase() == name.toLowerCase(),
      orElse: () => earth,
    );
  }
}
