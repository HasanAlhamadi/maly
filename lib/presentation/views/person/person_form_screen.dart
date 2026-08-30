// 📁 lib/presentation/views/person/person_form_screen.dart
// PURPOSE: One form used for both adding and editing a person.
// Passing a personId switches it into edit mode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/person_providers.dart';
import '../../viewmodels/person_viewmodel.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  /// Null means "create a new person".
  final int? personId;

  const PersonFormScreen({super.key, this.personId});

  bool get isEditing => personId != null;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isSaving = false;

  /// Stops the loaded person from overwriting what the user is typing.
  bool _prefilled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Empty optional fields are stored as null rather than an empty string.
  String? _optional(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    // Grab these before awaiting, so they stay valid after the screen pops.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);

    try {
      final actions = ref.read(personActionsProvider);

      if (widget.isEditing) {
        await actions.updatePerson(
          id: widget.personId!,
          name: _nameCtrl.text.trim(),
          phone: _optional(_phoneCtrl),
          notes: _optional(_notesCtrl),
        );
      } else {
        await actions.addPerson(
          name: _nameCtrl.text.trim(),
          phone: _optional(_phoneCtrl),
          notes: _optional(_notesCtrl),
        );
      }

      if (router.canPop()) router.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? l10n.personUpdated : l10n.personAdded,
          ),
        ),
      );
    } catch (_) {
      // Saving failed, so stay on the form and tell the user.
      messenger.showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // In edit mode, fill the fields once the person has loaded. The provider
    // is watched for the whole life of the screen; only the copy into the
    // controllers is done once, so it never overwrites the user's typing.
    if (widget.isEditing) {
      final person = ref
          .watch(personByIdProvider(widget.personId!))
          .valueOrNull;

      if (person != null && !_prefilled) {
        _nameCtrl.text = person.name;
        _phoneCtrl.text = person.phone ?? '';
        _notesCtrl.text = person.notes ?? '';
        _prefilled = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editPerson : l10n.addPerson),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: !widget.isEditing,
              decoration: InputDecoration(
                labelText: l10n.personName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.nameRequired;
                if (name.length > AppConstants.maxNameLength) {
                  return l10n.nameTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.personPhone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              maxLength: AppConstants.maxPhoneLength,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.personNotes,
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: AppConstants.maxNoteLength,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? l10n.saving : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
