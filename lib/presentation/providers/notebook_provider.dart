import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/datasources/gemini_api_datasource.dart';
import '../../data/repositories_impl/notebook_repository_impl.dart';

class NotebookState {
  final List<Notebook> notebooks;
  final Notebook? activeNotebook;
  final int activePageIndex;
  final bool isLoading;
  final String searchQuery;

  NotebookState({
    required this.notebooks,
    this.activeNotebook,
    this.activePageIndex = 0,
    this.isLoading = false,
    this.searchQuery = '',
  });

  NotebookState copyWith({
    List<Notebook>? notebooks,
    Notebook? activeNotebook,
    int? activePageIndex,
    bool? isLoading,
    String? searchQuery,
  }) {
    return NotebookState(
      notebooks: notebooks ?? this.notebooks,
      activeNotebook: activeNotebook ?? this.activeNotebook,
      activePageIndex: activePageIndex ?? this.activePageIndex,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NotebookNotifier extends StateNotifier<NotebookState> {
  final NotebookRepositoryImpl repository;
  static const _uuid = Uuid();

  NotebookNotifier(this.repository) : super(NotebookState(notebooks: [])) {
    loadAllNotebooks();
  }

  Future<void> loadAllNotebooks() async {
    state = state.copyWith(isLoading: true);
    final list = await repository.getNotebooks();
    state = state.copyWith(
      notebooks: list,
      activeNotebook: list.isNotEmpty ? list.first : null,
      activePageIndex: 0,
      isLoading: false,
    );
  }

  void selectNotebook(Notebook notebook) {
    state = state.copyWith(
      activeNotebook: notebook,
      activePageIndex: 0,
    );
  }

  void setPageIndex(int index) {
    if (state.activeNotebook == null) return;
    if (index >= 0 && index < state.activeNotebook!.pages.length) {
      state = state.copyWith(activePageIndex: index);
    }
  }

  Future<void> createNewNotebook(String title, String folder, int coverColor) async {
    final newNb = Notebook(
      id: _uuid.v4(),
      title: title,
      categoryFolder: folder,
      coverColorValue: coverColor,
    );
    await repository.saveNotebook(newNb);
    await loadAllNotebooks();
    selectNotebook(newNb);
  }

  Future<void> addPageToActiveNotebook() async {
    if (state.activeNotebook == null) return;
    final current = state.activeNotebook!;
    final newPageIndex = current.pages.length;
    final newPage = NotebookPage(
      id: '${current.id}_page_${newPageIndex + 1}',
      pageIndex: newPageIndex,
      paperStyle: current.pages.last.paperStyle,
    );

    final updatedPages = [...current.pages, newPage];
    final updatedNb = current.copyWith(pages: updatedPages);

    await repository.saveNotebook(updatedNb);
    state = state.copyWith(
      activeNotebook: updatedNb,
      activePageIndex: newPageIndex,
    );
  }

  Future<void> saveCurrentPageStrokes(NotebookPage updatedPage) async {
    if (state.activeNotebook == null) return;
    final current = state.activeNotebook!;
    final updatedPages = List<NotebookPage>.from(current.pages);
    updatedPages[state.activePageIndex] = updatedPage;

    final updatedNb = current.copyWith(pages: updatedPages);
    await repository.saveNotebook(updatedNb);

    // Update in local state
    final updatedList = state.notebooks.map((nb) => nb.id == updatedNb.id ? updatedNb : nb).toList();
    state = state.copyWith(
      notebooks: updatedList,
      activeNotebook: updatedNb,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final localStorageDatasourceProvider = Provider((ref) => LocalStorageDatasource());
final firebaseDatasourceProvider = Provider((ref) => FirebaseDatasource());
final geminiDatasourceProvider = Provider((ref) => GeminiApiDatasource());

final notebookRepositoryProvider = Provider((ref) {
  return NotebookRepositoryImpl(
    localStorage: ref.watch(localStorageDatasourceProvider),
    firebaseDatasource: ref.watch(firebaseDatasourceProvider),
    geminiDatasource: ref.watch(geminiDatasourceProvider),
  );
});

final notebookProvider = StateNotifierProvider<NotebookNotifier, NotebookState>((ref) {
  final repo = ref.watch(notebookRepositoryProvider);
  return NotebookNotifier(repo);
});
