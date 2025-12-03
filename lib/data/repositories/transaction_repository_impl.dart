import 'package:drift/drift.dart';
import 'package:prism/data/datasources/local/app_database.dart' as db;
import 'package:prism/domain/entities/transaction.dart' as domain;
import 'package:prism/domain/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository_impl.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepositoryImpl(ref.watch(db.appDatabaseProvider));
}

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<domain.Transaction>> watchTransactions() {
    return (_db.select(_db.transactions)..orderBy([
          (t) => OrderingTerm(
            expression: t.transactionDate,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch()
        .map((rows) {
          return rows.map(_toDomain).toList();
        });
  }

  @override
  Future<List<domain.Transaction>> getTransactions() async {
    final rows = await _db.select(_db.transactions).get();
    return rows.map(_toDomain).toList();
  }

  @override
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
  }) async {
    await _db
        .into(_db.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            accountId: accountId,
            amount: amount,
            transactionDate: date,
            categoryId: Value(categoryId),
            emotionalScore: Value(emotionalScore),
            emotionalTag: Value(emotionalTag),
            investmentFlag: Value(isInvestment),
            note: Value(note),
            type: Value(type),
          ),
        );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    await _db
        .update(_db.transactions)
        .replace(
          db.TransactionsCompanion(
            id: Value(transaction.id),
            accountId: Value(transaction.accountId),
            amount: Value(transaction.amount),
            transactionDate: Value(transaction.date),
            categoryId: Value(transaction.categoryId),
            emotionalScore: Value(transaction.emotionalScore),
            emotionalTag: Value(transaction.emotionalTag),
            investmentFlag: Value(transaction.isInvestment),
            note: Value(transaction.note),
            type: Value(transaction.type),
          ),
        );
  }

  domain.Transaction _toDomain(db.Transaction row) {
    return domain.Transaction(
      id: row.id,
      accountId: row.accountId,
      amount: row.amount,
      date: row.transactionDate,
      categoryId: row.categoryId,
      emotionalScore: row.emotionalScore,
      emotionalTag: row.emotionalTag,
      isInvestment: row.investmentFlag,
      note: row.note,
      type: row.type,
    );
  }
}
