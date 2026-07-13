import 'dart:ui';

import 'package:fast_fitness/core/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final bool blurBackground;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.blurBackground = true,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        child,

        Positioned.fill(
          child: IgnorePointer(
            ignoring: dismissible,
            child: blurBackground
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withValues(alpha: .35)),
                  )
                : Container(color: Colors.black.withValues(alpha: .45)),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            ignoring: dismissible,
            child: Center(
              child: Container(
                width: 180,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: .06)
                        : Colors.black.withValues(alpha: .06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: AppLoadingIndicator(
                  message: message ?? 'Please wait...',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
