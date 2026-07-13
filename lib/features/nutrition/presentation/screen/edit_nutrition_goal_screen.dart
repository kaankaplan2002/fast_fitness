import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/features/nutrition/data/model/nutrition_goal_model.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditNutritionGoalScreen extends ConsumerStatefulWidget {
  const EditNutritionGoalScreen({super.key});

  @override
  ConsumerState<EditNutritionGoalScreen> createState() =>
      _EditNutritionGoalScreenState();
}

class _EditNutritionGoalScreenState
    extends ConsumerState<EditNutritionGoalScreen> {
  final formKey = GlobalKey<FormState>();

  final calorieController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  bool initialized = false;
  bool isSaving = false;

  @override
  void dispose() {
    calorieController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  void _initializeControllers(NutritionGoalModel goal) {
    if (initialized) return;

    calorieController.text = goal.calorieGoal.toString();
    proteinController.text = goal.proteinGoal.toStringAsFixed(0);
    carbsController.text = goal.carbsGoal.toStringAsFixed(0);
    fatController.text = goal.fatGoal.toStringAsFixed(0);

    initialized = true;
  }

  Future<void> _saveGoal() async {
    await HapticService.light();

    if (!mounted) return;

    if (!formKey.currentState!.validate()) {
      await HapticService.warning();
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final goal = NutritionGoalModel(
        calorieGoal: int.parse(calorieController.text.trim()),
        proteinGoal: double.parse(proteinController.text.trim()),
        carbsGoal: double.parse(carbsController.text.trim()),
        fatGoal: double.parse(fatController.text.trim()),
      );

      await ref.read(nutritionRepositoryProvider).updateGoal(goal);

      ref.invalidate(nutritionGoalProvider);
      ref.invalidate(todayNutritionEntriesProvider);

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Nutrition goals updated.',
        title: 'Goals Updated',
      );

      Navigator.of(context).pop();
    } catch (error) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(context, error.toString(), title: 'Update Failed');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String? _positiveNumberValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'This field is required.';
    }

    final number = double.tryParse(text);

    if (number == null || number <= 0) {
      return 'Enter a valid positive number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(nutritionGoalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Goals'), centerTitle: false),
      body: goalAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nutrition goals could not be loaded.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (goal) {
          _initializeControllers(goal);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GoalHeaderCard(goal: goal),
                    const SizedBox(height: 24),
                    Text(
                      'Daily Targets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GoalTextField(
                      controller: calorieController,
                      label: 'Calories',
                      suffix: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    _GoalTextField(
                      controller: proteinController,
                      label: 'Protein',
                      suffix: 'g',
                      icon: Icons.fitness_center_rounded,
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    _GoalTextField(
                      controller: carbsController,
                      label: 'Carbs',
                      suffix: 'g',
                      icon: Icons.grain_rounded,
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    _GoalTextField(
                      controller: fatController,
                      label: 'Fat',
                      suffix: 'g',
                      icon: Icons.water_drop_rounded,
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveGoal,
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Goals',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GoalHeaderCard extends StatelessWidget {
  final NutritionGoalModel goal;

  const _GoalHeaderCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.96),
            AppTheme.primary.withValues(alpha: 0.58),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.track_changes_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 18),
          Text(
            'Set Your Targets',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your daily calorie and macro goals based on your fitness plan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _GoalHeaderStat(title: 'Calories', value: '${goal.calorieGoal}'),
              const SizedBox(width: 12),
              _GoalHeaderStat(
                title: 'Protein',
                value: '${goal.proteinGoal.toStringAsFixed(0)}g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalHeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _GoalHeaderStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final String? Function(String?) validator;

  const _GoalTextField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
