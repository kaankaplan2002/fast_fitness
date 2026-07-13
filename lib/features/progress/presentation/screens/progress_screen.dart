import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/ai/providers/ai_coach_provider.dart';
import 'package:fast_fitness/features/ai/presentation/widgets/ai_coach_card.dart';
import 'package:fast_fitness/features/home/presentation/providers/home_provider.dart';
import 'package:fast_fitness/features/progress/presentation/providers/progress_provider.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/achievements_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/add_weight_bottom_sheet.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/advanced_statistics_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/bmi_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/body_metric_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/daily_goal_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/goal_progress_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/monthly_challenge_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/monthly_progress_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/personal_records_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/progress_summary_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/weekly_activity_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/weekly_challenge_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/weight_chart_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/workout_analytics_card.dart';
import 'package:fast_fitness/features/progress/presentation/widgets/workout_heatmap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  Map<String, dynamic> _coachToExtra(coach) {
    return {
      'title': coach.title,
      'message': coach.message,
      'recommendation': coach.recommendation,
      'weeklyWorkouts': coach.weeklyWorkouts,
      'totalWorkouts': coach.totalWorkouts,
      'currentStreak': coach.currentStreak,
      'suggestedDuration': coach.suggestedDuration,
      'suggestedCalories': coach.suggestedCalories,
      'suggestedFocus': coach.suggestedFocus,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ---------------------------------------------------------------------------
    // Watch all providers once — no duplicate .when calls
    // ---------------------------------------------------------------------------
    final aiCoach = ref.watch(aiCoachProvider);
    final workoutCount = ref.watch(completedWorkoutsCountProvider);
    final workoutMinutes = ref.watch(totalWorkoutMinutesProvider);
    final weightHistory = ref.watch(weightHistoryProvider);
    final appUser = ref.watch(currentAppUserProvider);
    final ratingSummary = ref.watch(workoutRatingSummaryProvider);
    final workoutStatistics = ref.watch(workoutStatisticsProvider);
    final workoutAnalytics = ref.watch(workoutAnalyticsProvider);
    final heatmapDates = ref.watch(workoutHeatmapDatesProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final workoutCompletedToday = ref.watch(workoutCompletedTodayProvider);
    final weeklyChallenge = ref.watch(weeklyChallengeProgressProvider);
    final monthlyChallenge = ref.watch(monthlyChallengeProgressProvider);

    // ---------------------------------------------------------------------------
    // Resolve scalar values once — used by multiple cards
    // ---------------------------------------------------------------------------
    final workoutCountValue = workoutCount.whenOrNull(data: (v) => v) ?? 0;
    final workoutMinutesValue = workoutMinutes.whenOrNull(data: (v) => v) ?? 0;
    final streakValue = currentStreak.whenOrNull(data: (v) => v) ?? 0;
    final weightList = weightHistory.whenOrNull(data: (v) => v) ?? [];
    final currentUserWeight = appUser.whenOrNull(data: (u) => u?.weight);
    final statistics = workoutStatistics.whenOrNull(data: (v) => v);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary ──────────────────────────────────────────────────────
            ProgressSummaryCard(
              completedWorkouts: workoutCount.when(
                data: (v) => v.toString(),
                loading: () => '...',
                error: (_, __) => '-',
              ),
              workoutMinutes: workoutMinutes.when(
                data: (v) => v.toString(),
                loading: () => '...',
                error: (_, __) => '-',
              ),
            ),
            const SizedBox(height: 20),

            // ── AI Coach ─────────────────────────────────────────────────────
            aiCoach.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (coach) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AiCoachCard(
                    coach: coach,
                    onTap: () => context.push(
                      '/ai-coach-detail',
                      extra: _coachToExtra(coach),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Daily Goal ───────────────────────────────────────────────────
            workoutCompletedToday.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (completedToday) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DailyGoalCard(
                    workoutCompletedToday: completedToday,
                    currentStreak: streakValue,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Challenges ───────────────────────────────────────────────────
            weeklyChallenge.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (count) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WeeklyChallengeCard(completedThisWeek: count),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            monthlyChallenge.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (count) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MonthlyChallengeCard(completedThisMonth: count),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Weight section header ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                _AddWeightButton(
                  currentWeight: currentUserWeight,
                  onSaved: () {
                    ref.invalidate(weightHistoryProvider);
                    ref.invalidate(currentAppUserProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Weight Chart ─────────────────────────────────────────────────
            weightHistory.when(
              loading: () => const _CardShimmer(height: 240),
              error: (_, __) => const _WeightHistoryError(),
              data: (weights) => WeightChartCard(weights: weights),
            ),
            const SizedBox(height: 20),

            // ── Heatmap ───────────────────────────────────────────────────────
            heatmapDates.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (dates) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WorkoutHeatmapCard(workoutDates: dates),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Analytics ────────────────────────────────────────────────────
            workoutAnalytics.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (analytics) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WorkoutAnalyticsCard(analytics: analytics),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Advanced Statistics ───────────────────────────────────────────
            workoutStatistics.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (statistics) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdvancedStatisticsCard(statistics: statistics),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── BMI ───────────────────────────────────────────────────────────
            appUser.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BmiCard(weight: user?.weight, height: user?.height),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Goal Progress ─────────────────────────────────────────────────
            appUser.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GoalProgressCard(
                    currentWeight: user?.weight,
                    targetWeight: user?.targetWeight,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Rating Summary ────────────────────────────────────────────────
            ratingSummary.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (summary) {
                final avg =
                    (summary['averageRating'] as num?)?.toDouble() ?? 0.0;
                final count = summary['ratingCount'] as int? ?? 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RatingSummaryCard(
                      averageRating: avg,
                      ratingCount: count,
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            // ── Monthly Progress ──────────────────────────────────────────────
            MonthlyProgressCard(
              weights: weightList,
              completedWorkouts: workoutCountValue,
              workoutMinutes: workoutMinutesValue,
            ),
            const SizedBox(height: 20),

            // ── Personal Records ──────────────────────────────────────────────
            // longestWorkout comes from workoutAnalytics if available.
            PersonalRecordsCard(
              longestWorkout: statistics?.totalMinutes == 0
                  ? 0
                  : (workoutAnalytics.whenOrNull(data: (v) => v)?.longestWorkout ?? 0),
              totalWorkouts: workoutCountValue,
              streak: streakValue,
              weightEntries: weightList.length,
            ),
            const SizedBox(height: 20),

            // ── Achievements ──────────────────────────────────────────────────
            AchievementsCard(
              completedWorkouts: workoutCountValue,
              streak: streakValue,
              weightEntries: weightList.length,
            ),
            const SizedBox(height: 20),

            // ── Weekly Activity ───────────────────────────────────────────────
            const WeeklyActivityCard(),
            const SizedBox(height: 28),

            // ── Body Metrics section ──────────────────────────────────────────
            Text(
              'Body Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: BodyMetricCard(
                    title: 'Current Weight',
                    value: weightList.isEmpty
                        ? '-'
                        : '${weightList.last.weight.toStringAsFixed(1)} kg',
                    subtitle: weightList.isEmpty
                        ? 'No data'
                        : '${weightList.length} record${weightList.length == 1 ? '' : 's'}',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: BodyMetricCard(
                    title: 'Current Streak',
                    value: '$streakValue',
                    subtitle: streakValue == 1 ? 'Day' : 'Days',
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: BodyMetricCard(
                    title: 'Workout Time',
                    value: '$workoutMinutesValue',
                    subtitle: 'Total minutes',
                    icon: Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: BodyMetricCard(
                    title: 'Est. Calories',
                    value: (workoutMinutesValue * 8).toString(),
                    subtitle: 'Estimated burn',
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Weight Button
// ---------------------------------------------------------------------------

class _AddWeightButton extends StatefulWidget {
  final double? currentWeight;
  final VoidCallback onSaved;

  const _AddWeightButton({
    required this.currentWeight,
    required this.onSaved,
  });

  @override
  State<_AddWeightButton> createState() => _AddWeightButtonState();
}

class _AddWeightButtonState extends State<_AddWeightButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showAddWeightBottomSheet(
          context,
          currentWeight: widget.currentWeight,
        );
        if (!mounted) return;
        if (result == true) widget.onSaved();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: AppTheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              widget.currentWeight != null ? 'Update Weight' : 'Add Weight',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rating Summary Card
// ---------------------------------------------------------------------------

class _RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int ratingCount;

  const _RatingSummaryCard({
    required this.averageRating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final ratingText =
        ratingCount == 0 ? '-' : averageRating.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppTheme.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Average Workout Rating',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$ratingText / 5',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ratingCount == 0
                      ? 'No ratings yet'
                      : 'Based on $ratingCount rating${ratingCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helper widgets
// ---------------------------------------------------------------------------

/// Shimmer placeholder while a card is loading.
class _CardShimmer extends StatelessWidget {
  final double height;

  const _CardShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

/// Shown when weight history fails to load.
class _WeightHistoryError extends StatelessWidget {
  const _WeightHistoryError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Weight history could not be loaded.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
