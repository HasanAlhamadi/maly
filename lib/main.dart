// 📁 lib/main.dart
// PURPOSE: App entry point — loads saved settings, then starts the app.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/locale/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'generated/app_localizations.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Settings must be ready before the first frame, otherwise the app would
  // flash the default theme before switching to the saved one.
  final prefs = await SharedPreferences.getInstance();

  // Notifications are optional — set them up in the background so a failure
  // here can never stop the app from starting.
  NotificationService().init().catchError((Object _) {});

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MalyApp(),
    ),
  );
}

class MalyApp extends ConsumerWidget {
  const MalyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      // Localised, so the task switcher shows the right name in Arabic.
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization. A null locale means "follow the device language".
      // MaterialApp derives text direction (RTL for Arabic) from this on its
      // own, so no manual Directionality wrapper is needed.
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // Routing
      routerConfig: appRouter,
    );
  }
}
