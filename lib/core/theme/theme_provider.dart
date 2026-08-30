// 📁 lib/core/theme/theme_provider.dart
// PURPOSE: Theme mode state, persisted between launches.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(settingsServiceProvider));
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _settings;

  // Start from whatever was saved last time.
  ThemeNotifier(this._settings) : super(_settings.loadThemeMode());

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _settings.saveThemeMode(mode);
  }

  /// Quick light <-> dark flip. From "system" it goes to dark.
  void toggle() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
