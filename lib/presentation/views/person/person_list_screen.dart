// 📁 lib/presentation/views/person/person_list_screen.dart
// PURPOSE: Everyone you track, with a search box and swipe-to-delete.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/person_summary.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/person_providers.dart';
import '../../viewmodels/person_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/person_tile.dart';

class PersonListScreen extends ConsumerStatefulWidget {
  const PersonListScreen({super.key});

  @override
  ConsumerState<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends ConsumerState<PersonListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Keeps only the people whose name matches what was typed.
  List<PersonSummary> _filter(List<PersonSummary> all) {
    if (_query.isEmpty) return all;
    final needle = _query.toLowerCase();
    return all
        .where((s) => s.person.name.toLowerCase().contains(needle))
        .toList();
  }

  Future<void> _confirmDelete(PersonSummary summary) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePersonTitle),
        content: Text(l10n.deletePersonMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(personActionsProvider).deletePerson(summary.person.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.personDeleted)));
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.somethingWentWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summariesAsync = ref.watch(personSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.persons)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPadding,
              4,
              AppConstants.screenPadding,
              12,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value.trim()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchPeople,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: summariesAsync.when(
              data: (all) {
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_alt_outlined,
                    title: l10n.noPersons,
                    subtitle: l10n.noPersonsSubtitle,
                  );
                }

                final people = _filter(all);
                if (people.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.noSearchResults,
                    subtitle: l10n.searchPeople,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.screenPadding,
                    0,
                    AppConstants.screenPadding,
                    96,
                  ),
                  itemCount: people.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final summary = people[index];
                    return Dismissible(
                      key: ValueKey(summary.person.id),
                      direction: DismissDirection.endToStart,
                      background: _DeleteBackground(label: l10n.delete),
                      // Ask first — deleting a person also deletes their
                      // whole history, so it must not happen by accident.
                      confirmDismiss: (_) async {
                        await _confirmDelete(summary);
                        // The list is a stream, so it removes the row itself.
                        return false;
                      },
                      child: PersonTile(
                        summary: summary,
                        onTap: () =>
                            context.push('/person/${summary.person.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const ErrorView(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-person'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Red panel revealed behind a row while it is swiped.
class _DeleteBackground extends StatelessWidget {
  final String label;

  const _DeleteBackground({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
