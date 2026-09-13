import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/tasks.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  Stream<List<TaskModel>> getTasks() {
    return _tasksCollection.orderBy('scheduledAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': Timestamp.now(),
    });
  }
}
