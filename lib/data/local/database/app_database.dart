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

  /// Lets tests run against a throwaway in-memory database.
  AppDatabase.forTesting(super.executor);

  /// Bump this whenever a table changes, and add an `onUpgrade` step below.
  ///
  /// v2 added `transactions.due_date`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Existing rows keep their data; due_date simply starts out null.
      if (from < 2) {
        await m.addColumn(debtTransactions, debtTransactions.dueDate);
      }
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
