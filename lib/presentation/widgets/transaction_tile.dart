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

  /// Tapping opens the edit form. Null makes the row inert.
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCredit = transaction.type.isCredit;
    final color = isCredit ? AppColors.credit : AppColors.debit;

    final description = transaction.description;
    final hasDescription = description != null && description.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  isCredit
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            DateFormatter.relative(
                              transaction.date,
                              todayLabel: l10n.today,
                              yesterdayLabel: l10n.yesterday,
                              localeCode: Localizations.localeOf(
                                context,
                              ).languageCode,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (transaction.dueDate != null) ...[
                          const SizedBox(width: 8),
                          _DueChip(dueDate: transaction.dueDate!),
                        ],
                      ],
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
      ),
    );
  }
}

/// Small marker showing when a transaction is due, red once it is late.
class _DueChip extends StatelessWidget {
  final DateTime dueDate;

  const _DueChip({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // Compare calendar days: something due today is not late yet.
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = due.isBefore(today);

    final color = isOverdue ? AppColors.debit : AppColors.warning;
    final label = isOverdue
        ? l10n.overdue
        : '${l10n.due} ${DateFormatter.formatShort(dueDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
