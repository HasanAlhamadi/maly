// 📁 lib/presentation/providers/balance_providers.dart
// Balances are streams, so adding or deleting a transaction refreshes every
// figure on screen straight away.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_totals.dart';
import 'core_providers.dart';

final personBalanceProvider = StreamProvider.family<double, int>((
  ref,
  personId,
) {
  return ref.watch(debtRepositoryProvider).watchPersonBalance(personId);
});

final dashboardTotalsProvider = StreamProvider<DashboardTotals>((ref) {
  return ref.watch(debtRepositoryProvider).watchDashboardTotals();
});
