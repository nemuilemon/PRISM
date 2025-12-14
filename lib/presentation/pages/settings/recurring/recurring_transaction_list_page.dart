import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prism/core/theme/app_theme.dart';

import 'package:prism/presentation/controllers/category_list_controller.dart';
import 'package:prism/presentation/controllers/recurring_transaction_list_controller.dart';
import 'package:prism/presentation/pages/settings/recurring/add_recurring_transaction_page.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class RecurringTransactionListPage extends ConsumerWidget {
  const RecurringTransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(recurringTransactionListControllerProvider);
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: const Text(
          '定期支出(固定費)設定',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.baseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('定期支出は設定されていません'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final t = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeumorphicContainer(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.isActive ? Colors.green : Colors.grey,
                      child: Text(
                        t.dayOfMonth.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      t.note ?? '未分類',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: categoriesAsync.when(
                      data: (cats) {
                        final catName =
                            cats
                                .where((c) => c.id == t.categoryId)
                                .firstOrNull
                                ?.name ??
                            '-';
                        return Text(catName);
                      },
                      loading: () => const Text('...'),
                      error: (_, __) => const Text('-'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¥${NumberFormat('#,###').format(t.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: t.isActive ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.accentColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    AddRecurringTransactionPage(
                                      transaction: t,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, ref, t.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const AddRecurringTransactionPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('この設定を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(recurringTransactionListControllerProvider.notifier)
          .deleteRecurringTransaction(id);
    }
  }
}
