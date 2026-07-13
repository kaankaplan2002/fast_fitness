import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/profile/data/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final cardBgColor = theme.cardColor;
    final innerBgColor = isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final borderColor = badge.unlocked
        ? AppTheme.primary.withValues(alpha: .45)
        : (isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08));

    final iconColor = badge.unlocked
        ? AppTheme.primary
        : AppTheme.textSecondary;

    final titleColor = badge.unlocked
        ? (isDarkMode ? Colors.white : AppTheme.textDark)
        : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: badge.unlocked
                      ? AppTheme.primary.withValues(alpha: .16)
                      : innerBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(badge.icon, color: iconColor, size: 27),
              ),
              const Spacer(),
              Icon(
                badge.unlocked
                    ? Icons.check_circle_rounded
                    : Icons.lock_rounded,
                color: badge.unlocked
                    ? AppTheme.success
                    : AppTheme.textSecondary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            badge.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: badge.progress,
              minHeight: 8,
              backgroundColor: innerBgColor,
              color: badge.unlocked ? AppTheme.success : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.unlocked
                ? 'Completed'
                : '${badge.currentValue}/${badge.targetValue}',
            style: TextStyle(
              color: badge.unlocked ? AppTheme.success : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
