import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NutritionEmptyState extends StatelessWidget {
  const NutritionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: .12),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "No Meals Yet",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start tracking your nutrition by adding your first meal. Calories and macros will automatically update throughout the day.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .65),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/add-nutrition-entry');
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  "Add First Meal",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                context.push('/edit-nutrition-goal');
              },
              child: const Text(
                "Edit Daily Goals",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
