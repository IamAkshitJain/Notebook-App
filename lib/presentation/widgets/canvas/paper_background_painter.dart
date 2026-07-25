import 'package:flutter/material.dart';
import '../../../core/theme/paper_textures.dart';
import '../../../core/theme/app_colors.dart';

class PaperBackgroundPainter extends CustomPainter {
  final PaperStyle style;

  PaperBackgroundPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill base paper background color
    final bgPaint = Paint()..color = _getPaperColor(style.colorTheme);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = style.colorTheme == PaperColorTheme.darkBlueprint
          ? AppColors.gridDotColorDark
          : AppColors.ruleLineBlue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final marginPaint = Paint()
      ..color = AppColors.ruleLinePinkMargin
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (style.pattern) {
      case PaperPattern.lined:
        _drawLinedPattern(canvas, size, linePaint, marginPaint);
        break;
      case PaperPattern.grid:
        _drawGridPattern(canvas, size, linePaint);
        break;
      case PaperPattern.dotGrid:
        _drawDotGridPattern(canvas, size, linePaint);
        break;
      case PaperPattern.cornells:
        _drawCornellPattern(canvas, size, linePaint, marginPaint);
        break;
      case PaperPattern.blueprint:
        _drawGridPattern(canvas, size, linePaint);
        break;
      case PaperPattern.blank:
      default:
        break;
    }
  }

  Color _getPaperColor(PaperColorTheme theme) {
    switch (theme) {
      case PaperColorTheme.creamSepia:
        return AppColors.paperCreamSepia;
      case PaperColorTheme.warmIvory:
        return AppColors.paperWarmIvory;
      case PaperColorTheme.darkBlueprint:
        return AppColors.paperDarkBlueprint;
      case PaperColorTheme.darkGraphite:
        return AppColors.paperGraphiteDark;
      case PaperColorTheme.pureWhite:
      default:
        return AppColors.paperCleanWhite;
    }
  }

  void _drawLinedPattern(Canvas canvas, Size size, Paint linePaint, Paint marginPaint) {
    double y = 80.0;
    while (y < size.height - 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += style.lineSpacing;
    }

    // Left Margin Line
    canvas.drawLine(
      Offset(style.marginWidth, 0),
      Offset(style.marginWidth, size.height),
      marginPaint,
    );
  }

  void _drawGridPattern(Canvas canvas, Size size, Paint linePaint) {
    final step = style.gridSpacing;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawDotGridPattern(Canvas canvas, Size size, Paint linePaint) {
    final step = style.gridSpacing;
    final dotPaint = Paint()
      ..color = linePaint.color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  void _drawCornellPattern(Canvas canvas, Size size, Paint linePaint, Paint marginPaint) {
    _drawLinedPattern(canvas, size, linePaint, marginPaint);

    // Draw Cornell Left Cue Column (width = 220)
    canvas.drawLine(const Offset(220, 0), Offset(220, size.height - 200), linePaint..strokeWidth = 2.0);

    // Draw Cornell Bottom Summary Box Line (y = size.height - 200)
    canvas.drawLine(Offset(0, size.height - 200), Offset(size.width, size.height - 200), linePaint);
  }

  @override
  bool shouldRepaint(covariant PaperBackgroundPainter oldDelegate) {
    return oldDelegate.style != style;
  }
}
