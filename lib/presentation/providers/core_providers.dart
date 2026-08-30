// 📁 lib/presentation/providers/core_providers.dart
// PURPOSE: Database & Repository dependency injection

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/backup/backup_service.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/debt_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Close the connection if this provider is ever disposed (e.g. in tests).
  ref.onDispose(db.close);
  return db;
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(debtRepositoryProvider));
});
