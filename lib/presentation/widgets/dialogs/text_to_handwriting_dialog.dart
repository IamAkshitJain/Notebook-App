import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/handwriting_synthesizer.dart';
import '../../providers/canvas_state_provider.dart';
import '../../../core/theme/app_colors.dart';

class TextToHandwritingDialog extends ConsumerStatefulWidget {
  const TextToHandwritingDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<TextToHandwritingDialog> createState() => _TextToHandwritingDialogState();
}

class _TextToHandwritingDialogState extends ConsumerState<TextToHandwritingDialog> {
  final TextEditingController _textController = TextEditingController();
  Color selectedColor = AppColors.defaultInkColors.first;
  double fontSize = 26.0;
  double lineSpacing = 38.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.font_download_rounded, color: Color(0xFF6C5CE7)),
          SizedBox(width: 10),
          Text('Text to Organic Handwriting'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste copied text below. It will automatically convert into realistic handwritten ink strokes matching your paper layout.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Paste or type text here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Color Swatches
            Row(
              children: [
                const Text('Ink Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ...AppColors.defaultInkColors.take(5).map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: const Color(0xFF6C5CE7), width: 3)
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_textController.text.trim().isEmpty) return;

            final strokes = HandwritingSynthesizer.textToHandwritingStrokes(
              text: _textController.text.trim(),
              startOffset: const Offset(120, 160),
              color: selectedColor,
              fontSize: fontSize,
              lineSpacing: lineSpacing,
            );

            ref.read(canvasStateProvider.notifier).addStrokes(strokes);
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Generated ${strokes.length} organic handwritten strokes!')),
            );
          },
          child: const Text('Insert Ink Handwriting'),
        ),
      ],
    );
  }
}
