import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 報告書 3.2.1 アカウント（資産元）テーブル
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type =>
      text()(); // Cash, Bank, Securities, Point, Time, Experience
  TextColumn get currencyCode => text().withDefault(const Constant('JPY'))();
  BoolColumn get isAsset => boolean().withDefault(const Constant(true))();
}

// 報告書 3.2.2 トランザクション（取引）テーブル
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  RealColumn get amount => real()(); // Dartのdoubleに対応。金額。
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get categoryId => integer().nullable()(); // カテゴリID（別テーブル化も検討）
  IntColumn get emotionalScore =>
      integer().withDefault(const Constant(0))(); // -5 to +5
  TextColumn get emotionalTag => text().nullable()(); // "ワクワク", "後悔" など
  BoolColumn get investmentFlag =>
      boolean().withDefault(const Constant(false))(); // 自己投資フラグ
}

// 報告書 3.2.3 タグテーブル
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

// 報告書 3.2.3 トランザクションとタグの中間テーブル
class TransactionTags extends Table {
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}

// 報告書 3.3 為替レートテーブル
class ExchangeRates extends Table {
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {fromCurrency, toCurrency};
}

@DriftDatabase(
  tables: [Accounts, Transactions, Tags, TransactionTags, ExchangeRates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // バージョン1から2への移行: 新しいテーブルを作成し、Accountsにカラムを追加
        await m.createTable(transactions);
        await m.createTable(tags);
        await m.createTable(transactionTags);
        await m.createTable(exchangeRates);
        await m.addColumn(accounts, accounts.currencyCode);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'life_asset.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
