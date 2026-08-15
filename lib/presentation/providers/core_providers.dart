// 📁 lib/presentation/providers/core_providers.dart
// PURPOSE: Database & Repository dependency injection

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/debt_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DebtRepository(db);
});
