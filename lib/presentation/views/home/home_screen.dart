// 📁 lib/presentation/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../generated/app_localizations.dart';
import '../../providers/balance_providers.dart';
import '../../providers/person_providers.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/person_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalsAsync = ref.watch(dashboardTotalsProvider);
    final personsAsync = ref.watch(allPersonsStreamProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardTotalsProvider);
          ref.invalidate(allPersonsStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Dashboard Cards
            totalsAsync.when(
              data: (totals) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    BalanceCard(
                      balance: totals['owedToYou']!,
                      title: l10n.totalOwedToYou,
                    ),
                    const SizedBox(height: 10),
                    BalanceCard(
                      balance: totals['youOwe']!,
                      title: l10n.totalYouOwe,
                    ),
                    const SizedBox(height: 10),
                    BalanceCard(
                      balance: totals['net']!,
                      title: l10n.netBalance,
                      isNet: true,
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Divider(height: 32),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.persons,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/persons'),
                    child: Text(l10n.persons),
                  ),
                ],
              ),
            ),

            // Persons List (first 5)
            personsAsync.when(
              data: (persons) {
                if (persons.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: l10n.noPersons,
                    subtitle: l10n.noPersonsSubtitle,
                  );
                }
                final displayList = persons.take(5).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) => PersonTile(
                    person: displayList[index],
                    onTap: () =>
                        context.push('/person/${displayList[index].id}'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-person'),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addPerson),
      ),
    );
  }
}
