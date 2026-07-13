import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/personal_records/presentation/widgets/new_record_dialog.dart';
import 'package:fast_fitness/features/profile/data/services/xp_service.dart';
import 'package:fast_fitness/features/workout/data/models/workout_rating_model.dart';
import 'package:fast_fitness/features/workout/presentation/providers/workout_rating_provider.dart';
import 'package:fast_fitness/features/workout/presentation/widgets/workout_personal_best_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  final String title;
  final int exerciseCount;
  final int durationMinutes;
  final int caloriesBurned;
  final String source;
  final String focus;

  const WorkoutSummaryScreen({
    super.key,
    required this.title,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.source = 'manual',
    this.focus = 'General',
  });

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  static const int workoutCompletionXp = 100;
  static const int ratingRewardXp = 20;

  int selectedRating = 5;

  bool workoutXpGranted = false;
  bool ratingXpGranted = false;
  bool ratingSaved = false;
  bool recordDialogShown = false;
  bool isSharing = false;

  late final ConfettiController confettiController;
  late final Future<Map<String, int>> previousBestValuesFuture;
  late final Future<Map<String, bool>> personalBestsFuture;

  bool get isAiGenerated => widget.source == 'ai_generated';

  int get totalEarnedXp {
    return workoutCompletionXp + (ratingXpGranted ? ratingRewardXp : 0);
  }

  int get workoutScore {
    int score = 55;

    score += (widget.durationMinutes * 0.6).round().clamp(0, 20);
    score += (widget.exerciseCount * 3).clamp(0, 15);
    score += (widget.caloriesBurned ~/ 60).clamp(0, 10);

    if (isAiGenerated) {
      score += 3;
    }

    return score.clamp(0, 100);
  }

  String get workoutScoreLabel {
    if (workoutScore >= 95) return 'Elite';
    if (workoutScore >= 85) return 'Excellent';
    if (workoutScore >= 70) return 'Strong';
    if (workoutScore >= 55) return 'Good';

    return 'Completed';
  }

  String get feedbackText {
    switch (selectedRating) {
      case 1:
        return 'Brutal';
      case 2:
        return 'Hard';
      case 3:
        return 'Normal';
      case 4:
        return 'Good';
      default:
        return 'Amazing';
    }
  }

  String get aiEvaluationTitle {
    if (workoutScore >= 90) {
      return 'Outstanding session';
    }

    if (workoutScore >= 75) {
      return 'Strong performance';
    }

    if (workoutScore >= 60) {
      return 'Productive workout';
    }

    return 'Workout completed';
  }

  String get aiEvaluationMessage {
    final focus = widget.focus.trim().isEmpty ? 'General' : widget.focus;

    if (workoutScore >= 90) {
      return 'You delivered an excellent $focus session with strong volume '
          'and duration. Prioritize recovery before your next workout.';
    }

    if (workoutScore >= 75) {
      return 'Your $focus workout had a solid balance of duration and exercise '
          'volume. Stay consistent and gradually increase the challenge.';
    }

    if (widget.durationMinutes < 20) {
      return 'You completed your $focus workout. A slightly longer session '
          'next time may help you build more training volume.';
    }

    return 'You successfully completed your $focus workout. Keep tracking your '
        'sessions and aim for consistent progress each week.';
  }

  String get shareText {
    final sourceText = isAiGenerated
        ? 'AI-generated ${widget.focus} workout'
        : widget.title;

    return '''
FastFitness Workout Complete

$sourceText
Duration: ${widget.durationMinutes} minutes
Exercises: ${widget.exerciseCount}
Calories: ${widget.caloriesBurned} kcal
Workout Score: $workoutScore/100
Rating: $selectedRating/5

Completed with FastFitness.
''';
  }

  @override
  void initState() {
    super.initState();

    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    previousBestValuesFuture = _loadPreviousBestValues();
    personalBestsFuture = _loadPersonalBests();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _grantWorkoutXpIfNeeded();

      if (!mounted) return;

      await HapticService.success();
      confettiController.play();

      await _showNewRecordDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  int _readInt(Map<String, dynamic> data, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  Future<void> _grantWorkoutXpIfNeeded() async {
    if (workoutXpGranted) return;

    await XpService().addWorkoutCompletionXp();

    if (!mounted) return;

    setState(() {
      workoutXpGranted = true;
    });
  }

  Future<void> _grantRatingXpIfNeeded() async {
    if (ratingXpGranted) return;

    await XpService().addRatingXp();

    if (!mounted) return;

    setState(() {
      ratingXpGranted = true;
    });
  }

  Future<Map<String, int>> _loadPreviousBestValues() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const {'longestWorkout': 0, 'mostCalories': 0, 'mostExercises': 0};
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    int previousMaxDuration = 0;
    int previousMaxExercises = 0;
    int previousMaxCalories = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final duration = _readInt(data, const ['durationMinutes', 'duration']);

      final exercises = _readInt(data, const ['exerciseCount', 'exercises']);

      final storedCalories = _readInt(data, const [
        'caloriesBurned',
        'estimatedCalories',
        'calories',
      ]);

      final calories = storedCalories > 0 ? storedCalories : duration * 8;

      if (duration < widget.durationMinutes && duration > previousMaxDuration) {
        previousMaxDuration = duration;
      }

      if (exercises < widget.exerciseCount &&
          exercises > previousMaxExercises) {
        previousMaxExercises = exercises;
      }

      if (calories < widget.caloriesBurned && calories > previousMaxCalories) {
        previousMaxCalories = calories;
      }
    }

    return {
      'longestWorkout': previousMaxDuration,
      'mostCalories': previousMaxCalories,
      'mostExercises': previousMaxExercises,
    };
  }

  Future<Map<String, bool>> _loadPersonalBests() async {
    final previous = await previousBestValuesFuture;

    return {
      'longestWorkout':
          widget.durationMinutes > (previous['longestWorkout'] ?? 0),
      'mostCalories': widget.caloriesBurned > (previous['mostCalories'] ?? 0),
      'mostExercises': widget.exerciseCount > (previous['mostExercises'] ?? 0),
    };
  }

  Future<void> _showNewRecordDialogIfNeeded() async {
    if (recordDialogShown || !mounted) return;

    recordDialogShown = true;

    final previous = await previousBestValuesFuture;

    if (!mounted) return;

    final previousLongest = previous['longestWorkout'] ?? 0;
    final previousCalories = previous['mostCalories'] ?? 0;
    final previousExercises = previous['mostExercises'] ?? 0;

    if (widget.durationMinutes > previousLongest) {
      await HapticService.success();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) {
          return NewRecordDialog(
            title: 'Longest Workout',
            oldValue: '$previousLongest min',
            newValue: '${widget.durationMinutes} min',
          );
        },
      );

      return;
    }

    if (widget.caloriesBurned > previousCalories) {
      await HapticService.success();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) {
          return NewRecordDialog(
            title: 'Highest Calories',
            oldValue: '$previousCalories kcal',
            newValue: '${widget.caloriesBurned} kcal',
          );
        },
      );

      return;
    }

    if (widget.exerciseCount > previousExercises) {
      await HapticService.success();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) {
          return NewRecordDialog(
            title: 'Most Exercises',
            oldValue: '$previousExercises',
            newValue: '${widget.exerciseCount}',
          );
        },
      );
    }
  }

  Future<void> _selectRating(int rating) async {
    if (ratingSaved) return;

    await HapticService.selection();

    if (!mounted) return;

    setState(() {
      selectedRating = rating;
    });
  }

  Future<void> _saveRating() async {
    if (ratingSaved) return;

    await HapticService.light();

    try {
      ref.read(workoutRatingLoadingProvider.notifier).setLoading(true);

      await _grantWorkoutXpIfNeeded();

      final rating = WorkoutRatingModel(
        workoutTitle: widget.title,
        rating: selectedRating,
        feedback: feedbackText,
        createdAt: DateTime.now(),
      );

      await ref.read(workoutRatingRemoteDatasourceProvider).saveRating(rating);

      await _grantRatingXpIfNeeded();

      if (!mounted) return;

      setState(() {
        ratingSaved = true;
      });

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Your workout rating was saved and $ratingRewardXp XP was added.',
        title: 'Rating Saved',
      );
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Rating could not be saved.',
        title: 'Save Failed',
      );
    } finally {
      ref.read(workoutRatingLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _shareWorkout() async {
    if (isSharing) return;

    setState(() {
      isSharing = true;
    });

    try {
      await Share.share(shareText, subject: 'FastFitness Workout Complete');

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Workout summary is ready to share.',
        title: 'Share Ready',
      );
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Workout summary could not be shared.',
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

  Future<void> _goHome() async {
    await _grantWorkoutXpIfNeeded();

    if (!mounted) return;

    context.go('/home');
  }

  Future<void> _viewHistory() async {
    await _grantWorkoutXpIfNeeded();

    if (!mounted) return;

    context.push('/workout-history');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(workoutRatingLoadingProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
                child: Column(
                  children: [
                    _SuccessHeroCard(
                      title: widget.title,
                      isAiGenerated: isAiGenerated,
                      focus: widget.focus,
                      workoutScore: workoutScore,
                      workoutScoreLabel: workoutScoreLabel,
                      totalEarnedXp: totalEarnedXp,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            title: 'Minutes',
                            value: '${widget.durationMinutes}',
                            icon: Icons.timer_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SummaryItem(
                            title: 'Exercises',
                            value: '${widget.exerciseCount}',
                            icon: Icons.fitness_center_rounded,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            title: 'Calories',
                            value: '${widget.caloriesBurned}',
                            icon: Icons.local_fire_department_rounded,
                            color: AppTheme.warning,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SummaryItem(
                            title: 'Rating',
                            value: '$selectedRating/5',
                            icon: Icons.star_rounded,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    FutureBuilder<Map<String, bool>>(
                      future: personalBestsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        final data = snapshot.data;

                        if (data == null) {
                          return const SizedBox.shrink();
                        }

                        final hasPersonalBest =
                            (data['longestWorkout'] ?? false) ||
                            (data['mostCalories'] ?? false) ||
                            (data['mostExercises'] ?? false);

                        if (!hasPersonalBest) {
                          return const SizedBox.shrink();
                        }

                        return WorkoutPersonalBestCard(
                          longestWorkout: data['longestWorkout'] ?? false,
                          mostCalories: data['mostCalories'] ?? false,
                          mostExercises: data['mostExercises'] ?? false,
                        );
                      },
                    ),

                    if (isAiGenerated) ...[
                      const SizedBox(height: 24),
                      _AiEvaluationCard(
                        title: aiEvaluationTitle,
                        message: aiEvaluationMessage,
                        focus: widget.focus,
                        score: workoutScore,
                      ),
                    ],

                    const SizedBox(height: 24),

                    _RatingCard(
                      selectedRating: selectedRating,
                      feedbackText: feedbackText,
                      ratingSaved: ratingSaved,
                      ratingRewardXp: ratingRewardXp,
                      onRatingSelected: _selectRating,
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      text: ratingSaved
                          ? 'Rating Saved'
                          : 'Save Rating · +$ratingRewardXp XP',
                      icon: ratingSaved
                          ? Icons.check_circle_rounded
                          : Icons.star_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading || ratingSaved ? null : _saveRating,
                    ),

                    const SizedBox(height: 12),

                    AppButton(
                      text: isSharing ? 'Preparing Share...' : 'Share Workout',
                      icon: Icons.ios_share_rounded,
                      type: AppButtonType.secondary,
                      isLoading: isSharing,
                      onPressed: isSharing ? null : _shareWorkout,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'View History',
                            icon: Icons.history_rounded,
                            type: AppButtonType.ghost,
                            onPressed: _viewHistory,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Go Home',
                            icon: Icons.home_rounded,
                            type: AppButtonType.ghost,
                            onPressed: _goHome,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            IgnorePointer(
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppTheme.primary,
                  AppTheme.primaryLight,
                  AppTheme.success,
                  AppTheme.warning,
                  Colors.amber,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessHeroCard extends StatelessWidget {
  final String title;
  final bool isAiGenerated;
  final String focus;
  final int workoutScore;
  final String workoutScoreLabel;
  final int totalEarnedXp;

  const _SuccessHeroCard({
    required this.title,
    required this.isAiGenerated,
    required this.focus,
    required this.workoutScore,
    required this.workoutScoreLabel,
    required this.totalEarnedXp,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.28),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -72,
              right: -58,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
            ),
            Positioned(
              bottom: -86,
              left: -68,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.12),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Workout Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isAiGenerated)
                      AppChip(
                        label: 'AI Generated · $focus',
                        icon: Icons.auto_awesome_rounded,
                        backgroundColor: Colors.white.withValues(alpha: 0.17),
                        foregroundColor: Colors.white,
                      ),
                    AppChip(
                      label: '+$totalEarnedXp XP',
                      icon: Icons.bolt_rounded,
                      backgroundColor: Colors.white.withValues(alpha: 0.17),
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        title: 'Workout Score',
                        value: '$workoutScore',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroStat(
                        title: 'Performance',
                        value: workoutScoreLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String title;
  final String value;

  const _HeroStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.21)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.13),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final int selectedRating;
  final String feedbackText;
  final bool ratingSaved;
  final int ratingRewardXp;
  final ValueChanged<int> onRatingSelected;

  const _RatingCard({
    required this.selectedRating,
    required this.feedbackText,
    required this.ratingSaved,
    required this.ratingRewardXp,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ratingSaved ? Icons.check_circle_rounded : Icons.star_rounded,
              color: ratingSaved ? AppTheme.success : AppTheme.warning,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ratingSaved ? 'Rating Saved' : 'How was your workout?',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            ratingSaved
                ? 'Thank you for rating this workout.'
                : 'Your feedback helps track your training experience.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.4,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = rating <= selectedRating;

              return IconButton(
                onPressed: ratingSaved ? null : () => onRatingSelected(rating),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    key: ValueKey('$rating-$isSelected'),
                    color: isSelected
                        ? AppTheme.warning
                        : AppTheme.textSecondary,
                    size: 35,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              ratingSaved
                  ? '$feedbackText · +$ratingRewardXp XP earned'
                  : '$feedbackText · Save for +$ratingRewardXp XP',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiEvaluationCard extends StatelessWidget {
  final String title;
  final String message;
  final String focus;
  final int score;

  const _AiEvaluationCard({
    required this.title,
    required this.message,
    required this.focus,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      showShadow: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              top: -58,
              right: -46,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Coach Evaluation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$focus focus · Score $score/100',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
