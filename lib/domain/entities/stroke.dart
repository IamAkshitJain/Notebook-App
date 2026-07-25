import 'package:flutter/material.dart';
import 'touch_point.dart';
import 'drawing_tool.dart';

/// Represents a continuous handwritten vector line or geometric shape stroke
class Stroke {
  final String id;
  final List<TouchPoint> points;
  final ToolType toolType;
  final Color color;
  final double strokeWidth;
  final bool isSynthetic; // True if generated via Text-to-Handwriting or Shapes
  final ShapeType? recognizedShape;
  final Rect boundingBox;
  final bool isSelected;

  Stroke({
    required this.id,
    required this.points,
    required this.toolType,
    required this.color,
    required this.strokeWidth,
    this.isSynthetic = false,
    this.recognizedShape,
    Rect? boundingBox,
    this.isSelected = false,
  }) : boundingBox = boundingBox ?? computeBoundingBox(points, strokeWidth);

  static Rect computeBoundingBox(List<TouchPoint> points, double width) {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;

    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    // Pad bounding box with half stroke width
    final padding = width / 2.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  Stroke copyWith({
    String? id,
    List<TouchPoint>? points,
    ToolType? toolType,
    Color? color,
    double? strokeWidth,
    bool? isSynthetic,
    ShapeType? recognizedShape,
    Rect? boundingBox,
    bool? isSelected,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      toolType: toolType ?? this.toolType,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isSynthetic: isSynthetic ?? this.isSynthetic,
      recognizedShape: recognizedShape ?? this.recognizedShape,
      boundingBox: boundingBox ?? this.boundingBox,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Translate all points by an offset (used in Lasso move)
  Stroke translate(Offset delta) {
    final updatedPoints = points
        .map((p) => p.copyWith(x: p.x + delta.dx, y: p.y + delta.dy))
        .toList();
    return copyWith(points: updatedPoints);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points.map((p) => p.toJson()).toList(),
        'toolType': toolType.index,
        'color': color.value,
        'strokeWidth': strokeWidth,
        'isSynthetic': isSynthetic,
        'recognizedShape': recognizedShape?.index,
      };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
        id: json['id'] as String,
        points: (json['points'] as List)
            .map((p) => TouchPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        toolType: ToolType.values[json['toolType'] as int],
        color: Color(json['color'] as int),
        strokeWidth: (json['strokeWidth'] as num).toDouble(),
        isSynthetic: json['isSynthetic'] as bool? ?? false,
        recognizedShape: json['recognizedShape'] != null
            ? ShapeType.values[json['recognizedShape'] as int]
            : null,
      );
}
