import 'package:flutter/material.dart';

/// Chart Types Available
enum ChartType {
  expenseIncome, // Pie chart
  categoryBreakdown, // Pie chart
  monthlyTrends, // Line chart
  cashFlow, // Bar chart
  combined, // Mixed overview
}

/// Time Range for Data Filtering
enum ChartTimeRange { week, month, threeMonths, sixMonths, year, all }

/// Chart Data Model for consistent data structure
class ChartDataModel {
  final String label;
  final double value;
  final Color color;
  final String? category;
  final DateTime? date;

  ChartDataModel({
    required this.label,
    required this.value,
    required this.color,
    this.category,
    this.date,
  });

  /// Convert to Map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
      'color': color.value,
      'category': category,
      'date': date?.toIso8601String(),
    };
  }

  /// Create from Map for easy deserialization
  factory ChartDataModel.fromMap(Map<String, dynamic> map) {
    return ChartDataModel(
      label: map['label'] ?? '',
      value: (map['value'] ?? 0).toDouble(),
      color: Color(map['color'] ?? Colors.blue.value),
      category: map['category'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
    );
  }

  @override
  String toString() {
    return 'ChartDataModel(label: $label, value: $value, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartDataModel &&
        other.label == label &&
        other.value == value &&
        other.color == color;
  }

  @override
  int get hashCode {
    return label.hashCode ^ value.hashCode ^ color.hashCode;
  }
}

/// Monthly Trend Data Model
class MonthlyTrendData {
  final String month;
  final int monthIndex;
  final int year;
  final double income;
  final double expense;
  final double netFlow;
  final double toReceive;
  final double toGive;
  final DateTime date;

  MonthlyTrendData({
    required this.month,
    required this.monthIndex,
    required this.year,
    required this.income,
    required this.expense,
    required this.netFlow,
    required this.toReceive,
    required this.toGive,
    required this.date,
  });

  /// Calculate net income (income - expense)
  double get netIncome => income - expense;

  /// Calculate net cash flow (toReceive - toGive)
  double get netCashFlow => toReceive - toGive;

  /// Calculate total net worth change for the month
  double get totalNet => netIncome + netCashFlow;

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'monthIndex': monthIndex,
      'year': year,
      'income': income,
      'expense': expense,
      'netFlow': netFlow,
      'toReceive': toReceive,
      'toGive': toGive,
      'date': date.toIso8601String(),
    };
  }

  factory MonthlyTrendData.fromMap(Map<String, dynamic> map) {
    return MonthlyTrendData(
      month: map['month'] ?? '',
      monthIndex: map['monthIndex'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      income: (map['income'] ?? 0).toDouble(),
      expense: (map['expense'] ?? 0).toDouble(),
      netFlow: (map['netFlow'] ?? 0).toDouble(),
      toReceive: (map['toReceive'] ?? 0).toDouble(),
      toGive: (map['toGive'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  @override
  String toString() {
    return 'MonthlyTrendData(month: $month, income: $income, expense: $expense, netFlow: $netFlow)';
  }
}

/// Category Data Model with additional metadata
class CategoryData {
  final String name;
  final double amount;
  final int transactionCount;
  final Color color;
  final List<double> monthlyAmounts;

  CategoryData({
    required this.name,
    required this.amount,
    required this.transactionCount,
    required this.color,
    this.monthlyAmounts = const [],
  });

  /// Average transaction amount for this category
  double get averageTransaction =>
      transactionCount > 0 ? amount / transactionCount : 0;

  /// Percentage of total (will be calculated when used)
  double getPercentage(double total) => total > 0 ? (amount / total) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'transactionCount': transactionCount,
      'color': color.value,
      'monthlyAmounts': monthlyAmounts,
    };
  }

  factory CategoryData.fromMap(Map<String, dynamic> map) {
    return CategoryData(
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      color: Color(map['color'] ?? Colors.blue.value),
      monthlyAmounts: List<double>.from(map['monthlyAmounts'] ?? []),
    );
  }
}

/// Chart Configuration for customizing appearance
class ChartConfig {
  final bool showLegend;
  final bool showPercentages;
  final bool showValues;
  final bool animated;
  final Duration animationDuration;
  final double? maxHeight;
  final double? maxWidth;

  const ChartConfig({
    this.showLegend = true,
    this.showPercentages = true,
    this.showValues = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.maxHeight,
    this.maxWidth,
  });

  ChartConfig copyWith({
    bool? showLegend,
    bool? showPercentages,
    bool? showValues,
    bool? animated,
    Duration? animationDuration,
    double? maxHeight,
    double? maxWidth,
  }) {
    return ChartConfig(
      showLegend: showLegend ?? this.showLegend,
      showPercentages: showPercentages ?? this.showPercentages,
      showValues: showValues ?? this.showValues,
      animated: animated ?? this.animated,
      animationDuration: animationDuration ?? this.animationDuration,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }
}

/// Chart Theme for consistent styling
class ChartTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color gridColor;
  final TextStyle titleStyle;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final BorderRadius borderRadius;
  final double elevation;

  const ChartTheme({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.gridColor = const Color(0xFFE0E0E0),
    this.titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    this.labelStyle = const TextStyle(fontSize: 12, color: Colors.black54),
    this.valueStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
  });

  static const ChartTheme light = ChartTheme();

  static const ChartTheme dark = ChartTheme(
    backgroundColor: Color(0xFF1E1E1E),
    textColor: Colors.white70,
    gridColor: Color(0xFF404040),
    titleStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelStyle: TextStyle(fontSize: 12, color: Colors.white60),
    valueStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    ),
  );
}

/// Data point for line charts and time series
class TimeSeriesDataPoint {
  final DateTime date;
  final double value;
  final String? label;
  final Color? color;

  TimeSeriesDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
      'color': color?.value,
    };
  }

  factory TimeSeriesDataPoint.fromMap(Map<String, dynamic> map) {
    return TimeSeriesDataPoint(
      date: DateTime.parse(map['date']),
      value: (map['value'] ?? 0).toDouble(),
      label: map['label'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }
}

/// Chart Data Response wrapper
class ChartDataResponse<T> {
  final T data;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  ChartDataResponse({
    required this.data,
    this.isLoading = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  bool get hasError => error != null;
  bool get isEmpty => data == null;
  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes > 5;

  ChartDataResponse<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ChartDataResponse<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Extended chart data for more detailed analytics
class DetailedChartData {
  final List<ChartDataModel> primaryData;
  final List<TimeSeriesDataPoint>? timeSeriesData;
  final Map<String, dynamic>? metadata;
  final ChartConfig config;

  DetailedChartData({
    required this.primaryData,
    this.timeSeriesData,
    this.metadata,
    this.config = const ChartConfig(),
  });

  /// Get total value of all data points
  double get totalValue => primaryData.fold(0, (sum, item) => sum + item.value);

  /// Get data sorted by value (descending)
  List<ChartDataModel> get sortedByValue =>
      List.from(primaryData)..sort((a, b) => b.value.compareTo(a.value));

  /// Get top N items by value
  List<ChartDataModel> getTopItems(int n) => sortedByValue.take(n).toList();

  /// Get data as percentages
  List<ChartDataModel> get asPercentages {
    final total = totalValue;
    if (total == 0) return primaryData;

    return primaryData
        .map(
          (item) => ChartDataModel(
            label: item.label,
            value: (item.value / total) * 100,
            color: item.color,
            category: item.category,
            date: item.date,
          ),
        )
        .toList();
  }
}
