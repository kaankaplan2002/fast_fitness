import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class BmiCard extends StatelessWidget {
  final double? weight;
  final double? height;

  const BmiCard({
    super.key,
    required this.weight,
    required this.height,
  });

  double? get _bmi {
    if (weight == null || height == null || height == 0) return null;
    final heightMeter = height! / 100;
    return weight! / (heightMeter * heightMeter);
  }

  String get _category {
    final value = _bmi;
    if (value == null) return 'No data';
    if (value < 18.5) return 'Underweight';
    if (value < 25.0) return 'Normal';
    if (value < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _categoryColor(double? value) {
    if (value == null) return AppTheme.textSecondary;
    if (value < 18.5) return AppTheme.info;
    if (value < 25.0) return AppTheme.success;
    if (value < 30.0) return AppTheme.warning;
    return AppTheme.error;
  }

  // Returns normalized position on the BMI scale (10 to 40) clamped 0–1
  double _scalePosition(double? value) {
    if (value == null) return 0;
    return ((value - 10) / 30).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final bmiValue = _bmi;
    final accent = _categoryColor(bmiValue);
    final bmiText = bmiValue == null ? '-' : bmiValue.toStringAsFixed(1);
    final hasData = weight != null && height != null;

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
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
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
                      'Body Mass Index',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasData
                          ? 'Based on your weight and height'
                          : 'Update your profile to see BMI',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BMI value row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bmiText,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'BMI',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Text(
                  _category,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Scale bar
          _BmiScaleBar(position: _scalePosition(bmiValue), accent: accent),
          const SizedBox(height: 10),

          // Scale labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Under',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Text(
                'Normal',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Text(
                'Over',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Text(
                'Obese',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BmiScaleBar extends StatelessWidget {
  final double position; // 0.0 to 1.0
  final Color accent;

  const _BmiScaleBar({required this.position, required this.accent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final indicatorX = (position * totalWidth).clamp(6.0, totalWidth - 6.0);

        return SizedBox(
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient bar
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.info,
                          AppTheme.success,
                          AppTheme.warning,
                          AppTheme.error,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Indicator dot
              Positioned(
                top: 4,
                left: indicatorX - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}