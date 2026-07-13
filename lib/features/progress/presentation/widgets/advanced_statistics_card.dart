import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/progress/data/models/workout_statistics_model.dart';
import 'package:flutter/material.dart';

class AdvancedStatisticsCard extends StatelessWidget {
  final WorkoutStatisticsModel statistics;

  const AdvancedStatisticsCard({super.key, required this.statistics});

  int get weeklyWorkouts {
    return statistics.weeklyWorkouts < 0 ? 0 : statistics.weeklyWorkouts;
  }

  int get monthlyWorkouts {
    return statistics.monthlyWorkouts < 0 ? 0 : statistics.monthlyWorkouts;
  }

  int get averageWorkoutMinutes {
    return statistics.averageWorkoutMinutes < 0
        ? 0
        : statistics.averageWorkoutMinutes;
  }

  int get totalCalories {
    return statistics.totalCalories < 0 ? 0 : statistics.totalCalories;
  }

  String get favoriteMuscleGroup {
    final value = statistics.favoriteMuscleGroup.trim();

    if (value.isEmpty) {
      return 'No data';
    }

    return value;
  }

  String get lastWorkoutText {
    final value = statistics.lastWorkoutText.trim();

    if (value.isEmpty) {
      return 'No workout';
    }

    return value;
  }

  int get estimatedMonthlyGoal {
    return 20;
  }

  double get monthlyProgress {
    if (estimatedMonthlyGoal <= 0) {
      return 0;
    }

    return (monthlyWorkouts / estimatedMonthlyGoal).clamp(0.0, 1.0);
  }

  int get estimatedWeeklyGoal {
    return 5;
  }

  double get weeklyProgress {
    if (estimatedWeeklyGoal <= 0) {
      return 0;
    }

    return (weeklyWorkouts / estimatedWeeklyGoal).clamp(0.0, 1.0);
  }

  int get estimatedTrainingMinutes {
    return monthlyWorkouts * averageWorkoutMinutes;
  }

  String get formattedTrainingTime {
    final hours = estimatedTrainingMinutes ~/ 60;
    final minutes = estimatedTrainingMinutes % 60;

    if (estimatedTrainingMinutes <= 0) {
      return '0 min';
    }

    if (hours <= 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  String get summaryText {
    if (monthlyWorkouts == 0) {
      return 'Complete workouts to unlock advanced training statistics.';
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal) {
      return 'You have reached your weekly workout target.';
    }

    if (weeklyWorkouts >= 3) {
      return 'Your weekly training consistency is developing well.';
    }

    return 'Add another workout this week to strengthen your routine.';
  }

  String get performanceTitle {
    if (monthlyWorkouts == 0) {
      return 'Waiting for activity';
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal && averageWorkoutMinutes >= 40) {
      return 'Excellent training volume';
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal) {
      return 'Weekly goal achieved';
    }

    if (averageWorkoutMinutes >= 45) {
      return 'Strong session duration';
    }

    if (monthlyWorkouts >= 12) {
      return 'Consistent month';
    }

    return 'Progress in motion';
  }

  String get performanceMessage {
    if (monthlyWorkouts == 0) {
      return 'Your advanced insights will appear after completing your first '
          'workout.';
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal && averageWorkoutMinutes >= 40) {
      return 'You are combining strong weekly frequency with productive '
          'session duration. Keep recovery and sleep consistent.';
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal) {
      return 'You completed $weeklyWorkouts workouts this week. Maintain this '
          'rhythm without sacrificing exercise quality.';
    }

    if (averageWorkoutMinutes >= 45) {
      return 'Your average workout lasts $averageWorkoutMinutes minutes. '
          'Balance longer sessions with enough recovery.';
    }

    return 'You completed $monthlyWorkouts workouts this month. Aim for '
        'steady, sustainable progress rather than sudden increases.';
  }

  Color get performanceColor {
    if (monthlyWorkouts == 0) {
      return AppTheme.info;
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal) {
      return AppTheme.success;
    }

    if (averageWorkoutMinutes >= 45) {
      return AppTheme.warning;
    }

    return AppTheme.primary;
  }

  IconData get performanceIcon {
    if (monthlyWorkouts == 0) {
      return Icons.insights_rounded;
    }

    if (weeklyWorkouts >= estimatedWeeklyGoal) {
      return Icons.verified_rounded;
    }

    if (averageWorkoutMinutes >= 45) {
      return Icons.bolt_rounded;
    }

    return Icons.trending_up_rounded;
  }

  Color _muscleColor(String muscleGroup) {
    switch (muscleGroup.trim().toLowerCase()) {
      case 'chest':
        return AppTheme.error;
      case 'back':
        return AppTheme.primary;
      case 'legs':
        return AppTheme.success;
      case 'core':
        return AppTheme.warning;
      case 'shoulders':
      case 'shoulder':
        return AppTheme.info;
      default:
        return AppTheme.primary;
    }
  }

  IconData _muscleIcon(String muscleGroup) {
    switch (muscleGroup.trim().toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new_rounded;
      case 'back':
        return Icons.fitness_center_rounded;
      case 'legs':
        return Icons.directions_run_rounded;
      case 'core':
        return Icons.sports_gymnastics_rounded;
      case 'shoulders':
      case 'shoulder':
        return Icons.self_improvement_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final muscleColor = _muscleColor(favoriteMuscleGroup);
    final muscleIcon = _muscleIcon(favoriteMuscleGroup);

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              top: -72,
              right: -54,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -94,
              left: -72,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: performanceColor.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatisticsHeader(
                    summaryText: summaryText,
                    monthlyProgress: monthlyProgress,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _PrimaryStatisticCard(
                          title: 'This Week',
                          value: '$weeklyWorkouts',
                          subtitle: 'of $estimatedWeeklyGoal workout goal',
                          icon: Icons.calendar_view_week_rounded,
                          color: AppTheme.primary,
                          progress: weeklyProgress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrimaryStatisticCard(
                          title: 'This Month',
                          value: '$monthlyWorkouts',
                          subtitle: 'of $estimatedMonthlyGoal workout goal',
                          icon: Icons.calendar_month_rounded,
                          color: AppTheme.success,
                          progress: monthlyProgress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          title: 'Avg Workout',
                          value: '$averageWorkoutMinutes min',
                          icon: Icons.timer_rounded,
                          color: AppTheme.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatItem(
                          title: 'Calories',
                          value: '$totalCalories',
                          icon: Icons.local_fire_department_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          title: 'Training Time',
                          value: formattedTrainingTime,
                          icon: Icons.schedule_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatItem(
                          title: 'Last Workout',
                          value: lastWorkoutText,
                          icon: Icons.history_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.035)
                          : Colors.black.withValues(alpha: 0.025),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: muscleColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Icon(muscleIcon, color: muscleColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Most Trained Muscle',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                favoriteMuscleGroup,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppChip(
                          label: 'Favorite',
                          icon: Icons.favorite_rounded,
                          backgroundColor: muscleColor.withValues(alpha: 0.12),
                          foregroundColor: muscleColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  _PerformanceInsightCard(
                    title: performanceTitle,
                    message: performanceMessage,
                    icon: performanceIcon,
                    color: performanceColor,
                  ),
                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppChip(
                        label: '$weeklyWorkouts this week',
                        icon: Icons.calendar_today_rounded,
                      ),
                      AppChip(
                        label: '$monthlyWorkouts this month',
                        icon: Icons.date_range_rounded,
                        backgroundColor: AppTheme.success.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.success,
                      ),
                      AppChip(
                        label: '$averageWorkoutMinutes min average',
                        icon: Icons.timer_outlined,
                        backgroundColor: AppTheme.info.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.info,
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

class _StatisticsHeader extends StatelessWidget {
  final String summaryText;
  final double monthlyProgress;

  const _StatisticsHeader({
    required this.summaryText,
    required this.monthlyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = monthlyProgress.clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: const Icon(
            Icons.query_stats_rounded,
            color: AppTheme.primary,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advanced Statistics',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                summaryText,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: safeProgress),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  );
                },
              ),
              Text(
                '${(safeProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryStatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  const _PrimaryStatisticCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: 178,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.black.withValues(alpha: 0.032),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 7,
                  backgroundColor: color.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceInsightCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _PerformanceInsightCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
