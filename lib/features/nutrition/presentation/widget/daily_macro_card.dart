import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:fast_fitness/features/nutrition/presentation/widget/macro_ring.dart';
import 'package:flutter/material.dart';

class DailyMacroCard extends StatelessWidget {
  final NutritionSummary summary;

  const DailyMacroCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MacroRing(
            progress: summary.proteinProgress,
            title: 'Protein',
            value:
                '${summary.totalProtein.toStringAsFixed(0)}/${summary.goal.proteinGoal.toStringAsFixed(0)}g',
            icon: Icons.fitness_center_rounded,
          ),
        ),
        Expanded(
          child: MacroRing(
            progress: summary.carbsProgress,
            title: 'Carbs',
            value:
                '${summary.totalCarbs.toStringAsFixed(0)}/${summary.goal.carbsGoal.toStringAsFixed(0)}g',
            icon: Icons.grain_rounded,
          ),
        ),
        Expanded(
          child: MacroRing(
            progress: summary.fatProgress,
            title: 'Fat',
            value:
                '${summary.totalFat.toStringAsFixed(0)}/${summary.goal.fatGoal.toStringAsFixed(0)}g',
            icon: Icons.water_drop_rounded,
          ),
        ),
      ],
    );
  }
}
