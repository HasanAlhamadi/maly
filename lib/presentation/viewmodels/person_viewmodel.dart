// 📁 lib/presentation/viewmodels/person_viewmodel.dart
// PURPOSE: Person actions (mutations)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';

final personActionsProvider = Provider<PersonActions>((ref) {
  return PersonActions(ref);
});

class PersonActions {
  final Ref _ref;
  PersonActions(this._ref);

  Future<void> addPerson({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final repo = _ref.read(debtRepositoryProvider);
    await repo.insertPerson(name: name, phone: phone, notes: notes);
  }

  Future<void> deletePerson(int id) async {
    final repo = _ref.read(debtRepositoryProvider);
    await repo.deletePerson(id);
  }
}
