import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prism/domain/entities/transaction.dart';
import 'package:prism/data/repositories/transaction_repository_impl.dart';

part 'transaction_list_controller.g.dart';

@riverpod
class TransactionListController extends _$TransactionListController {
  @override
  Stream<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).watchTransactions();
  }

  Future<void> addTransaction({
    required int accountId,
    required double amount,
    required DateTime date,
    int? categoryId,
    int emotionalScore = 0,
    String? emotionalTag,
    bool isInvestment = false,
    String? note,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .addTransaction(
          accountId: accountId,
          amount: amount,
          date: date,
          categoryId: categoryId,
          emotionalScore: emotionalScore,
          emotionalTag: emotionalTag,
          isInvestment: isInvestment,
          note: note,
        );
  }

  Future<void> deleteTransaction(int id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
  }
}
