import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/home/presentation/providers/home_provider.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/setup_number_field.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/setup_option_card.dart';
import 'package:fast_fitness/features/progress/data/repository/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();

  String goal = 'Lose Fat';
  String activity = 'Moderate';

  bool initialized = false;
  bool saving = false;

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _save(String uid, double? oldWeight) async {
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final targetWeight = double.tryParse(targetWeightController.text.trim());
    final age = int.tryParse(ageController.text.trim());

    if (height == null || weight == null || targetWeight == null) {
      _showMessage('Please fill in height, weight, and target weight.', isError: true);
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'age': age,
        'height': height,
        'weight': weight,
        'targetWeight': targetWeight,
        'goal': goal,
        'activityLevel': activity,
        'profileCompleted': true,
      });

      if (oldWeight == null || oldWeight != weight) {
        await ProgressRepository().saveWeight(weight);
      }

      _showMessage('Profile updated successfully.', isError: false);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      _showMessage('Something went wrong.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Something went wrong.\n$error'),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          if (!initialized) {
            initialized = true;
            ageController.text = '';
            heightController.text = user.height?.toStringAsFixed(0) ?? '';
            weightController.text = user.weight?.toStringAsFixed(1) ?? '';
            targetWeightController.text = '';
            goal = user.goal ?? 'Lose Fat';
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update your details',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Keep your profile accurate so FastFitness can personalize your experience.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SetupNumberField(
                    controller: ageController,
                    label: 'Age',
                    suffix: 'years',
                    icon: Icons.cake_outlined,
                  ),
                  const SizedBox(height: 16),
                  SetupNumberField(
                    controller: heightController,
                    label: 'Height',
                    suffix: 'cm',
                    icon: Icons.height_rounded,
                  ),
                  const SizedBox(height: 16),
                  SetupNumberField(
                    controller: weightController,
                    label: 'Weight',
                    suffix: 'kg',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  const SizedBox(height: 16),
                  SetupNumberField(
                    controller: targetWeightController,
                    label: 'Target Weight',
                    suffix: 'kg',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SetupOptionCard(
                    title: 'Lose Fat',
                    icon: Icons.local_fire_department_rounded,
                    isSelected: goal == 'Lose Fat',
                    onTap: () => setState(() => goal = 'Lose Fat'),
                  ),
                  const SizedBox(height: 12),
                  SetupOptionCard(
                    title: 'Build Muscle',
                    icon: Icons.fitness_center_rounded,
                    isSelected: goal == 'Build Muscle',
                    onTap: () => setState(() => goal = 'Build Muscle'),
                  ),
                  const SizedBox(height: 12),
                  SetupOptionCard(
                    title: 'Stay Fit',
                    icon: Icons.favorite_rounded,
                    isSelected: goal == 'Stay Fit',
                    onTap: () => setState(() => goal = 'Stay Fit'),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: saving ? null : () => _save(user.uid, user.weight),
                    child: saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}