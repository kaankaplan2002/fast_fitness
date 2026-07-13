import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/dialog/app_dialog.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/workout/data/local/workout_session_storage.dart';
import 'package:fast_fitness/features/workout/domain/models/workout_session_model.dart';
import 'package:fast_fitness/features/workout/presentation/providers/workout_provider.dart';
import 'package:fast_fitness/features/workout/presentation/widgets/rest_timer_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String title;
  final List<ExerciseModel> exercises;
  final int initialExerciseIndex;
  final int initialCompletedSets;
  final int initialElapsedSeconds;
  final String source;
  final String focus;

  const WorkoutSessionScreen({
    super.key,
    required this.title,
    required this.exercises,
    this.initialExerciseIndex = 0,
    this.initialCompletedSets = 0,
    this.initialElapsedSeconds = 0,
    this.source = 'manual',
    this.focus = 'General',
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late int currentExerciseIndex;
  late int completedSets;
  int restAdjustmentSeconds = 0;
  late int elapsedSeconds;

  bool isPaused = false;
  Timer? workoutTimer;

  final storage = WorkoutSessionStorage();

  @override
  void initState() {
    super.initState();
    currentExerciseIndex = widget.initialExerciseIndex;
    completedSets = widget.initialCompletedSets;
    elapsedSeconds = widget.initialElapsedSeconds;
    _startWorkoutTimer();
    _saveCurrentSession();
  }

  @override
  void dispose() {
    workoutTimer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    workoutTimer?.cancel();

    workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !isPaused) {
        setState(() {
          elapsedSeconds++;
        });

        _saveCurrentSession();
      }
    });
  }

  Future<void> _saveCurrentSession() async {
    if (widget.exercises.isEmpty) return;

    await storage.saveSession(
      WorkoutSessionModel(
        title: widget.title,
        exercises: widget.exercises,
        currentExerciseIndex: currentExerciseIndex,
        completedSets: completedSets,
        elapsedSeconds: elapsedSeconds,
      ),
    );
  }

  Future<void> _togglePause() async {
    await HapticService.selection();

    setState(() {
      isPaused = !isPaused;
    });

    await _saveCurrentSession();

    if (!mounted) return;

    if (isPaused) {
      SnackBarService.info(
        context,
        'Workout paused. Your progress is saved.',
        title: 'Paused',
      );
    } else {
      SnackBarService.info(context, 'Workout resumed.', title: 'Resumed');
    }
  }

  String get formattedWorkoutTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get durationMinutes {
    final minutes = (elapsedSeconds / 60).ceil();
    return minutes == 0 ? 1 : minutes;
  }

  bool get isLastExercise =>
      currentExerciseIndex == widget.exercises.length - 1;

  ExerciseModel get currentExercise => widget.exercises[currentExerciseIndex];

  bool get isLastSet => completedSets == currentExercise.sets - 1;

  int get adjustedRestSeconds {
    final adjusted = currentExercise.restSeconds + restAdjustmentSeconds;
    if (adjusted < 15) return 15;
    return adjusted;
  }

  int get estimatedCalories => durationMinutes * 8;

  bool get isAiGeneratedWorkout {
    final title = widget.title.toLowerCase();
    return widget.source == 'ai_generated' || title.startsWith('ai ');
  }

  String get workoutSource {
    return isAiGeneratedWorkout ? 'ai_generated' : widget.source;
  }

  String get workoutFocus {
    if (widget.focus != 'General') return widget.focus;

    final title = widget.title.toLowerCase();

    if (title.contains('back')) return 'Back';
    if (title.contains('chest')) return 'Chest';
    if (title.contains('leg')) return 'Legs';
    if (title.contains('shoulder')) return 'Shoulders';
    if (title.contains('core')) return 'Core';
    if (title.contains('cardio')) return 'Cardio';

    return 'General';
  }

  Future<void> _increaseRest() async {
    if (isPaused) return;

    await HapticService.light();

    setState(() {
      restAdjustmentSeconds += 15;
    });

    await _saveCurrentSession();
  }

  Future<void> _decreaseRest() async {
    if (isPaused) return;

    await HapticService.light();

    setState(() {
      restAdjustmentSeconds -= 15;
    });

    await _saveCurrentSession();
  }

  Future<bool> _confirmExit() async {
    await HapticService.warning();

    if (!mounted) return false;

    final shouldExit = await AppDialog.confirm(
      context,
      title: 'Leave Workout?',
      message: 'Your workout progress will be saved so you can continue later.',
      confirmText: 'Leave',
      cancelText: 'Stay',
      isDanger: false,
    );

    if (shouldExit) {
      await HapticService.selection();
    }

    return shouldExit;
  }

  Future<bool> _confirmFinishWorkout() async {
    await HapticService.medium();

    if (!mounted) return false;

    final shouldFinish = await AppDialog.confirm(
      context,
      title: 'Finish Workout?',
      message:
          'You are about to complete "${widget.title}". Your workout will be saved and added to your history.',
      confirmText: 'Finish',
      cancelText: 'Cancel',
    );

    if (shouldFinish) {
      await HapticService.success();
    }

    return shouldFinish;
  }

  Future<void> _handleBackPressed() async {
    final shouldExit = await _confirmExit();

    if (shouldExit && mounted) {
      await _saveCurrentSession();
      workoutTimer?.cancel();

      if (!mounted) return;
      context.pop();
    }
  }

  Future<void> _completeSet() async {
    if (widget.exercises.isEmpty || isPaused) return;

    await HapticService.light();

    if (isLastExercise && isLastSet) {
      final shouldFinish = await _confirmFinishWorkout();

      if (!shouldFinish || !mounted) return;

      setState(() => completedSets = currentExercise.sets);
      await _finishWorkout();
      return;
    }

    _showRestTimer();
  }

  void _showRestTimer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return RestTimerSheet(
          restSeconds: adjustedRestSeconds,
          onFinished: _moveToNextStep,
        );
      },
    );
  }

  Future<void> _moveToNextStep() async {
    await HapticService.selection();

    if (!mounted) return;

    if (isLastSet) {
      setState(() {
        completedSets = 0;
        currentExerciseIndex++;
        restAdjustmentSeconds = 0;
      });
    } else {
      setState(() {
        completedSets++;
      });
    }

    await _saveCurrentSession();
  }

  Future<void> _finishWorkout() async {
    workoutTimer?.cancel();

    try {
      ref.read(workoutLoadingProvider.notifier).setLoading(true);

      await ref
          .read(workoutRemoteDatasourceProvider)
          .completeWorkout(
            workoutTitle: widget.title,
            exerciseCount: widget.exercises.length,
            durationMinutes: durationMinutes,
          );

      await _saveAiGeneratedMetadataIfNeeded();
      await storage.clearSession();

      await HapticService.success();

      if (!mounted) return;

      context.go(
        '/workout-summary',
        extra: {
          'title': widget.title,
          'exerciseCount': widget.exercises.length,
          'durationMinutes': durationMinutes,
          'caloriesBurned': estimatedCalories,
          'source': workoutSource,
          'focus': workoutFocus,
        },
      );
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Workout could not be saved.',
        title: 'Save Failed',
      );

      _startWorkoutTimer();
    } finally {
      ref.read(workoutLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _saveAiGeneratedMetadataIfNeeded() async {
    if (!isAiGeneratedWorkout) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ai_completed_workouts')
          .add({
        'workoutTitle': widget.title,
        'durationMinutes': durationMinutes,
        'completedAt': FieldValue.serverTimestamp(),
        'focus': workoutFocus,
      });
    } catch (_) {}
  }

  String _buttonText() {
    if (isLastExercise && isLastSet) {
      return 'Finish Workout';
    }

    if (isLastSet) {
      return 'Next Exercise';
    }

    return 'Complete Set';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = isDarkMode ? AppTheme.darkCard : AppTheme.lightCard;
    final progressTrackColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final innerContainerColor = isDarkMode
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    final isLoading = ref.watch(workoutLoadingProvider);

    if (widget.exercises.isEmpty) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No exercises found for this workout.')),
      );
    }

    final progressValue = completedSets / currentExercise.sets;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            onPressed: _handleBackPressed,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          actions: [
            IconButton(
              onPressed: _togglePause,
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  formattedWorkoutTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAiGeneratedWorkout) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'AI Generated • $workoutFocus',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      'Exercise ${currentExerciseIndex + 1} of ${widget.exercises.length}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentExercise.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentExercise.equipment} • ${currentExercise.difficulty}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Target',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${currentExercise.sets} sets x ${currentExercise.reps} reps',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: innerContainerColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: isPaused ? null : _decreaseRest,
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Rest',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${adjustedRestSeconds}s',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: isPaused ? null : _increaseRest,
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 10,
                            backgroundColor: progressTrackColor,
                            color: AppTheme.success,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '$completedSets / ${currentExercise.sets} sets completed',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: isLoading || isPaused ? null : _completeSet,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _buttonText(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              if (isPaused)
                Positioned.fill(
                  child: Container(
                    color: scaffoldBg.withValues(alpha: .72),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pause_circle_filled_rounded,
                              color: AppTheme.primary,
                              size: 70,
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Workout Paused',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Take a moment. Resume when you are ready.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _togglePause,
                              child: const Text(
                                'Resume Workout',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
