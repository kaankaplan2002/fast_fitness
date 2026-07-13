import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/auth/data/models/app_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User could not be created.',
      );
    }

    await user.updateDisplayName(name.trim());

    final appUser = AppUserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      height: null,
      weight: null,
      goal: null,
      profileCompleted: false,
      streak: 0,
      dailyCalories: 2400,
      createdAt: Timestamp.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

    return credential;
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> logout() {
    return _auth.signOut();
  }
}