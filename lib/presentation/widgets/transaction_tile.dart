// 📁 lib/presentation/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../../domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  final DebtTransaction transaction;
  final VoidCallback? onDelete;

  const TransactionTile({super.key, required this.transaction, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final type = transaction.type == 1
        ? TransactionType.credit
        : TransactionType.debit;
    final isCredit = type.isCredit;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? AppColors.credit.withOpacity(0.15)
              : AppColors.debit.withOpacity(0.15),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? AppColors.credit : AppColors.debit,
          ),
        ),
        title: Text(
          CurrencyFormatter.format(transaction.amount),
          style: TextStyle(
            color: isCredit ? AppColors.credit : AppColors.debit,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null &&
                transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              DateFormatter.relative(transaction.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: onDelete,
              )
            : Chip(
                label: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isCredit ? AppColors.credit : AppColors.debit,
                  ),
                ),
                backgroundColor: isCredit
                    ? AppColors.credit.withOpacity(0.1)
                    : AppColors.debit.withOpacity(0.1),
                side: BorderSide.none,
              ),
      ),
    );
  }
}
