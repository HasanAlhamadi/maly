// 📁 lib/data/local/database/tables.dart
import 'package:drift/drift.dart';

/// Persons Table
class Persons extends Table {
  @override
  String get tableName => 'persons'; // ← was DatabaseConstants.personsTable

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get notes => text().nullable().withLength(max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Transactions Table
class DebtTransactions extends Table {
  @override
  String get tableName => 'transactions'; // ← was DatabaseConstants.transactionsTable

  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real().check(amount.isBiggerThanValue(0))();
  IntColumn get type => integer().withDefault(const Constant(0))();
  TextColumn get description => text().nullable().withLength(max: 500)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
