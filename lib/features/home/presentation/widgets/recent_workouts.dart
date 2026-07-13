import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_skeleton.dart';
import 'package:fast_fitness/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecentWorkouts extends ConsumerWidget {
  const RecentWorkouts({super.key});

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  String _readString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  String _formatDate(dynamic value) {
    final date = _readDate(value);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference > 1 && difference < 7) {
      return '$difference days ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isAiWorkout(Map<String, dynamic> workout) {
    final source = _readString(
      workout['source'],
      fallback: 'manual',
    ).toLowerCase();

    final title = _readString(
      workout['workoutTitle'],
      fallback: 'Workout',
    ).toLowerCase();

    return source == 'ai_generated' || title.startsWith('ai ');
  }

  Future<void> _openHistory(BuildContext context) async {
    await HapticService.selection();

    if (!context.mounted) return;

    context.push('/workout-history');
  }

  Future<void> _openWorkoutDetail(
    BuildContext context,
    Map<String, dynamic> workout,
  ) async {
    await HapticService.selection();

    if (!context.mounted) return;

    final completedAt = _readDate(workout['completedAt']);

    context.push(
      '/history-detail',
      extra: {
        'id': _readString(workout['id']),
        'workoutTitle': _readString(
          workout['workoutTitle'],
          fallback: 'Workout',
        ),
        'exerciseCount': _readInt(workout['exerciseCount']),
        'durationMinutes': _readInt(workout['durationMinutes']),
        'completedAt': completedAt.toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(recentCompletedWorkoutsProvider);

    return workoutsAsync.when(
      loading: () => const _RecentWorkoutsLoading(),
      error: (error, stackTrace) {
        return _RecentWorkoutsError(
          onRetry: () {
            ref.invalidate(recentCompletedWorkoutsProvider);
          },
        );
      },
      data: (workouts) {
        if (workouts.isEmpty) {
          return _RecentWorkoutsEmpty(
            onStartWorkout: () async {
              await HapticService.selection();

              if (!context.mounted) return;

              context.push(
                '/generated-workout',
                extra: const {
                  'focus': 'Full Body',
                  'duration': 35,
                  'calories': 280,
                },
              );
            },
          );
        }

        return Column(
          children: [
            ...workouts.asMap().entries.map((entry) {
              final index = entry.key;
              final workout = entry.value;

              final title = _readString(
                workout['workoutTitle'],
                fallback: 'Workout',
              );

              final duration = _readInt(workout['durationMinutes']);
              final exerciseCount = _readInt(workout['exerciseCount']);
              final calories = _readInt(
                workout['caloriesBurned'] ??
                    workout['calories'] ??
                    workout['estimatedCalories'],
              );

              final source = _isAiWorkout(workout)
                  ? 'AI Generated'
                  : 'Completed';

              final focus = _readString(workout['focus'], fallback: 'General');

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == workouts.length - 1 ? 0 : 14,
                ),
                child: _RecentWorkoutCard(
                  title: title,
                  duration: duration,
                  exerciseCount: exerciseCount,
                  calories: calories,
                  date: _formatDate(workout['completedAt']),
                  source: source,
                  focus: focus,
                  isAiWorkout: _isAiWorkout(workout),
                  onTap: () => _openWorkoutDetail(context, workout),
                ),
              );
            }),
            const SizedBox(height: 18),
            AppButton(
              text: 'View Workout History',
              icon: Icons.history_rounded,
              type: AppButtonType.secondary,
              onPressed: () => _openHistory(context),
            ),
          ],
        );
      },
    );
  }
}

class _RecentWorkoutCard extends StatelessWidget {
  final String title;
  final int duration;
  final int exerciseCount;
  final int calories;
  final String date;
  final String source;
  final String focus;
  final bool isAiWorkout;
  final VoidCallback onTap;

  const _RecentWorkoutCard({
    required this.title,
    required this.duration,
    required this.exerciseCount,
    required this.calories,
    required this.date,
    required this.source,
    required this.focus,
    required this.isAiWorkout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isAiWorkout ? AppTheme.primary : AppTheme.success;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          children: [
            Positioned(
              top: -48,
              right: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      isAiWorkout
                          ? Icons.auto_awesome_rounded
                          : Icons.check_circle_rounded,
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              date,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '$exerciseCount exercises • $duration min',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _WorkoutTag(
                              label: source,
                              icon: isAiWorkout
                                  ? Icons.auto_awesome_rounded
                                  : Icons.done_rounded,
                              color: accentColor,
                            ),
                            if (focus.toLowerCase() != 'general')
                              _WorkoutTag(
                                label: focus,
                                icon: Icons.track_changes_rounded,
                                color: AppTheme.primary,
                              ),
                            if (calories > 0)
                              _WorkoutTag(
                                label: '$calories kcal',
                                icon: Icons.local_fire_department_rounded,
                                color: AppTheme.warning,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
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

class _WorkoutTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _WorkoutTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentWorkoutsEmpty extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const _RecentWorkoutsEmpty({required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Workouts Yet',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your first workout and your latest activity will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          AppButton(
            text: 'Start a Workout',
            icon: Icons.play_arrow_rounded,
            onPressed: onStartWorkout,
          ),
        ],
      ),
    );
  }
}

class _RecentWorkoutsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _RecentWorkoutsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.error.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.error,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent workouts could not be loaded',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Try Again',
            icon: Icons.refresh_rounded,
            type: AppButtonType.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _RecentWorkoutsLoading extends StatelessWidget {
  const _RecentWorkoutsLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RecentWorkoutSkeleton(),
        SizedBox(height: 14),
        _RecentWorkoutSkeleton(),
        SizedBox(height: 14),
        _RecentWorkoutSkeleton(),
      ],
    );
  }
}

class _RecentWorkoutSkeleton extends StatelessWidget {
  const _RecentWorkoutSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(18),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Row(
        children: [
          AppSkeleton(width: 56, height: 56, radius: AppTheme.radiusMedium),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(width: 170, height: 16),
                SizedBox(height: 10),
                AppSkeletonLine(width: 130, height: 12),
                SizedBox(height: 12),
                AppSkeletonLine(width: 100, height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
