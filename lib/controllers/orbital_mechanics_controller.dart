import 'dart:math';

import 'package:get/get.dart';

import '../data/celestial_bodies.dart';

/// Reactive state for the four interactive orbital-mechanics calculators.
///
/// All calculations work in km / km/s / s — never mix in metres. The math
/// is intentionally classroom-grade (two-body, circular reference orbits,
/// instantaneous burns) and is meant to teach intuition, not plan a mission.
class OrbitalMechanicsController extends GetxController {
  /// Speed of light, km/s. Used for time-dilation calculations.
  static const double cKmS = 299792.458;

  // 0 = Orbit, 1 = Escape, 2 = Hohmann, 3 = Time Dilation
  final selectedTab = 0.obs;

  /// When true, every tab reveals its formula panel.
  final showFormula = false.obs;

  // ── TAB 0 — ORBITAL PERIOD & VELOCITY ───────────────────────────
  final altitudeKm = 408.0.obs; // ISS default
  final centralBody = 'Earth'.obs;

  /// Period in seconds for a circular orbit at [altitudeKm] above the
  /// surface of [centralBody]. T = 2π · √(r³ / μ).
  double get orbitalPeriodSeconds {
    final body = CelestialBody.byName(centralBody.value);
    final r = body.radius + altitudeKm.value; // km
    final mu = body.gm; // km³/s²
    return 2 * pi * sqrt(pow(r, 3) / mu);
  }

  /// Circular orbital velocity in km/s. v = √(μ / r).
  double get orbitalVelocityKmS {
    final body = CelestialBody.byName(centralBody.value);
    final r = body.radius + altitudeKm.value;
    return sqrt(body.gm / r);
  }

  double get orbitsPerDay => 86400 / orbitalPeriodSeconds;

  // ── TAB 1 — ESCAPE VELOCITY ─────────────────────────────────────
  final escapeBody = 'Earth'.obs;

  /// Surface escape velocity in km/s. v_esc = √(2μ / r).
  double get escapeVelocityKmS {
    final body = CelestialBody.byName(escapeBody.value);
    return sqrt(2 * body.gm / body.radius);
  }

  // ── TAB 2 — HOHMANN TRANSFER ────────────────────────────────────
  final fromPlanet = 'Earth'.obs;
  final toPlanet = 'Mars'.obs;

  /// Δv₁, Δv₂, total Δv (km/s) and one-way transfer time (days) for a
  /// classical Hohmann transfer between the source and destination orbits.
  /// Returns NaN-safe zeros when from == to.
  Map<String, double> get hohmannResults {
    final from = CelestialBody.byName(fromPlanet.value);
    final to = CelestialBody.byName(toPlanet.value);
    if (from.name == to.name) {
      return const {
        'deltaV1': 0,
        'deltaV2': 0,
        'totalDeltaV': 0,
        'transferDays': 0,
      };
    }
    final mu = CelestialBody.sun.gm;
    final r1 = from.semiMajorAxis;
    final r2 = to.semiMajorAxis;
    final a = (r1 + r2) / 2; // transfer ellipse semi-major

    final v1 = sqrt(mu / r1);
    final v2 = sqrt(mu / r2);
    final vTrans1 = sqrt(mu * (2 / r1 - 1 / a));
    final vTrans2 = sqrt(mu * (2 / r2 - 1 / a));

    final dv1 = (vTrans1 - v1).abs();
    final dv2 = (v2 - vTrans2).abs();
    final transferSeconds = pi * sqrt(pow(a, 3) / mu);

    return {
      'deltaV1': dv1,
      'deltaV2': dv2,
      'totalDeltaV': dv1 + dv2,
      'transferDays': transferSeconds / 86400,
    };
  }

  // ── TAB 3 — SPECIAL-RELATIVITY TIME DILATION ────────────────────
  /// Fraction of the speed of light, 0..0.999.
  final speedFraction = 0.5.obs;

  /// Time elapsed in the rest frame (years).
  final restTimeYears = 1.0.obs;

  /// γ = 1 / √(1 − v²/c²). Capped at 1000 to avoid infinity.
  double get lorentzFactor {
    final v = speedFraction.value.clamp(0.0, 0.999999);
    if (v >= 0.999999) return 1000;
    return 1 / sqrt(1 - v * v);
  }

  /// Time experienced by a stationary observer for [restTimeYears] of the
  /// traveler's proper time, multiplied by γ.
  double get dilatedTimeYears => restTimeYears.value * lorentzFactor;

  /// Years younger the traveler is when they return.
  double get ageDifferenceYears =>
      dilatedTimeYears - restTimeYears.value;

  void changeTab(int idx) => selectedTab.value = idx;
  void toggleFormula() => showFormula.value = !showFormula.value;
}
