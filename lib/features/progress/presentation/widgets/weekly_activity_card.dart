import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class WeeklyActivityCard extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const WeeklyActivityCard({
    super.key,
    this.values = const [0.80, 0.50, 1.00, 0.35, 0.70, 0.20, 0.55],
    this.labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  });

  List<_DayProgress> get _days {
    final itemCount = values.length < labels.length
        ? values.length
        : labels.length;

    return List.generate(itemCount, (index) {
      return _DayProgress(
        label: labels[index],
        value: values[index].clamp(0.0, 1.0),
      );
    });
  }

  double get averageProgress {
    if (_days.isEmpty) return 0;

    final total = _days.fold<double>(0, (sum, day) => sum + day.value);

    return (total / _days.length).clamp(0.0, 1.0);
  }

  int get activeDays {
    return _days.where((day) => day.value > 0).length;
  }

  int get strongestDayIndex {
    if (_days.isEmpty) return -1;

    var bestIndex = 0;
    var bestValue = _days.first.value;

    for (var index = 1; index < _days.length; index++) {
      if (_days[index].value > bestValue) {
        bestValue = _days[index].value;
        bestIndex = index;
      }
    }

    return bestIndex;
  }

  String get strongestDayLabel {
    final index = strongestDayIndex;

    if (index < 0 || index >= _days.length) {
      return '-';
    }

    return _days[index].label;
  }

  String get summaryText {
    if (activeDays == 0) {
      return 'No activity recorded this week yet.';
    }

    if (activeDays <= 2) {
      return 'You have started the week. Aim for another active day.';
    }

    if (activeDays <= 4) {
      return 'Good consistency. Keep building your weekly routine.';
    }

    return 'Excellent consistency across the week.';
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
              top: -66,
              right: -48,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
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
                          color: AppTheme.primary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly Activity',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${(averageProgress * 100).round()}%',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _WeeklyMetric(
                          title: 'Active Days',
                          value: '$activeDays / ${_days.length}',
                          icon: Icons.calendar_today_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _WeeklyMetric(
                          title: 'Best Day',
                          value: strongestDayLabel,
                          icon: Icons.emoji_events_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 190,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _days.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isStrongest = index == strongestDayIndex;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == _days.length - 1 ? 0 : 8,
                            ),
                            child: _AnimatedActivityBar(
                              day: day,
                              isStrongest: isStrongest,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _AverageProgressBar(
                    progress: averageProgress,
                    isDarkMode: isDarkMode,
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

class _AnimatedActivityBar extends StatelessWidget {
  final _DayProgress day;
  final bool isStrongest;
  final bool isDarkMode;

  const _AnimatedActivityBar({
    required this.day,
    required this.isStrongest,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    const maximumBarHeight = 126.0;
    const minimumVisibleBarHeight = 8.0;

    final targetHeight = day.value <= 0
        ? minimumVisibleBarHeight
        : (maximumBarHeight * day.value).clamp(
            minimumVisibleBarHeight,
            maximumBarHeight,
          );

    final barColor = isStrongest ? AppTheme.success : AppTheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${(day.value * 100).round()}%',
          style: TextStyle(
            color: isStrongest ? AppTheme.success : AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 26,
              height: maximumBarHeight,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: minimumVisibleBarHeight,
                  end: targetHeight,
                ),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, animatedHeight, child) {
                  return Container(
                    width: 26,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [barColor.withValues(alpha: 0.72), barColor],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isStrongest
                          ? [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.28),
                                blurRadius: 14,
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
        const SizedBox(height: 10),
        Text(
          day.label,
          style: TextStyle(
            color: isStrongest ? AppTheme.success : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: isStrongest ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeeklyMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _WeeklyMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
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

class _AverageProgressBar extends StatelessWidget {
  final double progress;
  final bool isDarkMode;

  const _AverageProgressBar({required this.progress, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Weekly Completion',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${(safeProgress * 100).round()}%',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: safeProgress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 9,
                backgroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
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

class _DayProgress {
  final String label;
  final double value;

  const _DayProgress({required this.label, required this.value});
}
