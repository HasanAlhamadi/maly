// 📁 lib/presentation/providers/balance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

final personBalanceProvider = FutureProvider.family<double, int>((
  ref,
  personId,
) async {
  final repo = ref.read(debtRepositoryProvider);
  return repo.getPersonBalance(personId);
});

final dashboardTotalsProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final repo = ref.read(debtRepositoryProvider);
  return repo.getDashboardTotals();
});
