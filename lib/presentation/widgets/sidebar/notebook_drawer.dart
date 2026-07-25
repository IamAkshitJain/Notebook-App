import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notebook_provider.dart';

class NotebookDrawer extends ConsumerWidget {
  final VoidCallback onCreateNewNotebook;

  const NotebookDrawer({
    Key? key,
    required this.onCreateNewNotebook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebookState = ref.watch(notebookProvider);
    final notebookNotifier = ref.read(notebookProvider.notifier);

    final filteredNotebooks = notebookState.notebooks.where((nb) {
      if (notebookState.searchQuery.isEmpty) return true;
      return nb.title.toLowerCase().contains(notebookState.searchQuery.toLowerCase()) ||
          nb.categoryFolder.toLowerCase().contains(notebookState.searchQuery.toLowerCase());
    }).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book_rounded, color: Color(0xFF6C5CE7), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'My Notebooks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6C5CE7)),
                    tooltip: 'New Notebook',
                    onPressed: onCreateNewNotebook,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (val) => notebookNotifier.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search notes & folders...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Notebooks List
            Expanded(
              child: filteredNotebooks.isEmpty
                  ? const Center(child: Text('No notebooks found'))
                  : ListView.builder(
                      itemCount: filteredNotebooks.length,
                      itemBuilder: (context, index) {
                        final nb = filteredNotebooks[index];
                        final isSelected = notebookState.activeNotebook?.id == nb.id;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: const Color(0xFF6C5CE7).withOpacity(0.12),
                          leading: Container(
                            width: 36,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(nb.coverColorValue),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.menu_book, color: Colors.white, size: 18),
                            ),
                          ),
                          title: Text(
                            nb.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${nb.pages.length} Pages • ${nb.categoryFolder}'),
                          onTap: () {
                            notebookNotifier.selectNotebook(nb);
                            Navigator.of(context).pop(); // Close drawer
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
