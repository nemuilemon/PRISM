import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:prism/presentation/controllers/category_list_controller.dart';
import 'package:prism/presentation/controllers/transaction_list_controller.dart';
import 'package:prism/presentation/pages/transaction/add_transaction_page.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListControllerProvider);
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: const Text('取引一覧', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.baseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('取引はまだありません。'));
          }

          final categories = categoriesAsync.asData?.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final category = categories.firstWhere(
                (c) => c.id == transaction.categoryId,
                orElse: () => const Category(
                  id: -1,
                  name: '未分類',
                  type: 'expense',
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeumorphicContainer(
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              AddTransactionPage(transaction: transaction),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // 日付 (左)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MM/dd').format(transaction.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy').format(transaction.date),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // カテゴリとメモ (中央)
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (transaction.note != null &&
                                    transaction.note!.isNotEmpty)
                                  Text(
                                    transaction.note!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 金額と感情 (右)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${transaction.amount.toInt()} 円',
                                style: TextStyle(
                                  color: transaction.amount >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (transaction.emotionalScore != 0)
                                Text(
                                  '感情: ${transaction.emotionalScore}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: transaction.emotionalScore > 0
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: NeumorphicButton(
          padding: EdgeInsets.zero,
          borderRadius: 30,
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AddTransactionPage(),
              ),
            );
          },
          child: const Icon(Icons.add, color: AppTheme.accentColor, size: 30),
        ),
      ),
    );
  }
}
