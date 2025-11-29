import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prism/domain/entities/transaction.dart';
import 'package:prism/core/theme/app_theme.dart';

class EmotionScatterChart extends StatelessWidget {
  final List<Transaction> transactions;

  const EmotionScatterChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // 日付順にソート
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 直近30件に絞る
    final recent = sorted.length > 30
        ? sorted.sublist(sorted.length - 30)
        : sorted;

    List<ScatterSpot> spots = [];
    for (int i = 0; i < recent.length; i++) {
      final t = recent[i];
      // 半径は金額に応じて可変（最小4, 最大12）
      final double radius = (t.amount > 10000 ? 12 : (t.amount > 1000 ? 8 : 4))
          .toDouble();

      spots.add(
        ScatterSpot(
          i.toDouble(),
          t.emotionalScore.toDouble(),
          dotPainter: FlDotCirclePainter(
            radius: radius,
            color: t.emotionalScore > 0
                ? Colors.green.withOpacity(0.7)
                : (t.emotionalScore < 0
                      ? Colors.orange.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.7)),
            strokeWidth: 0,
          ),
        ),
      );
    }

    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots,
        minY: -6,
        maxY: 6,
        minX: -1,
        maxX: recent.length.toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            if (value == 0) {
              return const FlLine(color: Colors.grey, strokeWidth: 1);
            }
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        scatterTouchData: ScatterTouchData(
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (ScatterSpot spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= recent.length) return null;
              final t = recent[index];
              return ScatterTooltipItem(
                '${t.note ?? 'No memo'}\n¥${t.amount.toInt()}\nScore: ${t.emotionalScore}',
                textStyle: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
