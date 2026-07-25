import 'package:flutter/material.dart';
import '../../../domain/entities/stroke.dart';
import '../../../domain/entities/touch_point.dart';
import '../../../domain/entities/drawing_tool.dart';
import '../../../core/utils/bezier_smoother.dart';

class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentDrawingStroke;
  final Rect? lassoSelectionRect;
  final List<Stroke> selectedStrokes;

  StrokePainter({
    required this.strokes,
    this.currentDrawingStroke,
    this.lassoSelectionRect,
    required this.selectedStrokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw all completed strokes
    for (final stroke in strokes) {
      _drawSingleStroke(canvas, stroke);
    }

    // 2. Draw active in-progress drawing stroke
    if (currentDrawingStroke != null) {
      _drawSingleStroke(canvas, currentDrawingStroke!);
    }

    // 3. Draw Lasso Selection Rectangle & Handles
    if (lassoSelectionRect != null) {
      final lassoPaint = Paint()
        ..color = const Color(0xFF6C5CE7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawRect(lassoSelectionRect!, lassoPaint);

      // Fill light transparent background
      final fillPaint = Paint()
        ..color = const Color(0x1F6C5CE7)
        ..style = PaintingStyle.fill;
      canvas.drawRect(lassoSelectionRect!, fillPaint);
    }

    // 4. Highlight Selected Lasso Strokes
    for (final sel in selectedStrokes) {
      final selPaint = Paint()
        ..color = const Color(0xFF00CEC9)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawRect(sel.boundingBox, selPaint);
    }
  }

  void _drawSingleStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      final dotPaint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), stroke.strokeWidth / 2.0, dotPaint);
      return;
    }

    // Handle Shape Strokes (Lines, Circles, Rectangles)
    if (stroke.recognizedShape != null) {
      _drawRecognizedShape(canvas, stroke);
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.toolType == ToolType.highlighter) {
      paint.blendMode = BlendMode.multiply;
    }

    // Fountain Pen Pressure-Sensitive Thickness Path
    if (stroke.toolType == ToolType.fountainPen) {
      _drawPressureSensitiveStroke(canvas, stroke);
      return;
    }

    paint.strokeWidth = stroke.strokeWidth;
    final path = BezierSmoother.generateSmoothPath(stroke.points);
    canvas.drawPath(path, paint);
  }

  void _drawPressureSensitiveStroke(Canvas canvas, Stroke stroke) {
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];

      final currentWidth = stroke.strokeWidth * (0.4 + (p1.pressure * 0.9));
      final pPaint = Paint()
        ..color = stroke.color
        ..strokeWidth = currentWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1.toOffset(), p2.toOffset(), pPaint);
    }
  }

  void _drawRecognizedShape(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke;

    switch (stroke.recognizedShape!) {
      case ShapeType.line:
        canvas.drawLine(
          stroke.points.first.toOffset(),
          stroke.points.last.toOffset(),
          paint,
        );
        break;
      case ShapeType.circle:
        final path = BezierSmoother.generateSmoothPath(stroke.points, isClosed: true);
        canvas.drawPath(path, paint);
        break;
      case ShapeType.rectangle:
        final path = BezierSmoother.generateSmoothPath(stroke.points, isClosed: true);
        canvas.drawPath(path, paint);
        break;
      default:
        final path = BezierSmoother.generateSmoothPath(stroke.points);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return true; // Dynamic redraw on stroke move
  }
}
