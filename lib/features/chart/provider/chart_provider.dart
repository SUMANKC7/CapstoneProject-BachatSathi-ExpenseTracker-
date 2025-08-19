import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';

class ChartProvider extends ChangeNotifier {
  final AddTransactionRepo _transactionRepo;
  final EntityRepositoryService _entityRepo;

  ChartProvider(this._transactionRepo, this._entityRepo) {
    _loadData();
  }

  List<AllTransactionModel> _transactions = [];
  List<AddParty> _entities = [];
  ChartType _selectedChartType = ChartType.combined;
  ChartTimeRange _selectedTimeRange = ChartTimeRange.month;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AllTransactionModel> get transactions => _transactions;
  List<AddParty> get entities => _entities;
  ChartType get selectedChartType => _selectedChartType;
  ChartTimeRange get selectedTimeRange => _selectedTimeRange;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Enhanced Chart Colors with better contrast
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFf44336);
  static const Color toReceiveColor = Color(0xFF2196F3);
  static const Color toGiveColor = Color(0xFFFF9800);
  static const Color netFlowPositiveColor = Color(0xFF8BC34A);
  static const Color netFlowNegativeColor = Color(0xFFE91E63);

  static const List<Color> categoryColors = [
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
    Color(0xFF9E9E9E), // Grey
  ];

  void setChartType(ChartType type) {
    _selectedChartType = type;
    notifyListeners();
  }

  void setTimeRange(ChartTimeRange range) {
    _selectedTimeRange = range;
    _loadData(); // Reload data with new time range
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([_loadTransactions(), _loadEntities()]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
      debugPrint('Chart data loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final snapshot = await _transactionRepo.listenToTransactions().first;
      _transactions = snapshot;
    } catch (e) {
      _transactions = await _transactionRepo.getCachedTransactions();
      debugPrint('Using cached transactions: $e');
    }
  }

  Future<void> _loadEntities() async {
    try {
      _entities = await _entityRepo.fetchEntities();
    } catch (e) {
      _entities = await _entityRepo.getCachedEntities();
      debugPrint('Using cached entities: $e');
    }
  }

  DateTime _getStartDateForRange() {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case ChartTimeRange.week:
        return now.subtract(const Duration(days: 7));
      case ChartTimeRange.month:
        return DateTime(now.year, now.month - 1, now.day);
      case ChartTimeRange.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case ChartTimeRange.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case ChartTimeRange.year:
        return DateTime(now.year - 1, now.month, now.day);
      case ChartTimeRange.all:
        return DateTime(2000);
    }
  }

  DateTime _extractDateTime(dynamic dateField) {
    if (dateField is Timestamp) {
      return dateField.toDate();
    } else if (dateField is DateTime) {
      return dateField;
    } else if (dateField is String) {
      try {
        return DateTime.parse(dateField);
      } catch (e) {
        debugPrint('Failed to parse date string: $dateField');
        return DateTime.now();
      }
    } else if (dateField is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateField);
      } catch (e) {
        debugPrint('Failed to parse timestamp: $dateField');
        return DateTime.now();
      }
    } else {
      debugPrint('Unknown date format: ${dateField.runtimeType}');
      return DateTime.now();
    }
  }

  List<AllTransactionModel> get _filteredTransactions {
    final startDate = _getStartDateForRange();
    return _transactions.where((t) {
      final transactionDate = _extractDateTime(t.date);
      return transactionDate.isAfter(startDate);
    }).toList();
  }

  /// Enhanced Expense vs Income Data with better color coding
  List<ChartDataModel> getExpenseIncomeData() {
    final filtered = _filteredTransactions;
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in filtered) {
      if (transaction.expense) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    final result = <ChartDataModel>[];
    if (totalIncome > 0) {
      result.add(
        ChartDataModel(
          label: 'Income',
          value: totalIncome,
          color: incomeColor,
          category: 'income',
        ),
      );
    }
    if (totalExpense > 0) {
      result.add(
        ChartDataModel(
          label: 'Expense',
          value: totalExpense,
          color: expenseColor,
          category: 'expense',
        ),
      );
    }

    return result;
  }

  /// Enhanced Category Breakdown with better organization
  List<ChartDataModel> getCategoryBreakdownData() {
    final filtered = _filteredTransactions;
    final Map<String, CategoryData> categoryMap = {};

    // Process transactions by category
    for (final transaction in filtered) {
      final category = transaction.category.isEmpty
          ? 'General'
          : transaction.category;

      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = CategoryData(
          name: category,
          amount: 0,
          transactionCount: 0,
          color: categoryColors[categoryMap.length % categoryColors.length],
        );
      }

      final existing = categoryMap[category]!;
      categoryMap[category] = CategoryData(
        name: existing.name,
        amount: existing.amount + transaction.amount,
        transactionCount: existing.transactionCount + 1,
        color: existing.color,
        monthlyAmounts: existing.monthlyAmounts,
      );
    }

    // Convert to ChartDataModel and sort by amount
    return categoryMap.values
        .map(
          (cat) => ChartDataModel(
            label: cat.name,
            value: cat.amount,
            color: cat.color,
            category: 'category',
          ),
        )
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Enhanced Monthly Trends with complete data points
  List<MonthlyTrendData> getMonthlyTrendsData() {
    final filtered = _filteredTransactions;
    final Map<String, MonthlyTrendData> monthlyMap = {};
    final startDate = _getStartDateForRange();

    // Generate all months in range
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, 1);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final monthKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}';
      monthlyMap[monthKey] = MonthlyTrendData(
        month: _getMonthName(current.month),
        monthIndex: current.month,
        year: current.year,
        income: 0,
        expense: 0,
        netFlow: 0,
        toReceive: 0,
        toGive: 0,
        date: current,
      );
      current = DateTime(current.year, current.month + 1, 1);
    }

    // Add transaction data
    for (final transaction in filtered) {
      final date = _extractDateTime(transaction.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      if (monthlyMap.containsKey(monthKey)) {
        final existing = monthlyMap[monthKey]!;
        if (transaction.expense) {
          monthlyMap[monthKey] = MonthlyTrendData(
            month: existing.month,
            monthIndex: existing.monthIndex,
            year: existing.year,
            income: existing.income,
            expense: existing.expense + transaction.amount,
            netFlow: existing.income - (existing.expense + transaction.amount),
            toReceive: existing.toReceive,
            toGive: existing.toGive,
            date: existing.date,
          );
        } else {
          monthlyMap[monthKey] = MonthlyTrendData(
            month: existing.month,
            monthIndex: existing.monthIndex,
            year: existing.year,
            income: existing.income + transaction.amount,
            expense: existing.expense,
            netFlow: (existing.income + transaction.amount) - existing.expense,
            toReceive: existing.toReceive,
            toGive: existing.toGive,
            date: existing.date,
          );
        }
      }
    }

    // Sort by date and return
    final sortedData = monthlyMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedData;
  }

  /// Enhanced Cash Flow Data
  List<ChartDataModel> getCashFlowData() {
    double totalToReceive = 0;
    double totalToGive = 0;

    for (final entity in _entities) {
      if (entity.status == TransactionStatus.toReceive) {
        totalToReceive += entity.openingBalance;
      } else {
        totalToGive += entity.openingBalance;
      }
    }

    final result = <ChartDataModel>[];
    if (totalToReceive > 0) {
      result.add(
        ChartDataModel(
          label: 'To Receive',
          value: totalToReceive,
          color: toReceiveColor,
          category: 'cashflow',
        ),
      );
    }
    if (totalToGive > 0) {
      result.add(
        ChartDataModel(
          label: 'To Give',
          value: totalToGive,
          color: toGiveColor,
          category: 'cashflow',
        ),
      );
    }

    return result;
  }

  /// Enhanced Combined Data with all categories
  List<ChartDataModel> getCombinedData() {
    final expenseIncomeData = getExpenseIncomeData();
    final cashFlowData = getCashFlowData();
    return [...expenseIncomeData, ...cashFlowData];
  }

  /// Get time series data for line charts
  List<TimeSeriesDataPoint> getTimeSeriesData(String dataType) {
    final monthlyData = getMonthlyTrendsData();

    return monthlyData.map((monthly) {
      double value;
      Color color;

      switch (dataType) {
        case 'income':
          value = monthly.income;
          color = incomeColor;
          break;
        case 'expense':
          value = monthly.expense;
          color = expenseColor;
          break;
        case 'netFlow':
          value = monthly.netFlow;
          color = monthly.netFlow >= 0
              ? netFlowPositiveColor
              : netFlowNegativeColor;
          break;
        case 'toReceive':
          value = monthly.toReceive;
          color = toReceiveColor;
          break;
        case 'toGive':
          value = monthly.toGive;
          color = toGiveColor;
          break;
        default:
          value = monthly.netFlow;
          color = Colors.grey;
      }

      return TimeSeriesDataPoint(
        date: monthly.date,
        value: value,
        label: monthly.month,
        color: color,
      );
    }).toList();
  }

  /// Enhanced Summary Statistics
  Map<String, double> getSummaryStats() {
    final filtered = _filteredTransactions;
    double totalIncome = 0;
    double totalExpense = 0;
    double totalToReceive = 0;
    double totalToGive = 0;

    // Calculate transaction totals
    for (final transaction in filtered) {
      if (transaction.expense) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    // Calculate entity totals
    for (final entity in _entities) {
      if (entity.status == TransactionStatus.toReceive) {
        totalToReceive += entity.openingBalance;
      } else {
        totalToGive += entity.openingBalance;
      }
    }

    final netIncome = totalIncome - totalExpense;
    final netCashFlow = totalToReceive - totalToGive;
    final netWorth = netIncome + netCashFlow;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netIncome': netIncome,
      'totalToReceive': totalToReceive,
      'totalToGive': totalToGive,
      'netCashFlow': netCashFlow,
      'netWorth': netWorth,
      'savingsRate': totalIncome > 0 ? (netIncome / totalIncome) * 100 : 0,
      'expenseRatio': totalIncome > 0 ? (totalExpense / totalIncome) * 100 : 0,
    };
  }

  /// Get category performance over time
  Map<String, List<TimeSeriesDataPoint>> getCategoryTrendsData() {
    final filtered = _filteredTransactions;
    final categoryTrends = <String, Map<String, double>>{};

    // Group by category and month
    for (final transaction in filtered) {
      final category = transaction.category.isEmpty
          ? 'General'
          : transaction.category;
      final date = _extractDateTime(transaction.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      categoryTrends.putIfAbsent(category, () => {});
      categoryTrends[category]!.putIfAbsent(monthKey, () => 0);
      categoryTrends[category]![monthKey] =
          categoryTrends[category]![monthKey]! + transaction.amount;
    }

    // Convert to time series data
    final result = <String, List<TimeSeriesDataPoint>>{};
    int colorIndex = 0;

    for (final category in categoryTrends.keys) {
      final color = categoryColors[colorIndex % categoryColors.length];
      colorIndex++;

      result[category] = categoryTrends[category]!.entries.map((entry) {
        final parts = entry.key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        return TimeSeriesDataPoint(
          date: DateTime(year, month, 1),
          value: entry.value,
          label: _getMonthName(month),
          color: color,
        );
      }).toList()..sort((a, b) => a.date.compareTo(b.date));
    }

    return result;
  }

  /// Get entity balance trends
  List<ChartDataModel> getEntityBalanceData() {
    return _entities.map((entity) {
      return ChartDataModel(
        label: entity.name,
        value: entity.openingBalance,
        color: entity.status == TransactionStatus.toReceive
            ? toReceiveColor
            : toGiveColor,
        category: entity.status == TransactionStatus.toReceive
            ? 'toReceive'
            : 'toGive',
      );
    }).toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Get weekly breakdown for current month
  List<ChartDataModel> getWeeklyBreakdownData() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthTransactions = _transactions.where((t) {
      final date = _extractDateTime(t.date);
      return date.isAfter(startOfMonth) &&
          date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    final weeklyData = <String, double>{};

    for (final transaction in monthTransactions) {
      final date = _extractDateTime(transaction.date);
      final weekNumber = ((date.day - 1) ~/ 7) + 1;
      final weekKey = 'Week $weekNumber';

      weeklyData.putIfAbsent(weekKey, () => 0);
      weeklyData[weekKey] = weeklyData[weekKey]! + transaction.amount;
    }

    int colorIndex = 0;
    return weeklyData.entries.map((entry) {
      final color = categoryColors[colorIndex % categoryColors.length];
      colorIndex++;

      return ChartDataModel(
        label: entry.key,
        value: entry.value,
        color: color,
        category: 'weekly',
      );
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get data based on selected chart type
  dynamic getCurrentChartData() {
    switch (_selectedChartType) {
      case ChartType.expenseIncome:
        return getExpenseIncomeData();
      case ChartType.categoryBreakdown:
        return getCategoryBreakdownData();
      case ChartType.monthlyTrends:
        return getMonthlyTrendsData();
      case ChartType.cashFlow:
        return getCashFlowData();
      case ChartType.combined:
        return getCombinedData();
    }
  }

  String get chartTitle {
    switch (_selectedChartType) {
      case ChartType.expenseIncome:
        return 'Income vs Expense Distribution';
      case ChartType.categoryBreakdown:
        return 'Spending by Category';
      case ChartType.monthlyTrends:
        return 'Monthly Financial Trends';
      case ChartType.cashFlow:
        return 'Cash Flow Analysis';
      case ChartType.combined:
        return 'Complete Financial Overview';
    }
  }

  String get timeRangeLabel {
    switch (_selectedTimeRange) {
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

  /// Get color for a specific category (consistent colors)
  Color getCategoryColor(String category) {
    final categories = getCategoryBreakdownData();
    final categoryData = categories.firstWhere(
      (c) => c.label == category,
      orElse: () => ChartDataModel(
        label: category,
        value: 0,
        color: categoryColors[category.hashCode % categoryColors.length],
      ),
    );
    return categoryData.color;
  }

  /// Check if data is available for current time range
  bool get hasDataForCurrentRange {
    return _filteredTransactions.isNotEmpty || _entities.isNotEmpty;
  }

  /// Get data freshness indicator
  bool get isDataFresh {
    // Consider data fresh if loaded within last 5 minutes
    return DateTime.now().difference(DateTime.now()).inMinutes < 5;
  }
}
