// 📁 lib/data/local/database/tables.dart
import 'package:drift/drift.dart';
import '../../../domain/entities/transaction.dart';

/// Persons Table
class Persons extends Table {
  @override
  String get tableName => 'persons';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get notes => text().nullable().withLength(max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Transactions Table
class DebtTransactions extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  // Amount must always be positive; direction is carried by `type` instead.
  // ignore: recursive_getters
  RealColumn get amount => real().check(amount.isBiggerThanValue(0))();

  // Stored as the enum index (debit = 0, credit = 1), so the app never has to
  // compare raw magic numbers.
  IntColumn get type =>
      intEnum<TransactionType>().withDefault(const Constant(0))();

  TextColumn get description => text().nullable().withLength(max: 500)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  // Optional: when this debt is expected to be paid. Drives the reminder.
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
