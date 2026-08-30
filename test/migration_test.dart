// Verifies the v1 -> v2 upgrade (adding transactions.due_date) keeps the
// data that was already there.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/data/repositories/debt_repository.dart';
import 'package:maly/domain/entities/transaction.dart';

void main() {
  // Unix seconds — drift stores DateTime as an integer by default.
  const createdAt = 1767225600; // 2026-01-01
  const txDate = 1767312000; // 2026-01-02

  /// A database shaped exactly like schema version 1, with rows in it.
  AppDatabase openLegacyDatabase() {
    return AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE persons (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              phone TEXT NULL,
              notes TEXT NULL,
              created_at INTEGER NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE transactions (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              person_id INTEGER NOT NULL REFERENCES persons (id)
                ON DELETE CASCADE,
              amount REAL NOT NULL,
              type INTEGER NOT NULL DEFAULT 0,
              description TEXT NULL,
              date INTEGER NOT NULL,
              created_at INTEGER NOT NULL
            );
          ''');

          rawDb.execute(
            'INSERT INTO persons (id, name, phone, notes, created_at) '
            "VALUES (1, 'Sara', '777', 'Neighbour', $createdAt);",
          );
          // type 1 = credit, type 0 = debit
          rawDb.execute(
            'INSERT INTO transactions '
            '(id, person_id, amount, type, description, date, created_at) '
            "VALUES (1, 1, 1500, 1, 'Lunch', $txDate, $createdAt);",
          );
          rawDb.execute(
            'INSERT INTO transactions '
            '(id, person_id, amount, type, description, date, created_at) '
            'VALUES (2, 1, 400, 0, NULL, $txDate, $createdAt);',
          );

          // This is what makes drift run onUpgrade instead of onCreate.
          rawDb.execute('PRAGMA user_version = 1;');
        },
      ),
    );
  }

  test('upgrading from v1 keeps people and transactions', () async {
    final db = openLegacyDatabase();
    addTearDown(db.close);
    final repository = DebtRepository(db);

    final people = await repository.watchAllPersons().first;
    expect(people, hasLength(1));
    expect(people.single.name, 'Sara');
    expect(people.single.phone, '777');
    expect(people.single.notes, 'Neighbour');

    final transactions = await repository.watchTransactionsForPerson(1).first;
    expect(transactions, hasLength(2));

    // The stored integers still map onto the right enum values.
    expect(
      transactions.firstWhere((t) => t.amount == 1500).type,
      TransactionType.credit,
    );
    expect(
      transactions.firstWhere((t) => t.amount == 400).type,
      TransactionType.debit,
    );

    // 1500 owed to you minus 400 you owe.
    expect(await repository.watchPersonBalance(1).first, 1100);
  });

  test('the new dueDate column starts out null on existing rows', () async {
    final db = openLegacyDatabase();
    addTearDown(db.close);

    final transactions = await db.select(db.debtTransactions).get();
    expect(transactions, hasLength(2));
    expect(transactions.every((t) => t.dueDate == null), isTrue);
  });

  test('the database reports schema version 2 after upgrading', () async {
    final db = openLegacyDatabase();
    addTearDown(db.close);

    // Force the connection open so the migration actually runs.
    await db.select(db.persons).get();
    expect(db.schemaVersion, 2);
  });

  test('a brand new database is created at v2 with dueDate usable', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DebtRepository(db);

    final personId = await repository.insertPerson(name: 'Omar');
    await repository.insertTransaction(
      personId: personId,
      amount: 200,
      type: TransactionType.debit,
      dueDate: DateTime(2026, 9, 15),
    );

    final transactions = await repository
        .watchTransactionsForPerson(personId)
        .first;
    expect(transactions.single.dueDate, DateTime(2026, 9, 15));
  });
}
