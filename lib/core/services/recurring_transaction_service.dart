import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/data/repositories/recurring_transaction_repository.dart';
import 'package:prism/data/repositories/transaction_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>((ref) {
      return RecurringTransactionService(ref);
    });

class RecurringTransactionService {
  RecurringTransactionService(this._ref);

  final Ref _ref;
  static const String _lastCheckKey = 'last_recurring_check_date';

  Future<void> checkAndProcess() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckStr = prefs.getString(_lastCheckKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime lastCheckDate;
    if (lastCheckStr != null) {
      lastCheckDate = DateTime.parse(lastCheckStr);
    } else {
      // First run: assume checked yesterday so we only process today if matched
      lastCheckDate = today.subtract(const Duration(days: 1));
    }

    // If already checked today, skip
    if (!today.isAfter(lastCheckDate)) {
      return;
    }

    final recurringRepo = _ref.read(recurringTransactionRepositoryProvider);
    final transactionRepo = _ref.read(transactionRepositoryProvider);
    final recurrings = await recurringRepo.getRecurringTransactions();

    if (recurrings.isEmpty) {
      await prefs.setString(_lastCheckKey, today.toIso8601String());
      return;
    }

    // Loop from lastCheckDate + 1 day to today
    var currentCheck = lastCheckDate.add(const Duration(days: 1));
    while (!currentCheck.isAfter(today)) {
      final day = currentCheck.day;

      // Find matching items (handle month length edge cases?)
      // Simplest: If day exists in this month.
      // e.g. transaction on 31st. currentCheck (Feb 28). day=28.
      // Matches 28th.
      // If user holds 31st, it won't fire on Feb 28. This is intended behavior described in help text.
      final matches = recurrings.where(
        (r) => r.isActive && r.dayOfMonth == day,
      );

      for (final r in matches) {
        await transactionRepo.addTransaction(
          accountId: r.accountId,
          amount: r.amount,
          date: currentCheck, // Use the date it was supposed to happen
          categoryId: r.categoryId,
          note: r.note ?? 'Recurring Expense',
          type: r.type,
          emotionalScore: 0,
          isInvestment: false,
        );
      }

      currentCheck = currentCheck.add(const Duration(days: 1));
    }

    await prefs.setString(_lastCheckKey, today.toIso8601String());
  }
}
