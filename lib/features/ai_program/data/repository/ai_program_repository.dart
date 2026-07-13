import 'dart:convert';
import 'package:fast_fitness/features/ai_program/data/models/generated_exercise_model.dart';
import 'package:fast_fitness/features/ai_program/data/models/generated_workout_model.dart';
import 'package:fast_fitness/features/profile/data/services/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiProgramRepository {
  Future<GeneratedWorkoutModel> generateWorkout({
    required String focus,
    required int suggestedDuration,
    required int suggestedCalories,
  }) async {
    final settingsService = SettingsService();
    final apiKey = await settingsService.getGeminiApiKey();

    if (apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey',
        );

        final prompt = '''
You are a highly qualified personal fitness trainer.
Generate a custom workout program in JSON format matching the schema:
{
  "title": "string (e.g. 'Dynamic Chest Burn' or 'Advanced Back builder')",
  "focus": "string (e.g. 'Chest', 'Back', 'Legs', 'Full Body')",
  "estimatedMinutes": $suggestedDuration,
  "estimatedCalories": $suggestedCalories,
  "difficulty": "string (e.g. 'Beginner', 'Intermediate', 'Advanced')",
  "exercises": [
    {
      "name": "string (e.g. 'Flat Dumbbell Press')",
      "muscleGroup": "string (e.g. 'Chest')",
      "sets": "string (e.g. '4')",
      "reps": "string (e.g. '12' or '10-12')",
      "rest": "string (e.g. '60 sec' or '90 sec')",
      "note": "string (e.g. 'Focus on full stretch and slow eccentric phase')"
    }
  ]
}

Focus area: $focus
Target duration: $suggestedDuration minutes
Target calories to burn: $suggestedCalories kcal
Number of exercises: between 4 and 6 exercises.
Output ONLY valid JSON. No markdown formatting, no backticks, no explanations.
''';

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'responseMimeType': 'application/json',
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          final workoutJson = jsonDecode(text.trim());
          return GeneratedWorkoutModel.fromMap(workoutJson);
        } else {
          debugPrint('Gemini API returned status code: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Gemini workout generation failed, using fallback: $e');
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    final normalizedFocus = focus.toLowerCase();

    if (normalizedFocus.contains('back')) {
      return _backWorkout(suggestedDuration, suggestedCalories);
    }

    if (normalizedFocus.contains('chest')) {
      return _chestWorkout(suggestedDuration, suggestedCalories);
    }

    if (normalizedFocus.contains('leg')) {
      return _legsWorkout(suggestedDuration, suggestedCalories);
    }

    if (normalizedFocus.contains('shoulder')) {
      return _shoulderWorkout(suggestedDuration, suggestedCalories);
    }

    if (normalizedFocus.contains('core')) {
      return _coreWorkout(suggestedDuration, suggestedCalories);
    }

    if (normalizedFocus.contains('cardio')) {
      return _cardioWorkout(suggestedDuration, suggestedCalories);
    }

    return _fullBodyWorkout(suggestedDuration, suggestedCalories);
  }

  GeneratedWorkoutModel _backWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Back Workout',
      focus: 'Back',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Intermediate',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Lat Pulldown',
          muscleGroup: 'Back',
          sets: '4',
          reps: '12',
          rest: '75 sec',
          note: 'Control the movement and squeeze your lats.',
        ),
        GeneratedExerciseModel(
          name: 'Seated Cable Row',
          muscleGroup: 'Back',
          sets: '4',
          reps: '10',
          rest: '75 sec',
          note: 'Keep your chest up and pull elbows back.',
        ),
        GeneratedExerciseModel(
          name: 'Single Arm Dumbbell Row',
          muscleGroup: 'Back',
          sets: '3',
          reps: '12 each',
          rest: '60 sec',
          note: 'Focus on full range of motion.',
        ),
        GeneratedExerciseModel(
          name: 'Face Pull',
          muscleGroup: 'Rear Delts',
          sets: '3',
          reps: '15',
          rest: '45 sec',
          note: 'Great for posture and shoulder health.',
        ),
        GeneratedExerciseModel(
          name: 'Hammer Curl',
          muscleGroup: 'Biceps',
          sets: '3',
          reps: '12',
          rest: '60 sec',
          note: 'Finish with controlled arm work.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _chestWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Chest Workout',
      focus: 'Chest',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Intermediate',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Bench Press',
          muscleGroup: 'Chest',
          sets: '4',
          reps: '8-10',
          rest: '90 sec',
          note: 'Use a challenging but controlled weight.',
        ),
        GeneratedExerciseModel(
          name: 'Incline Dumbbell Press',
          muscleGroup: 'Upper Chest',
          sets: '4',
          reps: '10',
          rest: '75 sec',
          note: 'Control the negative phase.',
        ),
        GeneratedExerciseModel(
          name: 'Cable Fly',
          muscleGroup: 'Chest',
          sets: '3',
          reps: '12-15',
          rest: '60 sec',
          note: 'Squeeze at the center.',
        ),
        GeneratedExerciseModel(
          name: 'Push Up',
          muscleGroup: 'Chest',
          sets: '3',
          reps: 'AMRAP',
          rest: '60 sec',
          note: 'Finish strong with bodyweight work.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _legsWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Legs Workout',
      focus: 'Legs',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Intermediate',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Squat',
          muscleGroup: 'Legs',
          sets: '4',
          reps: '8-10',
          rest: '90 sec',
          note: 'Keep your core tight and depth controlled.',
        ),
        GeneratedExerciseModel(
          name: 'Leg Press',
          muscleGroup: 'Quads',
          sets: '4',
          reps: '12',
          rest: '75 sec',
          note: 'Do not lock your knees at the top.',
        ),
        GeneratedExerciseModel(
          name: 'Romanian Deadlift',
          muscleGroup: 'Hamstrings',
          sets: '3',
          reps: '10',
          rest: '75 sec',
          note: 'Hinge from the hips.',
        ),
        GeneratedExerciseModel(
          name: 'Standing Calf Raise',
          muscleGroup: 'Calves',
          sets: '4',
          reps: '15',
          rest: '45 sec',
          note: 'Pause at the top.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _shoulderWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Shoulder Workout',
      focus: 'Shoulders',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Intermediate',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Overhead Press',
          muscleGroup: 'Shoulders',
          sets: '4',
          reps: '8-10',
          rest: '90 sec',
          note: 'Brace your core before pressing.',
        ),
        GeneratedExerciseModel(
          name: 'Lateral Raise',
          muscleGroup: 'Side Delts',
          sets: '4',
          reps: '12-15',
          rest: '45 sec',
          note: 'Use controlled form, not momentum.',
        ),
        GeneratedExerciseModel(
          name: 'Rear Delt Fly',
          muscleGroup: 'Rear Delts',
          sets: '3',
          reps: '15',
          rest: '45 sec',
          note: 'Focus on shoulder blade movement.',
        ),
        GeneratedExerciseModel(
          name: 'Dumbbell Shrug',
          muscleGroup: 'Traps',
          sets: '3',
          reps: '12',
          rest: '60 sec',
          note: 'Pause briefly at the top.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _coreWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Core Workout',
      focus: 'Core',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Beginner',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Plank',
          muscleGroup: 'Core',
          sets: '3',
          reps: '45 sec',
          rest: '45 sec',
          note: 'Keep hips stable.',
        ),
        GeneratedExerciseModel(
          name: 'Crunch',
          muscleGroup: 'Abs',
          sets: '3',
          reps: '15',
          rest: '45 sec',
          note: 'Avoid pulling your neck.',
        ),
        GeneratedExerciseModel(
          name: 'Russian Twist',
          muscleGroup: 'Obliques',
          sets: '3',
          reps: '20',
          rest: '45 sec',
          note: 'Rotate with control.',
        ),
        GeneratedExerciseModel(
          name: 'Leg Raise',
          muscleGroup: 'Lower Abs',
          sets: '3',
          reps: '12',
          rest: '45 sec',
          note: 'Keep lower back stable.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _cardioWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Cardio Workout',
      focus: 'Cardio',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Beginner',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Incline Walk',
          muscleGroup: 'Cardio',
          sets: '1',
          reps: '15 min',
          rest: '0 sec',
          note: 'Keep a steady pace.',
        ),
        GeneratedExerciseModel(
          name: 'Bike Intervals',
          muscleGroup: 'Cardio',
          sets: '8',
          reps: '30 sec fast / 60 sec easy',
          rest: '60 sec',
          note: 'Push hard during fast intervals.',
        ),
        GeneratedExerciseModel(
          name: 'Cooldown Walk',
          muscleGroup: 'Cardio',
          sets: '1',
          reps: '5 min',
          rest: '0 sec',
          note: 'Lower your heart rate gradually.',
        ),
      ],
    );
  }

  GeneratedWorkoutModel _fullBodyWorkout(int minutes, int calories) {
    return GeneratedWorkoutModel(
      title: 'AI Full Body Workout',
      focus: 'Full Body',
      estimatedMinutes: minutes,
      estimatedCalories: calories,
      difficulty: 'Beginner',
      exercises: const [
        GeneratedExerciseModel(
          name: 'Goblet Squat',
          muscleGroup: 'Legs',
          sets: '3',
          reps: '12',
          rest: '60 sec',
          note: 'Control the movement.',
        ),
        GeneratedExerciseModel(
          name: 'Dumbbell Bench Press',
          muscleGroup: 'Chest',
          sets: '3',
          reps: '10',
          rest: '60 sec',
          note: 'Keep shoulders stable.',
        ),
        GeneratedExerciseModel(
          name: 'Lat Pulldown',
          muscleGroup: 'Back',
          sets: '3',
          reps: '12',
          rest: '60 sec',
          note: 'Pull elbows down.',
        ),
        GeneratedExerciseModel(
          name: 'Shoulder Press',
          muscleGroup: 'Shoulders',
          sets: '3',
          reps: '10',
          rest: '60 sec',
          note: 'Press with control.',
        ),
        GeneratedExerciseModel(
          name: 'Plank',
          muscleGroup: 'Core',
          sets: '3',
          reps: '30 sec',
          rest: '45 sec',
          note: 'Keep your body straight.',
        ),
      ],
    );
  }
}
