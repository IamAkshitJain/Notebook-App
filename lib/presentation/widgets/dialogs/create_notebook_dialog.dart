import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notebook_provider.dart';

class CreateNotebookDialog extends ConsumerStatefulWidget {
  const CreateNotebookDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends ConsumerState<CreateNotebookDialog> {
  final TextEditingController _titleController = TextEditingController(text: 'New Physics Notebook');
  final TextEditingController _folderController = TextEditingController(text: 'University');
  int selectedCoverColor = 0xFF6C5CE7;

  final List<int> coverColors = [
    0xFF6C5CE7, // Purple
    0xFF00CEC9, // Teal
    0xFFFF7675, // Coral
    0xFF00B894, // Emerald
    0xFF2D3436, // Graphite
    0xFFE17055, // Amber
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Create New Notebook'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notebook Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _folderController,
              decoration: const InputDecoration(
                labelText: 'Folder / Category',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Cover Style', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: coverColors.map((colorVal) {
                final isSelected = selectedCoverColor == colorVal;
                return GestureDetector(
                  onTap: () => setState(() => selectedCoverColor = colorVal),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
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
            if (_titleController.text.trim().isEmpty) return;
            ref.read(notebookProvider.notifier).createNewNotebook(
                  _titleController.text.trim(),
                  _folderController.text.trim(),
                  selectedCoverColor,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Create Notebook'),
        ),
      ],
    );
  }
}
