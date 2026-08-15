// 📁 lib/data/local/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Persons, DebtTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'debt_tracker_db');
  }
}
