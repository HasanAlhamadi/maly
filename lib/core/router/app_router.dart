import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/person/person_list_screen.dart';
import '../../presentation/views/person/add_person_screen.dart';
import '../../presentation/views/person/person_detail_screen.dart';
import '../../presentation/views/transaction/add_transaction_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/persons',
      builder: (context, state) => const PersonListScreen(),
    ),
    GoRoute(
      path: '/add-person',
      builder: (context, state) => const AddPersonScreen(),
    ),
    GoRoute(
      path: '/person/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PersonDetailScreen(personId: id);
      },
    ),
    GoRoute(
      path: '/add-transaction/:personId',
      builder: (context, state) {
        final personId = int.parse(state.pathParameters['personId']!);
        return AddTransactionScreen(personId: personId);
      },
    ),
  ],
);
