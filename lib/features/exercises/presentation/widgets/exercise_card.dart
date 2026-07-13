import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  Color get difficultyColor {
    switch (exercise.difficulty.trim().toLowerCase()) {
      case 'advanced':
        return AppTheme.error;
      case 'intermediate':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  IconData get muscleIcon {
    switch (exercise.muscleGroup.trim().toLowerCase()) {
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
      case 'arms':
      case 'biceps':
      case 'triceps':
        return Icons.sports_martial_arts_rounded;
      case 'cardio':
        return Icons.monitor_heart_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  String get equipmentText {
    final value = exercise.equipment.trim();

    return value.isEmpty ? 'No equipment' : value;
  }

  String get repsText {
    final value = exercise.reps.trim();

    return value.isEmpty ? '-' : value;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              right: -38,
              child: Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -62,
              left: -48,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: difficultyColor.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ExerciseImage(gifUrl: exercise.gifUrl, icon: muscleIcon),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.fitness_center_rounded,
                              color: AppTheme.textSecondary,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                equipmentText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            AppChip(
                              label: exercise.muscleGroup,
                              icon: muscleIcon,
                            ),
                            AppChip(
                              label: exercise.difficulty,
                              icon: Icons.signal_cellular_alt_rounded,
                              backgroundColor: difficultyColor.withValues(
                                alpha: 0.12,
                              ),
                              foregroundColor: difficultyColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ExerciseMetric(
                              icon: Icons.repeat_rounded,
                              text: '${exercise.sets} sets',
                            ),
                            const SizedBox(width: 12),
                            _ExerciseMetric(
                              icon: Icons.numbers_rounded,
                              text: '$repsText reps',
                            ),
                            const SizedBox(width: 12),
                            _ExerciseMetric(
                              icon: Icons.timer_outlined,
                              text: '${exercise.restSeconds}s',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onFavoriteTap,
                          customBorder: const CircleBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFavorite
                                  ? AppTheme.error.withValues(alpha: 0.13)
                                  : isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFavorite),
                                color: isFavorite
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary,
                        size: 22,
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

class _ExerciseImage extends StatelessWidget {
  final String gifUrl;
  final IconData icon;

  const _ExerciseImage({required this.gifUrl, required this.icon});

  @override
  Widget build(BuildContext context) {
    final hasImage = gifUrl.trim().isNotEmpty;

    return Container(
      width: 70,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        gradient: hasImage
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              gifUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppTheme.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) {
                return _ImageFallback(icon: icon);
              },
            )
          : _ImageFallback(icon: icon),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final IconData icon;

  const _ImageFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 31),
    );
  }
}

class _ExerciseMetric extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ExerciseMetric({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
