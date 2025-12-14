import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:prism/domain/entities/transaction.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class MonthlyCategoryTable extends StatefulWidget {
  const MonthlyCategoryTable({
    required this.transactions,
    required this.categories,
    super.key,
  });

  final List<Transaction> transactions;
  final List<Category> categories;

  @override
  State<MonthlyCategoryTable> createState() => _MonthlyCategoryTableState();
}

class _MonthlyCategoryTableState extends State<MonthlyCategoryTable> {
  // Start with a large number to allow swiping back
  static const int _initialPage = 1000;
  late final PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthFromIndex(int index) {
    final diff = index - _initialPage;
    return DateTime(_currentMonth.year, _currentMonth.month + diff);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Fixed height for the table area
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final month = _getMonthFromIndex(index);
          return _buildMonthPage(month);
        },
      ),
    );
  }

  Widget _buildMonthPage(DateTime month) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
    );

    // Filter transactions for this month
    final monthTransactions = widget.transactions.where((t) {
      return t.date.year == month.year &&
          t.date.month == month.month &&
          t.type == 'expense'; // Only expenses
    }).toList();

    // Aggregate by category
    final Map<int, double> sums = {};
    for (final t in monthTransactions) {
      final catId = t.categoryId ?? -1;
      sums[catId] = (sums[catId] ?? 0) + t.amount.abs();
    }

    final totalExpense = sums.values.fold(0.0, (sum, val) => sum + val);

    // Sort by amount desc
    final sortedKeys = sums.keys.toList()
      ..sort((a, b) => sums[b]!.compareTo(sums[a]!));

    return Column(
      children: [
        // Month Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              Text(
                DateFormat('yyyy年 MM月').format(month),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),

        // Total for the month
        Text(
          'Total: ${currencyFormatter.format(totalExpense)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // List
        Expanded(
          child: monthTransactions.isEmpty
              ? const Center(child: Text('データがありません'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final catId = sortedKeys[index];
                    final amount = sums[catId]!;

                    String name = '未分類';
                    if (catId != -1) {
                      final cat = widget.categories
                          .where((c) => c.id == catId)
                          .firstOrNull;
                      name = cat?.name ?? 'Unknown';
                    }

                    final percentage = totalExpense > 0
                        ? (amount / totalExpense * 100)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                currencyFormatter.format(amount),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
