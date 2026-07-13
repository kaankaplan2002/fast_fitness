import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/ai_program/data/models/generated_workout_model.dart';
import 'package:fast_fitness/features/ai_program/providers/ai_program_provider.dart';
import 'package:fast_fitness/features/ai_program/presentation/widgets/generated_exercise_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GeneratedWorkoutScreen extends ConsumerWidget {
  final String focus;
  final int duration;
  final int calories;

  const GeneratedWorkoutScreen({
    super.key,
    required this.focus,
    required this.duration,
    required this.calories,
  });

  List<Map<String, dynamic>> _exerciseMaps(GeneratedWorkoutModel workout) {
    return workout.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;

      return {
        'id': 'ai_generated_$index',
        'name': exercise.name,
        'muscleGroup': exercise.muscleGroup,
        'equipment': 'AI Generated',
        'difficulty': workout.difficulty,
        'sets': int.tryParse(exercise.sets) ?? 3,
        'reps': exercise.reps,
        'restSeconds': _restSecondsFromText(exercise.rest),
        'description': exercise.note,
        'gifUrl': '',
      };
    }).toList();
  }

  int _restSecondsFromText(String restText) {
    final numberText = restText.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numberText) ?? 60;
  }

  void _startWorkout(BuildContext context, GeneratedWorkoutModel workout) {
    context.push(
      '/workout-session',
      extra: {
        'title': workout.title,
        'exercises': _exerciseMaps(workout),
        'currentExerciseIndex': 0,
        'completedSets': 0,
        'elapsedSeconds': 0,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedWorkout = ref.watch(
      generatedWorkoutProvider('$focus|$duration|$calories'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generated Workout'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: generatedWorkout.when(
          loading: () => const _GeneratingWorkoutView(),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Workout could not be generated.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (workout) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        workout.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${workout.focus} • ${workout.difficulty}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _HeaderStat(
                            title: 'Time',
                            value: '${workout.estimatedMinutes}m',
                            icon: Icons.timer_rounded,
                          ),
                          const SizedBox(width: 10),
                          _HeaderStat(
                            title: 'Kcal',
                            value: '${workout.estimatedCalories}',
                            icon: Icons.local_fire_department_rounded,
                          ),
                          const SizedBox(width: 10),
                          _HeaderStat(
                            title: 'Moves',
                            value: '${workout.exercises.length}',
                            icon: Icons.fitness_center_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Generated Exercises',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  workout.exercises.length,
                  (index) => GeneratedExerciseTile(
                    index: index,
                    exercise: workout.exercises[index],
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _startWorkout(context, workout),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Start This Workout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GeneratingWorkoutView extends StatelessWidget {
  const _GeneratingWorkoutView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 24),
            Text(
              'Generating your workout...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Text(
              'Analyzing your progress and creating a smart training plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HeaderStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
