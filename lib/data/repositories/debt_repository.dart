import '../local/database/app_database.dart';
import 'package:drift/drift.dart';

class DebtRepository {
  final AppDatabase _db;
  DebtRepository(this._db);

  // ===== PERSON OPERATIONS =====
  Stream<List<Person>> watchAllPersons() {
    return (_db.select(
      _db.persons,
    )..orderBy([(p) => OrderingTerm(expression: p.name)])).watch();
  }

  Future<Person?> getPersonById(int id) {
    return (_db.select(
      _db.persons,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertPerson({
    required String name,
    String? phone,
    String? notes,
  }) {
    return _db
        .into(_db.persons)
        .insert(
          PersonsCompanion.insert(
            name: name,
            phone: Value(phone),
            notes: Value(notes),
          ),
        );
  }

  Future<int> deletePerson(int id) {
    return (_db.delete(_db.persons)..where((p) => p.id.equals(id))).go();
  }

  // ===== TRANSACTION OPERATIONS =====
  Stream<List<DebtTransaction>> watchTransactionsForPerson(int personId) {
    return (_db.select(_db.debtTransactions)
          ..where((t) => t.personId.equals(personId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> insertTransaction({
    required int personId,
    required double amount,
    required int type,
    String? description,
    DateTime? date,
  }) {
    return _db
        .into(_db.debtTransactions)
        .insert(
          DebtTransactionsCompanion.insert(
            personId: personId,
            amount: amount,
            type: Value(type),
            description: Value(description),
            date: Value(date ?? DateTime.now()),
          ),
        );
  }

  Future<int> deleteTransaction(int id) {
    return (_db.delete(
      _db.debtTransactions,
    )..where((t) => t.id.equals(id))).go();
  }

  // ===== BALANCE CALCULATIONS =====
  Future<double> getPersonBalance(int personId) async {
    final transactions = await (_db.select(
      _db.debtTransactions,
    )..where((t) => t.personId.equals(personId))).get();

    double balance = 0;
    for (final t in transactions) {
      if (t.type == 1)
        balance += t.amount; // credit: they owe me
      else
        balance -= t.amount; // debit: I owe them
    }
    return balance;
  }

  Future<Map<String, double>> getDashboardTotals() async {
    final allTransactions = await _db.select(_db.debtTransactions).get();
    double totalCredit = 0;
    double totalDebit = 0;

    for (final t in allTransactions) {
      if (t.type == 1)
        totalCredit += t.amount;
      else
        totalDebit += t.amount;
    }

    return {
      'owedToYou': totalCredit,
      'youOwe': totalDebit,
      'net': totalCredit - totalDebit,
    };
  }
}
