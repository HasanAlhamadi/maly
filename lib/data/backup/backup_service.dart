// 📁 lib/data/backup/backup_service.dart
// PURPOSE: Turns the whole database into a JSON file and back again.
//
// This class deliberately knows nothing about files or plugins — it only
// converts to and from a String. That keeps it testable, and leaves the
// "where do we save it" question to the viewmodel.

import 'dart:convert';

import '../local/database/app_database.dart';
import '../repositories/debt_repository.dart';

/// Thrown when a file is not a Maly backup, or is a newer format than this
/// version of the app understands.
class InvalidBackupException implements Exception {
  final String message;
  const InvalidBackupException(this.message);

  @override
  String toString() => 'InvalidBackupException: $message';
}

class BackupService {
  final DebtRepository _repository;
  BackupService(this._repository);

  /// Bumped only if the file layout itself changes. Stored in every backup so
  /// a future version of the app can still read today's files.
  static const int formatVersion = 1;

  /// Builds the backup file contents.
  Future<String> export({DateTime? now}) async {
    final data = await _repository.exportAll();

    final payload = {
      'version': formatVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'persons': data.persons.map((p) => p.toJson()).toList(),
      'transactions': data.transactions.map((t) => t.toJson()).toList(),
    };

    // Indented so the file is readable if someone opens it.
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Replaces everything in the database with the contents of [raw].
  ///
  /// Throws [InvalidBackupException] if the text is not a valid backup. The
  /// database is only touched once the whole file has parsed successfully.
  Future<void> import(String raw) async {
    final parsed = _parse(raw);

    await _repository.replaceAll(
      persons: parsed.persons,
      transactions: parsed.transactions,
    );
  }

  /// Reads and validates the file without writing anything.
  ({List<Person> persons, List<DebtTransaction> transactions}) _parse(
    String raw,
  ) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const InvalidBackupException('Not valid JSON');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const InvalidBackupException('Unexpected file contents');
    }

    final version = decoded['version'];
    if (version is! int) {
      throw const InvalidBackupException('Missing format version');
    }
    if (version > formatVersion) {
      throw const InvalidBackupException(
        'This backup was made by a newer version of the app',
      );
    }

    final rawPersons = decoded['persons'];
    final rawTransactions = decoded['transactions'];
    if (rawPersons is! List || rawTransactions is! List) {
      throw const InvalidBackupException('Missing people or transactions');
    }

    try {
      return (
        persons: rawPersons
            .cast<Map<String, dynamic>>()
            .map(Person.fromJson)
            .toList(),
        transactions: rawTransactions
            .cast<Map<String, dynamic>>()
            .map(DebtTransaction.fromJson)
            .toList(),
      );
    } catch (_) {
      // A row was missing a field or had the wrong type.
      throw const InvalidBackupException('Backup contents are damaged');
    }
  }

  /// Suggested file name, e.g. "maly-backup-2026-08-31.json".
  static String fileNameFor(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'maly-backup-${date.year}-$month-$day.json';
  }
}
