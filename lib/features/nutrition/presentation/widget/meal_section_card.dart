import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/nutrition/data/model/nutrition_entry_model.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/nutrition_entry_card.dart';
import 'package:flutter/material.dart';

class MealSectionCard extends StatelessWidget {
  final MealType mealType;
  final List<NutritionEntryModel> entries;
  final void Function(String entryId) onDelete;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onDelete,
  });

  int get totalCalories {
    return entries.fold<int>(0, (total, entry) => total + entry.calories);
  }

  double get totalProtein {
    return entries.fold<double>(0, (total, entry) => total + entry.protein);
  }

  double get totalCarbs {
    return entries.fold<double>(0, (total, entry) => total + entry.carbs);
  }

  double get totalFat {
    return entries.fold<double>(0, (total, entry) => total + entry.fat);
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: theme.cardColor,
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _MealSectionHeader(
            mealType: mealType,
            totalCalories: totalCalories,
            entryCount: entries.length,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _MealMacroChip(
                title: 'Protein',
                value: '${totalProtein.toStringAsFixed(0)}g',
              ),
              const SizedBox(width: 8),
              _MealMacroChip(
                title: 'Carbs',
                value: '${totalCarbs.toStringAsFixed(0)}g',
              ),
              const SizedBox(width: 8),
              _MealMacroChip(
                title: 'Fat',
                value: '${totalFat.toStringAsFixed(0)}g',
              ),
            ],
          ),

          const SizedBox(height: 18),

          ListView.separated(
            itemCount: entries.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppTheme.error.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: AppTheme.error,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Meal'),
                            content: Text(
                              'Do you want to delete "${entry.foodName}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.error,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;
                },
                onDismissed: (_) {
                  onDelete(entry.id);
                },
                child: NutritionEntryCard(
                  entry: entry,
                  onDelete: () => onDelete(entry.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MealSectionHeader extends StatelessWidget {
  final MealType mealType;
  final int totalCalories;
  final int entryCount;

  const _MealSectionHeader({
    required this.mealType,
    required this.totalCalories,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.14),
          ),
          child: Icon(_iconForMeal(mealType), color: AppTheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _labelForMeal(mealType),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$entryCount ${entryCount == 1 ? 'item' : 'items'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.primary.withValues(alpha: 0.14),
          ),
          child: Text(
            '$totalCalories kcal',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForMeal(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
      case MealType.snack:
        return Icons.cookie_rounded;
    }
  }

  String _labelForMeal(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snacks';
    }
  }
}

class _MealMacroChip extends StatelessWidget {
  final String title;
  final String value;

  const _MealMacroChip({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppTheme.primary.withValues(alpha: 0.10),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.62),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
