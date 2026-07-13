import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/progress/data/models/workout_analytics_model.dart';
import 'package:flutter/material.dart';

class WorkoutAnalyticsCard extends StatelessWidget {
  final WorkoutAnalyticsModel analytics;

  const WorkoutAnalyticsCard({super.key, required this.analytics});

  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<int> get weeklyMinutes {
    final rawMinutes = List<int>.from(analytics.weeklyMinutes);

    if (rawMinutes.length >= 7) {
      return rawMinutes.take(7).toList();
    }

    return [...rawMinutes, ...List<int>.filled(7 - rawMinutes.length, 0)];
  }

  int get totalWeeklyMinutes {
    return weeklyMinutes.fold<int>(0, (total, minutes) => total + minutes);
  }

  int get activeDays {
    return weeklyMinutes.where((minutes) => minutes > 0).length;
  }

  int get maximumMinutes {
    if (weeklyMinutes.isEmpty) return 1;

    final maximum = weeklyMinutes.reduce(
      (first, second) => first > second ? first : second,
    );

    return maximum <= 0 ? 1 : maximum;
  }

  int get strongestDayIndex {
    if (weeklyMinutes.isEmpty || totalWeeklyMinutes == 0) {
      return -1;
    }

    var bestIndex = 0;
    var bestValue = weeklyMinutes.first;

    for (var index = 1; index < weeklyMinutes.length; index++) {
      if (weeklyMinutes[index] > bestValue) {
        bestValue = weeklyMinutes[index];
        bestIndex = index;
      }
    }

    return bestIndex;
  }

  String get strongestDay {
    final index = strongestDayIndex;

    if (index < 0 || index >= _dayLabels.length) {
      return '-';
    }

    return _dayLabels[index];
  }

  int get strongestDayMinutes {
    final index = strongestDayIndex;

    if (index < 0 || index >= weeklyMinutes.length) {
      return 0;
    }

    return weeklyMinutes[index];
  }

  double get weeklyConsistency {
    if (weeklyMinutes.isEmpty) return 0;

    return (activeDays / 7).clamp(0.0, 1.0);
  }

  String get formattedWeeklyTime {
    final hours = totalWeeklyMinutes ~/ 60;
    final minutes = totalWeeklyMinutes % 60;

    if (totalWeeklyMinutes <= 0) {
      return '0 min';
    }

    if (hours <= 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  String get frequencyText {
    final frequency = analytics.workoutFrequency;

    if (frequency <= 0) {
      return '0';
    }

    return frequency.toString();
  }

  String get summaryText {
    if (totalWeeklyMinutes == 0) {
      return 'Complete a workout to begin generating weekly analytics.';
    }

    if (activeDays <= 2) {
      return 'You have started building your weekly training rhythm.';
    }

    if (activeDays <= 4) {
      return 'Your training frequency is developing consistently.';
    }

    return 'Excellent weekly consistency across multiple training days.';
  }

  String get insightTitle {
    if (totalWeeklyMinutes == 0) {
      return 'Start your analytics';
    }

    if (analytics.averageDuration >= 45) {
      return 'High-volume sessions';
    }

    if (activeDays >= 5) {
      return 'Excellent consistency';
    }

    if (analytics.longestWorkout >= 60) {
      return 'Strong endurance';
    }

    return 'Building momentum';
  }

  String get insightMessage {
    if (totalWeeklyMinutes == 0) {
      return 'Your duration, calorie, and frequency insights will appear '
          'after completing workouts.';
    }

    if (analytics.averageDuration >= 45) {
      return 'Your average session duration is high. Balance training volume '
          'with enough recovery between demanding workouts.';
    }

    if (activeDays >= 5) {
      return 'You trained on $activeDays days this week. Keep your schedule '
          'sustainable to maintain this level of consistency.';
    }

    if (analytics.longestWorkout >= 60) {
      return 'Your longest session reached ${analytics.longestWorkout} '
          'minutes, showing strong training endurance.';
    }

    return 'Aim for one additional active day while keeping your sessions '
        'controlled and consistent.';
  }

  Color get insightColor {
    if (totalWeeklyMinutes == 0) {
      return AppTheme.info;
    }

    if (activeDays >= 5) {
      return AppTheme.success;
    }

    if (analytics.averageDuration >= 45) {
      return AppTheme.warning;
    }

    return AppTheme.primary;
  }

  IconData get insightIcon {
    if (totalWeeklyMinutes == 0) {
      return Icons.insights_rounded;
    }

    if (activeDays >= 5) {
      return Icons.verified_rounded;
    }

    if (analytics.averageDuration >= 45) {
      return Icons.bolt_rounded;
    }

    return Icons.trending_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
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
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -68,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: insightColor.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnalyticsHeader(
                    summaryText: summaryText,
                    consistency: weeklyConsistency,
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: _OverviewMetric(
                          title: 'Weekly Time',
                          value: formattedWeeklyTime,
                          icon: Icons.schedule_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OverviewMetric(
                          title: 'Active Days',
                          value: '$activeDays / 7',
                          icon: Icons.calendar_today_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _OverviewMetric(
                          title: 'Best Day',
                          value: strongestDay,
                          icon: Icons.emoji_events_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OverviewMetric(
                          title: 'Best Volume',
                          value: '$strongestDayMinutes min',
                          icon: Icons.bar_chart_rounded,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.025)
                          : Colors.black.withValues(alpha: 0.018),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.055)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Training Volume',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Minutes trained during the current week',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 190,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index == 6 ? 0 : 7,
                                  ),
                                  child: _AnalyticsBar(
                                    label: _dayLabels[index],
                                    minutes: weeklyMinutes[index],
                                    maximumMinutes: maximumMinutes,
                                    isStrongest: index == strongestDayIndex,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsStatItem(
                          title: 'Avg Duration',
                          value: '${analytics.averageDuration} min',
                          icon: Icons.timer_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnalyticsStatItem(
                          title: 'Longest',
                          value: '${analytics.longestWorkout} min',
                          icon: Icons.trending_up_rounded,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsStatItem(
                          title: 'Avg Calories',
                          value: '${analytics.averageCalories}',
                          icon: Icons.local_fire_department_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnalyticsStatItem(
                          title: 'Frequency',
                          value: frequencyText,
                          icon: Icons.repeat_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _AnalyticsInsightCard(
                    title: insightTitle,
                    message: insightMessage,
                    icon: insightIcon,
                    color: insightColor,
                  ),
                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppChip(
                        label: '$activeDays active days',
                        icon: Icons.event_available_rounded,
                        backgroundColor: AppTheme.success.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.success,
                      ),
                      AppChip(
                        label:
                            '${(weeklyConsistency * 100).round()}% consistency',
                        icon: Icons.track_changes_rounded,
                      ),
                      AppChip(
                        label: '$totalWeeklyMinutes total min',
                        icon: Icons.timer_outlined,
                        backgroundColor: AppTheme.info.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.info,
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

class _AnalyticsHeader extends StatelessWidget {
  final String summaryText;
  final double consistency;

  const _AnalyticsHeader({
    required this.summaryText,
    required this.consistency,
  });

  @override
  Widget build(BuildContext context) {
    final safeConsistency = consistency.clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: AppTheme.primary,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Analytics',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                summaryText,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 54,
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: safeConsistency),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  );
                },
              ),
              Text(
                '${(safeConsistency * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewMetric({
    required this.title,
    required this.value,
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
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.055)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsBar extends StatelessWidget {
  final String label;
  final int minutes;
  final int maximumMinutes;
  final bool isStrongest;
  final bool isDarkMode;

  const _AnalyticsBar({
    required this.label,
    required this.minutes,
    required this.maximumMinutes,
    required this.isStrongest,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    const maximumHeight = 120.0;
    const minimumHeight = 7.0;

    final ratio = maximumMinutes <= 0
        ? 0.0
        : (minutes / maximumMinutes).clamp(0.0, 1.0);

    final targetHeight = minutes <= 0
        ? minimumHeight
        : (maximumHeight * ratio).clamp(minimumHeight, maximumHeight);

    final color = isStrongest ? AppTheme.success : AppTheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          minutes <= 0 ? '' : '$minutes',
          style: TextStyle(
            color: isStrongest ? AppTheme.success : AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 27,
              height: maximumHeight,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: minimumHeight, end: targetHeight),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, animatedHeight, child) {
                  return Container(
                    width: 27,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color.withValues(alpha: 0.65), color],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isStrongest
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.25),
                                blurRadius: 13,
                                offset: const Offset(0, 7),
                              ),
                            ]
                          : const [],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: TextStyle(
            color: isStrongest ? AppTheme.success : AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: isStrongest ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsStatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsInsightCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _AnalyticsInsightCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
