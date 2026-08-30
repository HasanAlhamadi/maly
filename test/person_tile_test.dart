// Widget test: a person row shows the right wording for each balance.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'package:maly/domain/entities/person_summary.dart';
import 'package:maly/generated/app_localizations.dart';
import 'package:maly/presentation/widgets/person_tile.dart';

void main() {
  Person person(String name) =>
      Person(id: 1, name: name, createdAt: DateTime(2026, 1, 1));

  Future<void> pumpTile(WidgetTester tester, double balance) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PersonTile(
            summary: PersonSummary(person: person('Sara'), balance: balance),
          ),
        ),
      ),
    );
  }

  testWidgets('a positive balance reads as "Owes you"', (tester) async {
    await pumpTile(tester, 1500);
    await tester.pumpAndSettle();

    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Owes you'), findsOneWidget);
    expect(find.text('1,500 YER'), findsOneWidget);
  });

  testWidgets('a negative balance reads as "You owe"', (tester) async {
    await pumpTile(tester, -250);
    await tester.pumpAndSettle();

    expect(find.text('You owe'), findsOneWidget);
    expect(find.text('250 YER'), findsOneWidget);
  });

  testWidgets('a zero balance reads as "Settled"', (tester) async {
    await pumpTile(tester, 0);
    await tester.pumpAndSettle();

    expect(find.text('Settled'), findsOneWidget);
  });
}
