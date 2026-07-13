import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';

class ProgressSummaryCard extends StatelessWidget {
  final String completedWorkouts;
  final String workoutMinutes;

  const ProgressSummaryCard({
    super.key,
    required this.completedWorkouts,
    required this.workoutMinutes,
  });

  int get completedWorkoutCount {
    return int.tryParse(completedWorkouts.trim()) ?? 0;
  }

  int get totalMinutes {
    return int.tryParse(workoutMinutes.trim()) ?? 0;
  }

  int get totalHours {
    return totalMinutes ~/ 60;
  }

  int get remainingMinutes {
    return totalMinutes % 60;
  }

  int get estimatedXp {
    return completedWorkoutCount * 100;
  }

  int get level {
    if (estimatedXp <= 0) {
      return 1;
    }

    return (estimatedXp ~/ 500) + 1;
  }

  int get currentLevelXp {
    if (estimatedXp <= 0) {
      return 0;
    }

    return estimatedXp % 500;
  }

  double get levelProgress {
    if (estimatedXp <= 0) {
      return 0;
    }

    return (currentLevelXp / 500).clamp(0.0, 1.0);
  }

  int get weeklyGoal {
    return 5;
  }

  int get weeklyProgress {
    if (completedWorkoutCount <= 0) {
      return 0;
    }

    return completedWorkoutCount.clamp(0, weeklyGoal);
  }

  double get weeklyProgressValue {
    if (weeklyGoal <= 0) {
      return 0;
    }

    return (weeklyProgress / weeklyGoal).clamp(0.0, 1.0);
  }

  String get workoutText {
    if (completedWorkoutCount == 1) {
      return '1 workout completed';
    }

    return '$completedWorkoutCount workouts completed';
  }

  String get timeText {
    if (totalMinutes <= 0) {
      return '0 min';
    }

    if (totalHours <= 0) {
      return '$remainingMinutes min';
    }

    if (remainingMinutes == 0) {
      return '$totalHours hr';
    }

    return '$totalHours hr $remainingMinutes min';
  }

  String get motivationText {
    if (completedWorkoutCount == 0) {
      return 'Complete your first workout to begin building your progress.';
    }

    if (completedWorkoutCount < 5) {
      return 'Great start. Keep building momentum one workout at a time.';
    }

    if (completedWorkoutCount < 15) {
      return 'Your consistency is growing. Stay focused on your routine.';
    }

    if (completedWorkoutCount < 30) {
      return 'Strong progress. Your training habits are becoming consistent.';
    }

    return 'Outstanding consistency. Keep challenging your previous best.';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.scale(scale: animationValue, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.28),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -78,
              right: -58,
              child: IgnorePointer(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -92,
              left: -74,
              child: IgnorePointer(
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.success.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.17),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'A complete view of your fitness journey',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppChip(
                      label: 'Level $level',
                      icon: Icons.bolt_rounded,
                      backgroundColor: Colors.white.withValues(alpha: 0.17),
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  workoutText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  motivationText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ProgressHeroMetric(
                        icon: Icons.fitness_center_rounded,
                        title: 'Workouts',
                        value: '$completedWorkoutCount',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressHeroMetric(
                        icon: Icons.timer_outlined,
                        title: 'Training Time',
                        value: timeText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ProgressHeroMetric(
                        icon: Icons.bolt_rounded,
                        title: 'Estimated XP',
                        value: '$estimatedXp',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressHeroMetric(
                        icon: Icons.calendar_month_rounded,
                        title: 'Weekly Goal',
                        value: '$weeklyProgress / $weeklyGoal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _ProgressBarSection(
                  title: 'Level Progress',
                  valueText: '$currentLevelXp / 500 XP',
                  progress: levelProgress,
                  color: Colors.white,
                ),
                const SizedBox(height: 18),
                _ProgressBarSection(
                  title: 'Weekly Workout Goal',
                  valueText: '$weeklyProgress of $weeklyGoal workouts',
                  progress: weeklyProgressValue,
                  color: AppTheme.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeroMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProgressHeroMetric({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarSection extends StatelessWidget {
  final String title;
  final String valueText;
  final double progress;
  final Color color;

  const _ProgressBarSection({
    required this.title,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              valueText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: safeProgress),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: 0.13),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
