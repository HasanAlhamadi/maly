// 📁 lib/data/local/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// Needed by the generated part file, which stores `type` as this enum.
import '../../../domain/entities/transaction.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Persons, DebtTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Bump this whenever a table changes, and add an `onUpgrade` step below.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection by default, which would
      // make `ON DELETE CASCADE` silently do nothing and leave orphan
      // transactions behind when a person is deleted.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'debt_tracker_db');
  }
}
