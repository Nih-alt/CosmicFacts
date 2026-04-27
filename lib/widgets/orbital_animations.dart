import 'dart:math';

import 'package:flutter/material.dart';

/// Painters for the Orbital Mechanics calculator. All accept [isDark] and
/// share the cockpit palette used by the Mission Control screen.

const Color _darkAccent = Color(0xFF00E5FF);
const Color _lightAccent = Color(0xFF1E40AF);

Color _accent(bool isDark) => isDark ? _darkAccent : _lightAccent;

Color _track(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFCBD5F0);

void _drawDashedCircle(
  Canvas canvas,
  Offset center,
  double radius,
  Paint paint, {
  double dashLen = 4,
  double gapLen = 4,
}) {
  final circumference = 2 * pi * radius;
  final dashCount = (circumference / (dashLen + gapLen)).floor();
  final dashAngle = (dashLen / circumference) * 2 * pi;
  final stepAngle = 2 * pi / dashCount;
  for (int i = 0; i < dashCount; i++) {
    final start = i * stepAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      dashAngle,
      false,
      paint,
    );
  }
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint,
    {double dashLen = 4, double gapLen = 4}) {
  for (final metric in path.computeMetrics()) {
    double dist = 0;
    final length = metric.length;
    while (dist < length) {
      final next = (dist + dashLen).clamp(0.0, length);
      final segment = metric.extractPath(dist, next);
      canvas.drawPath(segment, paint);
      dist = next + gapLen;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// 1) OrbitVisualPainter — central body + dashed orbit + rotating sat.
// ═══════════════════════════════════════════════════════════════════
class OrbitVisualPainter extends CustomPainter {
  final double altitudeKm;
  final double bodyRadiusKm;
  final Color bodyColor;
  final double satelliteAngle; // radians, animation-driven
  final bool isDark;

  OrbitVisualPainter({
    required this.altitudeKm,
    required this.bodyRadiusKm,
    required this.bodyColor,
    required this.satelliteAngle,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(isDark);
    final track = _track(isDark);
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2 - 12;

    // Map: planet radius ↦ inner-most filled circle, orbit ↦ at distance
    // proportional to (radius + altitude) / radius. Clamp the orbit so it
    // always stays inside the canvas — this is a *visual* not-to-scale guide.
    final ratio = (bodyRadiusKm + altitudeKm) / bodyRadiusKm;
    final visualRatio = ratio.clamp(1.05, 4.5).toDouble();
    final planetR = maxR / visualRatio;
    final orbitR = planetR * visualRatio;

    // Tick marks every 90°
    final tickPaint = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      final inner = Offset(
        center.dx + (orbitR + 4) * cos(a),
        center.dy + (orbitR + 4) * sin(a),
      );
      final outer = Offset(
        center.dx + (orbitR + 12) * cos(a),
        center.dy + (orbitR + 12) * sin(a),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Orbit (dashed)
    final orbitPaint = Paint()
      ..color = accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _drawDashedCircle(canvas, center, orbitR, orbitPaint);

    // Faint baseline (1×r) for scale reference
    final basePaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, planetR, basePaint);

    // Planet body
    final body = Paint()
      ..shader = RadialGradient(
        colors: [bodyColor, bodyColor.withValues(alpha: 0.65)],
      ).createShader(Rect.fromCircle(center: center, radius: planetR));
    canvas.drawCircle(center, planetR, body);

    // Subtle planet edge highlight
    canvas.drawCircle(
      center,
      planetR,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Satellite — small dot on the orbit + glowing trail
    final satPos = Offset(
      center.dx + orbitR * cos(satelliteAngle),
      center.dy + orbitR * sin(satelliteAngle),
    );
    canvas.drawCircle(
      satPos,
      6,
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(satPos, 3, Paint()..color = accent);

    // Trailing arc — last quarter of the orbit
    final trailPaint = Paint()
      ..shader = SweepGradient(
        startAngle: satelliteAngle - pi / 2,
        endAngle: satelliteAngle,
        colors: [accent.withValues(alpha: 0), accent.withValues(alpha: 0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: orbitR))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: orbitR),
      satelliteAngle - pi / 2,
      pi / 2,
      false,
      trailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OrbitVisualPainter old) =>
      old.altitudeKm != altitudeKm ||
      old.bodyRadiusKm != bodyRadiusKm ||
      old.bodyColor != bodyColor ||
      old.satelliteAngle != satelliteAngle ||
      old.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════════
// 2) EscapeTrajectoryPainter — planet + parabolic escape curve + gauge.
// ═══════════════════════════════════════════════════════════════════
class EscapeTrajectoryPainter extends CustomPainter {
  final Color bodyColor;
  final double escapeKmS; // for the side gauge label scaling
  final bool isDark;
  final double progress; // 0..1, drives the dot moving along the trajectory

  EscapeTrajectoryPainter({
    required this.bodyColor,
    required this.escapeKmS,
    required this.isDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(isDark);
    final track = _track(isDark);

    // Reserve right strip for the gauge.
    const gaugeWidth = 22.0;
    final mainW = size.width - gaugeWidth - 12;
    final mainCenter = Offset(mainW / 2, size.height / 2);
    final maxR = min(mainW, size.height) / 2 - 16;
    final planetR = maxR * 0.35;

    // Planet
    canvas.drawCircle(
      mainCenter,
      planetR,
      Paint()
        ..shader = RadialGradient(
          colors: [bodyColor, bodyColor.withValues(alpha: 0.6)],
        ).createShader(Rect.fromCircle(center: mainCenter, radius: planetR)),
    );

    // Trajectory: a parabola from the surface flying off to the right.
    // Build it from quadratic curves for the look.
    final start = Offset(mainCenter.dx + planetR, mainCenter.dy);
    final end = Offset(size.width - gaugeWidth - 8, mainCenter.dy - maxR);
    final ctrl = Offset(
      mainCenter.dx + planetR + (end.dx - start.dx) * 0.25,
      mainCenter.dy + maxR * 0.05,
    );
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

    // Dashed trajectory
    final trajPaint = Paint()
      ..color = accent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawDashedPath(canvas, path, trajPaint);

    // Animated dot moving along trajectory
    final metric = path.computeMetrics().first;
    final dotPos =
        metric.getTangentForOffset(metric.length * progress)?.position ?? start;
    canvas.drawCircle(
      dotPos,
      6,
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(dotPos, 3, Paint()..color = accent);

    // Side gauge — vertical bar fills proportionally to a fixed reference
    // (Earth = 11.2 km/s) so users can compare bodies relatively.
    const refEscape = 11.2; // km/s — Earth
    final fill = (escapeKmS / refEscape).clamp(0.0, 1.5) / 1.5;
    final gaugeRect = Rect.fromLTWH(
      size.width - gaugeWidth,
      8,
      gaugeWidth,
      size.height - 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gaugeRect, const Radius.circular(3)),
      Paint()..color = track,
    );
    final fillRect = Rect.fromLTWH(
      gaugeRect.left,
      gaugeRect.bottom - gaugeRect.height * fill,
      gaugeRect.width,
      gaugeRect.height * fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [accent.withValues(alpha: 0.55), accent],
        ).createShader(fillRect),
    );
  }

  @override
  bool shouldRepaint(covariant EscapeTrajectoryPainter old) =>
      old.bodyColor != bodyColor ||
      old.escapeKmS != escapeKmS ||
      old.isDark != isDark ||
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════
// 3) HohmannPainter — Sun-centred orbits + transfer ellipse.
// ═══════════════════════════════════════════════════════════════════
class HohmannPainter extends CustomPainter {
  final double r1Au; // source orbit, in fractional units (0..1 normalized)
  final double r2Au;
  final Color fromColor;
  final Color toColor;
  final double progress; // 0..1 progress along the transfer ellipse
  final bool isDark;

  HohmannPainter({
    required this.r1Au,
    required this.r2Au,
    required this.fromColor,
    required this.toColor,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(isDark);
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2 - 16;

    // Normalize the two orbital radii so that the larger one fills maxR.
    final largest = max(r1Au, r2Au);
    final smaller = min(r1Au, r2Au);
    final big = maxR;
    final small = maxR * (smaller / largest);

    final isOutbound = r2Au >= r1Au;
    final rFrom = isOutbound ? small : big;
    final rTo = isOutbound ? big : small;

    // Orbits — solid rings in each planet's color, dim.
    final fromPaint = Paint()
      ..color = fromColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final toPaint = Paint()
      ..color = toColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, rFrom, fromPaint);
    canvas.drawCircle(center, rTo, toPaint);

    // Sun
    canvas.drawCircle(
      center,
      4,
      Paint()
        ..color = const Color(0xFFFFB800)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center,
      2.5,
      Paint()..color = const Color(0xFFFFB800),
    );

    // Transfer ellipse — Sun is at one focus.
    // Semi-major: (rFrom + rTo) / 2.
    // Semi-minor: √(rFrom · rTo).
    final aTrans = (rFrom + rTo) / 2;
    final bTrans = sqrt(rFrom * rTo);
    // Translate so Sun (focus) sits at canvas center: shift by (a − rFrom).
    final shift = aTrans - rFrom;
    final ellipseRect = Rect.fromCenter(
      center: Offset(center.dx - shift, center.dy),
      width: aTrans * 2,
      height: bTrans * 2,
    );
    final transferPaint = Paint()
      ..color = accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final ellipsePath = Path()..addOval(ellipseRect);
    _drawDashedPath(canvas, ellipsePath, transferPaint, dashLen: 5, gapLen: 4);

    // Departure marker — at start of transfer (perihelion if outbound).
    final fromAngle = isOutbound ? pi : 0.0;
    final fromPos = Offset(
      center.dx + rFrom * cos(fromAngle),
      center.dy + rFrom * sin(fromAngle),
    );
    canvas.drawCircle(
      fromPos,
      6,
      Paint()
        ..color = fromColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(fromPos, 3.5, Paint()..color = fromColor);

    // Arrival marker — opposite end of transfer.
    final toAngle = isOutbound ? 0.0 : pi;
    final toPos = Offset(
      center.dx + rTo * cos(toAngle),
      center.dy + rTo * sin(toAngle),
    );
    canvas.drawCircle(
      toPos,
      6,
      Paint()
        ..color = toColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(toPos, 3.5, Paint()..color = toColor);

    // Animated transfer dot — interpolate from departure to arrival along
    // the ellipse. Travel half the ellipse → angular range π.
    final tAngle = isOutbound
        ? pi - pi * progress // outbound: π → 0
        : 0 + pi * progress; // inbound:  0 → π
    final ex = ellipseRect.center.dx + (aTrans) * cos(tAngle);
    final ey = ellipseRect.center.dy + (bTrans) * sin(tAngle);
    final transitDot = Offset(ex, ey);
    canvas.drawCircle(
      transitDot,
      5,
      Paint()
        ..color = accent.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(transitDot, 2.5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant HohmannPainter old) =>
      old.r1Au != r1Au ||
      old.r2Au != r2Au ||
      old.fromColor != fromColor ||
      old.toColor != toColor ||
      old.progress != progress ||
      old.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════════
// 4) DualClockPainter — two clocks for time-dilation visualization.
// ═══════════════════════════════════════════════════════════════════
class DualClockPainter extends CustomPainter {
  final double restAngle; // radians, stationary clock hand
  final double travelAngle; // radians, traveler clock hand
  final bool isDark;

  DualClockPainter({
    required this.restAngle,
    required this.travelAngle,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(isDark);
    final track = _track(isDark);

    final clockRadius = min(size.width / 2, size.height) / 2 - 16;
    final cy = size.height / 2;
    final c1 = Offset(size.width / 4, cy);
    final c2 = Offset(size.width * 3 / 4, cy);

    void drawClock(Offset center, double angle, Color hand) {
      // Bezel
      canvas.drawCircle(
        center,
        clockRadius,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // 12-hour ticks
      final tickPaint = Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      for (int i = 0; i < 12; i++) {
        final a = (i / 12) * 2 * pi;
        final inner = Offset(
          center.dx + (clockRadius - 5) * cos(a),
          center.dy + (clockRadius - 5) * sin(a),
        );
        final outer = Offset(
          center.dx + clockRadius * cos(a),
          center.dy + clockRadius * sin(a),
        );
        canvas.drawLine(inner, outer, tickPaint);
      }
      // Hand
      final tip = Offset(
        center.dx + (clockRadius - 8) * cos(angle - pi / 2),
        center.dy + (clockRadius - 8) * sin(angle - pi / 2),
      );
      canvas.drawLine(
        center,
        tip,
        Paint()
          ..color = hand
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(center, 3, Paint()..color = hand);
    }

    drawClock(c1, restAngle, accent);
    drawClock(c2, travelAngle, accent);
  }

  @override
  bool shouldRepaint(covariant DualClockPainter old) =>
      old.restAngle != restAngle ||
      old.travelAngle != travelAngle ||
      old.isDark != isDark;
}
