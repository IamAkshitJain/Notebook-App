import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_state_provider.dart';
import '../../providers/notebook_provider.dart';
import '../../providers/theme_provider.dart';

class TopToolbar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onOpenSidebar;
  final VoidCallback onOpenGeminiDialog;
  final VoidCallback onOpenTextToHandwritingDialog;
  final VoidCallback onExportPdf;

  const TopToolbar({
    Key? key,
    required this.onOpenSidebar,
    required this.onOpenGeminiDialog,
    required this.onOpenTextToHandwritingDialog,
    required this.onExportPdf,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final canvasNotifier = ref.read(canvasStateProvider.notifier);
    final notebookState = ref.watch(notebookProvider);
    final notebookNotifier = ref.read(notebookProvider.notifier);
    final themeMode = ref.watch(themeProvider);

    final activeNotebook = notebookState.activeNotebook;
    final totalPages = activeNotebook?.pages.length ?? 1;
    final currentPageIndex = notebookState.activePageIndex;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Drawer Toggle
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Notebooks & Page Thumbnails',
            onPressed: onOpenSidebar,
          ),

          const SizedBox(width: 8),

          // Notebook Title & Category Badge
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeNotebook?.title ?? 'Untitled Notebook',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Page ${currentPageIndex + 1} of $totalPages • ${activeNotebook?.categoryFolder ?? "General"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Undo Button
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
            onPressed: canvasState.undoStack.isNotEmpty ? canvasNotifier.undo : null,
          ),

          // Redo Button
          IconButton(
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Redo',
            onPressed: canvasState.redoStack.isNotEmpty ? canvasNotifier.redo : null,
          ),

          const VerticalDivider(indent: 14, endIndent: 14, width: 24),

          // Text to Handwriting Synthesizer Button
          ElevatedButton.icon(
            icon: const Icon(Icons.font_download_rounded, size: 18),
            label: const Text('Text ➔ Ink'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              foregroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 0,
            ),
            onPressed: onOpenTextToHandwritingDialog,
          ),

          const SizedBox(width: 8),

          // Gemini AI Assistant Button
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Gemini AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.2),
              foregroundColor: const Color(0xFF6C5CE7),
              elevation: 0,
            ),
            onPressed: onOpenGeminiDialog,
          ),

          const SizedBox(width: 8),

          // Export PDF Button
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export High-Quality PDF',
            onPressed: onExportPdf,
          ),

          // Dark/Light Theme Toggle
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme Mode',
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
    );
  }
}
