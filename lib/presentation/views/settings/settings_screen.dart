// 📁 lib/presentation/views/settings/settings_screen.dart
// PURPOSE: Theme and language. Both choices are saved and survive a restart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        children: [
          _SettingsGroup(
            title: l10n.appearance,
            children: [
              _ChoiceRow(
                label: l10n.system,
                icon: Icons.brightness_auto_rounded,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
              _ChoiceRow(
                label: l10n.light,
                icon: Icons.light_mode_outlined,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
              _ChoiceRow(
                label: l10n.dark,
                icon: Icons.dark_mode_outlined,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsGroup(
            title: l10n.language,
            children: [
              _ChoiceRow(
                label: l10n.system,
                icon: Icons.translate_rounded,
                // null means "follow the device language".
                selected: locale == null,
                onTap: () => ref.read(localeProvider.notifier).setLocale(null),
              ),
              _ChoiceRow(
                label: l10n.english,
                icon: Icons.abc_rounded,
                selected: locale?.languageCode == 'en',
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('en')),
              ),
              _ChoiceRow(
                label: l10n.arabic,
                icon: Icons.language_rounded,
                selected: locale?.languageCode == 'ar',
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ar')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A titled card holding a set of related choices.
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// One selectable option with a tick when it is active.
class _ChoiceRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      shape: const RoundedRectangleBorder(),
      leading: Icon(icon, color: selected ? color : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? color : null,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: color)
          : null,
    );
  }
}
