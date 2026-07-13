import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/profile/data/models/user_level_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class XpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserLevelModel> watchUserLevel() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(UserLevelModel.fromTotalXp(0));
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      final totalXp = data?['totalXp'] ?? 0;

      return UserLevelModel.fromTotalXp(totalXp);
    });
  }

  Future<void> addXp(int amount) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'totalXp': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  Future<void> addWorkoutCompletionXp() async {
    await addXp(100);
  }

  Future<void> addRatingXp() async {
    await addXp(20);
  }

  Future<void> addWeeklyChallengeXp() async {
    await addXp(150);
  }
}
