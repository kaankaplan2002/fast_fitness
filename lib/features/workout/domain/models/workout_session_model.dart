import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';

class WorkoutSessionModel {
  final String title;
  final List<ExerciseModel> exercises;
  final int currentExerciseIndex;
  final int completedSets;
  final int elapsedSeconds;

  const WorkoutSessionModel({
    required this.title,
    required this.exercises,
    required this.currentExerciseIndex,
    required this.completedSets,
    required this.elapsedSeconds,
  });
}
