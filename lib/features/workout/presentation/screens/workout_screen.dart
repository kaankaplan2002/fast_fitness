import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/dialog/app_dialog.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_loading_indicator.dart';
import 'package:fast_fitness/core/widgets/app_safe_scroll_view.dart';
import 'package:fast_fitness/core/widgets/app_section_title.dart';
import 'package:fast_fitness/core/widgets/empty_state.dart';
import 'package:fast_fitness/core/widgets/error_state.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/exercises/presentation/providers/exercise_provider.dart';
import 'package:fast_fitness/features/workout/data/local/workout_session_storage.dart';
import 'package:fast_fitness/features/workout/domain/models/workout_session_model.dart';
import 'package:fast_fitness/features/workout/presentation/providers/workout_provider.dart';
import 'package:fast_fitness/features/workout/presentation/widgets/workout_category_card.dart';
import 'package:fast_fitness/features/workout/presentation/widgets/workout_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final WorkoutSessionStorage storage = WorkoutSessionStorage();

  late Future<WorkoutSessionModel?> sessionFuture;

  final List<_WorkoutCategory> categories = const [
    _WorkoutCategory(title: 'Chest', icon: Icons.accessibility_new_rounded),
    _WorkoutCategory(title: 'Back', icon: Icons.fitness_center_rounded),
    _WorkoutCategory(title: 'Legs', icon: Icons.directions_run_rounded),
    _WorkoutCategory(title: 'Core', icon: Icons.sports_gymnastics_rounded),
  ];

  @override
  void initState() {
    super.initState();
    sessionFuture = storage.getSession();
  }

  List<Map<String, dynamic>> _exerciseMaps(List<ExerciseModel> exercises) {
    return exercises.map((exercise) {
      final map = exercise.toMap();
      map['id'] = exercise.id;
      return map;
    }).toList();
  }

  void _refreshSession() {
    if (!mounted) return;

    setState(() {
      sessionFuture = storage.getSession();
    });
  }

  Future<void> _refreshWorkoutScreen() async {
    await HapticService.light();

    ref.invalidate(exercisesProvider);
    _refreshSession();
  }

  Future<void> _resumeWorkout(WorkoutSessionModel session) async {
    await HapticService.selection();

    if (!mounted) return;

    await context.push(
      '/workout-session',
      extra: {
        'title': session.title,
        'exercises': _exerciseMaps(session.exercises),
        'currentExerciseIndex': session.currentExerciseIndex,
        'completedSets': session.completedSets,
        'elapsedSeconds': session.elapsedSeconds,
        'source': 'manual',
        'focus': _inferFocusFromTitle(session.title),
      },
    );

    _refreshSession();
  }

  Future<void> _startOver(WorkoutSessionModel session) async {
    await HapticService.warning();

    if (!mounted) return;

    final shouldStartOver = await AppDialog.confirm(
      context,
      title: 'Start Over?',
      message:
          'Your saved progress for "${session.title}" will be permanently cleared.',
      confirmText: 'Start Over',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (!shouldStartOver) return;

    await _resetSession();
  }

  Future<void> _resetSession() async {
    try {
      ref.read(workoutLoadingProvider.notifier).setLoading(true);

      await storage.clearSession();

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Saved workout progress was cleared.',
        title: 'Workout Reset',
      );

      _refreshSession();
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Saved workout progress could not be cleared.',
        title: 'Reset Failed',
      );
    } finally {
      ref.read(workoutLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _selectCategory(String muscleGroup) async {
    await HapticService.selection();

    ref
        .read(selectedMuscleGroupProvider.notifier)
        .selectMuscleGroup(muscleGroup);
  }

  Future<void> _openWorkoutDetail({
    required String title,
    required String subtitle,
    required String duration,
    required String focus,
    required List<ExerciseModel> exercises,
  }) async {
    await HapticService.light();

    if (!mounted) return;

    await context.push(
      '/workout-detail',
      extra: {
        'title': title,
        'subtitle': subtitle,
        'duration': duration,
        'focus': focus,
        'exercises': _exerciseMaps(exercises),
      },
    );

    _refreshSession();
  }

  String _inferFocusFromTitle(String title) {
    final normalizedTitle = title.toLowerCase();

    if (normalizedTitle.contains('chest')) return 'Chest';
    if (normalizedTitle.contains('back')) return 'Back';
    if (normalizedTitle.contains('leg')) return 'Legs';
    if (normalizedTitle.contains('core')) return 'Core';
    if (normalizedTitle.contains('shoulder')) return 'Shoulders';
    if (normalizedTitle.contains('cardio')) return 'Cardio';

    return 'General';
  }

  int _estimateDuration(List<ExerciseModel> exercises) {
    if (exercises.isEmpty) return 0;

    int totalSeconds = 0;

    for (final exercise in exercises) {
      final sets = exercise.sets <= 0 ? 1 : exercise.sets;
      final restSeconds = exercise.restSeconds <= 0 ? 60 : exercise.restSeconds;

      const estimatedSetDurationSeconds = 45;

      totalSeconds += sets * estimatedSetDurationSeconds;
      totalSeconds += (sets - 1).clamp(0, sets) * restSeconds;
    }

    final estimatedMinutes = (totalSeconds / 60).ceil();

    if (estimatedMinutes < 15) return 15;
    if (estimatedMinutes > 90) return 90;

    return estimatedMinutes;
  }

  String _buildDifficulty(List<ExerciseModel> exercises) {
    if (exercises.isEmpty) return 'Beginner';

    final normalizedDifficulties = exercises
        .map((exercise) => exercise.difficulty.toLowerCase())
        .toList();

    final advancedCount = normalizedDifficulties
        .where((difficulty) => difficulty.contains('advanced'))
        .length;

    final intermediateCount = normalizedDifficulties
        .where((difficulty) => difficulty.contains('intermediate'))
        .length;

    if (advancedCount >= intermediateCount && advancedCount > 0) {
      return 'Advanced';
    }

    if (intermediateCount > 0) {
      return 'Intermediate';
    }

    return 'Beginner';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMuscle = ref.watch(selectedMuscleGroupProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _refreshWorkoutScreen,
      child: AppSafeScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _WorkoutHeroHeader(),
            const SizedBox(height: 24),

            FutureBuilder<WorkoutSessionModel?>(
              future: sessionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ContinueWorkoutLoading();
                }

                if (snapshot.hasError) {
                  return _ContinueWorkoutError(onRetry: _refreshSession);
                }

                final session = snapshot.data;

                if (session == null || session.exercises.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _ContinueWorkoutCard(
                    session: session,
                    onResume: () => _resumeWorkout(session),
                    onStartOver: () => _startOver(session),
                  ),
                );
              },
            ),

            const AppSectionTitle(
              title: 'Training Focus',
              subtitle: 'Choose the muscle group you want to train today',
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () => _selectCategory(category.title),
                    child: WorkoutCategoryCard(
                      title: category.title,
                      icon: category.icon,
                      isSelected: selectedMuscle == category.title,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            AppSectionTitle(
              title: 'Recommended Plan',
              subtitle: 'A personalized $selectedMuscle workout for today',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 18),

            exercisesAsync.when(
              loading: () => const _WorkoutPlanLoading(),
              error: (error, stackTrace) {
                return AppErrorState(
                  title: 'Workout plans could not be loaded',
                  message:
                      'We could not retrieve your exercises. Check your connection and try again.',
                  onRetry: () {
                    ref.invalidate(exercisesProvider);
                  },
                );
              },
              data: (allExercises) {
                final selectedExercises = allExercises
                    .where(
                      (exercise) =>
                          exercise.muscleGroup.toLowerCase() ==
                          selectedMuscle.toLowerCase(),
                    )
                    .toList();

                if (selectedExercises.isEmpty) {
                  return AppEmptyState(
                    title: 'No Plan Available',
                    message:
                        'There are no exercises available for $selectedMuscle yet. Try another training focus.',
                    icon: Icons.fitness_center_rounded,
                  );
                }

                final estimatedMinutes = _estimateDuration(selectedExercises);
                final difficulty = _buildDifficulty(selectedExercises);
                final planTitle = '$selectedMuscle Focus';
                final subtitle =
                    '${selectedExercises.length} exercises • $difficulty';
                final duration = '$estimatedMinutes min';

                return Column(
                  children: [
                    WorkoutPlanCard(
                      title: planTitle,
                      subtitle: subtitle,
                      duration: duration,
                      onTap: () => _openWorkoutDetail(
                        title: planTitle,
                        subtitle: subtitle,
                        duration: duration,
                        focus: selectedMuscle,
                        exercises: selectedExercises,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _WorkoutPlanSummary(
                      exerciseCount: selectedExercises.length,
                      durationMinutes: estimatedMinutes,
                      difficulty: difficulty,
                      muscleGroup: selectedMuscle,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHeroHeader extends StatelessWidget {
  const _WorkoutHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.98),
            AppTheme.primaryDark.withValues(alpha: 0.78),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -54,
            right: -46,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -58,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fitness_center_rounded, color: Colors.white, size: 44),
              SizedBox(height: 20),
              Text(
                'Train With Purpose',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose your focus, follow your plan, and make every session count.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.45,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(value: '4', label: 'Focus areas'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _HeroMetric(value: 'Smart', label: 'Workout plans'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueWorkoutCard extends StatelessWidget {
  final WorkoutSessionModel session;
  final VoidCallback onResume;
  final VoidCallback onStartOver;

  const _ContinueWorkoutCard({
    required this.session,
    required this.onResume,
    required this.onStartOver,
  });

  double get progress {
    if (session.exercises.isEmpty) return 0;

    return ((session.currentExerciseIndex + 1) / session.exercises.length)
        .clamp(0.0, 1.0);
  }

  String get formattedElapsedTime {
    final minutes = session.elapsedSeconds ~/ 60;
    final seconds = session.elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.09),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppTheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Continue Last Workout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.07),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SessionMetric(
                          icon: Icons.format_list_numbered_rounded,
                          value:
                              '${session.currentExerciseIndex + 1}/${session.exercises.length}',
                          label: 'Exercise',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SessionMetric(
                          icon: Icons.check_circle_outline_rounded,
                          value: '${session.completedSets}',
                          label: 'Sets completed',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SessionMetric(
                          icon: Icons.timer_outlined,
                          value: formattedElapsedTime,
                          label: 'Elapsed',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Resume',
                          icon: Icons.play_arrow_rounded,
                          onPressed: onResume,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Start Over',
                          icon: Icons.restart_alt_rounded,
                          type: AppButtonType.ghost,
                          onPressed: onStartOver,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SessionMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 19),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanSummary extends StatelessWidget {
  final int exerciseCount;
  final int durationMinutes;
  final String difficulty;
  final String muscleGroup;

  const _WorkoutPlanSummary({
    required this.exerciseCount,
    required this.durationMinutes,
    required this.difficulty,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlanMetric(
            title: 'Exercises',
            value: '$exerciseCount',
            icon: Icons.format_list_numbered_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlanMetric(
            title: 'Duration',
            value: '$durationMinutes min',
            icon: Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlanMetric(
            title: 'Level',
            value: difficulty,
            icon: Icons.signal_cellular_alt_rounded,
          ),
        ),
      ],
    );
  }
}

class _PlanMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _PlanMetric({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      borderRadius: AppTheme.radiusMedium,
      showShadow: false,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 21),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanLoading extends StatelessWidget {
  const _WorkoutPlanLoading();

  @override
  Widget build(BuildContext context) {
    return const AppLoadingIndicator(message: 'Preparing your workout plan...');
  }
}

class _ContinueWorkoutLoading extends StatelessWidget {
  const _ContinueWorkoutLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: AppLoadingIndicator(message: 'Checking saved workout...'),
    );
  }
}

class _ContinueWorkoutError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ContinueWorkoutError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        borderRadius: AppTheme.radiusLarge,
        showShadow: false,
        child: Column(
          children: [
            const Icon(
              Icons.sync_problem_rounded,
              color: AppTheme.warning,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'Saved workout could not be checked',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              type: AppButtonType.secondary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCategory {
  final String title;
  final IconData icon;

  const _WorkoutCategory({required this.title, required this.icon});
}
