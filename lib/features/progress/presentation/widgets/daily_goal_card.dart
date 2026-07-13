import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  final bool workoutCompletedToday;
  final int currentStreak;

  const DailyGoalCard({
    super.key,
    required this.workoutCompletedToday,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Completed: gradient from primary to a deeper shade
    // Not completed: card surface with a subtle border
    final isCompleted = workoutCompletedToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryDark],
              )
            : null,
        color: isCompleted
            ? null
            : theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: isCompleted
            ? null
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.07),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.flag_rounded,
              color: isCompleted ? Colors.white : AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Goal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCompleted ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isCompleted ? 'Workout Done!' : 'No Workout Yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? 'Great job. Streak: $currentStreak day${currentStreak == 1 ? '' : 's'}.'
                      : 'Complete a workout to keep your streak alive.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCompleted ? Colors.white60 : AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (currentStreak > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: isCompleted ? Colors.white70 : AppTheme.warning,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: isCompleted ? Colors.white : AppTheme.warning,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
