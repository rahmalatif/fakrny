import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class UserFirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await firestore.collection('users').doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateStreak({
    required String uid,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastCompletedDate,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': Timestamp.fromDate(
        lastCompletedDate,
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBirthday({
    required String uid,
    required int month,
    required int day,
  }) async {
    await firestore.collection('users').doc(uid).set(
      {
        'birthdayMonth': month,
        'birthdayDay': day,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
  Future<void> updateVoiceGender({
    required String uid,
    required String voiceGender,
  }) async {
    await firestore.collection('users').doc(uid).set(
      {
        'voiceGender': voiceGender,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
  Future<String> getVoiceGender(String uid) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();

    final voiceGender =
    data?['voiceGender'] as String?;

    return voiceGender == 'male'
        ? 'male'
        : 'female';
  }
}
