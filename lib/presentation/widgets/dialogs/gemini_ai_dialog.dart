import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notebook_provider.dart';

class GeminiAiDialog extends ConsumerStatefulWidget {
  const GeminiAiDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<GeminiAiDialog> createState() => _GeminiAiDialogState();
}

class _GeminiAiDialogState extends ConsumerState<GeminiAiDialog> {
  bool isLoading = false;
  String aiResponse = '';

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    final activeNotebook = ref.read(notebookProvider).activeNotebook;
    if (activeNotebook == null) return;

    setState(() => isLoading = true);
    final repo = ref.read(notebookRepositoryProvider);
    final summary = await repo.summarizeWithGemini(activeNotebook);

    if (mounted) {
      setState(() {
        aiResponse = summary;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.auto_awesome, color: Color(0xFF6C5CE7)),
          SizedBox(width: 10),
          Text('Gemini AI Assistant'),
        ],
      ),
      content: SizedBox(
        width: 550,
        height: 400,
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                    SizedBox(height: 16),
                    Text('Gemini AI analyzing notebook strokes & layout...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: SelectableText(
                  aiResponse,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
