import 'dart:async';

import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class RestTimerSheet extends StatefulWidget {
  final int restSeconds;
  final VoidCallback onFinished;

  const RestTimerSheet({
    super.key,
    required this.restSeconds,
    required this.onFinished,
  });

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet>
    with SingleTickerProviderStateMixin {
  Timer? timer;

  late int initialSeconds;
  late int remainingSeconds;

  bool isFinishing = false;

  late final AnimationController pulseController;
  late final Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    initialSeconds = widget.restSeconds < 15 ? 15 : widget.restSeconds;
    remainingSeconds = initialSeconds;

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || isFinishing) return;

      if (remainingSeconds <= 1) {
        await _finishRest();
        return;
      }

      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 3) {
        await HapticService.selection();

        if (!pulseController.isAnimating) {
          await pulseController.forward();
          await pulseController.reverse();
        }
      }
    });
  }

  Future<void> _finishRest() async {
    if (isFinishing) return;

    isFinishing = true;
    timer?.cancel();

    await HapticService.success();

    if (!mounted) return;

    Navigator.of(context).pop();
    widget.onFinished();
  }

  Future<void> _skipRest() async {
    if (isFinishing) return;

    await HapticService.light();
    await _finishRest();
  }

  Future<void> _addTime() async {
    if (isFinishing) return;

    await HapticService.light();

    setState(() {
      remainingSeconds += 15;

      if (remainingSeconds > initialSeconds) {
        initialSeconds = remainingSeconds;
      }
    });
  }

  Future<void> _removeTime() async {
    if (isFinishing) return;

    await HapticService.light();

    setState(() {
      remainingSeconds = (remainingSeconds - 15).clamp(5, 3600);
    });
  }

  double get progress {
    if (initialSeconds <= 0) return 0;

    return (remainingSeconds / initialSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  bool get isCountdownActive => remainingSeconds <= 3;

  String get countdownText {
    if (remainingSeconds <= 0) return 'GO';
    return '$remainingSeconds';
  }

  String get helperText {
    if (isCountdownActive) {
      return 'Your next set starts in a moment.';
    }

    if (remainingSeconds <= 15) {
      return 'Get ready for the next set.';
    }

    return 'Recover, breathe, and prepare for your next set.';
  }

  Color get progressColor {
    if (isCountdownActive) {
      return AppTheme.success;
    }

    if (remainingSeconds <= 15) {
      return AppTheme.warning;
    }

    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXXLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    isCountdownActive
                        ? Icons.bolt_rounded
                        : Icons.self_improvement_rounded,
                    color: progressColor,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCountdownActive ? 'Get Ready' : 'Rest Time',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        helperText,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ScaleTransition(
              scale: pulseAnimation,
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.07),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Container(
                      width: 164,
                      height: 164,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: progressColor.withValues(alpha: 0.07),
                        border: Border.all(
                          color: progressColor.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            isCountdownActive ? countdownText : formattedTime,
                            key: ValueKey(
                              isCountdownActive ? countdownText : formattedTime,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: progressColor,
                              fontSize: isCountdownActive ? 72 : 48,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _TimerControlButton(
                    icon: Icons.remove_rounded,
                    label: '-15 sec',
                    onPressed: _removeTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimerControlButton(
                    icon: Icons.add_rounded,
                    label: '+15 sec',
                    onPressed: _addTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              text: isCountdownActive ? 'Start Next Set' : 'Skip Rest',
              icon: isCountdownActive
                  ? Icons.play_arrow_rounded
                  : Icons.skip_next_rounded,
              onPressed: isFinishing ? null : _skipRest,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _TimerControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primary, size: 21),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
