import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class AppGradientContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool showShadow;

  const AppGradientContainer({
    super.key,
    required this.child,
    this.color = AppTheme.primary,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = AppTheme.radiusXXLarge,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.96), color.withValues(alpha: 0.58)],
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.24),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
