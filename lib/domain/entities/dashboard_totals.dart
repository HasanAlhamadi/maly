// 📁 lib/domain/entities/dashboard_totals.dart
// PURPOSE: The three figures shown on the home screen.

class DashboardTotals {
  /// Sum of everything other people owe you.
  final double owedToYou;

  /// Sum of everything you owe other people.
  final double youOwe;

  const DashboardTotals({required this.owedToYou, required this.youOwe});

  static const empty = DashboardTotals(owedToYou: 0, youOwe: 0);

  /// What you are worth overall: positive means you are owed money.
  double get net => owedToYou - youOwe;

  /// True when there is nothing to track in either direction.
  bool get isEmpty => owedToYou == 0 && youOwe == 0;
}
