// 📁 lib/domain/entities/transaction.dart
// PURPOSE: What a transaction means. Drift stores this enum's index in the
// `type` column (debit = 0, credit = 1).

enum TransactionType {
  /// I owe them — money going out.
  debit,

  /// They owe me — money coming in.
  credit,
}

extension TransactionTypeX on TransactionType {
  bool get isCredit => this == TransactionType.credit;

  /// Credit adds to the balance, debit subtracts from it.
  double signedAmount(double amount) => isCredit ? amount : -amount;
}
