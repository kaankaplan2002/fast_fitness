import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:flutter/material.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 24,
    this.showBorder = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    await HapticService.light();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final card = GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => controller.forward(),
      onTapCancel: widget.onTap == null ? null : () => controller.reverse(),
      onTapUp: widget.onTap == null ? null : (_) => controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.cardColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.showBorder
                ? Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.07),
                  )
                : null,
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.16)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) {
      return card;
    }

    return Semantics(button: true, child: card);
  }
}
