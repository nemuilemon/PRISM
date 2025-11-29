import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prism/presentation/controllers/account_list_controller.dart';
import 'package:prism/presentation/controllers/transaction_list_controller.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';
import 'package:prism/presentation/widgets/charts/investment_trend_chart.dart';
import 'package:prism/presentation/widgets/charts/emotion_scatter_chart.dart';
import 'package:prism/domain/entities/asset.dart';
import 'package:prism/domain/entities/transaction.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(accountListControllerProvider);
    final transactionsAsync = ref.watch(transactionListControllerProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 総資産カード
            _buildTotalAssetCard(context, assetsAsync, currencyFormatter),
            const SizedBox(height: 24),

            // 統計情報（自己投資 & 感情）
            _buildStatsRow(context, transactionsAsync, currencyFormatter),
            const SizedBox(height: 24),

            // チャートセクション
            Text(
              'Investment Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: transactionsAsync.when(
                data: (data) => InvestmentTrendChart(transactions: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Emotion Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: transactionsAsync.when(
                data: (data) => EmotionScatterChart(transactions: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 24),

            // 直近の取引
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentTransactions(
              context,
              transactionsAsync,
              currencyFormatter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAssetCard(
    BuildContext context,
    AsyncValue<List<Asset>> assetsAsync,
    NumberFormat formatter,
  ) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Total Assets',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          assetsAsync.when(
            data: (assets) {
              // 金融資産とポイントを合算（簡易）
              double total = 0;
              for (var asset in assets) {
                asset.map(
                  financial: (a) => total += a.amount,
                  point: (a) => total += a.points * a.exchangeRate,
                  experience: (a) => 0, // 経験は金額に含めない
                );
              }
              return Text(
                formatter.format(total),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
    NumberFormat formatter,
  ) {
    return Row(
      children: [
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  'Investment',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                transactionsAsync.when(
                  data: (transactions) {
                    // 今月の自己投資額を集計
                    final now = DateTime.now();
                    final thisMonth = transactions.where(
                      (t) =>
                          t.date.year == now.year &&
                          t.date.month == now.month &&
                          t.isInvestment,
                    );
                    final total = thisMonth.fold<double>(
                      0.0,
                      (sum, t) => sum + t.amount,
                    );
                    return Text(
                      formatter.format(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                  loading: () => const Text('...'),
                  error: (_, __) => const Text('-'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mood, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  'Avg. Emotion',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) return const Text('-');
                    final sum = transactions.fold(
                      0,
                      (s, t) => s + t.emotionalScore,
                    );
                    final avg = sum / transactions.length;
                    return Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                  loading: () => const Text('...'),
                  error: (_, __) => const Text('-'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
    NumberFormat formatter,
  ) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('No transactions yet.'));
        }
        // 日付降順で先頭5件
        final recent = List<Transaction>.from(transactions)
          ..sort((a, b) => b.date.compareTo(a.date));
        final top5 = recent.take(5).toList();

        return Column(
          children: top5.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MM/dd').format(t.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          t.note ?? 'No memo',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (t.isInvestment)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                        Text(
                          formatter.format(t.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: t.isInvestment ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
