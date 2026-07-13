import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/nutrition_entry_model.dart';
import '../../data/model/nutrition_goal_model.dart';
import '../../data/repository/nutrition_repository.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

final todayNutritionEntriesProvider = StreamProvider<List<NutritionEntryModel>>(
  (ref) {
    final repository = ref.watch(nutritionRepositoryProvider);
    return repository.watchTodayEntries();
  },
);

final nutritionGoalProvider = StreamProvider<NutritionGoalModel>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.watchNutritionGoal();
});

final nutritionSummaryProvider = Provider<NutritionSummary>((ref) {
  final entries = ref.watch(todayNutritionEntriesProvider).value ?? [];
  final goal =
      ref.watch(nutritionGoalProvider).value ??
      NutritionGoalModel.defaultGoal();

  int totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;

  for (final entry in entries) {
    totalCalories += entry.calories;
    totalProtein += entry.protein;
    totalCarbs += entry.carbs;
    totalFat += entry.fat;
  }

  return NutritionSummary(
    totalCalories: totalCalories,
    totalProtein: totalProtein,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    goal: goal,
  );
});

class NutritionSummary {
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final NutritionGoalModel goal;

  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.goal,
  });

  double get calorieProgress {
    if (goal.calorieGoal <= 0) return 0;
    return (totalCalories / goal.calorieGoal).clamp(0, 1);
  }

  double get proteinProgress {
    if (goal.proteinGoal <= 0) return 0;
    return (totalProtein / goal.proteinGoal).clamp(0, 1);
  }

  double get carbsProgress {
    if (goal.carbsGoal <= 0) return 0;
    return (totalCarbs / goal.carbsGoal).clamp(0, 1);
  }

  double get fatProgress {
    if (goal.fatGoal <= 0) return 0;
    return (totalFat / goal.fatGoal).clamp(0, 1);
  }
}
