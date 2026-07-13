import 'package:fast_fitness/features/profile/data/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  final SettingsService _settingsService = SettingsService();

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.dark;
  }

  Future<void> _loadThemeMode() async {
    final isDarkMode = await _settingsService.getDarkMode();
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDarkMode(bool value) async {
    state = value ? ThemeMode.dark : ThemeMode.light;
    await _settingsService.setDarkMode(value);
  }
}
