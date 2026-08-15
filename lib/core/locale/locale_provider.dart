// PURPOSE: Language switching (EN/AR)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setEnglish() => state = const Locale('en');
  void setArabic() => state = const Locale('ar');
  void toggle() {
    state = state.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }

  bool get isArabic => state.languageCode == 'ar';
}
