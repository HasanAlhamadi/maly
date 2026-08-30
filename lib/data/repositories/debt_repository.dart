// 📁 lib/data/repositories/debt_repository.dart
// PURPOSE: The single place that talks to the database.
//
// Everything the UI reads is exposed as a Stream, so the screens update
// themselves whenever the data changes — no manual refresh needed.

import 'package:drift/drift.dart';
import '../../domain/entities/dashboard_totals.dart';
import '../../domain/entities/monthly_total.dart';
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
    DateTime? dueDate,
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
            dueDate: Value(dueDate),
          ),
        );
  }

  /// One transaction, kept live so an edit shows up straight away.
  Stream<DebtTransaction?> watchTransactionById(int id) {
    return (_db.select(
      _db.debtTransactions,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<bool> updateTransaction({
    required int id,
    required double amount,
    required TransactionType type,
    String? description,
    required DateTime date,
    DateTime? dueDate,
  }) {
    return (_db.update(_db.debtTransactions)..where((t) => t.id.equals(id)))
        .write(
          DebtTransactionsCompanion(
            amount: Value(amount),
            type: Value(type),
            description: Value(description),
            date: Value(date),
            dueDate: Value(dueDate),
          ),
        )
        .then((rows) => rows > 0);
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

  /// Writes the single transaction that brings a person's balance to zero.
  ///
  /// Returns false when there is nothing to settle — the amount column has a
  /// CHECK > 0 constraint, so inserting a zero would throw.
  Future<bool> settleUp({required int personId, String? description}) async {
    final transactions = await (_db.select(
      _db.debtTransactions,
    )..where((t) => t.personId.equals(personId))).get();

    final balance = _sumBalance(transactions);
    if (balance == 0) return false;

    // If they owe you, record a debit of the same size to cancel it out.
    final type = balance > 0 ? TransactionType.debit : TransactionType.credit;

    await insertTransaction(
      personId: personId,
      amount: balance.abs(),
      type: type,
      description: description,
    );
    return true;
  }

  // ===== STATS =====

  /// Credit and debit totals per month, oldest first.
  ///
  /// Months with no activity are still included, so the chart keeps an even
  /// spacing instead of skipping gaps. [now] is injectable for tests.
  Stream<List<MonthlyTotal>> watchMonthlyTotals({
    int months = 6,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    // Build the empty buckets first, ending with the current month.
    final buckets = <DateTime, MonthlyTotal>{};
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(today.year, today.month - i);
      buckets[month] = MonthlyTotal(month: month, credit: 0, debit: 0);
    }

    final oldest = buckets.keys.first;

    return (_db.select(
      _db.debtTransactions,
    )..where((t) => t.date.isBiggerOrEqualValue(oldest))).watch().map((
      transactions,
    ) {
      final totals = Map<DateTime, MonthlyTotal>.from(buckets);

      for (final t in transactions) {
        final key = DateTime(t.date.year, t.date.month);
        final current = totals[key];
        // Guard against a row dated in the future, which has no bucket.
        if (current == null) continue;

        totals[key] = MonthlyTotal(
          month: key,
          credit: current.credit + (t.type.isCredit ? t.amount : 0),
          debit: current.debit + (t.type.isCredit ? 0 : t.amount),
        );
      }

      return totals.values.toList();
    });
  }

  // ===== BACKUP =====

  /// Everything in the database, for writing a backup file.
  Future<({List<Person> persons, List<DebtTransaction> transactions})>
  exportAll() async {
    final persons = await _db.select(_db.persons).get();
    final transactions = await _db.select(_db.debtTransactions).get();
    return (persons: persons, transactions: transactions);
  }

  /// Wipes the database and writes the backup in its place.
  ///
  /// The whole thing runs in one transaction, so a failure part way through
  /// rolls back and leaves the existing data untouched.
  Future<void> replaceAll({
    required List<Person> persons,
    required List<DebtTransaction> transactions,
  }) {
    return _db.transaction(() async {
      // Transactions reference persons, so they have to go first.
      await _db.delete(_db.debtTransactions).go();
      await _db.delete(_db.persons).go();

      await _db.batch((batch) {
        batch.insertAll(_db.persons, persons);
        batch.insertAll(_db.debtTransactions, transactions);
      });
    });
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
