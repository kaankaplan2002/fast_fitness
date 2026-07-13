import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final bool fullScreen;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 42,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final widgetContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppTheme.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 18),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (!fullScreen) {
      return Center(child: widgetContent);
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(child: Center(child: widgetContent)),
    );
  }
}
