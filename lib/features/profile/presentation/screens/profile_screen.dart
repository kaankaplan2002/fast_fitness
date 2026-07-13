import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/achievements/presentation/providers/achievement_provider.dart';
import 'package:fast_fitness/features/exercises/data/datasource/exercise_seed_datasource.dart';
import 'package:fast_fitness/features/home/presentation/providers/home_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/nutrition_preview_card.dart';
import 'package:fast_fitness/features/profile/data/services/xp_service.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/badge_grid.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/level_progress_card.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/workout_reminder_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _seedExercises(BuildContext context) async {
    try {
      await ExerciseSeedDatasource().seedExercises();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercises seeded successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise seed failed.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);
    final nutritionSummary = ref.watch(nutritionSummaryProvider);

    return appUserAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (error, stackTrace) =>
          Center(child: Text('Could not load profile.\n$error')),
      data: (appUser) {
        final name = appUser?.name.isNotEmpty == true ? appUser!.name : 'User';
        final email = appUser?.email.isNotEmpty == true
            ? appUser!.email
            : 'No email';

        final weight = appUser?.weight == null
            ? '-'
            : '${appUser!.weight!.toStringAsFixed(1)} kg';

        final height = appUser?.height == null
            ? '-'
            : '${appUser!.height!.toStringAsFixed(0)} cm';

        final streak = '${appUser?.streak ?? 0} days';

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeaderCard(name: name, email: email),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(title: 'Weight', value: weight),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ProfileStatCard(title: 'Height', value: height),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ProfileStatCard(title: 'Streak', value: streak),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                StreamBuilder(
                  stream: XpService().watchUserLevel(),
                  builder: (context, snapshot) {
                    final level = snapshot.data;

                    if (level == null) {
                      return const SizedBox.shrink();
                    }

                    return LevelProgressCard(level: level);
                  },
                ),

                const SizedBox(height: 24),
                NutritionPreviewCard(summary: nutritionSummary),

                const SizedBox(height: 24),
                const _AchievementPreviewCard(),

                const SizedBox(height: 24),
                const BadgeGrid(),

                const SizedBox(height: 24),
                const WorkoutReminderCard(),

                const SizedBox(height: 28),
                const Text(
                  'Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),

                ProfileMenuTile(
                  title: 'Edit Profile',
                  icon: Icons.edit_rounded,
                  onTap: () => context.push('/edit-profile'),
                ),
                ProfileMenuTile(
                  title: 'Nutrition',
                  icon: Icons.restaurant_menu_rounded,
                  onTap: () => context.push('/nutrition'),
                ),
                ProfileMenuTile(
                  title: 'Daily Missions',
                  icon: Icons.task_alt_rounded,
                  onTap: () => context.push('/daily-missions'),
                ),
                ProfileMenuTile(
                  title: 'Achievements',
                  icon: Icons.military_tech_rounded,
                  onTap: () => context.push('/achievements'),
                ),
                ProfileMenuTile(
                  title: 'Personal Records',
                  icon: Icons.emoji_events_rounded,
                  onTap: () => context.push('/personal-records'),
                ),
                ProfileMenuTile(
                  title: 'Workout History',
                  icon: Icons.history_rounded,
                  onTap: () => context.push('/workout-history'),
                ),
                ProfileMenuTile(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  onTap: () => context.push('/settings'),
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _seedExercises(context),
                    child: const Text(
                      'Seed Exercises',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AchievementPreviewCard extends ConsumerWidget {
  const _AchievementPreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      loading: () => _AchievementCardShell(
        unlockedCount: 0,
        totalCount: 0,
        progress: 0,
        isLoading: true,
        onTap: () => context.push('/achievements'),
      ),
      error: (error, stackTrace) => _AchievementCardShell(
        unlockedCount: 0,
        totalCount: 0,
        progress: 0,
        isLoading: false,
        onTap: () => context.push('/achievements'),
      ),
      data: (achievements) {
        final unlockedCount = achievements
            .where((achievement) => achievement.unlocked)
            .length;

        final totalCount = achievements.length;
        final progress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

        return _AchievementCardShell(
          unlockedCount: unlockedCount,
          totalCount: totalCount,
          progress: progress,
          isLoading: false,
          onTap: () => context.push('/achievements'),
        );
      },
    );
  }
}

class _AchievementCardShell extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;
  final double progress;
  final bool isLoading;
  final VoidCallback onTap;

  const _AchievementCardShell({
    required this.unlockedCount,
    required this.totalCount,
    required this.progress,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.95),
              AppTheme.primary.withValues(alpha: 0.58),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.24),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trophy Room',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoading
                        ? 'Loading achievements...'
                        : '$unlockedCount of $totalCount achievements unlocked',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
