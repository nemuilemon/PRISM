class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.dayOfMonth,
    this.categoryId,
    this.isActive = true,
    this.note,
    this.type = 'expense',
  });

  final int id;
  final int accountId;
  final double amount;
  final int? categoryId;
  final int dayOfMonth;
  final bool isActive;
  final String? note;
  final String type;

  RecurringTransaction copyWith({
    int? id,
    int? accountId,
    double? amount,
    int? categoryId,
    int? dayOfMonth,
    bool? isActive,
    String? note,
    String? type,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }
}
