// Tests for grouping transactions into months, including across a year end.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/data/repositories/debt_repository.dart';
import 'package:maly/domain/entities/transaction.dart';

void main() {
  late AppDatabase db;
  late DebtRepository repository;
  late int personId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DebtRepository(db);
    personId = await repository.insertPerson(name: 'Sara');
  });

  tearDown(() => db.close());

  Future<void> add(
    double amount,
    TransactionType type,
    DateTime date,
  ) => repository.insertTransaction(
    personId: personId,
    amount: amount,
    type: type,
    date: date,
  );

  test('six buckets are returned even when most months are empty', () async {
    final totals = await repository
        .watchMonthlyTotals(now: DateTime(2026, 3, 15))
        .first;

    expect(totals, hasLength(6));
    expect(totals.every((t) => t.isEmpty), isTrue);

    // Oldest first, ending with the current month.
    expect(totals.first.month, DateTime(2025, 10));
    expect(totals.last.month, DateTime(2026, 3));
  });

  test('months are bucketed correctly across a year boundary', () async {
    await add(100, TransactionType.credit, DateTime(2025, 11, 20));
    await add(200, TransactionType.debit, DateTime(2025, 12, 31));
    await add(300, TransactionType.credit, DateTime(2026, 1, 1));

    final totals = await repository
        .watchMonthlyTotals(now: DateTime(2026, 3, 15))
        .first;

    final byMonth = {for (final t in totals) t.month: t};

    expect(byMonth[DateTime(2025, 11)]!.credit, 100);
    expect(byMonth[DateTime(2025, 12)]!.debit, 200);
    // 31 Dec and 1 Jan are one day apart but belong to different buckets.
    expect(byMonth[DateTime(2025, 12)]!.credit, 0);
    expect(byMonth[DateTime(2026, 1)]!.credit, 300);
  });

  test('credit and debit are totalled separately within a month', () async {
    await add(500, TransactionType.credit, DateTime(2026, 2, 3));
    await add(250, TransactionType.credit, DateTime(2026, 2, 20));
    await add(75, TransactionType.debit, DateTime(2026, 2, 28));

    final totals = await repository
        .watchMonthlyTotals(now: DateTime(2026, 3, 15))
        .first;
    final february = totals.firstWhere((t) => t.month == DateTime(2026, 2));

    expect(february.credit, 750);
    expect(february.debit, 75);
    expect(february.total, 825);
    expect(february.isEmpty, isFalse);
  });

  test('transactions older than the window are left out', () async {
    await add(999, TransactionType.credit, DateTime(2024, 1, 1));
    await add(100, TransactionType.credit, DateTime(2026, 3, 1));

    final totals = await repository
        .watchMonthlyTotals(now: DateTime(2026, 3, 15))
        .first;

    final sum = totals.fold<double>(0, (acc, t) => acc + t.total);
    expect(sum, 100);
  });
}
