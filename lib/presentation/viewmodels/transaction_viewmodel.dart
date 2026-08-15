// 📁 lib/presentation/viewmodels/transaction_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    required int type,
    String? description,
    DateTime? date,
  }) async {
    final repo = _ref.read(debtRepositoryProvider);
    await repo.insertTransaction(
      personId: personId,
      amount: amount,
      type: type,
      description: description,
      date: date,
    );
  }

  Future<void> deleteTransaction(int id) async {
    final repo = _ref.read(debtRepositoryProvider);
    await repo.deleteTransaction(id);
  }
}
