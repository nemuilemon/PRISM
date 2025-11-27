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

### Fixed
- Resolved Git synchronization issues by merging remote `LICENSE` and pushing local changes.
- Verified Windows build execution (required Developer Mode and Visual Studio C++ workload).
- Fixed `AccountRepositoryRef` type error by using `Ref` and importing `flutter_riverpod`.
- Resolved `InvalidTypeException` in `build_runner` by adjusting imports and types in `AccountListController`.
- Fixed `appDatabaseProvider` import issues in `AccountRepository`.
