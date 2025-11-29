import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prism/domain/repositories/category_repository.dart';
import 'package:prism/domain/repositories/transaction_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImportExportService {
  ImportExportService(this._transactionRepository, this._categoryRepository);

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  // AccountRepositoryが必要だが、今回は簡易的に実装するか、DIで渡す

  Future<void> exportToCsv() async {
    final transactions = await _transactionRepository.getTransactions();

    final rows = <List<dynamic>>[
      [
        '日付',
        '口座ID', // 本来は口座名にすべきだが、簡易実装
        'カテゴリID', // 本来はカテゴリ名
        '内容',
        '金額',
        'タイプ', // income/expense
        '感情スコア',
        '自己投資',
      ],
    ];

    for (final t in transactions) {
      rows.add([
        DateFormat('yyyy/MM/dd HH:mm:ss').format(t.date),
        t.accountId,
        t.categoryId,
        t.note,
        t.amount,
        t.type,
        t.emotionalScore,
        if (t.isInvestment) 'Yes' else 'No',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/prism_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'PRISM Export Data');
  }

  Future<void> importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final input = await file.readAsString();
      final fields = const CsvToListConverter().convert(input);

      // Header skip logic needed? Assuming header exists.
      // ユーザー提供のフォーマット: 日付,口座,分類,小分類,内容,金額,収入/支出

      // カテゴリキャッシュ
      final categories = await _categoryRepository.getCategories();

      // トランザクション一括追加はRepositoryにないのでループで追加（非効率だが一旦これで）
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 7) continue;

        try {
          final dateStr = row[0].toString();
          // final accountName = row[1].toString(); // 口座名からID解決が必要
          final categoryName = row[2].toString();
          // subCategory = row[3]
          final note = row[4].toString();
          final amountStr = row[5].toString();
          final typeStr = row[6].toString(); // 収入/支出

          final date = DateFormat('yyyy/MM/dd HH:mm:ss').parse(dateStr);
          final amount = double.tryParse(amountStr) ?? 0.0;

          // タイプ判定
          final type = typeStr == '収入' ? 'income' : 'expense';
          final finalAmount = type == 'expense' ? -amount.abs() : amount.abs();

          // カテゴリ解決
          int? categoryId;
          final category = categories.firstWhere(
            (c) => c.name == categoryName,
            orElse: () => categories.firstWhere((c) => c.name == 'その他'), // 仮
          );
          categoryId = category.id;

          // 口座解決 (今回はID=1固定とする、または別途解決ロジックが必要)
          // TODO(user): AccountRepositoryを使って名前からIDを引く
          const accountId = 1;

          await _transactionRepository.addTransaction(
            accountId: accountId,
            amount: finalAmount,
            date: date,
            categoryId: categoryId,
            note: note,
            type: type,
          );
        } on Exception catch (e) {
          debugPrint('Import error at line $i: $e');
        }
      }
    }
  }
}
