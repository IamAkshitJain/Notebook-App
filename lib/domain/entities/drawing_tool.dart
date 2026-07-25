import 'package:flutter/material.dart';

enum ToolType {
  fountainPen,
  ballpointPen,
  brushPen,
  highlighter,
  strokeEraser,
  pointEraser,
  lasso,
  shapes,
  textToHandwriting,
  imageSticker,
}

enum ShapeType {
  line,
  arrow,
  rectangle,
  circle,
  triangle,
}

class DrawingTool {
  final ToolType type;
  final Color color;
  final double width;
  final double opacity;
  final ShapeType activeShape;

  const DrawingTool({
    this.type = ToolType.fountainPen,
    this.color = const Color(0xFF1E1E1E),
    this.width = 3.0,
    this.opacity = 1.0,
    this.activeShape = ShapeType.line,
  });

  DrawingTool copyWith({
    ToolType? type,
    Color? color,
    double? width,
    double? opacity,
    ShapeType? activeShape,
  }) {
    return DrawingTool(
      type: type ?? this.type,
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
      activeShape: activeShape ?? this.activeShape,
    );
  }
}
