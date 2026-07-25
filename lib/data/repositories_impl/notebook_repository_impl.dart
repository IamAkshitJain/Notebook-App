import '../../domain/entities/notebook.dart';
import '../../domain/repositories/notebook_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../datasources/firebase_datasource.dart';
import '../datasources/gemini_api_datasource.dart';

class NotebookRepositoryImpl implements NotebookRepository {
  final LocalStorageDatasource localStorage;
  final FirebaseDatasource firebaseDatasource;
  final GeminiApiDatasource geminiDatasource;

  NotebookRepositoryImpl({
    required this.localStorage,
    required this.firebaseDatasource,
    required this.geminiDatasource,
  });

  @override
  Future<List<Notebook>> getNotebooks() async {
    final localList = await localStorage.getAllNotebooks();
    if (localList.isEmpty) {
      // Create initial sample notebook
      final defaultNotebook = Notebook(
        id: 'nb_default_01',
        title: 'Physics & Quantum Mechanics',
        categoryFolder: 'Science',
        coverColorValue: 0xFF6C5CE7,
      );
      await localStorage.saveNotebook(defaultNotebook);
      return [defaultNotebook];
    }
    return localList;
  }

  @override
  Future<Notebook?> getNotebookById(String id) async {
    return await localStorage.getNotebookById(id);
  }

  @override
  Future<void> saveNotebook(Notebook notebook) async {
    await localStorage.saveNotebook(notebook);
  }

  @override
  Future<void> deleteNotebook(String id) async {
    await localStorage.deleteNotebook(id);
  }

  @override
  Future<String> summarizeWithGemini(Notebook notebook) async {
    return await geminiDatasource.summarizeNotebook(notebook);
  }
}
