import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prism/domain/entities/transaction.dart';
import 'package:prism/core/theme/app_theme.dart';

class InvestmentTrendChart extends StatelessWidget {
  final List<Transaction> transactions;

  const InvestmentTrendChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // 日付順にソート
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 自己投資の積み上げ計算
    List<FlSpot> spots = [];
    double currentTotal = 0;
    int index = 0;
    bool hasInvestment = false;

    // 開始点
    spots.add(const FlSpot(0, 0));

    for (var t in sorted) {
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
              color: AppTheme.accentColor.withOpacity(0.2),
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
