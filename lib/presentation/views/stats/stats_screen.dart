// 📁 lib/presentation/views/stats/stats_screen.dart
// PURPOSE: Activity over the last six months, and who owes you most.
//
// The bars are plain widgets rather than a chart package, matching the
// breakdown bar on the home screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/monthly_total.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/stats_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/person_tile.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final monthlyAsync = ref.watch(monthlyTotalsProvider);
    final topDebtors = ref.watch(topDebtorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stats)),
      body: monthlyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const ErrorView(),
        data: (months) {
          // Nothing recorded in the whole window.
          if (months.every((m) => m.isEmpty)) {
            return EmptyState(
              icon: Icons.insights_outlined,
              title: l10n.noStatsYet,
              subtitle: l10n.noStatsYetSubtitle,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            children: [
              _MonthlyChartCard(months: months),
              const SizedBox(height: 20),
              Text(
                l10n.topDebtors,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              topDebtors.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (people) {
                  if (people.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            l10n.allSettled,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final summary in people)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PersonTile(
                            summary: summary,
                            onTap: () =>
                                context.push('/person/${summary.person.id}'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Grouped bars: one green (owed to you) and one red (you owe) per month.
class _MonthlyChartCard extends StatelessWidget {
  final List<MonthlyTotal> months;

  const _MonthlyChartCard({required this.months});

  /// Tallest bar in the chart, used to scale every other bar.
  double get _peak {
    var peak = 0.0;
    for (final m in months) {
      if (m.credit > peak) peak = m.credit;
      if (m.debit > peak) peak = m.debit;
    }
    return peak;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final labelFormat = DateFormat('MMM', localeCode);
    final peak = _peak;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyActivity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(l10n.last6Months, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),

            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final month in months)
                    Expanded(
                      child: _MonthColumn(
                        month: month,
                        peak: peak,
                        label: labelFormat.format(month.month),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                _LegendDot(color: AppColors.credit, label: l10n.totalOwedToYou),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.debit, label: l10n.totalYouOwe),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthColumn extends StatelessWidget {
  final MonthlyTotal month;
  final double peak;
  final String label;

  const _MonthColumn({
    required this.month,
    required this.peak,
    required this.label,
  });

  /// Height in pixels for one value, leaving room for the month label.
  double _barHeight(double value) {
    if (peak == 0 || value == 0) return 0;
    const maxHeight = 108.0;
    // A minimum keeps very small amounts visible rather than invisible.
    return (value / peak * maxHeight).clamp(3.0, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(height: _barHeight(month.credit), color: AppColors.credit),
            const SizedBox(width: 3),
            _Bar(height: _barHeight(month.debit), color: AppColors.debit),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;

  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
