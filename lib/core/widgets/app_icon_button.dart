import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 46,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    scale = Tween<double>(
      begin: 1,
      end: .92,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (widget.onPressed == null) return;

    await HapticService.selection();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => controller.forward(),
      onTapCancel: () => controller.reverse(),
      onTapUp: (_) => controller.reverse(),
      onTap: _tap,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.backgroundColor ?? theme.cardColor,
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: .06)
                  : Colors.black.withValues(alpha: .06),
            ),
          ),
          child: Icon(widget.icon, color: widget.iconColor ?? AppTheme.primary),
        ),
      ),
    );
  }
}
