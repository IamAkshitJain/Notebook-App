import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notebook_provider.dart';

class PageThumbnailBar extends ConsumerWidget {
  const PageThumbnailBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebookState = ref.watch(notebookProvider);
    final notebookNotifier = ref.read(notebookProvider.notifier);

    final activeNotebook = notebookState.activeNotebook;
    if (activeNotebook == null) return const SizedBox.shrink();

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header & Add Page Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pages Grid',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF6C5CE7)),
                  tooltip: 'Add New Page',
                  onPressed: () => notebookNotifier.addPageToActiveNotebook(),
                ),
              ],
            ),
          ),

          // Grid of Page Thumbnails
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: activeNotebook.pages.length,
              itemBuilder: (context, index) {
                final page = activeNotebook.pages[index];
                final isSelected = notebookState.activePageIndex == index;

                return GestureDetector(
                  onTap: () => notebookNotifier.setPageIndex(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF7EE), // Sepia paper preview
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.article_outlined, color: Colors.blueGrey),
                              const SizedBox(height: 4),
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${page.strokes.length} strokes',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (page.isBookmarked)
                          const Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.bookmark, color: Colors.amber, size: 16),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
