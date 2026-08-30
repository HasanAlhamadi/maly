# Maly — ديوني

A simple offline **debt tracker**: keep a record of who owes you money and who
you owe. Everything is stored locally on the device — there is no account, no
server and no sync.

Available in **English and Arabic** (with full right-to-left layout), in light
and dark themes.

## Features

- Add people with a phone number and notes
- Record dated **credit** ("they owe me") and **debit** ("I owe them") entries
- Per-person balance and a dashboard with the overall position
- Search, edit and delete people; swipe a transaction away with an undo
- Theme and language choices are saved between launches

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter with Dart 3.8 or newer.

### Regenerating code

Two things in this project are generated and **are committed to the repo**, so
you only need these after changing the matching source files.

```bash
# After editing lib/data/local/database/tables.dart  → app_database.g.dart
dart run build_runner build

# After editing lib/l10n/*.arb  → lib/generated/app_localizations*.dart
flutter gen-l10n
```

### Tests

```bash
flutter analyze
flutter test
```

## Architecture

MVVM-ish layering with Riverpod for state and Drift for storage.

```
lib/
├── core/            Colors, theme, router, settings, formatters
├── domain/          Plain business types (TransactionType, balances)
├── data/            Drift tables, the database, and the repository
├── presentation/    Providers (reads), viewmodels (writes), screens, widgets
└── services/        Local notifications
```

**How data flows.** Screens watch providers, providers expose repository
streams, and the repository is the only thing that touches the database:

```
Screen → provider (StreamProvider) → DebtRepository → Drift → SQLite
Screen → viewmodel (actions)       → DebtRepository → Drift → SQLite
```

Every read is a **stream**, so adding or deleting a transaction updates the
balances, the dashboard and the people list on its own — nothing has to be
refreshed by hand.

### Conventions worth knowing

- **Colors live in one file**, `core/constants/app_colors.dart`. Green means
  money coming to you, red means money going out, grey means settled.
- **Money is drawn by one widget**, `MoneyText`, which uses fixed-width digits
  so amounts line up in a column.
- **Transaction direction is an enum**, `TransactionType`, stored by Drift as
  its index (`debit = 0`, `credit = 1`). Never compare the raw number.
- **User-facing text always comes from l10n** (`lib/l10n/*.arb`), never a
  hardcoded string.

## Known limitations

- **Android is the tested target.** The other platform folders are the default
  scaffolds. Web additionally needs `sqlite3.wasm` and `drift_worker.js` placed
  in `web/` before Drift will open a database there.
- The release build still signs with the debug keystore and the application id
  is still `com.example.maly` — both need changing before publishing.
- `NotificationService` works and asks for permission, but nothing in the app
  schedules a notification yet.
