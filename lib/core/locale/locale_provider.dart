// 📁 lib/core/locale/locale_provider.dart
// PURPOSE: Language state (EN/AR), persisted between launches.
// A null value means "follow the device language".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(settingsServiceProvider));
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsService _settings;

  LocaleNotifier(this._settings) : super(_settings.loadLocale());

  /// Pass null to follow the device language.
  void setLocale(Locale? locale) {
    state = locale;
    _settings.saveLocale(locale);
  }
}
