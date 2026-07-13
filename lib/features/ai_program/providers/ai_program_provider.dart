import 'package:fast_fitness/features/ai_program/data/models/generated_workout_model.dart';
import 'package:fast_fitness/features/ai_program/data/repository/ai_program_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiProgramRepositoryProvider = Provider<AiProgramRepository>((ref) {
  return AiProgramRepository();
});

final generatedWorkoutProvider =
    FutureProvider.family<GeneratedWorkoutModel, String>((
      ref,
      paramString,
    ) {
      final parts = paramString.split('|');
      final focus = parts[0];
      final duration = int.tryParse(parts[1]) ?? 35;
      final calories = int.tryParse(parts[2]) ?? 280;

      return ref
          .read(aiProgramRepositoryProvider)
          .generateWorkout(
            focus: focus,
            suggestedDuration: duration,
            suggestedCalories: calories,
          );
    });
