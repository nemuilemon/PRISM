import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/core/services/import_export_service.dart';
import 'package:prism/data/repositories/transaction_repository_impl.dart';
import 'package:prism/data/repositories/category_repository_impl.dart';

import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';
import 'package:prism/presentation/pages/settings/category_list_page.dart';

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
                    onTap: () {
                      Navigator.push(
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
                      final service = ImportExportService(
                        transactionRepo,
                        categoryRepo,
                      );

                      try {
                        await service.importFromCsv();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('インポートが完了しました')),
                          );
                        }
                      } catch (e) {
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
                      final service = ImportExportService(
                        transactionRepo,
                        categoryRepo,
                      );

                      try {
                        await service.exportToCsv();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('エクスポートが完了しました')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('エクスポートエラー: $e')),
                          );
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
