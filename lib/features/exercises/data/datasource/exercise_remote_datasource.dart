import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/exercises/data/datasource/exercise_seed_datasource.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';

class ExerciseRemoteDatasource {
  final FirebaseFirestore _firestore;

  ExerciseRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> seedIfNeeded() async {
    try {
      final snapshot = await _firestore.collection('exercises').limit(50).get();
      if (snapshot.docs.length < 15) {
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        await ExerciseSeedDatasource(firestore: _firestore).seedExercises();
        return;
      }

      final categories = ['chest', 'back', 'legs', 'core'];
      final existingGroups = snapshot.docs
          .map((doc) => (doc.data()['muscleGroup'] as String?)?.toLowerCase())
          .whereType<String>()
          .toSet();

      bool needsSeed = false;
      for (final cat in categories) {
        if (!existingGroups.contains(cat)) {
          needsSeed = true;
          break;
        }
      }

      if (needsSeed) {
        await ExerciseSeedDatasource(firestore: _firestore).seedExercises();
      }
    } catch (e) {
      // Fail silently to prevent interrupting app startup
    }
  }

  Stream<List<ExerciseModel>> getExercises() {
    return _firestore
        .collection('exercises')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExerciseModel.fromMap(
          id: doc.id,
          map: doc.data(),
        );
      }).toList();
    });
  }

  Stream<List<ExerciseModel>> getExercisesByMuscleGroup(String muscleGroup) {
    return _firestore
        .collection('exercises')
        .where('muscleGroup', isEqualTo: muscleGroup)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExerciseModel.fromMap(
          id: doc.id,
          map: doc.data(),
        );
      }).toList();
    });
  }
}