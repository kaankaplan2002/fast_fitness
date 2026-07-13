import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/progress/data/models/weight_history_model.dart';
import 'package:flutter/material.dart';

class MonthlyProgressCard extends StatelessWidget {
  final List<WeightHistoryModel> weights;
  final int completedWorkouts;
  final int workoutMinutes;

  const MonthlyProgressCard({
    super.key,
    required this.weights,
    required this.completedWorkouts,
    required this.workoutMinutes,
  });

  double get _weightChange {
    if (weights.length < 2) return 0;
    return weights.last.weight - weights.first.weight;
  }

  bool get _hasWeightData => weights.length >= 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;

    final changeValue = _weightChange;
    final changeIsPositive = changeValue >= 0;
    final changeColor = changeIsPositive ? AppTheme.error : AppTheme.success;
    final changeText = _hasWeightData
        ? '${changeIsPositive ? '+' : ''}${changeValue.toStringAsFixed(1)} kg'
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Monthly Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your overall totals',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stat row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: changeText,
                  valueColor: _hasWeightData ? changeColor : null,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts',
                  value: completedWorkouts.toString(),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.timer_outlined,
                  label: 'Minutes',
                  value: workoutMinutes.toString(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (!_hasWeightData) ...[
            const SizedBox(height: 14),
            Text(
              'Add at least 2 weight entries to see weight change.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}