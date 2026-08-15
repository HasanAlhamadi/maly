// 📁 lib/presentation/widgets/person_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../providers/balance_providers.dart';

class PersonTile extends ConsumerWidget {
  final Person person;
  final VoidCallback? onTap;

  const PersonTile({super.key, required this.person, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(personBalanceProvider(person.id));

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text(
            person.name[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          person.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: balanceAsync.when(
          data: (balance) {
            if (balance == 0)
              return Text(
                'Settled',
                style: TextStyle(color: Colors.grey.shade600),
              );
            final isPos = balance > 0;
            return Text(
              isPos
                  ? 'Owes you ${CurrencyFormatter.format(balance)}'
                  : 'You owe ${CurrencyFormatter.format(balance)}',
              style: TextStyle(
                color: isPos ? AppColors.credit : AppColors.debit,
                fontWeight: FontWeight.w500,
              ),
            );
          },
          loading: () => const Text('...'),
          error: (_, __) => const Text('Error'),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
