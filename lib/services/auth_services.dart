import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/services/user_firestore_service.dart';
import '../model/user_model.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
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
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }
}
