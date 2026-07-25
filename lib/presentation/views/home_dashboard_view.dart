import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notebook_provider.dart';
import '../widgets/dialogs/create_notebook_dialog.dart';
import 'notebook_editor_view.dart';

class HomeDashboardView extends ConsumerWidget {
  const HomeDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebookState = ref.watch(notebookProvider);
    final notebookNotifier = ref.read(notebookProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PaperCraft Studio',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C5CE7),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Digital Paper Notebooks & Gemini AI Synthesis',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Notebook'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const CreateNotebookDialog(),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notebook Grid
              Expanded(
                child: notebookState.notebooks.isEmpty
                    ? const Center(child: Text('No notebooks yet. Click "New Notebook" to create one!'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: notebookState.notebooks.length,
                        itemBuilder: (context, index) {
                          final nb = notebookState.notebooks[index];

                          return GestureDetector(
                            onTap: () {
                              notebookNotifier.selectNotebook(nb);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const NotebookEditorView(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(nb.coverColorValue),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(4, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Spine Detail Line
                                  Positioned(
                                    left: 12,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      color: Colors.white24,
                                    ),
                                  ),

                                  // Cover Label Card
                                  Center(
                                    child: Container(
                                      width: 140,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            nb.title,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${nb.pages.length} Pages',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
        ),
      ),
    );
  }
}
