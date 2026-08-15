// 📁 lib/presentation/widgets/balance_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String title;
  final bool isNet;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.title,
    this.isNet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isZero = balance == 0;
    final isPositive = balance > 0;
    final color = isZero
        ? AppColors.settled
        : isNet
        ? (isPositive ? AppColors.credit : AppColors.debit)
        : (isPositive ? AppColors.credit : AppColors.debit);

    return Card(
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(balance),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
