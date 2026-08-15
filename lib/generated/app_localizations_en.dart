// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DebtTracker';

  @override
  String get persons => 'People';

  @override
  String get addPerson => 'Add Person';

  @override
  String get editPerson => 'Edit Person';

  @override
  String get personName => 'Name';

  @override
  String get personPhone => 'Phone Number';

  @override
  String get personNotes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get credit => 'Credit';

  @override
  String get debit => 'Debit';

  @override
  String get creditDesc => 'They owe me';

  @override
  String get debitDesc => 'I owe them';

  @override
  String get totalOwedToYou => 'Total Owed to You';

  @override
  String get totalYouOwe => 'Total You Owe';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get owesYou => 'owes you';

  @override
  String get youOwe => 'You owe';

  @override
  String get settled => 'Settled';

  @override
  String get noPersons => 'No people added yet';

  @override
  String get noPersonsSubtitle => 'Tap + to add someone';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsSubtitle => 'Add your first transaction';

  @override
  String get deletePersonTitle => 'Delete Person?';

  @override
  String get deletePersonMessage => 'This will delete all transactions too.';

  @override
  String get deleteTransactionTitle => 'Delete Transaction?';

  @override
  String get currency => 'YER';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get search => 'Search';

  @override
  String get balance => 'Balance';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get newPerson => 'New Person';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidAmount => 'Enter a valid amount';
}
