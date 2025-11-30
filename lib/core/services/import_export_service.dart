import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prism/data/repositories/account_repository.dart';
import 'package:prism/domain/repositories/category_repository.dart';
import 'package:prism/domain/repositories/transaction_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImportResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;

  ImportResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });
}

class ImportExportService {
  ImportExportService(
    this._transactionRepository,
    this._categoryRepository,
    this._accountRepository,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;

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

  Future<ImportResult?> importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    String input;
    try {
      input = await file.readAsString();
    } catch (e) {
      return ImportResult(
        successCount: 0,
        failureCount: 1,
        errors: ['ファイルの読み込みに失敗しました。文字コードがUTF-8であることを確認してください。\n詳細: $e'],
      );
    }

    // 改行コードの正規化 (CRLF -> LF, CR -> LF)
    input = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final fields = const CsvToListConverter(eol: '\n').convert(input);

    // カテゴリとアカウントの準備
    final categories = await _categoryRepository.getCategories();
    final accounts = await _accountRepository.getAllAccounts();

    if (accounts.isEmpty) {
      return ImportResult(
        successCount: 0,
        failureCount: 0,
        errors: ['アカウントが存在しません。先にアカウントを作成してください。'],
      );
    }

    // デフォルトアカウント（最初のアカウント）
    final defaultAccount = accounts.first;
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    if (fields.isEmpty) {
      return ImportResult(
        successCount: 0,
        failureCount: 0,
        errors: ['ファイルが空です (Input length: ${input.length})'],
      );
    }

    if (fields.length <= 1) {
      return ImportResult(
        successCount: 0,
        failureCount: 0,
        errors: [
          'データ行が見つかりませんでした (Rows: ${fields.length}, Input length: ${input.length})',
        ],
      );
    }

    // トランザクション一括追加
    // ヘッダー行をスキップするために1から開始
    for (var i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 7) {
        failureCount++;
        errors.add('Line $i: 列数が不足しています (期待: 7, 実際: ${row.length})');
        continue;
      }
      try {
        final dateStr = row[0].toString();
        // final accountName = row[1].toString(); // 口座名からID解決が必要
        final categoryName = row[2].toString();
        // subCategory = row[3]
        final note = row[4].toString();
        final amountStr = row[5].toString();
        final typeStr = row[6].toString(); // 収入/支出

        // 日付解析 (複数のフォーマットを試行)
        DateTime? date;
        final dateFormats = [
          DateFormat('yyyy/MM/dd HH:mm:ss'),
          DateFormat('yyyy/MM/dd'),
          DateFormat('yyyy-MM-dd HH:mm:ss'),
          DateFormat('yyyy-MM-dd'),
        ];

        for (final fmt in dateFormats) {
          try {
            date = fmt.parse(dateStr);
            break;
          } catch (_) {}
        }

        if (date == null) {
          throw FormatException('日付の形式が無効です: $dateStr');
        }

        final amount = double.tryParse(amountStr) ?? 0.0;

        // タイプ判定
        final type = typeStr == '収入' ? 'income' : 'expense';
        final finalAmount = type == 'expense' ? -amount.abs() : amount.abs();

        // カテゴリ解決
        int? categoryId;
        try {
          final category = categories.firstWhere(
            (c) => c.name == categoryName,
            orElse: () => categories.firstWhere((c) => c.name == 'その他'),
          );
          categoryId = category.id;
        } catch (e) {
          // 'その他' も見つからない場合
          throw Exception('カテゴリが見つかりません: $categoryName');
        }

        // 口座解決 (名前マッチング実装推奨だが、一旦デフォルト)
        // TODO: 名前でマッチング
        final accountId = defaultAccount.id;

        await _transactionRepository.addTransaction(
          accountId: accountId,
          amount: finalAmount,
          date: date,
          categoryId: categoryId,
          note: note,
          type: type,
        );
        successCount++;
      } catch (e) {
        failureCount++;
        errors.add('Line $i: $e');
        debugPrint('Import error at line $i: $e');
      }
    }

    return ImportResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }
}
