// 📁 lib/presentation/widgets/balance_card.dart
// PURPOSE: The money cards. NetBalanceCard is the home screen hero,
// BalanceCard is the smaller one on a person's page.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/dashboard_totals.dart';
import '../../generated/app_localizations.dart';
import 'money_text.dart';

/// Big gradient card summarising everything: the net position on top and the
/// two directions underneath.
class NetBalanceCard extends StatelessWidget {
  final DashboardTotals totals;

  const NetBalanceCard({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final net = totals.net;

    // One short sentence telling the user which way they stand overall.
    final String statusLabel;
    if (net == 0) {
      statusLabel = l10n.allSettled;
    } else if (net > 0) {
      statusLabel = l10n.youAreOwed;
    } else {
      statusLabel = l10n.youOweOthers;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.netBalance,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoneyText(
            net,
            signed: net != 0,
            fontSize: 34,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: l10n.totalOwedToYou,
                  amount: totals.owedToYou,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: l10n.totalYouOwe,
                  amount: totals.youOwe,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the two small panels inside the hero card.
class _HeroStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _HeroStat({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MoneyText(amount, fontSize: 16, color: Colors.white),
        ],
      ),
    );
  }
}

/// Single balance figure, used on a person's page.
class BalanceCard extends StatelessWidget {
  final double balance;
  final String title;

  const BalanceCard({super.key, required this.balance, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = AppColors.forBalance(balance);

    // Says who owes whom, in words, so the sign is never ambiguous.
    final String caption;
    if (balance == 0) {
      caption = l10n.settled;
    } else if (balance > 0) {
      caption = l10n.owesYou;
    } else {
      caption = l10n.youOwe;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: color.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          MoneyText(balance, fontSize: 30, color: color, fontWeight: FontWeight.w800),
          const SizedBox(height: 6),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
