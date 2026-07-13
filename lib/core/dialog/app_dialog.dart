import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

enum AppDialogType { success, error, warning, info, confirm }

class AppDialog {
  const AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await _show<bool>(
      context,
      type: isDanger ? AppDialogType.warning : AppDialogType.confirm,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      showCancelButton: true,
      isDanger: isDanger,
    );

    return result ?? false;
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Done',
  }) async {
    await _show<void>(
      context,
      type: AppDialogType.success,
      title: title,
      message: message,
      confirmText: buttonText,
      showCancelButton: false,
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await _show<void>(
      context,
      type: AppDialogType.error,
      title: title,
      message: message,
      confirmText: buttonText,
      showCancelButton: false,
      isDanger: true,
    );
  }

  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await _show<void>(
      context,
      type: AppDialogType.warning,
      title: title,
      message: message,
      confirmText: buttonText,
      showCancelButton: false,
      isDanger: true,
    );
  }

  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await _show<void>(
      context,
      type: AppDialogType.info,
      title: title,
      message: message,
      confirmText: buttonText,
      showCancelButton: false,
    );
  }

  static Future<T?> _show<T>(
    BuildContext context, {
    required AppDialogType type,
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Cancel',
    required bool showCancelButton,
    bool isDanger = false,
  }) async {
    if (!context.mounted) return null;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: showCancelButton,
      barrierLabel: title,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _AppDialogContent(
          type: type,
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          showCancelButton: showCancelButton,
          isDanger: isDanger,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

class _AppDialogContent extends StatelessWidget {
  final AppDialogType type;
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool showCancelButton;
  final bool isDanger;

  const _AppDialogContent({
    required this.type,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.showCancelButton,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(type);
    final icon = _iconForType(type);
    final confirmColor = isDanger ? AppTheme.error : color;

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 26),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.14),
                  ),
                  child: Icon(icon, color: color, size: 38),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.68,
                    ),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    if (showCancelButton) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (showCancelButton) {
                            Navigator.of(context).pop(true);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(AppDialogType type) {
    switch (type) {
      case AppDialogType.success:
        return AppTheme.success;
      case AppDialogType.error:
        return AppTheme.error;
      case AppDialogType.warning:
        return Colors.orange;
      case AppDialogType.info:
        return AppTheme.primary;
      case AppDialogType.confirm:
        return AppTheme.primary;
    }
  }

  IconData _iconForType(AppDialogType type) {
    switch (type) {
      case AppDialogType.success:
        return Icons.check_circle_rounded;
      case AppDialogType.error:
        return Icons.error_rounded;
      case AppDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogType.info:
        return Icons.info_rounded;
      case AppDialogType.confirm:
        return Icons.help_rounded;
    }
  }
}
