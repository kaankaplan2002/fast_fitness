import 'package:fast_fitness/core/widgets/app_page_transition.dart';
import 'package:fast_fitness/features/ai/data/models/ai_coach_model.dart';
import 'package:fast_fitness/features/ai/presentation/screens/ai_coach_detail_screen.dart';
import 'package:fast_fitness/features/ai_program/presentation/screens/generated_workout_screen.dart';
import 'package:fast_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:fast_fitness/features/auth/presentation/screens/login_screen.dart';
import 'package:fast_fitness/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:fast_fitness/features/auth/presentation/screens/register_screen.dart';
import 'package:fast_fitness/features/auth/presentation/screens/splash_screen.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:fast_fitness/features/history/data/models/workout_history_model.dart';
import 'package:fast_fitness/features/history/presentation/screens/workout_history_detail_screen.dart';
import 'package:fast_fitness/features/main/presentation/screens/main_shell_screen.dart';
import 'package:fast_fitness/features/missions/presentation/screen/daily_missions_screen.dart';
import 'package:fast_fitness/features/nutrition/presentation/screen/add_nutrition_entry_screen.dart';
import 'package:fast_fitness/features/nutrition/presentation/screen/edit_nutrition_goal_screen.dart';
import 'package:fast_fitness/features/nutrition/presentation/screen/nutrition_screen.dart';
import 'package:fast_fitness/features/personal_records/presentation/screens/personal_records_screen.dart';
import 'package:fast_fitness/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:fast_fitness/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:fast_fitness/features/profile/presentation/screens/settings_screen.dart';
import 'package:fast_fitness/features/workout/presentation/screens/workout_detail_screen.dart';
import 'package:fast_fitness/features/workout/presentation/screens/workout_history_screen.dart'
    as old_workout_history;
import 'package:fast_fitness/features/workout/presentation/screens/workout_session_screen.dart';
import 'package:fast_fitness/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/profile-setup',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const ProfileSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const SettingsScreen()),
    ),
    GoRoute(
      path: '/personal-records',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const PersonalRecordsScreen(),
      ),
    ),
    GoRoute(
      path: '/daily-missions',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const DailyMissionsScreen(),
      ),
    ),
    GoRoute(
      path: '/nutrition',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const NutritionScreen()),
    ),
    GoRoute(
      path: '/add-nutrition-entry',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const AddNutritionEntryScreen(),
      ),
    ),
    GoRoute(
      path: '/edit-nutrition-goal',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const EditNutritionGoalScreen(),
      ),
    ),

    GoRoute(
      path: '/ai-coach-detail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final coach = AiCoachModel(
          title: extra?['title'] ?? 'Today’s AI Coach',
          message: extra?['message'] ?? 'No coaching message available.',
          recommendation:
              extra?['recommendation'] ?? 'Complete a workout today.',
          weeklyWorkouts: extra?['weeklyWorkouts'] ?? 0,
          totalWorkouts: extra?['totalWorkouts'] ?? 0,
          currentStreak: extra?['currentStreak'] ?? 0,
          suggestedDuration: extra?['suggestedDuration'] ?? 30,
          suggestedCalories: extra?['suggestedCalories'] ?? 240,
          suggestedFocus: extra?['suggestedFocus'] ?? 'Full Body',
        );

        return AppPageTransition(
          key: state.pageKey,
          child: AiCoachDetailScreen(coach: coach),
        );
      },
    ),

    GoRoute(
      path: '/generated-workout',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AppPageTransition(
          key: state.pageKey,
          child: GeneratedWorkoutScreen(
            focus: extra?['focus'] ?? 'Full Body',
            duration: extra?['duration'] ?? 35,
            calories: extra?['calories'] ?? 280,
          ),
        );
      },
    ),

    GoRoute(
      path: '/workout-history',
      pageBuilder: (context, state) => AppPageTransition(
        key: state.pageKey,
        child: const old_workout_history.WorkoutHistoryScreen(),
      ),
    ),

    GoRoute(
      path: '/history-detail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final completedAtText = extra?['completedAt'] as String?;
        final completedAt = completedAtText == null
            ? DateTime.now()
            : DateTime.tryParse(completedAtText) ?? DateTime.now();

        final workout = WorkoutHistoryModel(
          id: extra?['id'] ?? '',
          workoutTitle: extra?['workoutTitle'] ?? 'Workout',
          exerciseCount: extra?['exerciseCount'] ?? 0,
          durationMinutes: extra?['durationMinutes'] ?? 0,
          completedAt: completedAt,
        );

        return AppPageTransition(
          key: state.pageKey,
          child: WorkoutHistoryDetailScreen(workout: workout),
        );
      },
    ),

    GoRoute(
      path: '/exercise-detail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AppPageTransition(
          key: state.pageKey,
          child: ExerciseDetailScreen(
            name: extra?['name'] ?? 'Exercise',
            muscleGroup: extra?['muscleGroup'] ?? 'Muscle',
            equipment: extra?['equipment'] ?? 'Equipment',
            difficulty: extra?['difficulty'] ?? 'Beginner',
            sets: extra?['sets'] ?? 3,
            reps: extra?['reps'] ?? '12',
            restSeconds: extra?['restSeconds'] ?? 60,
            description: extra?['description'] ?? '',
            gifUrl: extra?['gifUrl'] ?? '',
          ),
        );
      },
    ),

    GoRoute(
      path: '/workout-detail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final rawExercises = extra?['exercises'] as List<dynamic>? ?? [];

        final exercises = rawExercises.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return ExerciseModel.fromMap(id: map['id'] ?? '', map: map);
        }).toList();

        return AppPageTransition(
          key: state.pageKey,
          child: WorkoutDetailScreen(
            title: extra?['title'] ?? 'Workout Plan',
            subtitle: extra?['subtitle'] ?? 'Personalized workout plan',
            duration: extra?['duration'] ?? '45 min',
            exercises: exercises,
          ),
        );
      },
    ),

    GoRoute(
      path: '/workout-session',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final rawExercises = extra?['exercises'] as List<dynamic>? ?? [];

        final exercises = rawExercises.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return ExerciseModel.fromMap(id: map['id'] ?? '', map: map);
        }).toList();

        return AppPageTransition(
          key: state.pageKey,
          child: WorkoutSessionScreen(
            title: extra?['title'] ?? 'Workout Session',
            exercises: exercises,
            initialExerciseIndex: extra?['currentExerciseIndex'] ?? 0,
            initialCompletedSets: extra?['completedSets'] ?? 0,
            initialElapsedSeconds: extra?['elapsedSeconds'] ?? 0,
            source: extra?['source'] ?? 'manual',
            focus: extra?['focus'] ?? 'General',
          ),
        );
      },
    ),

    GoRoute(
      path: '/workout-summary',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AppPageTransition(
          key: state.pageKey,
          child: WorkoutSummaryScreen(
            title: extra?['title'] ?? 'Workout',
            exerciseCount: extra?['exerciseCount'] ?? 0,
            durationMinutes: extra?['durationMinutes'] ?? 0,
            caloriesBurned: extra?['caloriesBurned'] ?? 0,
            source: extra?['source'] ?? 'manual',
            focus: extra?['focus'] ?? 'General',
          ),
        );
      },
    ),

    GoRoute(
      path: '/home',
      pageBuilder: (context, state) =>
          AppPageTransition(key: state.pageKey, child: const MainShellScreen()),
    ),
  ],
);
