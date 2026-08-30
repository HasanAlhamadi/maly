// Tests for the balance rules: credit adds, debit subtracts.

import 'package:flutter_test/flutter_test.dart';
import 'package:maly/domain/entities/dashboard_totals.dart';
import 'package:maly/domain/entities/transaction.dart';

void main() {
  group('TransactionType', () {
    test('credit counts as money coming to you', () {
      expect(TransactionType.credit.isCredit, isTrue);
      expect(TransactionType.credit.signedAmount(100), 100);
    });

    test('debit counts as money you owe', () {
      expect(TransactionType.debit.isCredit, isFalse);
      expect(TransactionType.debit.signedAmount(100), -100);
    });

    test('the stored index matches the database convention', () {
      expect(TransactionType.debit.index, 0);
      expect(TransactionType.credit.index, 1);
    });
  });

  group('DashboardTotals', () {
    test('net is what you are owed minus what you owe', () {
      const totals = DashboardTotals(owedToYou: 800, youOwe: 300);
      expect(totals.net, 500);
    });

    test('net goes negative when you owe more', () {
      const totals = DashboardTotals(owedToYou: 100, youOwe: 450);
      expect(totals.net, -350);
    });

    test('isEmpty is true only when both sides are zero', () {
      expect(DashboardTotals.empty.isEmpty, isTrue);
      expect(const DashboardTotals(owedToYou: 0, youOwe: 5).isEmpty, isFalse);
    });
  });
}
