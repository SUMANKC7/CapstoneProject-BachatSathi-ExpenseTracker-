import 'package:expensetrack/features/chart/model/chart_model.dart';

String getTimeRangeLabel(ChartTimeRange range) {
  switch (range) {
    case ChartTimeRange.week:
      return 'Last 7 Days';
    case ChartTimeRange.month:
      return 'Last Month';
    case ChartTimeRange.threeMonths:
      return 'Last 3 Months';
    case ChartTimeRange.sixMonths:
      return 'Last 6 Months';
    case ChartTimeRange.year:
      return 'Last Year';
    case ChartTimeRange.all:
      return 'All Time';
  }
}

String formatCurrency(double amount) {
  if (amount.abs() >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(1)} Cr';
  } else if (amount.abs() >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)} L';
  } else if (amount.abs() >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
