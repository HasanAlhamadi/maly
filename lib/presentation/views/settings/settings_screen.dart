// 📁 lib/presentation/views/settings/settings_screen.dart
// PURPOSE: Theme, language and backup. Every choice here is saved and
// survives a restart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../generated/app_localizations.dart';
import '../../viewmodels/backup_viewmodel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Blocks both backup buttons while a file is being written or read.
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _busy = true);
    final result = await ref.read(backupActionsProvider).exportBackup();
    if (mounted) setState(() => _busy = false);

    switch (result) {
      // Cancelling is a normal choice, so it gets no message.
      case BackupResult.cancelled:
        return;
      case BackupResult.success:
        messenger.showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
      case BackupResult.invalidFile:
      case BackupResult.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.somethingWentWrong)),
        );
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Restoring wipes what is already there, so always confirm first.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.importWarningTitle),
        content: Text(l10n.importWarningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.debit),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    final result = await ref.read(backupActionsProvider).importBackup();
    if (mounted) setState(() => _busy = false);

    switch (result) {
      case BackupResult.cancelled:
        return;
      case BackupResult.success:
        messenger.showSnackBar(SnackBar(content: Text(l10n.importSuccess)));
      case BackupResult.invalidFile:
        messenger.showSnackBar(SnackBar(content: Text(l10n.invalidBackupFile)));
      case BackupResult.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.somethingWentWrong)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // A null locale means "follow the device language".
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
          const SizedBox(height: 20),
          _SettingsGroup(
            title: l10n.backup,
            children: [
              _ActionRow(
                label: l10n.exportData,
                subtitle: l10n.exportDataSubtitle,
                icon: Icons.upload_file_rounded,
                enabled: !_busy,
                onTap: _export,
              ),
              _ActionRow(
                label: l10n.importData,
                subtitle: l10n.importDataSubtitle,
                icon: Icons.download_rounded,
                enabled: !_busy,
                onTap: _import,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A titled card holding a set of related rows.
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
        Card(clipBehavior: Clip.antiAlias, child: Column(children: children)),
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
      trailing: selected ? Icon(Icons.check_circle_rounded, color: color) : null,
    );
  }
}

/// A row that performs an action rather than choosing a setting.
class _ActionRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      shape: const RoundedRectangleBorder(),
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
