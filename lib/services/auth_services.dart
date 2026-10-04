import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/services/user_firestore_service.dart';

import '../model/user_model.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String birthdayScope =
      'https://www.googleapis.com/auth/user.birthday.read';

  User? get currentUser => firebaseAuth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        photoUrl: null,
        language: 'en',
        createdAt: null,
        updatedAt: null,
      );

      await UserFirestoreService().createUser(userModel);
    }

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<Map<String, int>?> getGoogleBirthday(
      GoogleSignInAccount googleUser,
      ) async {
    try {
      final GoogleSignInClientAuthorization authorization =
      await googleUser.authorizationClient.authorizeScopes(
        [birthdayScope],
      );

      final response = await http.get(
        Uri.parse(
          'https://people.googleapis.com/v1/people/me?personFields=birthdays',
        ),
        headers: {
          'Authorization': 'Bearer ${authorization.accessToken}',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data =
      jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic>? birthdays = data['birthdays'] as List<dynamic>?;

      if (birthdays == null || birthdays.isEmpty) {
        return null;
      }

      for (final birthday in birthdays) {
        final Map<String, dynamic>? date =
        birthday['date'] as Map<String, dynamic>?;

        if (date == null) {
          continue;
        }

        final int? month = date['month'] as int?;
        final int? day = date['day'] as int?;

        if (month != null && day != null && month > 0 && day > 0) {
          return {
            'month': month,
            'day': day,
          };
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        final birthday = await getGoogleBirthday(googleUser);
        if (birthday != null) {
          await UserFirestoreService().updateBirthday(
            uid: user.uid,
            month: birthday['month']!,
            day: birthday['day']!,
          );
        }
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          language: 'en',
          createdAt: null,
          updatedAt: null,
        );

        await UserFirestoreService().createUser(userModel);

        if (birthday != null) {
          await firestore.collection('users').doc(user.uid).set(
            {
              'birthdayMonth': birthday['month'],
              'birthdayDay': birthday['day'],
            },
            SetOptions(merge: true),
          );
        }
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }
}