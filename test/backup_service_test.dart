// Round-trip test for backup export/import, against a real in-memory database.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/backup/backup_service.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/data/repositories/debt_repository.dart';
import 'package:maly/domain/entities/transaction.dart';

void main() {
  late AppDatabase db;
  late DebtRepository repository;
  late BackupService backup;

  setUp(() {
    // A fresh in-memory database per test, so nothing leaks between them.
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DebtRepository(db);
    backup = BackupService(repository);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    final sara = await repository.insertPerson(name: 'Sara', phone: '777');
    final omar = await repository.insertPerson(name: 'Omar', notes: 'Neighbour');

    await repository.insertTransaction(
      personId: sara,
      amount: 1500,
      type: TransactionType.credit,
      description: 'Lunch',
      date: DateTime(2026, 5, 1),
    );
    await repository.insertTransaction(
      personId: omar,
      amount: 400,
      type: TransactionType.debit,
      date: DateTime(2026, 5, 2),
    );
  }

  test('exported data comes back unchanged after a wipe', () async {
    await seed();

    final json = await backup.export();

    // Wipe everything, the way a fresh install would look.
    await repository.replaceAll(persons: [], transactions: []);
    expect(await repository.watchAllPersons().first, isEmpty);

    await backup.import(json);

    final people = await repository.watchAllPersons().first;
    expect(people.map((p) => p.name), ['Omar', 'Sara']);
    expect(people.firstWhere((p) => p.name == 'Sara').phone, '777');
    expect(people.firstWhere((p) => p.name == 'Omar').notes, 'Neighbour');

    final summaries = await repository.watchPersonSummaries().first;
    final byName = {for (final s in summaries) s.person.name: s.balance};
    expect(byName['Sara'], 1500);
    expect(byName['Omar'], -400);
  });

  test('the transaction type survives the round trip', () async {
    await seed();
    final json = await backup.export();
    await backup.import(json);

    final all = await db.select(db.debtTransactions).get();
    final credit = all.firstWhere((t) => t.amount == 1500);
    final debit = all.firstWhere((t) => t.amount == 400);

    expect(credit.type, TransactionType.credit);
    expect(debit.type, TransactionType.debit);
  });

  test('the file records its format version', () async {
    await seed();
    expect(await backup.export(), contains('"version": 1'));
  });

  test('a damaged or unrelated file is rejected', () async {
    await seed();

    // Anything that is not a Maly backup must throw, not corrupt the data.
    for (final bad in ['not json at all', '{}', '[]', '{"version": 1}']) {
      expect(
        () => backup.import(bad),
        throwsA(isA<InvalidBackupException>()),
        reason: 'should have rejected: $bad',
      );
    }

    // A backup from a future version of the app is refused too.
    expect(
      () => backup.import('{"version": 99, "persons": [], "transactions": []}'),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  test('a rejected import leaves the existing data untouched', () async {
    await seed();

    await expectLater(
      () => backup.import('garbage'),
      throwsA(isA<InvalidBackupException>()),
    );

    final people = await repository.watchAllPersons().first;
    expect(people, hasLength(2));
  });

  test('the suggested file name is dated', () {
    expect(
      BackupService.fileNameFor(DateTime(2026, 8, 31)),
      'maly-backup-2026-08-31.json',
    );
  });
}
