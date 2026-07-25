import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';
import '../../domain/entities/notebook.dart';

class FirebaseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncNotebookToCloud(String userId, Notebook notebook) async {
    final docRef = _firestore
        .collection(AppConfig.userProfilesCollection)
        .doc(userId)
        .collection(AppConfig.notebooksCollection)
        .doc(notebook.id);

    await docRef.set(notebook.toJson(), SetOptions(merge: true));
  }

  Future<List<Notebook>> fetchCloudNotebooks(String userId) async {
    final snapshot = await _firestore
        .collection(AppConfig.userProfilesCollection)
        .doc(userId)
        .collection(AppConfig.notebooksCollection)
        .get();

    return snapshot.docs.map((doc) => Notebook.fromJson(doc.data())).toList();
  }

  Future<void> deleteCloudNotebook(String userId, String notebookId) async {
    await _firestore
        .collection(AppConfig.userProfilesCollection)
        .doc(userId)
        .collection(AppConfig.notebooksCollection)
        .doc(notebookId)
        .delete();
  }
}
