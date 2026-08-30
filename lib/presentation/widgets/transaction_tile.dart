// 📁 lib/presentation/widgets/transaction_tile.dart
// PURPOSE: One row in a person's transaction history.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/local/database/app_database.dart';
// Provides the .isCredit / .signedAmount helpers on TransactionType.
import '../../domain/entities/transaction.dart';
import '../../generated/app_localizations.dart';
import 'money_text.dart';

class TransactionTile extends StatelessWidget {
  final DebtTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCredit = transaction.type.isCredit;
    final color = isCredit ? AppColors.credit : AppColors.debit;

    final description = transaction.description;
    final hasDescription = description != null && description.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Fall back to the type name when there is no note.
                    hasDescription
                        ? description
                        : (isCredit ? l10n.credit : l10n.debit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormatter.relative(
                      transaction.date,
                      todayLabel: l10n.today,
                      yesterdayLabel: l10n.yesterday,
                      localeCode: Localizations.localeOf(context).languageCode,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Credit shows as +, debit as -, so direction is obvious at a glance.
            MoneyText(
              transaction.type.signedAmount(transaction.amount),
              fontSize: 15,
              color: color,
              signed: true,
            ),
          ],
        ),
      ),
    );
  }
}
