import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  final double? currentWeight;
  final double? targetWeight;

  const GoalProgressCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
  });

  double get _progress {
    if (currentWeight == null || targetWeight == null) return 0;
    if (currentWeight == targetWeight) return 1;

    final difference = (currentWeight! - targetWeight!).abs();
    if (difference == 0) return 1;

    final remaining = (currentWeight! - targetWeight!).abs();
    final calculated = 1 - (remaining / difference);
    if (calculated.isNaN || calculated.isInfinite) return 0;
    return calculated.clamp(0.0, 1.0);
  }

  String get _remainingText {
    if (currentWeight == null || targetWeight == null) return 'Set a target weight in your profile';
    final diff = currentWeight! - targetWeight!;
    if (diff.abs() < 0.05) return 'Target reached!';
    final label = diff > 0 ? 'to lose' : 'to gain';
    return '${diff.abs().toStringAsFixed(1)} kg $label';
  }

  bool get _isGoalToLose =>
      currentWeight != null && targetWeight != null && currentWeight! > targetWeight!;

  Color _accentColor(bool isDark) {
    if (currentWeight == null || targetWeight == null) return AppTheme.primary;
    final p = _progress;
    if (p >= 1.0) return AppTheme.success;
    if (p >= 0.75) return const Color(0xFF22C55E);
    if (p >= 0.5) return AppTheme.primary;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final accent = _accentColor(isDark);
    final progressPercent = (_progress * 100).round();
    final hasData = currentWeight != null && targetWeight != null;
    final targetText = targetWeight == null
        ? 'Not set'
        : '${targetWeight!.toStringAsFixed(1)} kg';
    final currentText = currentWeight == null
        ? 'Not set'
        : '${currentWeight!.toStringAsFixed(1)} kg';

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
          // Header row
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  _progress >= 1.0
                      ? Icons.emoji_events_rounded
                      : (_isGoalToLose
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded),
                  color: accent,
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
                      'Goal Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasData
                          ? (_isGoalToLose ? 'Weight loss goal' : 'Weight gain goal')
                          : 'No goal set',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Current / Target row
          Row(
            children: [
              Expanded(
                child: _WeightLabel(
                  label: 'Current',
                  value: currentText,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeightLabel(
                  label: 'Target',
                  value: targetText,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 13,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),

          // Remaining text
          Text(
            _remainingText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _WeightLabel({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}