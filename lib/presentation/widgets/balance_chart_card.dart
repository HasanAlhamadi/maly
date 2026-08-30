// 📁 lib/presentation/widgets/balance_chart_card.dart
// PURPOSE: Shows at a glance how what you are owed compares with what you owe.
//
// Drawn with plain widgets rather than a chart package, so it stays small and
// has no extra dependency to keep up to date.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/dashboard_totals.dart';
import '../../generated/app_localizations.dart';
import 'money_text.dart';

class BalanceChartCard extends StatelessWidget {
  final DashboardTotals totals;

  const BalanceChartCard({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sum = totals.owedToYou + totals.youOwe;

    // The caller only shows this card when there is something to compare,
    // but guard anyway so the bar can never divide by zero.
    final creditShare = sum == 0 ? 0.0 : totals.owedToYou / sum;
    final debitShare = sum == 0 ? 0.0 : totals.youOwe / sum;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.overview, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Single bar split in proportion to the two sides.
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    Flexible(
                      // Flex must be a whole number, so scale the share up.
                      flex: (creditShare * 1000).round(),
                      child: Container(color: AppColors.credit),
                    ),
                    Flexible(
                      flex: (debitShare * 1000).round(),
                      child: Container(color: AppColors.debit),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _Legend(
                    color: AppColors.credit,
                    label: l10n.totalOwedToYou,
                    amount: totals.owedToYou,
                    share: creditShare,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Legend(
                    color: AppColors.debit,
                    label: l10n.totalYouOwe,
                    amount: totals.youOwe,
                    share: debitShare,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One colour-keyed figure under the bar.
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final double share;

  const _Legend({
    required this.color,
    required this.label,
    required this.amount,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (share * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        MoneyText(amount, fontSize: 15, color: color),
      ],
    );
  }
}
