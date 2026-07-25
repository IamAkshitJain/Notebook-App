import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/touch_point.dart';
import '../../domain/entities/drawing_tool.dart';

class RecognizedShapeResult {
  final ShapeType shapeType;
  final List<TouchPoint> sanitizedPoints;

  RecognizedShapeResult({
    required this.shapeType,
    required this.sanitizedPoints,
  });
}

class ShapeRecognizer {
  /// Evaluates a raw user stroke and detects if it matches a Line, Rectangle, Circle, or Arrow
  static RecognizedShapeResult? detectShape(List<TouchPoint> rawPoints) {
    if (rawPoints.length < 5) return null;

    final start = rawPoints.first;
    final end = rawPoints.last;
    final totalDistance = _distance(start, end);

    double totalPathLength = 0;
    for (int i = 0; i < rawPoints.length - 1; i++) {
      totalPathLength += _distance(rawPoints[i], rawPoints[i + 1]);
    }

    // Ratio of end-to-end distance vs total path length
    final straightnessRatio = totalDistance / (totalPathLength == 0 ? 1 : totalPathLength);

    // 1. Detect Straight Line
    if (straightnessRatio > 0.92) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return RecognizedShapeResult(
        shapeType: ShapeType.line,
        sanitizedPoints: [
          TouchPoint(x: start.x, y: start.y, pressure: 0.5, timestamp: now),
          TouchPoint(x: end.x, y: end.y, pressure: 0.5, timestamp: now + 10),
        ],
      );
    }

    // Calculate Bounding Box
    double minX = rawPoints.first.x, maxX = rawPoints.first.x;
    double minY = rawPoints.first.y, maxY = rawPoints.first.y;
    for (final p in rawPoints) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    final width = maxX - minX;
    final height = maxY - minY;

    // Check if start and end points are close (Closed Loop)
    final closeLoopDistance = _distance(start, end);
    final isClosedLoop = closeLoopDistance < max(width, height) * 0.3;

    if (isClosedLoop && rawPoints.length > 10) {
      final aspectRatio = width / (height == 0 ? 1 : height);
      final now = DateTime.now().millisecondsSinceEpoch;

      // 2. Circle / Ellipse Detection
      if (aspectRatio >= 0.7 && aspectRatio <= 1.3) {
        final cx = minX + width / 2.0;
        final cy = minY + height / 2.0;
        final radius = (width + height) / 4.0;
        final circlePoints = <TouchPoint>[];

        for (int i = 0; i <= 36; i++) {
          final angle = (i * 10) * (pi / 180.0);
          circlePoints.add(TouchPoint(
            x: cx + radius * cos(angle),
            y: cy + radius * sin(angle),
            pressure: 0.5,
            timestamp: now + i * 2,
          ));
        }

        return RecognizedShapeResult(
          shapeType: ShapeType.circle,
          sanitizedPoints: circlePoints,
        );
      }

      // 3. Rectangle / Square Detection
      final rectPoints = <TouchPoint>[
        TouchPoint(x: minX, y: minY, pressure: 0.5, timestamp: now),
        TouchPoint(x: maxX, y: minY, pressure: 0.5, timestamp: now + 5),
        TouchPoint(x: maxX, y: maxY, pressure: 0.5, timestamp: now + 10),
        TouchPoint(x: minX, y: maxY, pressure: 0.5, timestamp: now + 15),
        TouchPoint(x: minX, y: minY, pressure: 0.5, timestamp: now + 20),
      ];

      return RecognizedShapeResult(
        shapeType: ShapeType.rectangle,
        sanitizedPoints: rectPoints,
      );
    }

    return null;
  }

  static double _distance(TouchPoint a, TouchPoint b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    return sqrt(dx * dx + dy * dy);
  }
}
