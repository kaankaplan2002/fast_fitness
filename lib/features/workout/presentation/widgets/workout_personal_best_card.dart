import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class WorkoutPersonalBestCard extends StatelessWidget {
  final bool longestWorkout;
  final bool mostCalories;
  final bool mostExercises;

  const WorkoutPersonalBestCard({
    super.key,
    required this.longestWorkout,
    required this.mostCalories,
    required this.mostExercises,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = <_PersonalBestItem>[];

    if (longestWorkout) {
      achievements.add(
        const _PersonalBestItem(
          icon: Icons.timer_rounded,
          title: 'Longest Workout',
        ),
      );
    }

    if (mostCalories) {
      achievements.add(
        const _PersonalBestItem(
          icon: Icons.local_fire_department_rounded,
          title: 'Most Calories Burned',
        ),
      );
    }

    if (mostExercises) {
      achievements.add(
        const _PersonalBestItem(
          icon: Icons.fitness_center_rounded,
          title: 'Most Exercises Completed',
        ),
      );
    }

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amber,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'New Personal Best!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Congratulations! You achieved a new record.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          ...achievements,

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PersonalBestItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PersonalBestItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
