// 📁 lib/data/repositories/debt_repository.dart
// PURPOSE: The single place that talks to the database.
//
// Everything the UI reads is exposed as a Stream, so the screens update
// themselves whenever the data changes — no manual refresh needed.

import 'package:drift/drift.dart';
import '../../domain/entities/dashboard_totals.dart';
import '../../domain/entities/person_summary.dart';
import '../../domain/entities/transaction.dart';
import '../local/database/app_database.dart';

class DebtRepository {
  final AppDatabase _db;
  DebtRepository(this._db);

  // ===== PERSON OPERATIONS =====

  Stream<List<Person>> watchAllPersons() {
    return (_db.select(
      _db.persons,
    )..orderBy([(p) => OrderingTerm(expression: p.name)])).watch();
  }

  /// A person's details, kept live so an edit shows up straight away.
  Stream<Person?> watchPersonById(int id) {
    return (_db.select(
      _db.persons,
    )..where((p) => p.id.equals(id))).watchSingleOrNull();
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

  Future<bool> updatePerson({
    required int id,
    required String name,
    String? phone,
    String? notes,
  }) {
    return (_db.update(_db.persons)..where((p) => p.id.equals(id))).write(
          PersonsCompanion(
            name: Value(name),
            phone: Value(phone),
            notes: Value(notes),
          ),
        ).then((rows) => rows > 0);
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
    required TransactionType type,
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

  /// Returns the deleted row so the UI can offer an "Undo".
  Future<DebtTransaction?> deleteTransaction(int id) async {
    final rows = await (_db.delete(
      _db.debtTransactions,
    )..where((t) => t.id.equals(id))).goAndReturn();
    return rows.isEmpty ? null : rows.first;
  }

  /// Puts a deleted transaction back, keeping its original values.
  Future<void> restoreTransaction(DebtTransaction transaction) {
    return _db.into(_db.debtTransactions).insert(transaction);
  }

  // ===== BALANCES =====

  /// One person's running balance. Positive means they owe you.
  Stream<double> watchPersonBalance(int personId) {
    return watchTransactionsForPerson(personId).map(_sumBalance);
  }

  /// Every person plus their balance, from a single query, so a list of N
  /// people does not run N separate balance queries.
  Stream<List<PersonSummary>> watchPersonSummaries() {
    final query =
        _db.select(_db.persons).join([
            leftOuterJoin(
              _db.debtTransactions,
              _db.debtTransactions.personId.equalsExp(_db.persons.id),
            ),
          ])
          ..orderBy([OrderingTerm(expression: _db.persons.name)]);

    return query.watch().map((rows) {
      // The join repeats a person once per transaction, so add the amounts up
      // per person. Insertion order keeps the name ordering from the query.
      final summaries = <int, PersonSummary>{};

      for (final row in rows) {
        final person = row.readTable(_db.persons);
        final transaction = row.readTableOrNull(_db.debtTransactions);

        final current =
            summaries[person.id] ?? PersonSummary(person: person, balance: 0);

        summaries[person.id] = transaction == null
            ? current
            : current.copyWith(
                balance:
                    current.balance +
                    transaction.type.signedAmount(transaction.amount),
              );
      }

      return summaries.values.toList();
    });
  }

  /// The three home screen figures, recalculated on every database change.
  Stream<DashboardTotals> watchDashboardTotals() {
    return _db.select(_db.debtTransactions).watch().map((transactions) {
      double owedToYou = 0;
      double youOwe = 0;

      for (final t in transactions) {
        if (t.type.isCredit) {
          owedToYou += t.amount;
        } else {
          youOwe += t.amount;
        }
      }

      return DashboardTotals(owedToYou: owedToYou, youOwe: youOwe);
    });
  }

  /// Credit adds, debit subtracts.
  double _sumBalance(List<DebtTransaction> transactions) {
    double balance = 0;
    for (final t in transactions) {
      balance += t.type.signedAmount(t.amount);
    }
    return balance;
  }
}
