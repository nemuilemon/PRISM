import '../entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<Transaction>> watchTransactions();
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction({
    required int accountId,
    required double amount,
    required DateTime date,
    int? categoryId,
    int emotionalScore = 0,
    String? emotionalTag,
    bool isInvestment = false,
    String? note,
    String type = 'expense',
  });
  Future<void> deleteTransaction(int id);
  Future<void> updateTransaction(Transaction transaction);
}
