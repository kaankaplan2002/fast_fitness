import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/history/data/models/workout_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<WorkoutHistoryModel>> watchWorkoutHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final workouts = snapshot.docs
              .map((doc) => WorkoutHistoryModel.fromFirestore(doc))
              .toList();

          workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

          return workouts;
        });
  }
}
