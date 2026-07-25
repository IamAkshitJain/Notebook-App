import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../domain/entities/drawing_tool.dart';

class PdfExporter {
  /// Renders a full Notebook into a PDF binary ByteData
  static Future<Uint8List> buildNotebookPdf(Notebook notebook) async {
    final pdf = pw.Document(
      title: notebook.title,
      author: 'PaperCraft Studio',
    );

    for (final page in notebook.pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.CustomPaint(
                painter: (PdfGraphics canvas, PdfPoint size) {
                  _drawPaperBackground(canvas, size, page);
                  _drawPageStrokes(canvas, size, page);
                },
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static void _drawPaperBackground(PdfGraphics canvas, PdfPoint size, NotebookPage page) {
    // Draw background color
    canvas.setFillColor(PdfColor.fromInt(0xFFFBF7EE)); // Sepia Cream
    canvas.drawRect(0, 0, size.x, size.y);
    canvas.fillPath();

    // Draw horizontal ruled lines
    canvas.setStrokeColor(PdfColor.fromInt(0x334A90E2));
    canvas.setLineWidth(0.5);

    double y = size.y - 60;
    while (y > 40) {
      canvas.moveTo(0, y);
      canvas.lineTo(size.x, y);
      canvas.strokePath();
      y -= 28.0;
    }

    // Draw margin line
    canvas.setStrokeColor(PdfColor.fromInt(0x66FF7675));
    canvas.setLineWidth(1.0);
    canvas.moveTo(60, 0);
    canvas.lineTo(60, size.y);
    canvas.strokePath();
  }

  static void _drawPageStrokes(PdfGraphics canvas, PdfPoint size, NotebookPage page) {
    final scaleX = PdfPageFormat.a4.width / 1240.0;
    final scaleY = PdfPageFormat.a4.height / 1754.0;

    for (final stroke in page.strokes) {
      if (stroke.points.isEmpty) continue;

      final pdfColor = PdfColor(
        stroke.color.r,
        stroke.color.g,
        stroke.color.b,
        stroke.toolType == ToolType.highlighter ? 0.35 : stroke.color.a,
      );

      canvas.setStrokeColor(pdfColor);
      canvas.setLineWidth(stroke.strokeWidth * scaleX);

      final p0 = stroke.points.first;
      // In PDF coordinate space, Y zero is at the BOTTOM
      canvas.moveTo(p0.x * scaleX, size.y - (p0.y * scaleY));

      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i];
        canvas.lineTo(p.x * scaleX, size.y - (p.y * scaleY));
      }

      canvas.strokePath();
    }
  }
}
