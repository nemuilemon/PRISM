import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required int id,
    required int accountId,
    required double amount,
    required DateTime date,
    int? categoryId,
    @Default(0) int emotionalScore,
    String? emotionalTag,
    @Default(false) bool isInvestment,
    String? note,
    @Default('expense') String type,
  }) = _Transaction;
}
