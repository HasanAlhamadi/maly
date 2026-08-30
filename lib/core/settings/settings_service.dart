// 📁 lib/core/settings/settings_service.dart
// PURPOSE: Saves the two user preferences (theme + language) to disk so they
// survive an app restart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences _prefs;
  SettingsService(this._prefs);

  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_code';

  /// Reads the saved theme. Falls back to "follow the system".
  ThemeMode loadThemeMode() {
    switch (_prefs.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeKey, mode.name);
  }

  /// Reads the saved language. `null` means "follow the device language".
  Locale? loadLocale() {
    final code = _prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> saveLocale(Locale? locale) {
    // An empty string records the explicit "use the device language" choice.
    return _prefs.setString(_localeKey, locale?.languageCode ?? '');
  }
}

/// Overridden in main() once SharedPreferences has loaded, so the rest of the
/// app can read settings synchronously.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('settingsServiceProvider must be overridden');
});
