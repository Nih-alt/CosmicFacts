import 'dart:math';

import 'package:flutter/material.dart';

/// Cockpit / NASA Mission Control painters used by the Space Statistics
/// dashboard. All painters honor the dark/light theme via [isDark].
///
/// Color contract:
///   Dark  → cyan/green CRT accents on near-black.
///   Light → deep blue/purple accents on light bg.

const _darkAccent = Color(0xFF00E5FF);
const _darkLive = Color(0xFF00FFB3);
const _lightAccent = Color(0xFF1E40AF);
const _lightLive = Color(0xFF5B21B6);

Color cockpitAccent(bool isDark) => isDark ? _darkAccent : _lightAccent;
Color cockpitLive(bool isDark) => isDark ? _darkLive : _lightLive;
Color cockpitTrack(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFCBD5F0);
Color cockpitText(bool isDark) =>
    isDark ? Colors.white : const Color(0xFF0A1628);

// ═══════════════════════════════════════════════════════════════════
// 1) SpeedometerPainter — semi-circular gauge, 180° arc.
// ═══════════════════════════════════════════════════════════════════
class SpeedometerPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final bool isDark;

  SpeedometerPainter({
    required this.value,
    required this.maxValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = min(size.width / 2, size.height * 0.92) - 6;

    final accent = cockpitAccent(isDark);
    final track = cockpitTrack(isDark);

    // Arc geometry: -180° (π rad) sweeping +180° (π rad) → full bottom-up half
    const startAngle = pi; // 180° (left)
    const sweepAngle = pi; // 180° clockwise to right

    // Outer track
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active fill — proportional to value/maxValue
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [accent.withValues(alpha: 0.6), accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * ratio,
      false,
      activePaint,
    );

    // Tick marks every 30°
    final tickPaint = Paint()
      ..color = track
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 6; i++) {
      final t = i / 6;
      final a = startAngle + sweepAngle * t;
      final inner = Offset(
        center.dx + (radius - 12) * cos(a),
        center.dy + (radius - 12) * sin(a),
      );
      final outer = Offset(
        center.dx + radius * cos(a),
        center.dy + radius * sin(a),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Needle pointing to value
    final needleAngle = startAngle + sweepAngle * ratio;
    final needleEnd = Offset(
      center.dx + (radius - 8) * cos(needleAngle),
      center.dy + (radius - 8) * sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Glow on needle
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(center, needleEnd, glowPaint);

    // Center hub
    canvas.drawCircle(center, 7, Paint()..color = accent);
    canvas.drawCircle(
      center,
      4,
      Paint()..color = isDark ? const Color(0xFF050514) : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter old) =>
      old.value != value || old.maxValue != maxValue || old.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════════
// 2) AltimeterBarPainter — vertical rocket-style altitude bar.
// ═══════════════════════════════════════════════════════════════════
class AltimeterBarPainter extends CustomPainter {
  final double altitudeKm;
  final double maxAltitudeKm;
  final bool isDark;

  AltimeterBarPainter({
    required this.altitudeKm,
    this.maxAltitudeKm = 500,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accent = cockpitAccent(isDark);
    final track = cockpitTrack(isDark);

    const padding = 10.0;
    final barWidth = size.width * 0.42;
    final barRect = Rect.fromLTWH(
      padding,
      padding,
      barWidth,
      size.height - padding * 2,
    );

    // Track
    final trackPaint = Paint()..color = track.withValues(alpha: 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
      trackPaint,
    );

    // Active fill from bottom up
    final ratio = (altitudeKm / maxAltitudeKm).clamp(0.0, 1.0);
    final fillHeight = barRect.height * ratio;
    final fillRect = Rect.fromLTWH(
      barRect.left,
      barRect.bottom - fillHeight,
      barRect.width,
      fillHeight,
    );
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [accent.withValues(alpha: 0.5), accent],
      ).createShader(fillRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(4)),
      fillPaint,
    );

    // Glow at top of fill
    if (fillHeight > 4) {
      final glowPaint = Paint()
        ..color = accent.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        Offset(barRect.center.dx, barRect.bottom - fillHeight),
        5,
        glowPaint,
      );
    }

    // Tick marks every 100km on right side
    final tickPaint = Paint()
      ..color = track
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: cockpitText(isDark).withValues(alpha: 0.55),
      fontSize: 8,
      fontFamily: 'monospace',
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final tickXStart = barRect.right + 4;
    final tickXEnd = barRect.right + 12;
    for (int km = 0; km <= maxAltitudeKm.toInt(); km += 100) {
      final t = km / maxAltitudeKm;
      final y = barRect.bottom - barRect.height * t;
      canvas.drawLine(
        Offset(tickXStart, y),
        Offset(tickXEnd, y),
        tickPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: '${km}K', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tickXEnd + 3, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant AltimeterBarPainter old) =>
      old.altitudeKm != altitudeKm ||
      old.maxAltitudeKm != maxAltitudeKm ||
      old.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════════
// 3) RadarSweepPainter — concentric rings with rotating sweep arm.
// ═══════════════════════════════════════════════════════════════════
class RadarSweepPainter extends CustomPainter {
  final double sweepAngle; // 0..2π
  final int blipCount;
  final bool isDark;
  final int seed;

  RadarSweepPainter({
    required this.sweepAngle,
    required this.blipCount,
    required this.isDark,
    this.seed = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    final accent = cockpitAccent(isDark);
    final live = cockpitLive(isDark);

    // Concentric rings
    final ringPaint = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, ringPaint);
    }

    // Crosshair
    final crossPaint = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );

    // Sweep wedge
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 0.6,
        endAngle: sweepAngle,
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        sweepAngle - 0.6,
        0.6,
        false,
      )
      ..close();
    canvas.drawPath(path, sweepPaint);

    // Sweep arm
    final armEnd = Offset(
      center.dx + radius * cos(sweepAngle),
      center.dy + radius * sin(sweepAngle),
    );
    final armPaint = Paint()
      ..color = accent
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, armEnd, armPaint);

    // Blips — fixed positions seeded by [seed]
    final rng = Random(seed);
    final blipPaint = Paint()..color = live;
    final blipGlow = Paint()
      ..color = live.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < blipCount; i++) {
      final r = radius * (0.2 + rng.nextDouble() * 0.75);
      final a = rng.nextDouble() * 2 * pi;
      final p = Offset(
        center.dx + r * cos(a),
        center.dy + r * sin(a),
      );
      canvas.drawCircle(p, 2.5, blipGlow);
      canvas.drawCircle(p, 1.6, blipPaint);
    }

    // Center dot
    canvas.drawCircle(center, 2.5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter old) =>
      old.sweepAngle != sweepAngle ||
      old.blipCount != blipCount ||
      old.isDark != isDark;
}
