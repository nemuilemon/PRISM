import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/account_repository.dart';
import '../../domain/entities/asset.dart';

part 'account_list_controller.g.dart';

@riverpod
class AccountListController extends _$AccountListController {
  @override
  Stream<List<Asset>> build() {
    // リポジトリからデータを監視
    final repository = ref.watch(accountRepositoryProvider);
    return repository.watchAssets();
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
