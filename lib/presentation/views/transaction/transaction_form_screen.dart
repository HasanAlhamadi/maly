// 📁 lib/presentation/views/transaction/transaction_form_screen.dart
// PURPOSE: One form used for both adding and editing a transaction.
// Passing a transactionId switches it into edit mode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/person_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int personId;

  /// Null means "create a new transaction".
  final int? transactionId;

  const TransactionFormScreen({
    super.key,
    required this.personId,
    this.transactionId,
  });

  bool get isEditing => transactionId != null;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TransactionType _selectedType = TransactionType.credit;
  DateTime _selectedDate = DateTime.now();

  /// Optional. When set, a reminder is scheduled for this day.
  DateTime? _dueDate;
  bool _isSaving = false;

  /// Stops the loaded transaction from overwriting what the user is typing.
  bool _prefilled = false;

  /// Kept so the reminder body can name the person without a lookup.
  String? _personName;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // validate() already checked this parses, so it cannot be null here.
    final amount = CurrencyFormatter.parse(_amountCtrl.text)!;

    final l10n = AppLocalizations.of(context)!;
    // Grab these before awaiting, so they stay valid after the screen pops.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);

    try {
      final description = _descCtrl.text.trim();
      final actions = ref.read(transactionActionsProvider);

      // Wording for the reminder is built here, where l10n is available.
      final reminder = _dueDate == null
          ? null
          : ReminderText(
              title: l10n.paymentDue,
              body:
                  '${_personName ?? ''} · '
                          '${CurrencyFormatter.format(amount)}'
                      .trim(),
            );

      if (widget.isEditing) {
        await actions.updateTransaction(
          id: widget.transactionId!,
          amount: amount,
          type: _selectedType,
          description: description.isEmpty ? null : description,
          date: _selectedDate,
          dueDate: _dueDate,
          reminder: reminder,
        );
      } else {
        await actions.addTransaction(
          personId: widget.personId,
          amount: amount,
          type: _selectedType,
          description: description.isEmpty ? null : description,
          date: _selectedDate,
          dueDate: _dueDate,
          reminder: reminder,
        );
      }

      if (router.canPop()) router.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? l10n.transactionUpdated : l10n.transactionAdded,
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Due dates look forward, unlike the transaction date which looks back.
  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final person = ref.watch(personByIdProvider(widget.personId)).valueOrNull;
    _personName = person?.name;
    final localeCode = Localizations.localeOf(context).languageCode;

    // In edit mode, fill the fields once the transaction has loaded. Only the
    // copy into the controllers is done once, so it never overwrites typing.
    if (widget.isEditing) {
      final existing = ref
          .watch(transactionByIdProvider(widget.transactionId!))
          .valueOrNull;

      if (existing != null && !_prefilled) {
        _amountCtrl.text = CurrencyFormatter.formatPlain(existing.amount);
        _descCtrl.text = existing.description ?? '';
        _selectedType = existing.type;
        _selectedDate = existing.date;
        _dueDate = existing.dueDate;
        _prefilled = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isEditing ? l10n.editTransaction : l10n.addTransaction),
            if (person != null)
              Text(person.name, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          children: [
            // ===== Which direction does the money go? =====
            Text(
              l10n.transactionType,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    type: TransactionType.credit,
                    isSelected: _selectedType == TransactionType.credit,
                    onTap: () =>
                        setState(() => _selectedType = TransactionType.credit),
                    title: l10n.credit,
                    subtitle: l10n.creditDesc,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    type: TransactionType.debit,
                    isSelected: _selectedType == TransactionType.debit,
                    onTap: () =>
                        setState(() => _selectedType = TransactionType.debit),
                    title: l10n.debit,
                    subtitle: l10n.debitDesc,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ===== How much? =====
            Text(l10n.amount, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountCtrl,
              autofocus: !widget.isEditing,
              // The amount is the point of this screen, so make it big.
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
                suffixText: l10n.currency,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.amountRequired;
                }
                final parsed = CurrencyFormatter.parse(value);
                if (parsed == null || parsed <= 0) return l10n.invalidAmount;
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: l10n.description,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 2,
              maxLength: AppConstants.maxNoteLength,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 4),

            // ===== When? =====
            _DateField(
              label: l10n.date,
              value: DateFormatter.format(_selectedDate, localeCode),
              onTap: _pickDate,
            ),

            const SizedBox(height: 12),

            // ===== Optional reminder =====
            _DateField(
              label: l10n.dueDate,
              value: _dueDate == null
                  ? l10n.noDueDate
                  : DateFormatter.format(_dueDate!, localeCode),
              icon: Icons.notifications_none_rounded,
              onTap: _pickDueDate,
              // Only offer "clear" once a date has actually been chosen.
              onClear: _dueDate == null
                  ? null
                  : () => setState(() => _dueDate = null),
            ),

            const SizedBox(height: 28),

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

/// One of the two credit / debit choices.
class _TypeCard extends StatelessWidget {
  final TransactionType type;
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;

  const _TypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = type.isCredit;
    final color = isCredit ? AppColors.credit : AppColors.debit;
    final idle = theme.textTheme.bodySmall?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.10) : theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
          border: Border.all(
            color: isSelected ? color : theme.dividerTheme.color!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (isSelected ? color : idle!).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: isSelected ? color : idle,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : idle,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: idle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable row that opens the date picker.
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  /// Shows a clear button when provided.
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.calendar_today_outlined,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
          border: Border.all(color: theme.dividerTheme.color!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }
}
