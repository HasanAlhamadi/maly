// 📁 lib/presentation/views/person/person_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/balance_providers.dart';
import '../../providers/person_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../viewmodels/person_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';

class PersonDetailScreen extends ConsumerWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final personAsync = ref.watch(personByIdProvider(personId));
    final transactionsAsync = ref.watch(
      personTransactionsStreamProvider(personId),
    );
    final balanceAsync = ref.watch(personBalanceProvider(personId));
    final transactionActions = ref.read(transactionActionsProvider);
    final personActions = ref.read(personActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: personAsync.when(
          data: (p) => Text(p?.name ?? l10n.persons),
          loading: () => const Text('...'),
          error: (_, __) => Text(l10n.persons),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _confirmDeletePerson(context, ref, personActions, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          balanceAsync.when(
            data: (balance) =>
                BalanceCard(balance: balance, title: l10n.balance),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(),

          // Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.transactionHistory,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTransactions,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          l10n.noTransactionsSubtitle,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return Slidable(
                      key: ValueKey(t.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                transactionActions.deleteTransaction(t.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: l10n.delete,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: TransactionTile(
                        transaction: t,
                        onDelete: () =>
                            transactionActions.deleteTransaction(t.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction/$personId'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTransaction),
      ),
    );
  }

  void _confirmDeletePerson(
    BuildContext context,
    WidgetRef ref,
    PersonActions actions,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePersonTitle),
        content: Text(l10n.deletePersonMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await actions.deletePerson(personId);
              if (context.mounted) {
                context.pop(); // close dialog
                context.pop(); // go back
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.debit),
            ),
          ),
        ],
      ),
    );
  }
}
