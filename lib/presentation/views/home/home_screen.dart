// 📁 lib/presentation/views/home/home_screen.dart
// PURPOSE: Dashboard — the overall position first, then the most recent people.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/dashboard_totals.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/balance_providers.dart';
import '../../providers/person_providers.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/balance_chart_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/person_tile.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalsAsync = ref.watch(dashboardTotalsProvider);
    final summariesAsync = ref.watch(personSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.stats,
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.screenPadding,
          8,
          AppConstants.screenPadding,
          // Leaves room so the FAB never covers the last row.
          96,
        ),
        children: [
          // ===== Overall position =====
          totalsAsync.when(
            data: (totals) => Column(
              children: [
                NetBalanceCard(totals: totals),
                // The chart only means something once there is money to split.
                if (!totals.isEmpty) ...[
                  const SizedBox(height: 16),
                  BalanceChartCard(totals: totals),
                ],
              ],
            ),
            loading: () => const _HeroPlaceholder(),
            error: (_, _) => const NetBalanceCard(totals: DashboardTotals.empty),
          ),

          const SizedBox(height: 28),

          // ===== People =====
          SectionHeader(
            title: l10n.persons,
            actionLabel: l10n.seeAll,
            onAction: () => context.push('/persons'),
          ),
          const SizedBox(height: 8),

          summariesAsync.when(
            data: (summaries) {
              if (summaries.isEmpty) {
                return EmptyState(
                  icon: Icons.people_alt_outlined,
                  title: l10n.noPersons,
                  subtitle: l10n.noPersonsSubtitle,
                );
              }

              final preview = summaries
                  .take(AppConstants.homePreviewCount)
                  .toList();

              return Column(
                children: [
                  for (final summary in preview)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PersonTile(
                        summary: summary,
                        onTap: () =>
                            context.push('/person/${summary.person.id}'),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const ErrorView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-person'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l10n.addPerson),
      ),
    );
  }
}

/// Keeps the layout from jumping while the first totals load.
class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}
