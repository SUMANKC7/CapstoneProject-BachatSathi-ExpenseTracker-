import 'dart:ui';

enum ChartType {
  expenseIncome,
  categoryBreakdown,
  monthlyTrends,
  cashFlow,
  combined,
}

enum ChartTimeRange { week, month, threeMonths, sixMonths, year, all }

class ChartDataModel {
  final String label;
  final double value;
  final Color color;
  final DateTime? date;

  ChartDataModel({
    required this.label,
    required this.value,
    required this.color,
    this.date,
  });
}
