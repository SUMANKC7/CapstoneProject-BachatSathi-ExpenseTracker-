import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'pie_chart_widget.dart';
import 'line_chart_widget.dart';

class ChartArea extends StatelessWidget {
  final ChartProvider provider;

  const ChartArea({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    switch (provider.selectedChartType) {
      case ChartType.expenseIncome:
      case ChartType.categoryBreakdown:
      case ChartType.cashFlow:
      case ChartType.combined:
        return PieChartWidget(provider: provider);
      case ChartType.monthlyTrends:
        return LineChartWidget(provider: provider);
    }
  }
}
