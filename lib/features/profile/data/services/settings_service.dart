import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _darkModeKey = 'dark_mode';
  static const String _metricUnitsKey = 'metric_units';
  static const String _privateProfileKey = 'private_profile';
  static const String _workoutRemindersKey = 'workout_reminders';
  static const String _geminiApiKey = 'gemini_api_key';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? true;
  }

  Future<bool> getMetricUnits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_metricUnitsKey) ?? true;
  }

  Future<bool> getPrivateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privateProfileKey) ?? false;
  }

  Future<bool> getWorkoutReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_workoutRemindersKey) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setMetricUnits(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_metricUnitsKey, value);
  }

  Future<void> setPrivateProfile(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privateProfileKey, value);
  }

  Future<void> setWorkoutReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_workoutRemindersKey, value);
  }

  Future<String> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKey) ?? '';
  }

  Future<void> setGeminiApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKey, value);
  }
}
