import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/tasks.dart';

class TaskFirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<String> addTask({required String uid, required TaskModel task}) async {
    final doc = _tasksCollection(uid).doc();

    await doc.set({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<List<TaskModel>> getTasks(String uid) async {
    final snapshot = await _tasksCollection(uid).orderBy('scheduledAt').get();

    return snapshot.docs.map((doc) {
      return TaskModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> updateTask({
    required String uid,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    await _tasksCollection(
      uid,
    ).doc(taskId).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    await _tasksCollection(uid).doc(taskId).delete();
  }

  Future<TaskModel?> getTask({
    required String uid,
    required String taskId,
  }) async {
    final doc = await _tasksCollection(uid).doc(taskId).get();

    if (!doc.exists) {
      return null;
    }

    return TaskModel.fromMap(doc.id, doc.data()!);
  }
}
