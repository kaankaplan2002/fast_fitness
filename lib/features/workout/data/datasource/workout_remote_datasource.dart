import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkoutRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> completeWorkout({
    required String workoutTitle,
    required int exerciseCount,
    required int durationMinutes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not found.');
    }

    await _firestore.collection('completed_workouts').add({
      'userId': user.uid,
      'workoutTitle': workoutTitle,
      'exerciseCount': exerciseCount,
      'durationMinutes': durationMinutes,
      'completedAt': Timestamp.now(),
    });

    await _firestore.collection('users').doc(user.uid).update({
      'streak': FieldValue.increment(1),
    });
  }
}