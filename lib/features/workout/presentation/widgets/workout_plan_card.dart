import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';

class WorkoutPlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final VoidCallback onTap;

  const WorkoutPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onTap,
  });

  String get difficulty {
    final normalizedSubtitle = subtitle.toLowerCase();

    if (normalizedSubtitle.contains('advanced')) {
      return 'Advanced';
    }

    if (normalizedSubtitle.contains('intermediate')) {
      return 'Intermediate';
    }

    return 'Beginner';
  }

  int get exerciseCount {
    final match = RegExp(
      r'(\d+)\s+exercise',
    ).firstMatch(subtitle.toLowerCase());

    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'Advanced':
        return AppTheme.error;
      case 'Intermediate':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              top: -72,
              right: -52,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -78,
              left: -60,
              child: Container(
                width: 170,
                height: 170,
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
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      AppChip(label: duration, icon: Icons.timer_outlined),
                      if (exerciseCount > 0)
                        AppChip(
                          label: '$exerciseCount exercises',
                          icon: Icons.format_list_numbered_rounded,
                        ),
                      AppChip(
                        label: difficulty,
                        icon: Icons.signal_cellular_alt_rounded,
                        backgroundColor: difficultyColor.withValues(alpha: 0.12),
                        foregroundColor: difficultyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.045)
                          : Colors.black.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppTheme.primary,
                          size: 23,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'View workout plan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textSecondary,
                        ),
                      ],
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
