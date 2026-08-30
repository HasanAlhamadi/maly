// 📁 lib/presentation/widgets/money_text.dart
// PURPOSE: One way of drawing money everywhere in the app.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

class MoneyText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;

  /// Shows a leading + or - (used for the net balance).
  final bool signed;

  /// Hides the "YER" suffix when the currency is already shown elsewhere.
  final bool showCurrency;

  const MoneyText(
    this.amount, {
    super.key,
    this.fontSize = 16,
    this.color,
    this.fontWeight = FontWeight.w700,
    this.signed = false,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final String text;
    if (!showCurrency) {
      text = CurrencyFormatter.formatPlain(amount);
    } else if (signed) {
      text = CurrencyFormatter.formatSigned(amount);
    } else {
      text = CurrencyFormatter.format(amount);
    }

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        // Keeps digits aligned when amounts sit above each other in a list.
        fontFeatures: AppTheme.tabularFigures,
        height: 1.2,
      ),
    );
  }
}
