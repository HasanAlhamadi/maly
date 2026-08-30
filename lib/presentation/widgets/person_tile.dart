// 📁 lib/presentation/widgets/person_tile.dart
// PURPOSE: One row in the people list. The balance arrives with the summary,
// so this widget never queries the database itself.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/person_summary.dart';
import '../../generated/app_localizations.dart';
import 'money_text.dart';

class PersonTile extends StatelessWidget {
  final PersonSummary summary;
  final VoidCallback? onTap;

  const PersonTile({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final person = summary.person;
    final balance = summary.balance;
    final color = AppColors.forBalance(balance);

    // Says which way the balance leans, so the sign is never ambiguous.
    final String caption;
    if (balance == 0) {
      caption = l10n.settled;
    } else if (balance > 0) {
      caption = l10n.owesYou;
    } else {
      caption = l10n.youOwe;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Initial on a circle tinted by the balance colour.
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initial(person.name),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Amounts sit hard right so they line up down the column.
              MoneyText(balance, fontSize: 15, color: color),
            ],
          ),
        ),
      ),
    );
  }

  /// First letter of the name, safe for Arabic and emoji too.
  static String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}
