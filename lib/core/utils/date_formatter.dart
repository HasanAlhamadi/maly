// 📁 lib/core/utils/date_formatter.dart
// PURPOSE: Date formatting. Labels are passed in so they can be translated.

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// "05 Mar 2026" in the given language.
  static String format(DateTime date, [String? localeCode]) =>
      DateFormat('dd MMM yyyy', localeCode).format(date);

  /// "05/03/2026"
  static String formatShort(DateTime date, [String? localeCode]) =>
      DateFormat('dd/MM/yyyy', localeCode).format(date);

  /// "Today" / "Yesterday" / a full date. The two labels come from l10n so
  /// this stays translatable.
  static String relative(
    DateTime date, {
    required String todayLabel,
    required String yesterdayLabel,
    String? localeCode,
  }) {
    final now = DateTime.now();
    // Compare calendar days, not 24-hour spans.
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return todayLabel;
    if (diff == 1) return yesterdayLabel;
    return format(date, localeCode);
  }
}
