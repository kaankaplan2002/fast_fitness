import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class SnackBarService {
  const SnackBarService._();

  static void success(BuildContext context, String message, {String? title}) {
    _show(
      context,
      message,
      title: title ?? 'Success',
      type: SnackBarType.success,
    );
  }

  static void error(BuildContext context, String message, {String? title}) {
    _show(context, message, title: title ?? 'Error', type: SnackBarType.error);
  }

  static void info(BuildContext context, String message, {String? title}) {
    _show(context, message, title: title ?? 'Info', type: SnackBarType.info);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    _show(
      context,
      message,
      title: title ?? 'Warning',
      type: SnackBarType.warning,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required String title,
    required SnackBarType type,
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        content: _SnackBarContent(title: title, message: message, type: type),
      ),
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final SnackBarType type;

  const _SnackBarContent({
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(type);
    final icon = _iconForType(type);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.68,
                    ),
                    height: 1.32,
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

  Color _colorForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppTheme.success;
      case SnackBarType.error:
        return AppTheme.error;
      case SnackBarType.info:
        return AppTheme.primary;
      case SnackBarType.warning:
        return Colors.orange;
    }
  }

  IconData _iconForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
    }
  }
}
