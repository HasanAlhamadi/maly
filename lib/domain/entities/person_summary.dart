// 📁 lib/domain/entities/person_summary.dart
// PURPOSE: A person together with their current balance, so a list of people
// can be built from a single database query.

import '../../data/local/database/app_database.dart';

class PersonSummary {
  final Person person;

  /// Positive = they owe you. Negative = you owe them. Zero = settled.
  final double balance;

  const PersonSummary({required this.person, required this.balance});

  PersonSummary copyWith({double? balance}) =>
      PersonSummary(person: person, balance: balance ?? this.balance);
}
