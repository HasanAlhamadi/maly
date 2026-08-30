// Widget test: a transaction row shows a signed, colour-coded amount.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/domain/entities/transaction.dart';
import 'package:maly/generated/app_localizations.dart';
import 'package:maly/presentation/widgets/transaction_tile.dart';

void main() {
  DebtTransaction transaction({
    required TransactionType type,
    String? description,
  }) {
    final date = DateTime.now();
    return DebtTransaction(
      id: 1,
      personId: 1,
      amount: 2000,
      type: type,
      description: description,
      date: date,
      createdAt: date,
    );
  }

  Future<void> pumpTile(WidgetTester tester, DebtTransaction value) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TransactionTile(transaction: value)),
      ),
    );
  }

  testWidgets('credit is shown as a positive amount', (tester) async {
    await pumpTile(
      tester,
      transaction(type: TransactionType.credit, description: 'Lunch'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('+2,000 YER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('debit is shown as a negative amount', (tester) async {
    await pumpTile(tester, transaction(type: TransactionType.debit));
    await tester.pumpAndSettle();

    expect(find.text('-2,000 YER'), findsOneWidget);
    // With no description the type name is used instead.
    expect(find.text('Debit'), findsOneWidget);
  });
}
