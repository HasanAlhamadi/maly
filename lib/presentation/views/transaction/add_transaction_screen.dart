// 📁 lib/presentation/views/transaction/add_transaction_screen.dart
// PURPOSE: Record a new debt entry against one person.

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
import '../../viewmodels/transaction_viewmodel.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int personId;

  const AddTransactionScreen({super.key, required this.personId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TransactionType _selectedType = TransactionType.credit;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

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

      await ref
          .read(transactionActionsProvider)
          .addTransaction(
            personId: widget.personId,
            amount: amount,
            type: _selectedType,
            description: description.isEmpty ? null : description,
            date: _selectedDate,
          );

      if (router.canPop()) router.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionAdded)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.addTransaction),
            if (person != null)
              Text(
                person.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          children: [
            // ===== Which direction does the money go? =====
            Text(l10n.transactionType, style: Theme.of(context).textTheme.titleMedium),
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
              autofocus: true,
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
          color: isSelected
              ? color.withValues(alpha: 0.10)
              : theme.cardColor,
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
                isCredit
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
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

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
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
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
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
