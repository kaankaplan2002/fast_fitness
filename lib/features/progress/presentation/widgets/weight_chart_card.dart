import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/progress/data/models/weight_history_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightChartCard extends StatelessWidget {
  final List<WeightHistoryModel> weights;

  const WeightChartCard({super.key, required this.weights});

  List<WeightHistoryModel> get sortedWeights {
    final sorted = List<WeightHistoryModel>.from(weights);

    sorted.sort((first, second) => first.createdAt.compareTo(second.createdAt));

    return sorted;
  }

  bool get hasWeightData => sortedWeights.isNotEmpty;

  bool get hasEnoughChartData => sortedWeights.length >= 2;

  double get firstWeight {
    if (!hasWeightData) return 0;

    return sortedWeights.first.weight;
  }

  double get latestWeight {
    if (!hasWeightData) return 0;

    return sortedWeights.last.weight;
  }

  double get lowestWeight {
    if (!hasWeightData) return 0;

    return sortedWeights
        .map((entry) => entry.weight)
        .reduce((first, second) => first < second ? first : second);
  }

  double get highestWeight {
    if (!hasWeightData) return 0;

    return sortedWeights
        .map((entry) => entry.weight)
        .reduce((first, second) => first > second ? first : second);
  }

  double get averageWeight {
    if (!hasWeightData) return 0;

    final total = sortedWeights.fold<double>(
      0,
      (sum, entry) => sum + entry.weight,
    );

    return total / sortedWeights.length;
  }

  double get totalChange {
    if (!hasEnoughChartData) return 0;

    return latestWeight - firstWeight;
  }

  double get absoluteChange => totalChange.abs();

  bool get isLosingWeight => totalChange < 0;

  bool get isGainingWeight => totalChange > 0;

  bool get isStableWeight => totalChange.abs() < 0.05;

  Color get trendColor {
    if (isLosingWeight) {
      return AppTheme.success;
    }

    if (isGainingWeight) {
      return AppTheme.warning;
    }

    return AppTheme.info;
  }

  IconData get trendIcon {
    if (isLosingWeight) {
      return Icons.trending_down_rounded;
    }

    if (isGainingWeight) {
      return Icons.trending_up_rounded;
    }

    return Icons.trending_flat_rounded;
  }

  String get trendLabel {
    if (!hasEnoughChartData) {
      return 'Waiting for data';
    }

    if (isLosingWeight) {
      return '${absoluteChange.toStringAsFixed(1)} kg lost';
    }

    if (isGainingWeight) {
      return '${absoluteChange.toStringAsFixed(1)} kg gained';
    }

    return 'Weight stable';
  }

  String get summaryText {
    if (!hasWeightData) {
      return 'Add your first weight entry to begin tracking your progress.';
    }

    if (!hasEnoughChartData) {
      return 'Add another weight entry to reveal your progress trend.';
    }

    if (isLosingWeight) {
      return 'Your weight is trending downward across the recorded period.';
    }

    if (isGainingWeight) {
      return 'Your weight is trending upward across the recorded period.';
    }

    return 'Your weight has remained stable across recent entries.';
  }

  List<FlSpot> get chartSpots {
    return sortedWeights.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  double get chartMinY {
    if (!hasWeightData) return 0;

    final range = highestWeight - lowestWeight;
    final padding = range < 2 ? 2.0 : range * 0.18;

    final value = lowestWeight - padding;

    return value < 0 ? 0 : value;
  }

  double get chartMaxY {
    if (!hasWeightData) return 100;

    final range = highestWeight - lowestWeight;
    final padding = range < 2 ? 2.0 : range * 0.18;

    return highestWeight + padding;
  }

  double get horizontalInterval {
    final range = chartMaxY - chartMinY;

    if (range <= 5) return 1;
    if (range <= 12) return 2;
    if (range <= 25) return 5;

    return 10;
  }

  double get bottomTitleInterval {
    final length = sortedWeights.length;

    if (length <= 6) return 1;
    if (length <= 12) return 2;
    if (length <= 24) return 4;

    return (length / 6).ceilToDouble();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
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
              bottom: -92,
              left: -72,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: trendColor.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WeightHeader(
                    hasWeightData: hasWeightData,
                    latestWeight: latestWeight,
                    summaryText: summaryText,
                    trendColor: trendColor,
                    trendIcon: trendIcon,
                    trendLabel: trendLabel,
                  ),
                  const SizedBox(height: 22),

                  if (hasWeightData) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _WeightMetricCard(
                            title: 'Starting',
                            value: '${firstWeight.toStringAsFixed(1)} kg',
                            icon: Icons.flag_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WeightMetricCard(
                            title: 'Latest',
                            value: '${latestWeight.toStringAsFixed(1)} kg',
                            icon: Icons.monitor_weight_outlined,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _WeightMetricCard(
                            title: 'Lowest',
                            value: '${lowestWeight.toStringAsFixed(1)} kg',
                            icon: Icons.south_rounded,
                            color: AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WeightMetricCard(
                            title: 'Average',
                            value: '${averageWeight.toStringAsFixed(1)} kg',
                            icon: Icons.analytics_outlined,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 22, 12, 10),
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
                    child: SizedBox(
                      height: 250,
                      child: !hasEnoughChartData
                          ? _WeightChartEmptyState(
                              hasWeightData: hasWeightData,
                              latestWeight: latestWeight,
                            )
                          : LineChart(
                              _buildChartData(isDarkMode),
                              duration: const Duration(milliseconds: 850),
                              curve: Curves.easeOutCubic,
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (hasWeightData)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppChip(
                          label:
                              '${sortedWeights.length} ${sortedWeights.length == 1 ? 'entry' : 'entries'}',
                          icon: Icons.history_rounded,
                        ),
                        AppChip(
                          label: trendLabel,
                          icon: trendIcon,
                          backgroundColor: trendColor.withValues(alpha: 0.12),
                          foregroundColor: trendColor,
                        ),
                        AppChip(
                          label:
                              'Highest ${highestWeight.toStringAsFixed(1)} kg',
                          icon: Icons.north_rounded,
                          backgroundColor: AppTheme.warning.withValues(alpha: 0.12),
                          foregroundColor: AppTheme.warning,
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

  LineChartData _buildChartData(bool isDarkMode) {
    return LineChartData(
      minX: 0,
      maxX: (sortedWeights.length - 1).toDouble(),
      minY: chartMinY,
      maxY: chartMaxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: horizontalInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.black.withValues(alpha: 0.055),
            strokeWidth: 1,
            dashArray: const [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: horizontalInterval,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: bottomTitleInterval,
            getTitlesWidget: (value, meta) {
              final index = value.round();

              if (index < 0 || index >= sortedWeights.length) {
                return const SizedBox.shrink();
              }

              final shouldShow =
                  index == 0 ||
                  index == sortedWeights.length - 1 ||
                  index % bottomTitleInterval.round() == 0;

              if (!shouldShow) {
                return const SizedBox.shrink();
              }

              final date = sortedWeights[index].createdAt;

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 9,
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchSpotThreshold: 28,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: AppTheme.primary.withValues(alpha: 0.35),
                strokeWidth: 1.5,
                dashArray: const [4, 4],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: AppTheme.primary,
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          getTooltipColor: (_) => AppTheme.darkBackground,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.round().clamp(0, sortedWeights.length - 1);

              final date = sortedWeights[index].createdAt;

              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} kg\n',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text: _formatDate(date),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: chartSpots,
          isCurved: true,
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          barWidth: 4,
          isStrokeCapRound: true,
          color: AppTheme.primary,
          shadow: Shadow(
            color: AppTheme.primary.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              final index = spot.x.round();

              return index == 0 ||
                  index == sortedWeights.length - 1 ||
                  sortedWeights.length <= 7;
            },
            getDotPainter: (spot, percent, barData, index) {
              final isLatest = index == sortedWeights.length - 1;

              return FlDotCirclePainter(
                radius: isLatest ? 6 : 4,
                color: isLatest ? trendColor : AppTheme.primary,
                strokeWidth: 2.5,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.28),
                AppTheme.primary.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightHeader extends StatelessWidget {
  final bool hasWeightData;
  final double latestWeight;
  final String summaryText;
  final Color trendColor;
  final IconData trendIcon;
  final String trendLabel;

  const _WeightHeader({
    required this.hasWeightData,
    required this.latestWeight,
    required this.summaryText,
    required this.trendColor,
    required this.trendIcon,
    required this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
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
            Icons.monitor_weight_rounded,
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
                'Weight History',
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
        if (hasWeightData) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${latestWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, color: trendColor, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    trendLabel,
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WeightMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _WeightMetricCard({
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
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

class _WeightChartEmptyState extends StatelessWidget {
  final bool hasWeightData;
  final double latestWeight;

  const _WeightChartEmptyState({
    required this.hasWeightData,
    required this.latestWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: AppTheme.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasWeightData
                  ? '${latestWeight.toStringAsFixed(1)} kg recorded'
                  : 'No Weight Data Yet',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              hasWeightData
                  ? 'Add at least one more weight entry to display your trend chart.'
                  : 'Update your weight from your profile to begin tracking progress.',
              textAlign: TextAlign.center,
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
    );
  }
}
