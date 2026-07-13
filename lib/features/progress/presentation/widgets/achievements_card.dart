import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class AchievementsCard extends StatelessWidget {
  final int completedWorkouts;
  final int streak;
  final int weightEntries;

  const AchievementsCard({
    super.key,
    required this.completedWorkouts,
    required this.streak,
    required this.weightEntries,
  });

  bool get _firstWorkout => completedWorkouts >= 1;
  bool get _fiveWorkouts => completedWorkouts >= 5;
  bool get _tenWorkouts => completedWorkouts >= 10;
  bool get _twentyFiveWorkouts => completedWorkouts >= 25;
  bool get _sevenDayStreak => streak >= 7;
  bool get _thirtyDayStreak => streak >= 30;
  bool get _weightTracker => weightEntries >= 3;
  bool get _weightMaster => weightEntries >= 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;

    final achievements = [
      _Achievement(
        title: 'First Workout',
        description: 'Complete your first session',
        icon: Icons.flag_rounded,
        unlocked: _firstWorkout,
        color: AppTheme.success,
      ),
      _Achievement(
        title: '5 Workouts',
        description: 'Complete 5 sessions total',
        icon: Icons.fitness_center_rounded,
        unlocked: _fiveWorkouts,
        color: AppTheme.primary,
      ),
      _Achievement(
        title: '10 Workouts',
        description: 'Complete 10 sessions total',
        icon: Icons.workspace_premium_rounded,
        unlocked: _tenWorkouts,
        color: const Color(0xFF8B6CFF),
      ),
      _Achievement(
        title: '25 Workouts',
        description: 'Complete 25 sessions total',
        icon: Icons.emoji_events_rounded,
        unlocked: _twentyFiveWorkouts,
        color: const Color(0xFFF59E0B),
      ),
      _Achievement(
        title: '7 Day Streak',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department_rounded,
        unlocked: _sevenDayStreak,
        color: const Color(0xFFF97316),
      ),
      _Achievement(
        title: '30 Day Streak',
        description: 'Maintain a 30-day streak',
        icon: Icons.whatshot_rounded,
        unlocked: _thirtyDayStreak,
        color: AppTheme.error,
      ),
      _Achievement(
        title: 'Weight Tracker',
        description: 'Log 3 weight entries',
        icon: Icons.monitor_weight_outlined,
        unlocked: _weightTracker,
        color: AppTheme.info,
      ),
      _Achievement(
        title: 'Weight Master',
        description: 'Log 10 weight entries',
        icon: Icons.bar_chart_rounded,
        unlocked: _weightMaster,
        color: const Color(0xFF22C55E),
      ),
    ];

    final unlockedCount = achievements.where((a) => a.unlocked).length;

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
                  color: AppTheme.warning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.warning,
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
                      'Achievements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unlockedCount / ${achievements.length} unlocked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: unlockedCount / achievements.length,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.07),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warning),
            ),
          ),
          const SizedBox(height: 20),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              return _AchievementTile(
                achievement: achievements[index],
                isDark: isDark,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final Color color;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.color,
  });
}

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;
  final bool isDark;

  const _AchievementTile({required this.achievement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = achievement.unlocked;
    final accent = unlocked ? achievement.color : AppTheme.textSecondary;
    final surfaceColor = unlocked
        ? achievement.color.withValues(alpha: isDark ? 0.10 : 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: unlocked
            ? Border.all(
                color: achievement.color.withValues(alpha: 0.25),
                width: 1,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(achievement.icon, color: accent, size: 26),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: unlocked ? null : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            unlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              color: unlocked ? accent : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
