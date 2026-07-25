import 'package:flutter/material.dart';
import '../../domain/entities/touch_point.dart';

class BezierSmoother {
  /// Converts raw touch points into a continuous smooth Path using Catmull-Rom / Bézier control points
  static Path generateSmoothPath(List<TouchPoint> points, {bool isClosed = false}) {
    final path = Path();
    if (points.isEmpty) return path;

    if (points.length < 3) {
      path.moveTo(points.first.x, points.first.y);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      return path;
    }

    path.moveTo(points[0].x, points[0].y);

    // Quad / Cubic Interpolation across consecutive points
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i == 0 ? 0 : i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2 >= points.length ? i + 1 : i + 2];

      // Catmull-Rom to Cubic Bézier control points calculation
      final cp1x = p1.x + (p2.x - p0.x) / 6.0;
      final cp1y = p1.y + (p2.y - p0.y) / 6.0;

      final cp2x = p2.x - (p3.x - p1.x) / 6.0;
      final cp2y = p2.y - (p3.y - p1.y) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
    }

    if (isClosed) {
      path.close();
    }

    return path;
  }

  /// Interpolate pressure smoothly along stroke
  static double getInterpolatedPressure(TouchPoint p1, TouchPoint p2, double t) {
    return p1.pressure + (p2.pressure - p1.pressure) * t;
  }
}
