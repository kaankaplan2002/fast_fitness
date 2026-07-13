import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/features/nutrition/data/model/nutrition_entry_model.dart';
import 'package:fast_fitness/features/nutrition/presentation/provider/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNutritionEntryScreen extends ConsumerStatefulWidget {
  const AddNutritionEntryScreen({super.key});

  @override
  ConsumerState<AddNutritionEntryScreen> createState() =>
      _AddNutritionEntryScreenState();
}

class _AddNutritionEntryScreenState
    extends ConsumerState<AddNutritionEntryScreen> {
  final formKey = GlobalKey<FormState>();

  final foodController = TextEditingController();
  final calorieController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  MealType selectedMealType = MealType.breakfast;
  bool isSaving = false;

  @override
  void dispose() {
    foodController.dispose();
    calorieController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
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
      await ref
          .read(nutritionRepositoryProvider)
          .addEntry(
            foodName: foodController.text.trim(),
            mealType: selectedMealType,
            calories: int.parse(calorieController.text.trim()),
            protein: double.parse(proteinController.text.trim()),
            carbs: double.parse(carbsController.text.trim()),
            fat: double.parse(fatController.text.trim()),
          );

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Food entry saved successfully.',
        title: 'Food Added',
      );

      Navigator.of(context).pop();
    } catch (error) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(context, error.toString(), title: 'Save Failed');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _changeMealType(MealType type) async {
    await HapticService.selection();

    if (!mounted) return;

    setState(() {
      selectedMealType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _FoodTextField(
                  controller: foodController,
                  label: 'Food name',
                  icon: Icons.restaurant_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Food name is required.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _MealTypeSelector(
                  selectedMealType: selectedMealType,
                  onChanged: _changeMealType,
                ),
                const SizedBox(height: 16),
                _FoodTextField(
                  controller: calorieController,
                  label: 'Calories',
                  icon: Icons.local_fire_department_rounded,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 16),
                _FoodTextField(
                  controller: proteinController,
                  label: 'Protein (g)',
                  icon: Icons.fitness_center_rounded,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 16),
                _FoodTextField(
                  controller: carbsController,
                  label: 'Carbs (g)',
                  icon: Icons.grain_rounded,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 16),
                _FoodTextField(
                  controller: fatController,
                  label: 'Fat (g)',
                  icon: Icons.water_drop_rounded,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveEntry,
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
                          'Save Food',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _numberValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'This field is required.';
    }

    final number = double.tryParse(text);

    if (number == null || number < 0) {
      return 'Enter a valid number.';
    }

    return null;
  }
}

class _FoodTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FoodTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _MealTypeSelector extends StatelessWidget {
  final MealType selectedMealType;
  final ValueChanged<MealType> onChanged;

  const _MealTypeSelector({
    required this.selectedMealType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MealType>(
      segments: const [
        ButtonSegment(
          value: MealType.breakfast,
          label: Text('Breakfast'),
          icon: Icon(Icons.free_breakfast_rounded),
        ),
        ButtonSegment(
          value: MealType.lunch,
          label: Text('Lunch'),
          icon: Icon(Icons.lunch_dining_rounded),
        ),
        ButtonSegment(
          value: MealType.dinner,
          label: Text('Dinner'),
          icon: Icon(Icons.dinner_dining_rounded),
        ),
        ButtonSegment(
          value: MealType.snack,
          label: Text('Snack'),
          icon: Icon(Icons.cookie_rounded),
        ),
      ],
      selected: {selectedMealType},
      onSelectionChanged: (value) {
        onChanged(value.first);
      },
    );
  }
}
