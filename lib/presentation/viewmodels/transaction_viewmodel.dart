// 📁 lib/presentation/viewmodels/transaction_viewmodel.dart
// PURPOSE: Transaction actions (writes). Reads live in the providers.
//
// Writing a transaction also keeps its payment reminder in step: scheduled
// when there is a due date, cancelled when there is not.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../domain/entities/transaction.dart';
import '../../services/notification_service.dart';
import '../providers/core_providers.dart';

/// The wording for a reminder. Passed in by the screen, because translated
/// text belongs to the UI layer rather than to a viewmodel.
class ReminderText {
  final String title;
  final String body;

  const ReminderText({required this.title, required this.body});
}

final transactionActionsProvider = Provider<TransactionActions>((ref) {
  return TransactionActions(ref);
});

class TransactionActions {
  final Ref _ref;
  TransactionActions(this._ref);

  NotificationService get _notifications => NotificationService();

  Future<void> addTransaction({
    required int personId,
    required double amount,
    required TransactionType type,
    String? description,
    DateTime? date,
    DateTime? dueDate,
    ReminderText? reminder,
  }) async {
    final id = await _ref
        .read(debtRepositoryProvider)
        .insertTransaction(
          personId: personId,
          amount: amount,
          type: type,
          description: description,
          date: date,
          dueDate: dueDate,
        );

    await _syncReminder(id: id, dueDate: dueDate, reminder: reminder);
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required TransactionType type,
    String? description,
    required DateTime date,
    DateTime? dueDate,
    ReminderText? reminder,
  }) async {
    await _ref
        .read(debtRepositoryProvider)
        .updateTransaction(
          id: id,
          amount: amount,
          type: type,
          description: description,
          date: date,
          dueDate: dueDate,
        );

    // Covers all three cases: added, changed, or removed a due date.
    await _syncReminder(id: id, dueDate: dueDate, reminder: reminder);
  }

  /// Deletes and hands back the removed row so the caller can offer an Undo.
  Future<DebtTransaction?> deleteTransaction(int id) async {
    final deleted = await _ref
        .read(debtRepositoryProvider)
        .deleteTransaction(id);

    if (deleted != null) await _notifications.cancelReminder(id);
    return deleted;
  }

  Future<void> restoreTransaction(
    DebtTransaction transaction, {
    ReminderText? reminder,
  }) async {
    await _ref.read(debtRepositoryProvider).restoreTransaction(transaction);

    await _syncReminder(
      id: transaction.id,
      dueDate: transaction.dueDate,
      reminder: reminder,
    );
  }

  /// Cancels out a person's balance. False means there was nothing to settle.
  Future<bool> settleUp({required int personId, String? description}) {
    return _ref
        .read(debtRepositoryProvider)
        .settleUp(personId: personId, description: description);
  }

  /// Schedules the reminder, or clears it when the due date has gone away.
  Future<void> _syncReminder({
    required int id,
    required DateTime? dueDate,
    required ReminderText? reminder,
  }) {
    if (dueDate == null || reminder == null) {
      return _notifications.cancelReminder(id);
    }

    return _notifications.scheduleReminder(
      id: id,
      title: reminder.title,
      body: reminder.body,
      dueDate: dueDate,
    );
  }
}
