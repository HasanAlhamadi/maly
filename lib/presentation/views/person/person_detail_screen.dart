// 📁 lib/presentation/views/person/person_detail_screen.dart
// PURPOSE: One person's balance and their full transaction history.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/balance_providers.dart';
import '../../providers/person_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../viewmodels/person_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/transaction_tile.dart';

class PersonDetailScreen extends ConsumerWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final person = ref.watch(personByIdProvider(personId)).valueOrNull;
    final balance = ref.watch(personBalanceProvider(personId)).valueOrNull ?? 0;
    final transactionsAsync = ref.watch(
      personTransactionsStreamProvider(personId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(person?.name ?? l10n.persons),
        actions: [
          IconButton(
            tooltip: l10n.editPerson,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/edit-person/$personId'),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDeletePerson(context, ref, l10n),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPadding,
                4,
                AppConstants.screenPadding,
                0,
              ),
              child: Column(
                children: [
                  BalanceCard(balance: balance, title: l10n.balance),
                  // Contact details are only shown when they exist.
                  if (person?.phone != null && person!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      text: person.phone!,
                    ),
                  ],
                  if (person?.notes != null && person!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.notes_rounded, text: person.notes!),
                  ],
                  const SizedBox(height: 24),
                  SectionHeader(title: l10n.transactionHistory),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.noTransactions,
                    subtitle: l10n.noTransactionsSubtitle,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPadding,
                  0,
                  AppConstants.screenPadding,
                  96,
                ),
                sliver: SliverList.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Slidable(
                      key: ValueKey(transaction.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.28,
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                _deleteTransaction(context, ref, transaction.id),
                            backgroundColor: AppColors.debit,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline_rounded,
                            label: l10n.delete,
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                          ),
                        ],
                      ),
                      child: TransactionTile(transaction: transaction),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorView(),
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

  /// Deletes a transaction and offers an Undo for a few seconds.
  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    int transactionId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(transactionActionsProvider);

    try {
      final deleted = await actions.deleteTransaction(transactionId);
      if (deleted == null) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => actions.restoreTransaction(deleted),
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    }
  }

  void _confirmDeletePerson(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePersonTitle),
        content: Text(l10n.deletePersonMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              Navigator.pop(dialogContext);

              try {
                await ref.read(personActionsProvider).deletePerson(personId);
                if (router.canPop()) router.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.personDeleted)),
                );
              } catch (_) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.somethingWentWrong)),
                );
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

/// Small phone / notes line under the balance card.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}
