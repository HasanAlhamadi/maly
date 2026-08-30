// 📁 lib/presentation/viewmodels/transaction_viewmodel.dart
// PURPOSE: Transaction actions (writes). Reads live in the providers.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../domain/entities/transaction.dart';
import '../providers/core_providers.dart';

final transactionActionsProvider = Provider<TransactionActions>((ref) {
  return TransactionActions(ref);
});

class TransactionActions {
  final Ref _ref;
  TransactionActions(this._ref);

  Future<void> addTransaction({
    required int personId,
    required double amount,
    required TransactionType type,
    String? description,
    DateTime? date,
  }) {
    return _ref
        .read(debtRepositoryProvider)
        .insertTransaction(
          personId: personId,
          amount: amount,
          type: type,
          description: description,
          date: date,
        );
  }

  /// Deletes and hands back the removed row so the caller can offer an Undo.
  Future<DebtTransaction?> deleteTransaction(int id) {
    return _ref.read(debtRepositoryProvider).deleteTransaction(id);
  }

  Future<void> restoreTransaction(DebtTransaction transaction) {
    return _ref.read(debtRepositoryProvider).restoreTransaction(transaction);
  }
}
