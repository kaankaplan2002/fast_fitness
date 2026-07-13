import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/profile/data/services/notification_service.dart';
import 'package:fast_fitness/features/profile/data/services/settings_service.dart';
import 'package:flutter/material.dart';

class WorkoutReminderCard extends StatefulWidget {
  const WorkoutReminderCard({super.key});

  @override
  State<WorkoutReminderCard> createState() => _WorkoutReminderCardState();
}

class _WorkoutReminderCardState extends State<WorkoutReminderCard> {
  final SettingsService settingsService = SettingsService();
  final NotificationService notificationService = NotificationService();

  bool isLoading = true;
  bool isEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final savedValue = await settingsService.getWorkoutReminders();

    if (!mounted) return;

    setState(() {
      isEnabled = savedValue;
      isLoading = false;
    });

    if (savedValue) {
      await notificationService.scheduleDailyWorkoutReminder();
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      isEnabled = value;
    });

    await settingsService.setWorkoutReminders(value);

    if (value) {
      await notificationService.scheduleDailyWorkoutReminder();
      _showMessage('Workout reminder enabled for 20:00.');
    } else {
      await notificationService.cancelWorkoutReminder();
      _showMessage('Workout reminder disabled.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Reminder',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  isEnabled ? 'Daily reminder: 20:00' : 'Reminder disabled',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeThumbColor: AppTheme.primary,
            onChanged: _toggleReminder,
          ),
        ],
      ),
    );
  }
}
