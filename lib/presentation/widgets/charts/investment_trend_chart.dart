import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/transaction.dart';

class InvestmentTrendChart extends StatelessWidget {
  const InvestmentTrendChart({required this.transactions, super.key});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // 日付順にソート
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 自己投資の積み上げ計算
    final spots = <FlSpot>[];
    double currentTotal = 0;
    var index = 0;
    var hasInvestment = false;

    // 開始点
    spots.add(FlSpot.zero);

    for (final t in sorted) {
      if (t.isInvestment) {
        currentTotal += t.amount;
        hasInvestment = true;
      }
      index++;
      // トランザクションごとの推移をプロット（X軸は件数ベース）
      spots.add(FlSpot(index.toDouble(), currentTotal));
    }

    if (!hasInvestment) {
      return const Center(
        child: Text(
          'No investments yet.\nTurn on "Investment" flag when adding transaction.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.accentColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.accentColor.withValues(alpha: 0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '¥${spot.y.toInt()}',
                  const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
