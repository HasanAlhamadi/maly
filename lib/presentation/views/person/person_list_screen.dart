// 📁 lib/presentation/views/person/person_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/person_providers.dart';
import '../../viewmodels/person_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/person_tile.dart';

class PersonListScreen extends ConsumerWidget {
  const PersonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final personsAsync = ref.watch(allPersonsStreamProvider);
    final actions = ref.read(personActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.persons)),
      body: personsAsync.when(
        data: (persons) {
          if (persons.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: l10n.noPersons,
              subtitle: l10n.noPersonsSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              return Dismissible(
                key: ValueKey(person.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => actions.deletePerson(person.id),
                child: PersonTile(
                  person: person,
                  onTap: () => context.push('/person/${person.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-person'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
