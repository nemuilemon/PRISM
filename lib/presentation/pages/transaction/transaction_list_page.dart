import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/presentation/controllers/transaction_list_controller.dart';
import 'package:prism/presentation/pages/transaction/add_transaction_page.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListControllerProvider);

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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeumorphicContainer(
                  child: ListTile(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              AddTransactionPage(transaction: transaction),
                        ),
                      );
                    },
                    title: Text(
                      transaction.note ?? '取引',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy/MM/dd').format(transaction.date),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.amount.toInt()} 円',
                          style: TextStyle(
                            color: transaction.amount >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (transaction.emotionalScore != 0)
                          Text(
                            '感情: ${transaction.emotionalScore}',
                            style: TextStyle(
                              fontSize: 12,
                              color: transaction.emotionalScore > 0
                                  ? Colors.green
                                  : Colors.orange,
                            ),
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
