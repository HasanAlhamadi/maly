// 📁 lib/presentation/providers/transaction_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import 'core_providers.dart';

final personTransactionsStreamProvider =
    StreamProvider.family<List<DebtTransaction>, int>((ref, personId) {
      return ref
          .watch(debtRepositoryProvider)
          .watchTransactionsForPerson(personId);
    });
