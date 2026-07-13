import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_progress_card.dart';
import 'package:flutter/material.dart';

class CalorieCard extends StatelessWidget {
  final int dailyCalories;
  final int consumedCalories;

  const CalorieCard({
    super.key,
    required this.dailyCalories,
    this.consumedCalories = 620,
  });

  double get progress {
    if (dailyCalories <= 0) return 0;

    return (consumedCalories / dailyCalories).clamp(0.0, 1.0);
  }

  int get remainingCalories {
    final remaining = dailyCalories - consumedCalories;

    return remaining < 0 ? 0 : remaining;
  }

  String get statusText {
    if (dailyCalories <= 0) {
      return 'Set your daily calorie target to track progress.';
    }

    if (consumedCalories > dailyCalories) {
      return 'You have exceeded today’s calorie target.';
    }

    if (progress >= 0.85) {
      return 'You are close to reaching today’s target.';
    }

    if (progress >= 0.50) {
      return 'You are making steady progress today.';
    }

    return 'You still have room in today’s calorie plan.';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

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
              right: -55,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.08),
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
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppTheme.success,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Calories',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Track your nutrition target',
                              style: TextStyle(
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  AppProgressCard(
                    title: 'Calories Consumed',
                    value: '$consumedCalories / $dailyCalories kcal',
                    subtitle: statusText,
                    progress: progress,
                    icon: Icons.bolt_rounded,
                    color: AppTheme.success,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _CalorieMetric(
                          title: 'Consumed',
                          value: '$consumedCalories',
                          suffix: 'kcal',
                          icon: Icons.restaurant_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CalorieMetric(
                          title: 'Remaining',
                          value: '$remainingCalories',
                          suffix: 'kcal',
                          icon: Icons.flag_rounded,
                          color: AppTheme.success,
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

class _CalorieMetric extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;

  const _CalorieMetric({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            suffix,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
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
