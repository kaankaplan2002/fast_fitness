import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:flutter/material.dart';

class MacroSummaryCard extends StatelessWidget {
  final NutritionSummary summary;

  const MacroSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MacroTile(
          title: 'Protein',
          value: summary.totalProtein,
          goal: summary.goal.proteinGoal,
          progress: summary.proteinProgress,
          icon: Icons.fitness_center_rounded,
        ),
        const SizedBox(height: 12),
        _MacroTile(
          title: 'Carbs',
          value: summary.totalCarbs,
          goal: summary.goal.carbsGoal,
          progress: summary.carbsProgress,
          icon: Icons.grain_rounded,
        ),
        const SizedBox(height: 12),
        _MacroTile(
          title: 'Fat',
          value: summary.totalFat,
          goal: summary.goal.fatGoal,
          progress: summary.fatProgress,
          icon: Icons.water_drop_rounded,
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String title;
  final double value;
  final double goal;
  final double progress;
  final IconData icon;

  const _MacroTile({
    required this.title,
    required this.value,
    required this.goal,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.cardColor,
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)}g',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
