// 📁 lib/presentation/providers/person_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../domain/entities/person_summary.dart';
import 'core_providers.dart';

/// Every person with their balance already calculated — one query for the
/// whole list, and it updates itself when anything changes.
final personSummariesProvider = StreamProvider<List<PersonSummary>>((ref) {
  return ref.watch(debtRepositoryProvider).watchPersonSummaries();
});

/// A single person, kept live so edits appear immediately.
final personByIdProvider = StreamProvider.family<Person?, int>((ref, id) {
  return ref.watch(debtRepositoryProvider).watchPersonById(id);
});
