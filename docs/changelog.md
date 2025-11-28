# Changelog

## [Unreleased]

### Added
- Initial project setup with Clean Architecture structure.
- Added dependencies:
    - `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`
    - `drift`, `sqlite3_flutter_libs`, `drift_dev`
    - `freezed`, `freezed_annotation`
    - `go_router`, `fl_chart`, `intl`, `uuid`
    - `very_good_analysis`
- Created `lib/data/datasources/local/app_database.dart` with initial `Accounts` table.
- Configured `lib/main.dart` with Riverpod `ProviderScope` and `AppDatabase` injection.
- Added `analysis_options.yaml` with customized rules.
- Created directory structure for Domain, Data, and Presentation layers.
- Implemented `Asset` entity in `lib/domain/entities/asset.dart` using Freezed Union Types (Financial, Point, Experience).
- Implemented Neumorphism UI components:
    - `AppTheme` in `lib/core/theme/app_theme.dart` defining base colors.
    - `NeumorphicContainer` in `lib/presentation/widgets/neumorphism/neumorphic_container.dart` for shadow effects.
    - `NeumorphicButton` in `lib/presentation/widgets/neumorphism/neumorphic_button.dart` with press interaction.
- Expanded Database Schema in `lib/data/datasources/local/app_database.dart`:
    - Added `Transactions`, `Tags`, `TransactionTags`, `ExchangeRates` tables.
    - Updated `Accounts` table with `currencyCode`.
    - Implemented migration strategy from schema version 1 to 2.
- Implemented Account Management Feature:
    - `AccountRepository` for database interactions.
    - `AccountListController` for state management using Riverpod.
    - `AccountListPage` for displaying and adding accounts.
- Implemented Transaction Management Feature:
    - `Transaction` entity and repository.
    - `TransactionListController` for managing transaction state.
    - `TransactionListPage` for viewing transactions.
    - `AddTransactionPage` with fields for Amount, Date, Account, Note, Investment Flag, and Emotional Score.
- Implemented Navigation:
    - BottomNavigationBar with "Transactions" and "Accounts" tabs.
    - Navigation logic in `main.dart`.

### Changed
- Updated `AppDatabase` schema to version 3 (added `note` column to `Transactions`).
- Reordered BottomNavigationBar items: "Transactions" (Left) and "Accounts" (Right).
- Localized UI text to Japanese for `TransactionListPage`, `AddTransactionPage`, and Navigation.
- Adjusted `FloatingActionButton` size in `TransactionListPage` to prevent UI obstruction.

### Fixed
- Resolved Git synchronization issues by merging remote `LICENSE` and pushing local changes.
- Verified Windows build execution (required Developer Mode and Visual Studio C++ workload).
- Fixed `AccountRepositoryRef` type error by using `Ref` and importing `flutter_riverpod`.
- Resolved `InvalidTypeException` in `build_runner` by adjusting imports and types in `AccountListController`.
- Fixed `appDatabaseProvider` import issues in `AccountRepository`.
- Resolved `MSB8066` build error by adding `abstract` to `Transaction` class.
- Fixed `MaterialPageRoute` type inference and import path issues in `TransactionListPage`.
