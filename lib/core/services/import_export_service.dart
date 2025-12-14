import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prism/data/repositories/account_repository.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:prism/domain/repositories/category_repository.dart';
import 'package:prism/domain/repositories/transaction_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImportResult {
  ImportResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  final int successCount;
  final int failureCount;
  final List<String> errors;
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

  Future<bool> exportToCsv() async {
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

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '保存先を選択してください',
        fileName:
            'prism_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csv);
        return true;
      }
      return false;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/prism_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'PRISM Export Data');
      return true;
    }
  }

  Future<void> deleteAllData() async {
    final transactions = await _transactionRepository.getTransactions();
    for (final t in transactions) {
      await _transactionRepository.deleteTransaction(t.id);
    }
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
    } on Exception catch (e) {
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
    var successCount = 0;
    var failureCount = 0;
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
      // PRISM export format expects at least 6 columns (Date, AccountID, CategoryID, Note, Amount, Type)
      if (row.length < 6) {
        failureCount++;
        errors.add('Line $i: 列数が不足しています (期待: 6+, 実際: ${row.length})');
        continue;
      }
      try {
        // PRISM Export Format:
        // 0: Date
        // 1: Account ID
        // 2: Category ID
        // 3: Note
        // 4: Amount
        // 5: Type
        // 6: Emotional Score
        // 7: Self Investment

        final dateStr = row[0].toString();
        // final accountIdStr = row[1].toString();
        final categoryIdStr = row[2].toString();
        final note = row[3].toString();
        final amountStr = row[4].toString();
        final typeStr = row[5].toString();

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
          } on FormatException catch (_) {}
        }

        if (date == null) {
          throw FormatException('日付の形式が無効です: $dateStr');
        }

        final amount = double.tryParse(amountStr) ?? 0.0;

        // タイプ判定
        final type = typeStr == 'income' || typeStr == '収入'
            ? 'income'
            : 'expense';
        final finalAmount = type == 'expense' ? -amount.abs() : amount.abs();

        // カテゴリ解決
        int? categoryId;

        // IDでの検索を試みる
        final parsedCategoryId = int.tryParse(categoryIdStr);
        if (parsedCategoryId != null) {
          if (categories.any((c) => c.id == parsedCategoryId)) {
            categoryId = parsedCategoryId;
          }
        }

        // IDで見つからない、またはIDでない場合は名前で検索
        if (categoryId == null) {
          Category? category;
          try {
            category = categories.firstWhere((c) => c.name == categoryIdStr);
          } on StateError catch (_) {
            try {
              category = categories.firstWhere((c) => c.name == 'その他');
            } on StateError catch (_) {
              // Ignore
            }
          }

          if (category != null) {
            categoryId = category.id;
          } else {
            // 'その他' も見つからない場合
            // 最後の手段として最初のカテゴリを使用、またはエラー
            if (categories.isNotEmpty) {
              categoryId = categories.first.id;
            } else {
              throw Exception('カテゴリが見つかりません: $categoryIdStr');
            }
          }
        }

        // 口座解決 (名前マッチング実装推奨だが、一旦デフォルト)
        // TODO(user): 名前でマッチング
        final accountId = defaultAccount.id;

        // 感情スコアと自己投資フラグ（もしあれば）
        var emotionalScore = 0;
        var isInvestment = false;
        if (row.length > 6) {
          emotionalScore = int.tryParse(row[6].toString()) ?? 0;
        }
        if (row.length > 7) {
          final invStr = row[7].toString();
          isInvestment = invStr == 'Yes' || invStr == 'true';
        }

        await _transactionRepository.addTransaction(
          accountId: accountId,
          amount: finalAmount,
          date: date,
          categoryId: categoryId,
          note: note,
          type: type,
          emotionalScore: emotionalScore,
          isInvestment: isInvestment,
        );
        successCount++;
      } on Exception catch (e) {
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
