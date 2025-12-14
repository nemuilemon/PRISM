import 'package:prism/domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getRecurringTransactions();
  Future<void> addRecurringTransaction(RecurringTransaction transaction);
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
  Future<void> deleteRecurringTransaction(int id);
}
