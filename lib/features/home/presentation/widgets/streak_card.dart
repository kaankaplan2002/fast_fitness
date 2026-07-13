import 'package:fast_fitness/core/widgets/app_progress_card.dart';
import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({super.key, required this.streak});

  double get progress {
    if (streak >= 30) return 1.0;
    return (streak / 30).clamp(0.0, 1.0);
  }

  String get subtitle {
    if (streak == 0) {
      return 'Complete your first workout to start your streak.';
    }

    if (streak < 7) {
      return 'Great start! Stay consistent every day.';
    }

    if (streak < 30) {
      return 'Excellent consistency. Keep the momentum going.';
    }

    return 'Outstanding! You have reached an elite streak.';
  }

  @override
  Widget build(BuildContext context) {
    return AppProgressCard(
      title: 'Workout Streak',
      value: streak == 1 ? '1 day' : '$streak days',
      subtitle: subtitle,
      progress: progress,
      icon: Icons.local_fire_department_rounded,
      color: Colors.deepOrange,
    );
  }
}
