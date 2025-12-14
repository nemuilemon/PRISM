import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/data/repositories/recurring_transaction_repository.dart';
import 'package:prism/domain/entities/recurring_transaction.dart';

final recurringTransactionListControllerProvider =
    AsyncNotifierProvider<
      RecurringTransactionListController,
      List<RecurringTransaction>
    >(() {
      return RecurringTransactionListController();
    });

class RecurringTransactionListController
    extends AsyncNotifier<List<RecurringTransaction>> {
  @override
  Future<List<RecurringTransaction>> build() async {
    return _fetch();
  }

  Future<List<RecurringTransaction>> _fetch() async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    return repository.getRecurringTransactions();
  }

  Future<void> addRecurringTransaction({
    required int accountId,
    required double amount,
    required int dayOfMonth,
    int? categoryId,
    String? note,
    String type = 'expense',
    bool isActive = true,
  }) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    final transaction = RecurringTransaction(
      id: 0, // ID is auto-increment
      accountId: accountId,
      amount: amount,
      dayOfMonth: dayOfMonth,
      categoryId: categoryId,
      note: note,
      type: type,
      isActive: isActive,
    );
    await repository.addRecurringTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    await repository.updateRecurringTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> deleteRecurringTransaction(int id) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    await repository.deleteRecurringTransaction(id);
    ref.invalidateSelf();
  }
}
