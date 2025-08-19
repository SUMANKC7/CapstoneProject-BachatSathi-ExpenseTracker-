import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/legend_widget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final ChartProvider provider;

  const PieChartWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.getCurrentChartData() as List<ChartDataModel>;

    if (data.isEmpty || data.every((element) => element.value == 0)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data available for selected period'),
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
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: data.map((item) {
                      final total = data.fold(
                        0.0,
                        (sum, item) => sum + item.value,
                      );
                      final percentage = total > 0
                          ? (item.value / total) * 100
                          : 0;

                      return PieChartSectionData(
                        value: item.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        color: item.color,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(flex: 1, child: LegendWidget(data: data)),
            ],
          ),
        ),
      ],
    );
  }
}
