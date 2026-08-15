import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();
  static final _fmt = NumberFormat('#,##0.##');

  static String format(double amount) {
    return '${_fmt.format(amount.abs())} YER';
  }

  static String formatSigned(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign${format(amount)}';
  }

  static double? parse(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(cleaned);
  }
}
