// 📁 lib/domain/entities/monthly_total.dart
// PURPOSE: One month's worth of activity, for the stats screen.

class MonthlyTotal {
  /// First day of the month this covers.
  final DateTime month;

  /// Money others took on towards you during the month.
  final double credit;

  /// Money you took on towards others during the month.
  final double debit;

  const MonthlyTotal({
    required this.month,
    required this.credit,
    required this.debit,
  });

  double get total => credit + debit;

  bool get isEmpty => total == 0;
}
