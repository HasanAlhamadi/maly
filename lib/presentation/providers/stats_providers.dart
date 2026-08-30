// 📁 lib/presentation/providers/stats_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/monthly_total.dart';
import '../../domain/entities/person_summary.dart';
import 'core_providers.dart';
import 'person_providers.dart';

/// Activity for the last six months, oldest first.
final monthlyTotalsProvider = StreamProvider<List<MonthlyTotal>>((ref) {
  return ref.watch(debtRepositoryProvider).watchMonthlyTotals();
});

/// The people who owe you the most, largest first.
final topDebtorsProvider = Provider<AsyncValue<List<PersonSummary>>>((ref) {
  return ref
      .watch(personSummariesProvider)
      .whenData((summaries) {
        final owing = summaries.where((s) => s.balance > 0).toList()
          ..sort((a, b) => b.balance.compareTo(a.balance));
        return owing.take(5).toList();
      });
});
