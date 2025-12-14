import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/data/datasources/local/app_database.dart';
import 'package:prism/domain/entities/recurring_transaction.dart' as domain;
import 'package:prism/domain/repositories/recurring_transaction_repository.dart';

final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
      return RecurringTransactionRepositoryImpl(ref.watch(appDatabaseProvider));
    });

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  RecurringTransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.RecurringTransaction>> getRecurringTransactions() async {
    final results = await _db.select(_db.recurringTransactions).get();
    return results
        .map(
          (row) => domain.RecurringTransaction(
            id: row.id,
            accountId: row.accountId,
            amount: row.amount,
            categoryId: row.categoryId,
            dayOfMonth: row.dayOfMonth,
            isActive: row.isActive,
            note: row.note,
            type: row.type,
          ),
        )
        .toList();
  }

  @override
  Future<void> addRecurringTransaction(
    domain.RecurringTransaction transaction,
  ) async {
    await _db
        .into(_db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            accountId: transaction.accountId,
            amount: transaction.amount,
            dayOfMonth: transaction.dayOfMonth,
            categoryId: Value(transaction.categoryId),
            isActive: Value(transaction.isActive),
            note: Value(transaction.note),
            type: Value(transaction.type),
          ),
        );
  }

  @override
  Future<void> updateRecurringTransaction(
    domain.RecurringTransaction transaction,
  ) async {
    await (_db.update(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(transaction.id))).write(
      RecurringTransactionsCompanion(
        accountId: Value(transaction.accountId),
        amount: Value(transaction.amount),
        categoryId: Value(transaction.categoryId),
        dayOfMonth: Value(transaction.dayOfMonth),
        isActive: Value(transaction.isActive),
        note: Value(transaction.note),
        type: Value(transaction.type),
      ),
    );
  }

  @override
  Future<void> deleteRecurringTransaction(int id) async {
    await (_db.delete(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).go();
  }
}
