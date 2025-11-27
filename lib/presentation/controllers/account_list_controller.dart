import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/datasources/local/app_database.dart' as db;

part 'account_list_controller.g.dart';

@riverpod
class AccountListController extends _$AccountListController {
  @override
  Future<List<dynamic>> build() async {
    // リポジトリからデータを取得
    final repository = ref.watch(accountRepositoryProvider);
    return repository.getAllAccounts();
  }

  // アカウント追加
  Future<void> addAccount(String name, String type) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.createAccount(name: name, type: type);
      // リストを再取得して更新
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
