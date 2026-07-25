import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/drawing_tool.dart';
import '../../domain/entities/stroke.dart';
import '../../domain/entities/touch_point.dart';
import '../../domain/entities/image_sticker.dart';
import '../../domain/entities/page.dart';
import '../../core/utils/shape_recognizer.dart';

class CanvasState {
  final DrawingTool activeTool;
  final List<Stroke> strokes;
  final List<ImageSticker> imageStickers;
  final Stroke? currentDrawingStroke;
  final List<List<Stroke>> undoStack;
  final List<List<Stroke>> redoStack;
  final Rect? lassoSelectionRect;
  final List<Stroke> selectedStrokes;
  final double zoomScale;
  final Offset panOffset;

  CanvasState({
    required this.activeTool,
    required this.strokes,
    required this.imageStickers,
    this.currentDrawingStroke,
    required this.undoStack,
    required this.redoStack,
    this.lassoSelectionRect,
    required this.selectedStrokes,
    this.zoomScale = 1.0,
    this.panOffset = Offset.zero,
  });

  CanvasState copyWith({
    DrawingTool? activeTool,
    List<Stroke>? strokes,
    List<ImageSticker>? imageStickers,
    Stroke? currentDrawingStroke,
    bool clearCurrentStroke = false,
    List<List<Stroke>>? undoStack,
    List<List<Stroke>>? redoStack,
    Rect? lassoSelectionRect,
    bool clearLassoRect = false,
    List<Stroke>? selectedStrokes,
    double? zoomScale,
    Offset? panOffset,
  }) {
    return CanvasState(
      activeTool: activeTool ?? this.activeTool,
      strokes: strokes ?? this.strokes,
      imageStickers: imageStickers ?? this.imageStickers,
      currentDrawingStroke: clearCurrentStroke
          ? null
          : (currentDrawingStroke ?? this.currentDrawingStroke),
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      lassoSelectionRect: clearLassoRect
          ? null
          : (lassoSelectionRect ?? this.lassoSelectionRect),
      selectedStrokes: selectedStrokes ?? this.selectedStrokes,
      zoomScale: zoomScale ?? this.zoomScale,
      panOffset: panOffset ?? this.panOffset,
    );
  }
}

class CanvasStateNotifier extends StateNotifier<CanvasState> {
  static const _uuid = Uuid();

  CanvasStateNotifier()
      : super(CanvasState(
          activeTool: const DrawingTool(),
          strokes: [],
          imageStickers: [],
          undoStack: [],
          redoStack: [],
          selectedStrokes: [],
        ));

  void loadPage(NotebookPage page) {
    state = state.copyWith(
      strokes: page.strokes,
      imageStickers: page.imageStickers,
      undoStack: [],
      redoStack: [],
      selectedStrokes: [],
      clearLassoRect: true,
      clearCurrentStroke: true,
    );
  }

  void setActiveTool(DrawingTool tool) {
    state = state.copyWith(activeTool: tool);
  }

  void setToolType(ToolType type) {
    state = state.copyWith(activeTool: state.activeTool.copyWith(type: type));
  }

  void setToolColor(Color color) {
    state = state.copyWith(activeTool: state.activeTool.copyWith(color: color));
  }

  void setToolWidth(double width) {
    state = state.copyWith(activeTool: state.activeTool.copyWith(width: width));
  }

  void setShapeType(ShapeType shape) {
    state = state.copyWith(
      activeTool: state.activeTool.copyWith(
        type: ToolType.shapes,
        activeShape: shape,
      ),
    );
  }

  /// Start drawing a new stroke
  void onPointerDown(Offset position, double pressure) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final firstPoint = TouchPoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure,
      timestamp: now,
    );

    if (state.activeTool.type == ToolType.lasso) {
      state = state.copyWith(
        lassoSelectionRect: Rect.fromLTWH(position.dx, position.dy, 1, 1),
        selectedStrokes: [],
      );
      return;
    }

    if (state.activeTool.type == ToolType.strokeEraser) {
      _eraseStrokesAt(position);
      return;
    }

    final newStroke = Stroke(
      id: _uuid.v4(),
      points: [firstPoint],
      toolType: state.activeTool.type,
      color: state.activeTool.type == ToolType.highlighter
          ? state.activeTool.color.withOpacity(0.35)
          : state.activeTool.color,
      strokeWidth: state.activeTool.width,
    );

    state = state.copyWith(currentDrawingStroke: newStroke);
  }

  /// Move pointer along drawing path
  void onPointerMove(Offset position, double pressure) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final nextPoint = TouchPoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure,
      timestamp: now,
    );

    if (state.activeTool.type == ToolType.lasso && state.lassoSelectionRect != null) {
      final rect = state.lassoSelectionRect!;
      final newRect = Rect.fromLTRB(
        rect.left < position.dx ? rect.left : position.dx,
        rect.top < position.dy ? rect.top : position.dy,
        rect.right > position.dx ? rect.right : position.dx,
        rect.bottom > position.dy ? rect.bottom : position.dy,
      );
      state = state.copyWith(lassoSelectionRect: newRect);
      return;
    }

    if (state.activeTool.type == ToolType.strokeEraser) {
      _eraseStrokesAt(position);
      return;
    }

    if (state.currentDrawingStroke != null) {
      final updatedPoints = [...state.currentDrawingStroke!.points, nextPoint];
      state = state.copyWith(
        currentDrawingStroke: state.currentDrawingStroke!.copyWith(points: updatedPoints),
      );
    }
  }

  /// End pointer drawing stroke
  void onPointerUp() {
    if (state.activeTool.type == ToolType.lasso && state.lassoSelectionRect != null) {
      final selected = state.strokes
          .where((s) => state.lassoSelectionRect!.overlaps(s.boundingBox))
          .toList();
      state = state.copyWith(selectedStrokes: selected);
      return;
    }

    if (state.currentDrawingStroke == null) return;

    var finalStroke = state.currentDrawingStroke!;

    // Perform Auto Shape Detection if in Shapes mode or line draw
    if (state.activeTool.type == ToolType.shapes) {
      final shapeResult = ShapeRecognizer.detectShape(finalStroke.points);
      if (shapeResult != null) {
        finalStroke = finalStroke.copyWith(
          points: shapeResult.sanitizedPoints,
          recognizedShape: shapeResult.shapeType,
          isSynthetic: true,
        );
      }
    }

    final newStrokes = [...state.strokes, finalStroke];
    final newUndo = [...state.undoStack, state.strokes];

    state = state.copyWith(
      strokes: newStrokes,
      undoStack: newUndo,
      redoStack: [],
      clearCurrentStroke: true,
    );
  }

  void _eraseStrokesAt(Offset pos) {
    const eraseRadius = 16.0;
    final remainingStrokes = state.strokes.where((stroke) {
      for (final p in stroke.points) {
        final dx = p.x - pos.dx;
        final dy = p.y - pos.dy;
        if ((dx * dx + dy * dy) <= eraseRadius * eraseRadius) {
          return false; // Erase entire stroke
        }
      }
      return true;
    }).toList();

    if (remainingStrokes.length != state.strokes.length) {
      final newUndo = [...state.undoStack, state.strokes];
      state = state.copyWith(strokes: remainingStrokes, undoStack: newUndo);
    }
  }

  void addStrokes(List<Stroke> newStrokes) {
    final updated = [...state.strokes, ...newStrokes];
    final newUndo = [...state.undoStack, state.strokes];
    state = state.copyWith(strokes: updated, undoStack: newUndo, redoStack: []);
  }

  void addImageSticker(ImageSticker sticker) {
    final updated = [...state.imageStickers, sticker];
    state = state.copyWith(imageStickers: updated);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final previousStrokes = state.undoStack.last;
    final newUndo = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedo = [...state.redoStack, state.strokes];

    state = state.copyWith(
      strokes: previousStrokes,
      undoStack: newUndo,
      redoStack: newRedo,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final nextStrokes = state.redoStack.last;
    final newRedo = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndo = [...state.undoStack, state.strokes];

    state = state.copyWith(
      strokes: nextStrokes,
      undoStack: newUndo,
      redoStack: newRedo,
    );
  }

  void clearCanvas() {
    final newUndo = [...state.undoStack, state.strokes];
    state = state.copyWith(
      strokes: [],
      imageStickers: [],
      undoStack: newUndo,
      redoStack: [],
      selectedStrokes: [],
      clearLassoRect: true,
    );
  }
}

final canvasStateProvider =
    StateNotifierProvider<CanvasStateNotifier, CanvasState>((ref) {
  return CanvasStateNotifier();
});
