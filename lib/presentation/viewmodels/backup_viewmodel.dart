// 📁 lib/presentation/viewmodels/backup_viewmodel.dart
// PURPOSE: Export and import actions, including choosing the file.
//
// The screens never see an exception — every action reports back with a
// BackupResult so the UI just picks a message to show.

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/backup/backup_service.dart';
import '../providers/core_providers.dart';

enum BackupResult {
  success,

  /// The user closed the file picker without choosing anything.
  cancelled,

  /// The chosen file was not a usable Maly backup.
  invalidFile,

  failed,
}

final backupActionsProvider = Provider<BackupActions>((ref) {
  return BackupActions(ref);
});

class BackupActions {
  final Ref _ref;
  BackupActions(this._ref);

  /// Writes a backup to wherever the user chooses.
  Future<BackupResult> exportBackup() async {
    try {
      final json = await _ref.read(backupServiceProvider).export();

      // FileType.any avoids per-device problems with custom extension and
      // MIME mapping; the suggested file name still ends in .json.
      final path = await FilePicker.platform.saveFile(
        fileName: BackupService.fileNameFor(DateTime.now()),
        bytes: utf8.encode(json),
      );

      return path == null ? BackupResult.cancelled : BackupResult.success;
    } catch (_) {
      return BackupResult.failed;
    }
  }

  /// Replaces all current data with the chosen backup file.
  Future<BackupResult> importBackup() async {
    try {
      // withData loads the bytes for us, so this works the same on every
      // platform without touching the file system directly.
      final picked = await FilePicker.platform.pickFiles(withData: true);
      if (picked == null || picked.files.isEmpty) {
        return BackupResult.cancelled;
      }

      final bytes = picked.files.single.bytes;
      if (bytes == null) return BackupResult.failed;

      await _ref.read(backupServiceProvider).import(utf8.decode(bytes));
      return BackupResult.success;
    } on InvalidBackupException {
      return BackupResult.invalidFile;
    } catch (_) {
      return BackupResult.failed;
    }
  }
}
