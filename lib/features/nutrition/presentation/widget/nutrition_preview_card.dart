import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/daily_macro_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NutritionPreviewCard extends StatelessWidget {
  final NutritionSummary summary;

  const NutritionPreviewCard({super.key, required this.summary});

  int get remainingCalories {
    return summary.goal.calorieGoal - summary.totalCalories;
  }

  double get calorieProgress {
    return summary.calorieProgress.clamp(0.0, 1.0);
  }

  int get caloriePercentage {
    return (calorieProgress * 100).round();
  }

  String get statusTitle {
    if (summary.goal.calorieGoal <= 0) {
      return 'Set your nutrition goals';
    }

    if (remainingCalories < 0) {
      return 'Daily goal exceeded';
    }

    if (calorieProgress >= 0.90) {
      return 'Almost at your goal';
    }

    if (calorieProgress >= 0.50) {
      return 'Great progress today';
    }

    if (summary.totalCalories > 0) {
      return 'Your nutrition is underway';
    }

    return 'Ready to track your meals';
  }

  String get statusMessage {
    if (summary.goal.calorieGoal <= 0) {
      return 'Open Nutrition to create your daily calorie and macro targets.';
    }

    if (remainingCalories < 0) {
      return '${remainingCalories.abs()} calories over today’s target.';
    }

    if (remainingCalories == 0) {
      return 'You have reached today’s calorie target.';
    }

    if (calorieProgress >= 0.90) {
      return '$remainingCalories calories remaining today.';
    }

    if (calorieProgress >= 0.50) {
      return '$remainingCalories calories left to complete your daily plan.';
    }

    return '$remainingCalories calories remaining today.';
  }

  Color get progressColor {
    if (remainingCalories < 0) {
      return AppTheme.error;
    }

    if (calorieProgress >= 0.90) {
      return AppTheme.warning;
    }

    return AppTheme.primary;
  }

  void _openNutrition(BuildContext context) {
    context.push('/nutrition');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      onTap: () => _openNutrition(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              top: -76,
              right: -54,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: progressColor.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -86,
              left: -62,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.05),
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
                          color: progressColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: progressColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nutrition',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusTitle,
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: progressColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$caloriePercentage%',
                          style: TextStyle(
                            color: progressColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${summary.totalCalories}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '/ ${summary.goal.calorieGoal} kcal',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusMessage,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: calorieProgress,
                      minHeight: 10,
                      backgroundColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.025)
                          : Colors.black.withValues(alpha: 0.018),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusXLarge,
                      ),
                    ),
                    child: DailyMacroCard(summary: summary),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Open Nutrition',
                    icon: Icons.arrow_forward_rounded,
                    type: AppButtonType.secondary,
                    onPressed: () => _openNutrition(context),
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
