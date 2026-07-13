import 'dart:io';

import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/features/history/data/models/workout_history_model.dart';
import 'package:fast_fitness/features/history/presentation/widgets/workout_share_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class WorkoutHistoryDetailScreen extends StatefulWidget {
  final WorkoutHistoryModel workout;

  const WorkoutHistoryDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutHistoryDetailScreen> createState() =>
      _WorkoutHistoryDetailScreenState();
}

class _WorkoutHistoryDetailScreenState
    extends State<WorkoutHistoryDetailScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  bool isSharing = false;

  String get formattedDate {
    final date = widget.workout.completedAt;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get formattedTime {
    final date = widget.workout.completedAt;

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _goBack() async {
    await HapticService.light();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _shareWorkout() async {
    await HapticService.light();

    try {
      setState(() {
        isSharing = true;
      });

      final imageBytes = await screenshotController.capture(pixelRatio: 2.5);

      if (imageBytes == null) {
        await HapticService.error();

        if (!mounted) return;

        SnackBarService.error(
          context,
          'Share image could not be created.',
          title: 'Share Failed',
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/fastfitness_workout_${DateTime.now().millisecondsSinceEpoch}.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'My FastFitness workout: ${widget.workout.workoutTitle}');

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Workout share card is ready.',
        title: 'Shared',
      );
    } catch (error) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Workout could not be shared.',
        title: 'Share Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Detail'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: isSharing ? null : _shareWorkout,
            icon: isSharing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Material(
                  color: Colors.transparent,
                  child: WorkoutShareCard(workout: widget.workout),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSharing ? null : _shareWorkout,
                  icon: isSharing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.ios_share_rounded),
                  label: Text(
                    isSharing ? 'Preparing Share Card...' : 'Share Workout',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Workout Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DetailStatCard(
                      title: 'Minutes',
                      value: '${widget.workout.durationMinutes}',
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _DetailStatCard(
                      title: 'Exercises',
                      value: '${widget.workout.exerciseCount}',
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DetailStatCard(
                      title: 'Calories',
                      value: '${widget.workout.caloriesBurned}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: _DetailStatCard(
                      title: 'Status',
                      value: 'Done',
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  'Completed on $formattedDate at $formattedTime. This workout was saved successfully to your history.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
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

class _DetailStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isDone = title == 'Status';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDone ? AppTheme.success : AppTheme.primary,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
