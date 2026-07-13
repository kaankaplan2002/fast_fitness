import 'package:fast_fitness/features/exercises/data/datasource/exercise_remote_datasource.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';

class ExerciseRepository {
  final ExerciseRemoteDatasource _remoteDatasource;

  ExerciseRepository({
    required ExerciseRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  Stream<List<ExerciseModel>> getExercises() {
    return _remoteDatasource.getExercises();
  }

  Stream<List<ExerciseModel>> getExercisesByMuscleGroup(String muscleGroup) {
    return _remoteDatasource.getExercisesByMuscleGroup(muscleGroup);
  }

  Future<void> seedIfNeeded() async {
    await _remoteDatasource.seedIfNeeded();
  }
}