// 📁 lib/domain/entities/transaction.dart

enum TransactionType {
  debit, // 0 - I owe them
  credit, // 1 - They owe me
}

extension TransactionTypeX on TransactionType {
  int get value => index;
  String get label => this == TransactionType.debit ? 'Debit' : 'Credit';
  String get description =>
      this == TransactionType.debit ? 'I owe them' : 'They owe me';
  bool get isCredit => this == TransactionType.credit;
}
