import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';

class WorkoutHeatmapCard extends StatelessWidget {
  final List<DateTime> workoutDates;

  const WorkoutHeatmapCard({super.key, required this.workoutDates});

  static const int visibleDayCount = 28;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> get normalizedWorkoutDates {
    final uniqueDates = <DateTime>{};

    for (final date in workoutDates) {
      uniqueDates.add(_dateOnly(date));
    }

    final dates = uniqueDates.toList()
      ..sort((first, second) => first.compareTo(second));

    return dates;
  }

  Map<DateTime, int> get workoutCountByDay {
    final counts = <DateTime, int>{};

    for (final date in workoutDates) {
      final normalizedDate = _dateOnly(date);

      counts.update(normalizedDate, (value) => value + 1, ifAbsent: () => 1);
    }

    return counts;
  }

  List<DateTime> get visibleDays {
    final today = _dateOnly(DateTime.now());

    return List<DateTime>.generate(visibleDayCount, (index) {
      return today.subtract(Duration(days: visibleDayCount - 1 - index));
    });
  }

  int _workoutCountForDay(DateTime date) {
    return workoutCountByDay[_dateOnly(date)] ?? 0;
  }

  bool _hasWorkoutOn(DateTime date) {
    return _workoutCountForDay(date) > 0;
  }

  bool _isToday(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final normalizedDate = _dateOnly(date);

    return today == normalizedDate;
  }

  int get activeDayCount {
    return visibleDays.where(_hasWorkoutOn).length;
  }

  int get totalWorkoutCount {
    return visibleDays.fold<int>(
      0,
      (total, date) => total + _workoutCountForDay(date),
    );
  }

  int get inactiveDayCount {
    return visibleDayCount - activeDayCount;
  }

  double get activityRate {
    if (visibleDayCount <= 0) {
      return 0;
    }

    return (activeDayCount / visibleDayCount).clamp(0.0, 1.0);
  }

  int get currentStreak {
    if (normalizedWorkoutDates.isEmpty) {
      return 0;
    }

    final workoutDateSet = normalizedWorkoutDates.toSet();
    var day = _dateOnly(DateTime.now());

    if (!workoutDateSet.contains(day)) {
      day = day.subtract(const Duration(days: 1));
    }

    var streak = 0;

    while (workoutDateSet.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int get longestStreak {
    if (normalizedWorkoutDates.isEmpty) {
      return 0;
    }

    var longest = 1;
    var current = 1;

    for (var index = 1; index < normalizedWorkoutDates.length; index++) {
      final previousDate = normalizedWorkoutDates[index - 1];
      final currentDate = normalizedWorkoutDates[index];

      final difference = currentDate.difference(previousDate).inDays;

      if (difference == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else if (difference > 1) {
        current = 1;
      }
    }

    return longest;
  }

  int get busiestDayWorkoutCount {
    if (visibleDays.isEmpty) {
      return 0;
    }

    var maximum = 0;

    for (final date in visibleDays) {
      final count = _workoutCountForDay(date);

      if (count > maximum) {
        maximum = count;
      }
    }

    return maximum;
  }

  String get summaryText {
    if (activeDayCount == 0) {
      return 'Complete a workout to begin building your activity calendar.';
    }

    if (activeDayCount <= 4) {
      return 'You have started building activity across the last 28 days.';
    }

    if (activeDayCount <= 10) {
      return 'Your workout consistency is developing steadily.';
    }

    if (activeDayCount <= 18) {
      return 'Strong consistency across the last four weeks.';
    }

    return 'Outstanding activity across the last 28 days.';
  }

  String get consistencyLabel {
    final percentage = (activityRate * 100).round();

    if (percentage == 0) {
      return 'No activity';
    }

    if (percentage < 25) {
      return 'Getting started';
    }

    if (percentage < 50) {
      return 'Building consistency';
    }

    if (percentage < 75) {
      return 'Strong consistency';
    }

    return 'Excellent consistency';
  }

  Color _activityColor(int workoutCount) {
    if (workoutCount <= 0) {
      return Colors.transparent;
    }

    if (workoutCount == 1) {
      return AppTheme.primary.withValues(alpha: 0.45);
    }

    if (workoutCount == 2) {
      return AppTheme.primary.withValues(alpha: 0.72);
    }

    return AppTheme.primary;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _weekdayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
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
              right: -54,
              child: IgnorePointer(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -68,
              child: IgnorePointer(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.success.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeatmapHeader(
                    summaryText: summaryText,
                    activityRate: activityRate,
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: _HeatmapMetric(
                          title: 'Active Days',
                          value: '$activeDayCount',
                          icon: Icons.event_available_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeatmapMetric(
                          title: 'Workouts',
                          value: '$totalWorkoutCount',
                          icon: Icons.fitness_center_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _HeatmapMetric(
                          title: 'Current Streak',
                          value: '$currentStreak days',
                          icon: Icons.local_fire_department_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeatmapMetric(
                          title: 'Longest Streak',
                          value: '$longestStreak days',
                          icon: Icons.emoji_events_rounded,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Last 28 Days',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tap a day to see its workout count.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(activityRate * 100).round()}%',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        const _WeekdayHeader(),
                        const SizedBox(height: 8),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleDays.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final day = visibleDays[index];
                            final workoutCount = _workoutCountForDay(day);

                            return _HeatmapDayCell(
                              date: day,
                              workoutCount: workoutCount,
                              isToday: _isToday(day),
                              activityColor: _activityColor(workoutCount),
                              isDarkMode: isDarkMode,
                              formattedDate: _formatDate(day),
                              weekdayLabel: _weekdayLabel(day),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        const _HeatmapLegend(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _ConsistencyProgress(
                    progress: activityRate,
                    label: consistencyLabel,
                    activeDays: activeDayCount,
                    inactiveDays: inactiveDayCount,
                  ),
                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppChip(
                        label: '$activeDayCount active days',
                        icon: Icons.calendar_today_rounded,
                        backgroundColor: AppTheme.success.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.success,
                      ),
                      AppChip(
                        label: '$currentStreak day streak',
                        icon: Icons.local_fire_department_rounded,
                        backgroundColor: AppTheme.warning.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.warning,
                      ),
                      AppChip(
                        label: '$busiestDayWorkoutCount max in one day',
                        icon: Icons.bolt_rounded,
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

class _HeatmapHeader extends StatelessWidget {
  final String summaryText;
  final double activityRate;

  const _HeatmapHeader({required this.summaryText, required this.activityRate});

  @override
  Widget build(BuildContext context) {
    final safeProgress = activityRate.clamp(0.0, 1.0);

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
            Icons.calendar_view_month_rounded,
            color: AppTheme.primary,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Calendar',
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
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: safeProgress),
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
                '${(safeProgress * 100).round()}%',
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

class _HeatmapMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HeatmapMetric({
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
              mainAxisSize: MainAxisSize.min,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HeatmapDayCell extends StatelessWidget {
  final DateTime date;
  final int workoutCount;
  final bool isToday;
  final Color activityColor;
  final bool isDarkMode;
  final String formattedDate;
  final String weekdayLabel;

  const _HeatmapDayCell({
    required this.date,
    required this.workoutCount,
    required this.isToday,
    required this.activityColor,
    required this.isDarkMode,
    required this.formattedDate,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivity = workoutCount > 0;

    return Tooltip(
      message: workoutCount <= 0
          ? '$weekdayLabel, $formattedDate\nNo workout'
          : '$weekdayLabel, $formattedDate\n'
                '$workoutCount ${workoutCount == 1 ? 'workout' : 'workouts'}',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.78, end: 1),
        duration: Duration(milliseconds: 280 + (date.day * 8)),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            color: hasActivity
                ? activityColor
                : isDarkMode
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.black.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: isToday ? 2 : 1,
              color: isToday
                  ? AppTheme.warning
                  : hasActivity
                  ? AppTheme.primary.withValues(alpha: 0.55)
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.07),
            ),
            boxShadow: hasActivity
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: hasActivity ? Colors.white : AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: isToday || hasActivity
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 7),
        _LegendBox(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        const SizedBox(width: 5),
        _LegendBox(color: AppTheme.primary.withValues(alpha: 0.45)),
        const SizedBox(width: 5),
        _LegendBox(color: AppTheme.primary.withValues(alpha: 0.72)),
        const SizedBox(width: 5),
        const _LegendBox(color: AppTheme.primary),
        const SizedBox(width: 7),
        const Text(
          'More',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;

  const _LegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ConsistencyProgress extends StatelessWidget {
  final double progress;
  final String label;
  final int activeDays;
  final int inactiveDays;

  const _ConsistencyProgress({
    required this.progress,
    required this.label,
    required this.activeDays,
    required this.inactiveDays,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '28-Day Consistency',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$activeDays active · $inactiveDays rest',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: safeProgress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 9,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
