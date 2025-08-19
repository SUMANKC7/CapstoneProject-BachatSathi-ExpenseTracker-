import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';

class ChartTypeSelector extends StatelessWidget {
  final ChartProvider provider;

  const ChartTypeSelector({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ChartType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_getChartTypeLabel(type)),
              selected: provider.selectedChartType == type,
              onSelected: (selected) {
                if (selected) provider.setChartType(type);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getChartTypeLabel(ChartType type) {
    switch (type) {
      case ChartType.expenseIncome:
        return 'Income vs Expense';
      case ChartType.categoryBreakdown:
        return 'Categories';
      case ChartType.monthlyTrends:
        return 'Monthly Trends';
      case ChartType.cashFlow:
        return 'Cash Flow';
      case ChartType.combined:
        return 'Overview';
    }
  }
}
