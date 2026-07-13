import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class WeightCard extends StatelessWidget {
  final double? weight;

  const WeightCard({super.key, required this.weight});

  double get targetWeight => 85;

  double get progress {
    if (weight == null) return 0;

    // Başlangıç ağırlığı: 97.5 kg
    const startWeight = 97.5;

    final totalToLose = startWeight - targetWeight;
    final lost = startWeight - weight!;

    if (totalToLose <= 0) return 0;

    return (lost / totalToLose).clamp(0.0, 1.0);
  }

  String get displayWeight {
    if (weight == null) {
      return '--';
    }

    return '${weight!.toStringAsFixed(1)} kg';
  }

  String get progressText {
    if (weight == null) {
      return 'No weight recorded yet.';
    }

    if (progress >= 1) {
      return 'Target weight achieved!';
    }

    if (progress >= .75) {
      return 'Almost there. Keep pushing!';
    }

    if (progress >= .40) {
      return 'Great progress so far.';
    }

    return 'Your weight-loss journey has started.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      child: Padding(
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
                    color: AppTheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.monitor_weight_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Weight',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        progressText,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayWeight,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: .06)
                    : Colors.black.withValues(alpha: .06),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _MetricBox(
                    title: 'Goal',
                    value: '${targetWeight.toStringAsFixed(0)} kg',
                    icon: Icons.flag_rounded,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBox(
                    title: 'Remaining',
                    value: weight == null
                        ? '--'
                        : '${(weight! - targetWeight).clamp(0, 999).toStringAsFixed(1)} kg',
                    icon: Icons.trending_down_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
