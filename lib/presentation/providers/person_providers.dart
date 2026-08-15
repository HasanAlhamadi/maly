// 📁 lib/presentation/providers/person_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import 'core_providers.dart';

// Stream of all persons (auto-updates when DB changes)
final allPersonsStreamProvider = StreamProvider<List<Person>>((ref) {
  final repo = ref.watch(debtRepositoryProvider);
  return repo.watchAllPersons();
});

// Single person by ID
final personByIdProvider = FutureProvider.family<Person?, int>((ref, id) async {
  final repo = ref.read(debtRepositoryProvider);
  return repo.getPersonById(id);
});
