import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, danger, ghost }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonType type;
  final double height;
  final double borderRadius;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.height = 56,
    this.borderRadius = 18,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scaleAnimation;

  bool get isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (isDisabled) return;

    await HapticService.light();
    widget.onPressed?.call();
  }

  Color _backgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isDisabled) {
      return isDarkMode
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08);
    }

    switch (widget.type) {
      case AppButtonType.primary:
        return AppTheme.primary;
      case AppButtonType.secondary:
        return theme.cardColor;
      case AppButtonType.danger:
        return AppTheme.error;
      case AppButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isDisabled) {
      return isDarkMode
          ? Colors.white.withValues(alpha: 0.42)
          : Colors.black.withValues(alpha: 0.38);
    }

    switch (widget.type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
      case AppButtonType.ghost:
        return AppTheme.primary;
    }
  }

  Border? _border(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    switch (widget.type) {
      case AppButtonType.secondary:
        return Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        );
      case AppButtonType.ghost:
        return Border.all(color: AppTheme.primary.withValues(alpha: 0.26));
      case AppButtonType.primary:
      case AppButtonType.danger:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: isDisabled ? null : (_) => controller.forward(),
      onTapCancel: isDisabled ? null : () => controller.reverse(),
      onTapUp: isDisabled ? null : (_) => controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _backgroundColor(context),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _border(context),
            boxShadow: widget.type == AppButtonType.primary && !isDisabled
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: _foregroundColor(context),
                    ),
                  )
                : Row(
                    mainAxisSize: widget.fullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: _foregroundColor(context),
                          size: 21,
                        ),
                        const SizedBox(width: 9),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: _foregroundColor(context),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return button;
    }

    return IntrinsicWidth(child: button);
  }
}
