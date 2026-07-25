import '../entities/notebook.dart';

abstract class NotebookRepository {
  Future<List<Notebook>> getNotebooks();
  Future<Notebook?> getNotebookById(String id);
  Future<void> saveNotebook(Notebook notebook);
  Future<void> deleteNotebook(String id);
  Future<String> summarizeWithGemini(Notebook notebook);
}
