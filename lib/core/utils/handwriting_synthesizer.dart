import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/stroke.dart';
import '../../domain/entities/touch_point.dart';
import '../../domain/entities/drawing_tool.dart';

class HandwritingSynthesizer {
  /// Converts plain text string into realistic organic vector handwritten stroke strokes
  static List<Stroke> textToHandwritingStrokes({
    required String text,
    required Offset startOffset,
    required Color color,
    double strokeWidth = 2.5,
    double fontSize = 24.0,
    double lineSpacing = 36.0,
    double maxLineWidth = 800.0,
  }) {
    final List<Stroke> resultStrokes = [];
    final random = Random(42); // Seeded for deterministic natural variations

    double currentX = startOffset.dx;
    double currentY = startOffset.dy;
    int timestampCounter = DateTime.now().millisecondsSinceEpoch;

    final charLines = text.split('\n');

    for (final rawLine in charLines) {
      final words = rawLine.split(' ');

      for (final word in words) {
        final wordWidth = word.length * (fontSize * 0.55);
        if (currentX + wordWidth > startOffset.dx + maxLineWidth && currentX > startOffset.dx) {
          currentX = startOffset.dx;
          currentY += lineSpacing;
        }

        for (int i = 0; i < word.length; i++) {
          final char = word[i];
          final glyphPoints = _generateGlyphPoints(
            char,
            Offset(currentX, currentY),
            fontSize,
            random,
            timestampCounter,
          );

          if (glyphPoints.isNotEmpty) {
            timestampCounter += 50;
            resultStrokes.add(Stroke(
              id: 'syn_${timestampCounter}_${random.nextInt(10000)}',
              points: glyphPoints,
              toolType: ToolType.fountainPen,
              color: color,
              strokeWidth: strokeWidth + (random.nextDouble() * 0.4 - 0.2),
              isSynthetic: true,
            ));
          }

          // Advance X with organic character spacing
          currentX += (fontSize * 0.55) + (random.nextDouble() * 2.0 - 1.0);
        }

        // Word spacing
        currentX += (fontSize * 0.4);
      }

      // Next line
      currentX = startOffset.dx;
      currentY += lineSpacing;
    }

    return resultStrokes;
  }

  /// Generates parametric Bézier points for a single character glyph
  static List<TouchPoint> _generateGlyphPoints(
    String char,
    Offset pos,
    double size,
    Random random,
    int baseTime,
  ) {
    final points = <TouchPoint>[];
    final baselineJitter = (random.nextDouble() * 2.5 - 1.25);
    final slantAngle = (random.nextDouble() * 0.08 - 0.04);

    final x = pos.dx;
    final y = pos.dy + baselineJitter;
    final h = size;
    final w = size * 0.5;

    // Approximate handwriting curves for common character types
    final steps = 12;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      double px = x + w * t;
      double py = y;

      // Natural loops & curves depending on character group
      if ('aeiou'.contains(char.toLowerCase())) {
        py = y - (sin(t * pi) * (h * 0.35));
      } else if ('bdfhklt'.contains(char.toLowerCase())) {
        py = y - (h * 0.7 * (1.0 - (2 * (t - 0.5)).abs()));
      } else if ('gjpqy'.contains(char.toLowerCase())) {
        py = y + (h * 0.4 * sin(t * pi));
      } else {
        py = y - (h * 0.3 * sin(t * pi * 0.8));
      }

      // Apply slant transformation
      px += (y - py) * tan(slantAngle);

      final pressure = 0.4 + 0.3 * sin(t * pi);
      points.add(TouchPoint(
        x: px,
        y: py,
        pressure: pressure,
        timestamp: baseTime + i * 2,
      ));
    }

    return points;
  }
}
