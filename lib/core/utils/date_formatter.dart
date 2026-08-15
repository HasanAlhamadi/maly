import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _shortFmt = DateFormat('dd/MM/yyyy');

  static String format(DateTime date) => _dateFmt.format(date);
  static String formatShort(DateTime date) => _shortFmt.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return format(date);
  }
}
