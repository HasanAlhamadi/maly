import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maly/core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidAmount)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(transactionActionsProvider)
          .addTransaction(
            personId: widget.personId,
            amount: amount,
            type: _selectedType.value,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            date: _selectedDate,
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction added')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final personAsync = ref.watch(personByIdProvider(widget.personId));

    return Scaffold(
      appBar: AppBar(
        title: personAsync.when(
          data: (p) => Text('${l10n.addTransaction} - ${p?.name ?? ''}'),
          loading: () => Text(l10n.addTransaction),
          error: (_, __) => Text(l10n.addTransaction),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            _TypeSelector(
              selected: _selectedType,
              onChanged: (t) => setState(() => _selectedType = t),
              l10n: l10n,
            ),
            const SizedBox(height: 24),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: l10n.amount,
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: l10n.currency,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.nameRequired;
                final parsed = CurrencyFormatter.parse(v);
                if (parsed == null || parsed <= 0) return l10n.invalidAmount;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: l10n.description,
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      Theme.of(context).dividerTheme.color ??
                      Colors.grey.shade300,
                ),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.date),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  final AppLocalizations l10n;

  const _TypeSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transactionType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeCard(
                type: TransactionType.credit,
                isSelected: selected == TransactionType.credit,
                onTap: () => onChanged(TransactionType.credit),
                title: l10n.credit,
                subtitle: l10n.creditDesc,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeCard(
                type: TransactionType.debit,
                isSelected: selected == TransactionType.debit,
                onTap: () => onChanged(TransactionType.debit),
                title: l10n.debit,
                subtitle: l10n.debitDesc,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
    final isCredit = type == TransactionType.credit;
    final color = isCredit ? AppColors.credit : AppColors.debit;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color.withOpacity(0.8) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
