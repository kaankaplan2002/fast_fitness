import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/error_state.dart';
import 'package:fast_fitness/core/widgets/app_loading_indicator.dart';
import 'package:fast_fitness/core/widgets/app_safe_scroll_view.dart';
import 'package:fast_fitness/core/widgets/app_section_title.dart';
import 'package:fast_fitness/core/widgets/app_status_banner.dart';
import 'package:fast_fitness/features/home/presentation/providers/home_provider.dart';
import 'package:fast_fitness/features/home/presentation/widgets/calorie_card.dart';
import 'package:fast_fitness/features/home/presentation/widgets/home_header.dart';
import 'package:fast_fitness/features/home/presentation/widgets/quick_actions.dart';
import 'package:fast_fitness/features/home/presentation/widgets/recent_workouts.dart';
import 'package:fast_fitness/features/home/presentation/widgets/streak_card.dart';
import 'package:fast_fitness/features/home/presentation/widgets/today_workout_card.dart';
import 'package:fast_fitness/features/home/presentation/widgets/weight_card.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/nutrition_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);
    final nutritionSummary = ref.watch(nutritionSummaryProvider);

    return appUserAsync.when(
      loading: () =>
          const AppLoadingIndicator(message: 'Loading your dashboard...'),
      error: (error, stackTrace) => AppErrorState(
        title: 'Dashboard could not be loaded',
        message: error.toString(),
        onRetry: () {
          ref.invalidate(currentAppUserProvider);
        },
      ),
      data: (appUser) {
        final name = appUser?.name.isNotEmpty == true ? appUser!.name : 'User';

        return AppSafeScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(name: name),
              const SizedBox(height: 24),

              AppStatusBanner(
                title: 'Today is a good day to move',
                message:
                    'Stay consistent, complete your planned workout, and keep your streak alive.',
                type: AppStatusType.info,
              ),

              const SizedBox(height: 24),

              AppSectionTitle(
                title: 'Today',
                subtitle: 'Your fitness snapshot for the day',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              StreakCard(streak: appUser?.streak ?? 0),
              const SizedBox(height: 18),

              const TodayWorkoutCard(),
              const SizedBox(height: 18),

              NutritionPreviewCard(summary: nutritionSummary),
              const SizedBox(height: 18),

              CalorieCard(dailyCalories: appUser?.dailyCalories ?? 2400),
              const SizedBox(height: 18),

              WeightCard(weight: appUser?.weight),
              const SizedBox(height: 28),

              const AppSectionTitle(
                title: 'Quick Actions',
                subtitle: 'Jump into the most important parts of your plan',
              ),
              const SizedBox(height: 16),

              const QuickActions(),
              const SizedBox(height: 28),

              const AppSectionTitle(
                title: 'Recent Activity',
                subtitle: 'Your latest completed workouts',
              ),
              const SizedBox(height: 16),

              const RecentWorkouts(),
            ],
          ),
        );
      },
    );
  }
}
