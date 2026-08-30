// 📁 lib/presentation/viewmodels/person_viewmodel.dart
// PURPOSE: Person actions (writes). Reads live in the providers.

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
  }) {
    return _ref
        .read(debtRepositoryProvider)
        .insertPerson(name: name, phone: phone, notes: notes);
  }

  Future<void> updatePerson({
    required int id,
    required String name,
    String? phone,
    String? notes,
  }) {
    return _ref
        .read(debtRepositoryProvider)
        .updatePerson(id: id, name: name, phone: phone, notes: notes);
  }

  Future<void> deletePerson(int id) {
    return _ref.read(debtRepositoryProvider).deletePerson(id);
  }
}
