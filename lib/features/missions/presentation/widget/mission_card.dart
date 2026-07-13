import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/missions/data/model/mission_model.dart';
import 'package:flutter/material.dart';

class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final bool claiming;
  final VoidCallback onClaim;

  const MissionCard({
    super.key,
    required this.mission,
    required this.claiming,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final canClaim = mission.completed && !mission.claimed && !claiming;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.cardColor,
        border: Border.all(
          color: mission.completed
              ? AppTheme.primary.withValues(alpha: 0.45)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: mission.completed
                ? AppTheme.primary.withValues(alpha: 0.14)
                : (isDarkMode
                    ? Colors.black.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.04)),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mission.completed
                  ? AppTheme.primary.withValues(alpha: 0.18)
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Center(
              child: Text(mission.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  mission.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    minHeight: 8,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.completed ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      '${mission.currentValue.clamp(0, mission.requiredValue)} / ${mission.requiredValue}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: mission.completed
                            ? AppTheme.success
                            : theme.textTheme.bodySmall?.color?.withValues(
                                alpha: 0.62,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppTheme.primary.withValues(alpha: 0.14),
                      ),
                      child: Text(
                        '+${mission.rewardValue} XP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          SizedBox(
            width: 92,
            child: ElevatedButton(
              onPressed: canClaim ? onClaim : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: mission.claimed
                    ? AppTheme.success.withValues(alpha: 0.4)
                    : AppTheme.primary,
                disabledBackgroundColor: mission.claimed
                    ? AppTheme.success.withValues(alpha: 0.24)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08)),
                foregroundColor: Colors.white,
                disabledForegroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.48)
                    : Colors.black.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: claiming
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      mission.claimed
                          ? 'Claimed'
                          : mission.completed
                              ? 'Claim'
                              : 'Locked',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
