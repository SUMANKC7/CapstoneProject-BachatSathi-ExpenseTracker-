import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final ChartProvider provider;

  const LineChartWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.getMonthlyTrendsData();

    if (data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No trend data available'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          provider.chartTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1000,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            data[index].month,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrency(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.income);
                  }).toList(),
                  isCurved: true,
                  color: ChartProvider.incomeColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ChartProvider.incomeColor.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.expense);
                  }).toList(),
                  isCurved: true,
                  color: ChartProvider.expenseColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ChartProvider.expenseColor.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.netFlow);
                  }).toList(),
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                  dashArray: [5, 5],
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      const textStyle = TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      String label;
                      switch (touchedSpot.barIndex) {
                        case 0:
                          label = 'Income: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        case 1:
                          label = 'Expense: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        case 2:
                          label = 'Net: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        default:
                          label = _formatCurrency(touchedSpot.y);
                      }
                      return LineTooltipItem(label, textStyle);
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLineLegendItem('Income', ChartProvider.incomeColor),
              _buildLineLegendItem('Expense', ChartProvider.expenseColor),
              _buildLineLegendItem('Net Flow', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount.abs() >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}
