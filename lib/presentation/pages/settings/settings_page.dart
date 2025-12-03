import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/services/import_export_service.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/data/repositories/account_repository.dart';
import 'package:prism/data/repositories/category_repository_impl.dart';
import 'package:prism/data/repositories/transaction_repository_impl.dart';
import 'package:prism/presentation/pages/settings/category_list_page.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.baseColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'データ管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicContainer(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.category,
                      color: AppTheme.accentColor,
                    ),
                    title: const Text('カテゴリ管理'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const CategoryListPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.file_upload,
                      color: AppTheme.accentColor,
                    ),
                    title: const Text('CSVインポート'),
                    subtitle: const Text('anc_ae_kakeibo_export.csv 形式'),
                    onTap: () async {
                      final transactionRepo = ref.read(
                        transactionRepositoryProvider,
                      );
                      final categoryRepo = ref.read(categoryRepositoryProvider);
                      final accountRepo = ref.read(accountRepositoryProvider);
                      final service = ImportExportService(
                        transactionRepo,
                        categoryRepo,
                        accountRepo,
                      );

                      try {
                        final result = await service.importFromCsv();
                        if (!context.mounted) return;

                        if (result == null) {
                          return;
                        }

                        if (result.successCount > 0 &&
                            result.failureCount == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${result.successCount}件のインポートが完了しました',
                              ),
                            ),
                          );
                        } else if (result.successCount == 0 &&
                            result.failureCount == 0 &&
                            result.errors.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('インポートするデータが見つかりませんでした'),
                            ),
                          );
                        } else {
                          await showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('インポート結果'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('成功: ${result.successCount}件'),
                                    Text(
                                      '失敗: ${result.failureCount}件',
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    if (result.errors.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text('エラー詳細 (最初の5件):'),
                                      ...result.errors
                                          .take(5)
                                          .map(
                                            (e) => Text(
                                              e,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } on Exception catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('インポートエラー: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.file_download,
                      color: AppTheme.accentColor,
                    ),
                    title: const Text('CSVエクスポート'),
                    onTap: () async {
                      final transactionRepo = ref.read(
                        transactionRepositoryProvider,
                      );
                      final categoryRepo = ref.read(categoryRepositoryProvider);
                      final accountRepo = ref.read(accountRepositoryProvider);
                      final service = ImportExportService(
                        transactionRepo,
                        categoryRepo,
                        accountRepo,
                      );

                      try {
                        final success = await service.exportToCsv();
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('エクスポートが完了しました')),
                          );
                        }
                      } on Exception catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('エクスポートエラー: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'データを全削除',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('データの削除'),
                          content: const Text(
                            'すべての取引データを削除します。\nこの操作は取り消せません。\n本当によろしいですか？',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      );

                      if ((confirmed ?? false) && context.mounted) {
                        final transactionRepo = ref.read(
                          transactionRepositoryProvider,
                        );
                        final categoryRepo = ref.read(
                          categoryRepositoryProvider,
                        );
                        final accountRepo = ref.read(accountRepositoryProvider);
                        final service = ImportExportService(
                          transactionRepo,
                          categoryRepo,
                          accountRepo,
                        );

                        try {
                          await service.deleteAllData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('データを削除しました')),
                            );
                          }
                        } on Exception catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('削除エラー: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
