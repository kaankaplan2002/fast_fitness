import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class PersonalRecordsCard extends StatelessWidget {
  final int longestWorkout;
  final int totalWorkouts;
  final int streak;
  final int weightEntries;

  const PersonalRecordsCard({
    super.key,
    required this.longestWorkout,
    required this.totalWorkouts,
    required this.streak,
    required this.weightEntries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;

    final records = [
      _Record(
        icon: Icons.timer_rounded,
        label: 'Longest\nWorkout',
        value: longestWorkout == 0 ? '-' : '$longestWorkout min',
        color: AppTheme.primary,
      ),
      _Record(
        icon: Icons.fitness_center_rounded,
        label: 'Completed\nWorkouts',
        value: totalWorkouts.toString(),
        color: const Color(0xFF8B6CFF),
      ),
      _Record(
        icon: Icons.local_fire_department_rounded,
        label: 'Current\nStreak',
        value: streak == 0 ? '-' : '$streak day${streak == 1 ? '' : 's'}',
        color: const Color(0xFFF59E0B),
      ),
      _Record(
        icon: Icons.monitor_weight_outlined,
        label: 'Weight\nEntries',
        value: weightEntries.toString(),
        color: const Color(0xFF22C55E),
      ),
    ];

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
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: AppTheme.primary,
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
                      'Personal Records',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your all-time bests',
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

          // 2x2 grid
          Row(
            children: [
              _RecordTile(record: records[0], isDark: isDark),
              const SizedBox(width: 12),
              _RecordTile(record: records[1], isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RecordTile(record: records[2], isDark: isDark),
              const SizedBox(width: 12),
              _RecordTile(record: records[3], isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _Record {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Record({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _RecordTile extends StatelessWidget {
  final _Record record;
  final bool isDark;

  const _RecordTile({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: record.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(record.icon, color: record.color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              record.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              record.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}