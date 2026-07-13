import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

enum AppStatusType { success, warning, error, info }

class AppStatusBanner extends StatelessWidget {
  final String title;
  final String message;
  final AppStatusType type;

  const AppStatusBanner({
    super.key,
    required this.title,
    required this.message,
    this.type = AppStatusType.info,
  });

  Color get _color {
    switch (type) {
      case AppStatusType.success:
        return AppTheme.success;
      case AppStatusType.warning:
        return AppTheme.warning;
      case AppStatusType.error:
        return AppTheme.error;
      case AppStatusType.info:
        return AppTheme.primary;
    }
  }

  IconData get _icon {
    switch (type) {
      case AppStatusType.success:
        return Icons.check_circle_rounded;
      case AppStatusType.warning:
        return Icons.warning_amber_rounded;
      case AppStatusType.error:
        return Icons.error_rounded;
      case AppStatusType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: _color.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
