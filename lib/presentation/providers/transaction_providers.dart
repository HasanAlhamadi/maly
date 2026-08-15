import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maly/data/local/database/app_database.dart';
import 'core_providers.dart';

final personTransactionsStreamProvider =
    StreamProvider.family<List<DebtTransaction>, int>((ref, personId) {
      final repo = ref.watch(debtRepositoryProvider);
      return repo.watchTransactionsForPerson(personId);
    });
