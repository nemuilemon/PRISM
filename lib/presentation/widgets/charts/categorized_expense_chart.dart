import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:prism/domain/entities/transaction.dart';

class CategorizedExpenseChart extends StatelessWidget {
  const CategorizedExpenseChart({
    required this.transactions,
    required this.categories,
    super.key,
  });

  final List<Transaction> transactions;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // Filter expenses (amount is usually negative for expenses, or type is 'expense')
    // Assuming 'expense' type or negative amount. Based on import logic: type == 'expense'
    final expenses = transactions.where((t) => t.type == 'expense');

    if (expenses.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    // Group by categoryId
    final Map<int, double> sums = {};
    for (final t in expenses) {
      final catId = t.categoryId ?? -1;
      sums[catId] = (sums[catId] ?? 0) + t.amount.abs();
    }

    if (sums.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    final total = sums.values.fold(0.0, (sum, val) => sum + val);

    // Create sections
    final List<PieChartSectionData> sections = [];
    int index = 0;

    // Sort by amount descending
    final sortedKeys = sums.keys.toList()
      ..sort((a, b) => sums[b]!.compareTo(sums[a]!));

    for (final catId in sortedKeys) {
      final amount = sums[catId]!;
      final percentage = (amount / total) * 100;

      // Skip very small sections
      if (percentage < 3) continue;

      String name = 'Unknown';
      if (catId == -1) {
        name = 'Uncategorized';
      } else {
        final cat = categories.where((c) => c.id == catId).firstOrNull;
        name = cat?.name ?? 'Unknown';
      }

      final color = Colors.primaries[index % Colors.primaries.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _Badge(
            name,
            size: 40,
            borderColor: color,
          ),
          badgePositionPercentageOffset: .98,
        ),
      );
      index++;
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });
  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4), // Add padding to prevent text clipping
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center, // Center the text
          style: const TextStyle(
            fontSize: 10, // Slightly smaller font
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis, // Add ellipsis for long names
          maxLines: 2, // Allow 2 lines
        ),
      ),
    );
  }
}
