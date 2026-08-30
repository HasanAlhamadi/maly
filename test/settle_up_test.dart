// Tests for settling a person's balance down to zero.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/data/repositories/debt_repository.dart';
import 'package:maly/domain/entities/transaction.dart';

void main() {
  late AppDatabase db;
  late DebtRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DebtRepository(db);
  });

  tearDown(() => db.close());

  Future<double> balanceOf(int personId) =>
      repository.watchPersonBalance(personId).first;

  test('settling a positive balance brings it to exactly zero', () async {
    final id = await repository.insertPerson(name: 'Sara');
    await repository.insertTransaction(
      personId: id,
      amount: 1500,
      type: TransactionType.credit,
    );
    await repository.insertTransaction(
      personId: id,
      amount: 500,
      type: TransactionType.credit,
    );
    expect(await balanceOf(id), 2000);

    expect(await repository.settleUp(personId: id), isTrue);
    expect(await balanceOf(id), 0);
  });

  test('settling a negative balance brings it to exactly zero', () async {
    final id = await repository.insertPerson(name: 'Omar');
    await repository.insertTransaction(
      personId: id,
      amount: 750,
      type: TransactionType.debit,
    );
    expect(await balanceOf(id), -750);

    expect(await repository.settleUp(personId: id), isTrue);
    expect(await balanceOf(id), 0);
  });

  test('the settling entry is the opposite type', () async {
    final id = await repository.insertPerson(name: 'Sara');
    await repository.insertTransaction(
      personId: id,
      amount: 300,
      type: TransactionType.credit,
    );

    await repository.settleUp(personId: id, description: 'Settled up');

    final all = await repository.watchTransactionsForPerson(id).first;
    final settling = all.firstWhere((t) => t.description == 'Settled up');
    expect(settling.type, TransactionType.debit);
    expect(settling.amount, 300);
  });

  test('settling an already-zero balance is refused, not written', () async {
    final id = await repository.insertPerson(name: 'Ali');

    // Nothing recorded at all.
    expect(await repository.settleUp(personId: id), isFalse);
    expect(await repository.watchTransactionsForPerson(id).first, isEmpty);

    // And again once entries cancel each other out exactly.
    await repository.insertTransaction(
      personId: id,
      amount: 100,
      type: TransactionType.credit,
    );
    await repository.insertTransaction(
      personId: id,
      amount: 100,
      type: TransactionType.debit,
    );
    expect(await balanceOf(id), 0);

    expect(await repository.settleUp(personId: id), isFalse);
    expect(await repository.watchTransactionsForPerson(id).first, hasLength(2));
  });

  test('editing a transaction updates the balance', () async {
    final id = await repository.insertPerson(name: 'Sara');
    final txId = await repository.insertTransaction(
      personId: id,
      amount: 1000,
      type: TransactionType.credit,
    );
    expect(await balanceOf(id), 1000);

    // Same entry, corrected amount and flipped direction.
    await repository.updateTransaction(
      id: txId,
      amount: 250,
      type: TransactionType.debit,
      description: 'Corrected',
      date: DateTime(2026, 6, 1),
    );

    expect(await balanceOf(id), -250);

    final updated = await repository.watchTransactionById(txId).first;
    expect(updated!.description, 'Corrected');
    expect(updated.type, TransactionType.debit);
  });
}
