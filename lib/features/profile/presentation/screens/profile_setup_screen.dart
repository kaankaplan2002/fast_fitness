import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/setup_number_field.dart';
import 'package:fast_fitness/features/profile/presentation/widgets/setup_option_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();

  String selectedGoal = 'Lose Fat';
  String selectedActivity = 'Moderate';
  bool isLoading = false;

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (ageController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        targetWeightController.text.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'age': int.tryParse(ageController.text.trim()),
        'height': double.tryParse(heightController.text.trim()),
        'weight': double.tryParse(weightController.text.trim()),
        'targetWeight': double.tryParse(targetWeightController.text.trim()),
        'goal': selectedGoal,
        'activityLevel': selectedActivity,
        'profileCompleted': true,
      });

      if (mounted) {
        context.go('/home');
      }
    } catch (_) {
      _showMessage('Something went wrong.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = [
      'Lose Fat',
      'Build Muscle',
      'Stay Fit',
    ];

    final activities = [
      'Low',
      'Moderate',
      'High',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We will use this information to personalize your fitness experience.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
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
                label: 'Current Weight',
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
              const SizedBox(height: 30),
              const Text(
                'Your Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SetupOptionCard(
                    title: goal,
                    icon: Icons.flag_rounded,
                    isSelected: selectedGoal == goal,
                    onTap: () {
                      setState(() {
                        selectedGoal = goal;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Activity Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SetupOptionCard(
                    title: activity,
                    icon: Icons.bolt_rounded,
                    isSelected: selectedActivity == activity,
                    onTap: () {
                      setState(() {
                        selectedActivity = activity;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Complete Setup',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}