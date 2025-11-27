import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/local/app_database.dart' as db;
import '../../main.dart'; // appDatabaseProviderへのアクセス

part 'account_repository.g.dart';

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(ref.watch(appDatabaseProvider));
}

class AccountRepository {
  final db.AppDatabase _db;

  AccountRepository(this._db);

  // 全てのアカウントを取得
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
