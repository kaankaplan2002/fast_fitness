import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/workout/data/models/workout_rating_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutRatingRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkoutRatingRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  Future<void> saveRating(WorkoutRatingModel rating) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not found.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workout_ratings')
        .add(rating.toMap());
  }
}
