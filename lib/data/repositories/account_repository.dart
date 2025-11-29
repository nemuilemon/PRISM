import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/local/app_database.dart' as db;
import '../../domain/entities/asset.dart';
import '../../main.dart'; // appDatabaseProviderへのアクセス

part 'account_repository.g.dart';

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(ref.watch(appDatabaseProvider));
}

class AccountRepository {
  final db.AppDatabase _db;

  AccountRepository(this._db);

  // 資産リスト（残高付き）を監視
  Stream<List<Asset>> watchAssets() {
    final amountSum = _db.transactions.amount.sum();

    final query =
        _db.select(_db.accounts).join([
            leftOuterJoin(
              _db.transactions,
              _db.transactions.accountId.equalsExp(_db.accounts.id),
            ),
          ])
          ..addColumns([amountSum])
          ..groupBy([_db.accounts.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final account = row.readTable(_db.accounts);
        final balance = row.read(amountSum) ?? 0.0;

        // アカウントタイプに応じてAssetを生成
        // 現状は簡易的にFinancialとPointのみ対応
        switch (account.type) {
          case 'Point':
            return Asset.point(
              id: account.id.toString(),
              providerName: account.name,
              points: balance.toInt(),
              exchangeRate: 1.0, // 仮: 後でExchangeRatesテーブルから取得
            );
          case 'Time':
          case 'Experience':
            return Asset.experience(
              id: account.id.toString(),
              activityName: account.name,
              totalTime: Duration(minutes: balance.toInt()), // 仮: amountを分として扱う
              accumulatedLevel: (balance / 60).floor(), // 仮: 1時間=1レベル
            );
          default:
            return Asset.financial(
              id: account.id.toString(),
              name: account.name,
              amount: balance,
              currency: account.currencyCode,
            );
        }
      }).toList();
    });
  }

  // 全てのアカウントを取得 (Legacy)
  Future<List<db.Account>> getAllAccounts() async {
    return await _db.select(_db.accounts).get();
  }

  // アカウント作成
  Future<int> createAccount({
    required String name,
    required String type,
    String currencyCode = 'JPY',
  }) async {
    return await _db
        .into(_db.accounts)
        .insert(
          db.AccountsCompanion.insert(
            name: name,
            type: type,
            currencyCode: Value(currencyCode),
          ),
        );
  }
}
