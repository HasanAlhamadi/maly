// 📁 lib/core/router/app_router.dart
// PURPOSE: All the app's routes in one place.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../generated/app_localizations.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/person/person_detail_screen.dart';
import '../../presentation/views/person/person_form_screen.dart';
import '../../presentation/views/person/person_list_screen.dart';
import '../../presentation/views/settings/settings_screen.dart';
import '../../presentation/views/stats/stats_screen.dart';
import '../../presentation/views/transaction/transaction_form_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  // Shown instead of a crash when a link points nowhere.
  errorBuilder: (context, state) => const _RouteErrorScreen(),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/persons',
      builder: (context, state) => const PersonListScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/add-person',
      builder: (context, state) => const PersonFormScreen(),
    ),
    GoRoute(
      path: '/edit-person/:id',
      builder: (context, state) {
        final id = _idOrNull(state.pathParameters['id']);
        if (id == null) return const _RouteErrorScreen();
        return PersonFormScreen(personId: id);
      },
    ),
    GoRoute(
      path: '/person/:id',
      builder: (context, state) {
        final id = _idOrNull(state.pathParameters['id']);
        if (id == null) return const _RouteErrorScreen();
        return PersonDetailScreen(personId: id);
      },
    ),
    GoRoute(
      path: '/add-transaction/:personId',
      builder: (context, state) {
        final id = _idOrNull(state.pathParameters['personId']);
        if (id == null) return const _RouteErrorScreen();
        return TransactionFormScreen(personId: id);
      },
    ),
    GoRoute(
      // The person id travels in the URL too, so the form never has to look
      // it up before it can render.
      path: '/edit-transaction/:personId/:id',
      builder: (context, state) {
        final personId = _idOrNull(state.pathParameters['personId']);
        final transactionId = _idOrNull(state.pathParameters['id']);
        if (personId == null || transactionId == null) {
          return const _RouteErrorScreen();
        }
        return TransactionFormScreen(
          personId: personId,
          transactionId: transactionId,
        );
      },
    ),
  ],
);

/// Reads an id from the URL without throwing on a malformed link.
int? _idOrNull(String? value) =>
    value == null ? null : int.tryParse(value);

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off_rounded, size: 44),
            const SizedBox(height: 12),
            Text(l10n.somethingWentWrong),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text(l10n.appName),
            ),
          ],
        ),
      ),
    );
  }
}
