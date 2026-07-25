import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/notebook.dart';

class LocalStorageDatasource {
  static const String notebookBoxName = 'papercraft_notebooks';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(notebookBoxName)) {
      await Hive.openBox<String>(notebookBoxName);
    }
  }

  Box<String> get _box => Hive.box<String>(notebookBoxName);

  Future<List<Notebook>> getAllNotebooks() async {
    final List<Notebook> notebooks = [];
    for (var key in _box.keys) {
      final jsonStr = _box.get(key);
      if (jsonStr != null) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          notebooks.add(Notebook.fromJson(map));
        } catch (_) {}
      }
    }
    return notebooks;
  }

  Future<Notebook?> getNotebookById(String id) async {
    final jsonStr = _box.get(id);
    if (jsonStr == null) return null;
    return Notebook.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> saveNotebook(Notebook notebook) async {
    final jsonStr = jsonEncode(notebook.toJson());
    await _box.put(notebook.id, jsonStr);
  }

  Future<void> deleteNotebook(String id) async {
    await _box.delete(id);
  }
}
