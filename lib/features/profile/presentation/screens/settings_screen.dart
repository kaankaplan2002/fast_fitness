import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/app/theme_controller.dart';
import 'package:fast_fitness/core/dialog/app_dialog.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_list_tile.dart';
import 'package:fast_fitness/core/widgets/app_loading_indicator.dart';
import 'package:fast_fitness/core/widgets/app_safe_scroll_view.dart';
import 'package:fast_fitness/core/widgets/app_section_title.dart';
import 'package:fast_fitness/features/profile/data/services/notification_service.dart';
import 'package:fast_fitness/features/profile/data/services/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SettingsService settingsService = SettingsService();
  final NotificationService notificationService = NotificationService();

  bool isLoading = true;
  bool isMetric = true;
  bool isPrivateProfile = false;
  bool workoutReminders = true;
  bool isSendingTestNotification = false;
  bool isLoggingOut = false;
  String geminiApiKey = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final metricUnits = await settingsService.getMetricUnits();
    final privateProfile = await settingsService.getPrivateProfile();
    final reminders = await settingsService.getWorkoutReminders();
    final geminiKey = await settingsService.getGeminiApiKey();

    if (!mounted) return;

    setState(() {
      isMetric = metricUnits;
      isPrivateProfile = privateProfile;
      workoutReminders = reminders;
      geminiApiKey = geminiKey;
      isLoading = false;
    });
  }

  Future<void> _updateDarkMode(bool value) async {
    await HapticService.selection();
    await ref.read(themeControllerProvider.notifier).setDarkMode(value);

    if (!mounted) return;

    SnackBarService.success(
      context,
      value ? 'Dark mode enabled.' : 'Light mode enabled.',
      title: 'Theme Updated',
    );
  }

  Future<void> _updateMetricUnits(bool value) async {
    await HapticService.selection();

    setState(() => isMetric = value);
    await settingsService.setMetricUnits(value);

    if (!mounted) return;

    SnackBarService.success(
      context,
      value ? 'Metric units enabled.' : 'Imperial units enabled.',
      title: 'Units Updated',
    );
  }

  Future<void> _updatePrivateProfile(bool value) async {
    await HapticService.selection();

    setState(() => isPrivateProfile = value);
    await settingsService.setPrivateProfile(value);

    if (!mounted) return;

    SnackBarService.success(
      context,
      value ? 'Private profile enabled.' : 'Private profile disabled.',
      title: 'Privacy Updated',
    );
  }

  Future<void> _updateWorkoutReminders(bool value) async {
    await HapticService.selection();

    setState(() => workoutReminders = value);
    await settingsService.setWorkoutReminders(value);

    if (value) {
      await notificationService.scheduleDailyWorkoutReminder();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Workout reminder enabled for 20:00.',
        title: 'Reminder Enabled',
      );
    } else {
      await notificationService.cancelWorkoutReminder();

      if (!mounted) return;

      SnackBarService.info(
        context,
        'Workout reminder disabled.',
        title: 'Reminder Disabled',
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await HapticService.light();

    if (!mounted) return;

    setState(() {
      isSendingTestNotification = true;
    });

    try {
      await notificationService.scheduleTestNotification();

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Test notification will arrive in 5 seconds.',
        title: 'Test Scheduled',
      );
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Test notification could not be scheduled.',
        title: 'Notification Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingTestNotification = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await AppDialog.confirm(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of FastFitness?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
    );

    if (!shouldLogout) return;

    await HapticService.medium();

    if (!mounted) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        context.go('/login');
      }
    } catch (_) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Logout failed. Please try again.',
        title: 'Logout Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _deleteAccountPreview() async {
    await HapticService.warning();

    if (!mounted) return;

    await AppDialog.warning(
      context,
      title: 'Delete Account',
      message:
          'This action will permanently delete your account and fitness data. Account deletion will be enabled in a later production step.',
      buttonText: 'I Understand',
    );
  }

  void _showComingSoon(String feature) {
    SnackBarService.info(
      context,
      '$feature will be available soon.',
      title: 'Coming Soon',
    );
  }

  Future<void> _updateGeminiApiKey(String value) async {
    setState(() => geminiApiKey = value);
    await settingsService.setGeminiApiKey(value);
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: geminiApiKey);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          title: const Text('Gemini API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Gemini API key from Google AI Studio. This is stored locally on your device.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = controller.text.trim();
                await _updateGeminiApiKey(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarService.success(
                    context,
                    key.isEmpty ? 'API Key removed.' : 'API Key saved successfully.',
                    title: 'API Key Saved',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isLoading
          ? const AppLoadingIndicator(message: 'Loading settings...')
          : AppSafeScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle(title: 'Preferences'),
                  const SizedBox(height: 16),
                  _SettingsSwitchTile(
                    title: 'Dark Mode',
                    subtitle: isDarkMode
                        ? 'Use dark appearance'
                        : 'Use light appearance',
                    icon: Icons.dark_mode_rounded,
                    value: isDarkMode,
                    onChanged: _updateDarkMode,
                  ),
                  _SettingsSwitchTile(
                    title: 'Metric Units',
                    subtitle: isMetric ? 'kg / cm' : 'lb / ft',
                    icon: Icons.monitor_weight_outlined,
                    value: isMetric,
                    onChanged: _updateMetricUnits,
                  ),
                  _SettingsSwitchTile(
                    title: 'Workout Reminders',
                    subtitle: workoutReminders
                        ? 'Daily reminder at 20:00'
                        : 'Reminder disabled',
                    icon: Icons.notifications_active_rounded,
                    value: workoutReminders,
                    onChanged: _updateWorkoutReminders,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: isSendingTestNotification
                        ? 'Scheduling Test...'
                        : 'Send Test Notification',
                    icon: Icons.notifications_rounded,
                    isLoading: isSendingTestNotification,
                    onPressed: isSendingTestNotification
                        ? null
                        : _sendTestNotification,
                  ),
                  const SizedBox(height: 28),
                  const AppSectionTitle(title: 'AI Coaching'),
                  const SizedBox(height: 16),
                  AppListTile(
                    title: 'Gemini API Key',
                    subtitle: geminiApiKey.isEmpty
                        ? 'Not configured (using local fallback)'
                        : 'Gemini AI active',
                    icon: Icons.psychology_rounded,
                    onTap: _showApiKeyDialog,
                  ),
                  const SizedBox(height: 28),
                  const AppSectionTitle(title: 'Privacy'),
                  const SizedBox(height: 16),
                  _SettingsSwitchTile(
                    title: 'Private Profile',
                    subtitle: 'Hide your activity from others',
                    icon: Icons.lock_rounded,
                    value: isPrivateProfile,
                    onChanged: _updatePrivateProfile,
                  ),
                  const SizedBox(height: 28),
                  const AppSectionTitle(title: 'App'),
                  const SizedBox(height: 16),
                  const AppListTile(
                    title: 'Version',
                    subtitle: '1.0.0',
                    icon: Icons.info_outline_rounded,
                    showChevron: false,
                  ),
                  const AppListTile(
                    title: 'App Name',
                    subtitle: 'FastFitness',
                    icon: Icons.fitness_center_rounded,
                    showChevron: false,
                  ),
                  AppListTile(
                    title: 'Privacy Policy',
                    subtitle: 'Read how your data is handled',
                    icon: Icons.privacy_tip_rounded,
                    onTap: () => _showComingSoon('Privacy Policy'),
                  ),
                  AppListTile(
                    title: 'Terms of Service',
                    subtitle: 'View app usage terms',
                    icon: Icons.description_rounded,
                    onTap: () => _showComingSoon('Terms of Service'),
                  ),
                  AppListTile(
                    title: 'Contact Support',
                    subtitle: 'Get help with FastFitness',
                    icon: Icons.support_agent_rounded,
                    onTap: () => _showComingSoon('Contact Support'),
                  ),
                  AppListTile(
                    title: 'Share App',
                    subtitle: 'Invite friends to FastFitness',
                    icon: Icons.ios_share_rounded,
                    onTap: () => _showComingSoon('Share App'),
                  ),
                  AppListTile(
                    title: 'Rate FastFitness',
                    subtitle: 'Support us with a review',
                    icon: Icons.star_rate_rounded,
                    onTap: () => _showComingSoon('Rate FastFitness'),
                  ),
                  const SizedBox(height: 28),
                  const AppSectionTitle(title: 'Account'),
                  const SizedBox(height: 16),
                  AppListTile(
                    title: isLoggingOut ? 'Logging Out...' : 'Log Out',
                    subtitle: 'Sign out of your account',
                    icon: Icons.logout_rounded,
                    onTap: isLoggingOut ? null : _logout,
                  ),
                  AppListTile(
                    title: 'Delete Account',
                    subtitle: 'Request permanent account deletion',
                    icon: Icons.delete_forever_rounded,
                    isDanger: true,
                    onTap: _deleteAccountPreview,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      showChevron: false,
      trailing: Switch(
        value: value,
        activeThumbColor: AppTheme.primary,
        onChanged: onChanged,
      ),
    );
  }
}
