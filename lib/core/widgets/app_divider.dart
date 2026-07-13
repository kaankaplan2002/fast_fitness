import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final EdgeInsetsGeometry margin;
  final Color? color;

  const AppDivider({
    super.key,
    this.height = 1,
    this.thickness = .7,
    this.margin = const EdgeInsets.symmetric(vertical: 18),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: Divider(
        height: height,
        thickness: thickness,
        color: color ??
            (isDarkMode
                ? Colors.white.withValues(alpha: .06)
                : Colors.black.withValues(alpha: .06)),
      ),
    );
  }
}
