import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

enum AppBadgeType { success, warning, error, primary }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeType type;

  const AppBadge({
    super.key,
    required this.text,
    this.type = AppBadgeType.primary,
  });

  Color get background {
    switch (type) {
      case AppBadgeType.success:
        return AppTheme.success.withValues(alpha: .14);
      case AppBadgeType.warning:
        return Colors.orange.withValues(alpha: .14);
      case AppBadgeType.error:
        return AppTheme.error.withValues(alpha: .14);
      case AppBadgeType.primary:
        return AppTheme.primary.withValues(alpha: .14);
    }
  }

  Color get foreground {
    switch (type) {
      case AppBadgeType.success:
        return AppTheme.success;
      case AppBadgeType.warning:
        return Colors.orange;
      case AppBadgeType.error:
        return AppTheme.error;
      case AppBadgeType.primary:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
