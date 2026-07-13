import 'package:fast_fitness/features/exercises/data/datasource/exercise_remote_datasource.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/exercises/data/repositories/exercise_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exerciseRemoteDatasourceProvider =
    Provider<ExerciseRemoteDatasource>((ref) {
  return ExerciseRemoteDatasource();
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(
    remoteDatasource: ref.watch(exerciseRemoteDatasourceProvider),
  );
});

final exercisesProvider = StreamProvider<List<ExerciseModel>>((ref) {
  ref.read(exerciseRepositoryProvider).seedIfNeeded();
  return ref.watch(exerciseRepositoryProvider).getExercises();
});

final selectedMuscleGroupProvider =
    NotifierProvider<SelectedMuscleGroupNotifier, String>(
  SelectedMuscleGroupNotifier.new,
);

class SelectedMuscleGroupNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Chest';
  }

  void selectMuscleGroup(String muscleGroup) {
    state = muscleGroup;
  }
}