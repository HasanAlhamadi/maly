// 📁 lib/core/utils/currency_formatter.dart
// PURPOSE: Turns doubles into readable money strings, and back again.

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _fmt = NumberFormat('#,##0.##');

  /// "12,500 YER" — always positive, the sign is shown by colour instead.
  static String format(double amount, {String? symbol}) {
    return '${_fmt.format(amount.abs())} ${symbol ?? AppConstants.currencySymbol}';
  }

  /// "+12,500 YER" / "-12,500 YER" for the net balance.
  static String formatSigned(double amount, {String? symbol}) {
    if (amount == 0) return format(amount, symbol: symbol);
    final sign = amount > 0 ? '+' : '-';
    return '$sign${format(amount, symbol: symbol)}';
  }

  /// Number only, no currency code — used inside the hero card.
  static String formatPlain(double amount) => _fmt.format(amount.abs());

  /// Reads what the user typed. Returns null if it is not a number.
  static double? parse(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(cleaned);
  }
}
