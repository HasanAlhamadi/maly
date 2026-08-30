// Tests for the relative date labels shown on transactions.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:maly/core/utils/date_formatter.dart';

void main() {
  // The running app gets this from flutter_localizations; a plain unit test
  // has to load intl's date data itself.
  setUpAll(() => initializeDateFormatting('en'));

  String relative(DateTime date) => DateFormatter.relative(
    date,
    todayLabel: 'Today',
    yesterdayLabel: 'Yesterday',
    localeCode: 'en',
  );

  test('today is labelled Today, even late in the evening', () {
    final now = DateTime.now();
    final lateToday = DateTime(now.year, now.month, now.day, 23, 30);
    expect(relative(lateToday), 'Today');
  });

  test('yesterday is labelled Yesterday', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    expect(relative(yesterday), 'Yesterday');
  });

  test('older dates fall back to a full date', () {
    expect(relative(DateTime(2024, 3, 5)), '05 Mar 2024');
  });
}
