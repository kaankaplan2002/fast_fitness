import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/features/nutrition/data/model/nutrition_entry_model.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/daily_goal_header.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/daily_macro_card.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/meal_section_card.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/nutrition_empty_state.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/nutrition_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  Future<void> _goToAddEntry(BuildContext context) async {
    await HapticService.light();

    if (context.mounted) {
      context.push('/add-nutrition-entry');
    }
  }

  Future<void> _goToEditGoal(BuildContext context) async {
    await HapticService.light();

    if (context.mounted) {
      context.push('/edit-nutrition-goal');
    }
  }

  Future<void> _deleteEntry({
    required BuildContext context,
    required WidgetRef ref,
    required String entryId,
  }) async {
    await HapticService.warning();

    if (!context.mounted) return;

    try {
      await ref.read(nutritionRepositoryProvider).deleteEntry(entryId);

      await HapticService.success();

      if (!context.mounted) return;

      SnackBarService.success(context, 'Food entry deleted.', title: 'Deleted');
    } catch (error) {
      await HapticService.error();

      if (!context.mounted) return;

      SnackBarService.error(context, error.toString(), title: 'Delete Failed');
    }
  }

  Map<MealType, List<NutritionEntryModel>> _groupEntriesByMeal(
    List<NutritionEntryModel> entries,
  ) {
    final groupedEntries = <MealType, List<NutritionEntryModel>>{
      MealType.breakfast: [],
      MealType.lunch: [],
      MealType.dinner: [],
      MealType.snack: [],
    };

    for (final entry in entries) {
      groupedEntries[entry.mealType]?.add(entry);
    }

    return groupedEntries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(todayNutritionEntriesProvider);
    final summary = ref.watch(nutritionSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Edit nutrition goals',
            onPressed: () => _goToEditGoal(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToAddEntry(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Food',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: entriesAsync.when(
        loading: () => const NutritionLoadingSkeleton(),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nutrition data could not be loaded.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (entries) {
          final groupedEntries = _groupEntriesByMeal(entries);

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              await HapticService.light();

              ref.invalidate(todayNutritionEntriesProvider);
              ref.invalidate(nutritionGoalProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: DailyGoalHeader(summary: summary),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: DailyMacroCard(summary: summary),
                  ),
                ),
                if (entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: NutritionEmptyState(),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _NutritionSectionTitle(
                        title: 'Today’s Meals',
                        subtitle: '${entries.length} food items logged',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        MealSectionCard(
                          mealType: MealType.breakfast,
                          entries:
                              groupedEntries[MealType.breakfast] ?? const [],
                          onDelete: (entryId) => _deleteEntry(
                            context: context,
                            ref: ref,
                            entryId: entryId,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MealSectionCard(
                          mealType: MealType.lunch,
                          entries: groupedEntries[MealType.lunch] ?? const [],
                          onDelete: (entryId) => _deleteEntry(
                            context: context,
                            ref: ref,
                            entryId: entryId,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MealSectionCard(
                          mealType: MealType.dinner,
                          entries: groupedEntries[MealType.dinner] ?? const [],
                          onDelete: (entryId) => _deleteEntry(
                            context: context,
                            ref: ref,
                            entryId: entryId,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MealSectionCard(
                          mealType: MealType.snack,
                          entries: groupedEntries[MealType.snack] ?? const [],
                          onDelete: (entryId) => _deleteEntry(
                            context: context,
                            ref: ref,
                            entryId: entryId,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NutritionSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NutritionSectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
      ],
    );
  }
}
