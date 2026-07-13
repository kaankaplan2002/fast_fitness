import 'package:fast_fitness/features/ai_program/data/models/generated_exercise_model.dart';

class GeneratedWorkoutModel {
  final String title;
  final String focus;
  final int estimatedMinutes;
  final int estimatedCalories;
  final String difficulty;
  final List<GeneratedExerciseModel> exercises;

  const GeneratedWorkoutModel({
    required this.title,
    required this.focus,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.difficulty,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'focus': focus,
      'estimatedMinutes': estimatedMinutes,
      'estimatedCalories': estimatedCalories,
      'difficulty': difficulty,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory GeneratedWorkoutModel.fromMap(Map<String, dynamic> map) {
    final exercisesList = map['exercises'] as List? ?? [];
    return GeneratedWorkoutModel(
      title: map['title'] ?? 'AI Workout Plan',
      focus: map['focus'] ?? 'Full Body',
      estimatedMinutes: (map['estimatedMinutes'] ?? map['estimatedMinutes'] ?? 30) as int,
      estimatedCalories: (map['estimatedCalories'] ?? map['estimatedCalories'] ?? 240) as int,
      difficulty: map['difficulty'] ?? 'Intermediate',
      exercises: exercisesList
          .map((item) => GeneratedExerciseModel.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
