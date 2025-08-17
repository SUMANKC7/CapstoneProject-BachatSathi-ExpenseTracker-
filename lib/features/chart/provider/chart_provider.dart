import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';

class MonthlyData {
  final String month;
  final double income;
  final double expense;
  final double netFlow;
  final double toReceive;
  final double toGive;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
    required this.netFlow,
    required this.toReceive,
    required this.toGive,
  });
}

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

  // Chart Colors
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFf44336);
  static const Color toReceiveColor = Color(0xFF2196F3);
  static const Color toGiveColor = Color(0xFFFF9800);
  static const List<Color> categoryColors = [
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFCDDC39),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
  ];

  void setChartType(ChartType type) {
    _selectedChartType = type;
    notifyListeners();
  }

  void setTimeRange(ChartTimeRange range) {
    _selectedTimeRange = range;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load both transactions and entities simultaneously
      final results = await Future.wait([_loadTransactions(), _loadEntities()]);

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
      // Try to get fresh data, fallback to cached if needed
      final snapshot = await _transactionRepo.listenToTransactions().first;
      _transactions = snapshot;
    } catch (e) {
      // Fallback to cached data
      _transactions = await _transactionRepo.getCachedTransactions();
      debugPrint('Using cached transactions: $e');
    }
  }

  Future<void> _loadEntities() async {
    try {
      _entities = await _entityRepo.fetchEntities();
    } catch (e) {
      // Fallback to cached data
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
        return DateTime(2000); // Very old date to include all
    }
  }

  // Helper method to safely extract DateTime from various formats
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
      // Handle milliseconds timestamp
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

  // Expense vs Income Pie Chart Data
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

    return [
      ChartDataModel(label: 'Income', value: totalIncome, color: incomeColor),
      ChartDataModel(
        label: 'Expense',
        value: totalExpense,
        color: expenseColor,
      ),
    ];
  }

  // Category Breakdown Data
  List<ChartDataModel> getCategoryBreakdownData() {
    final filtered = _filteredTransactions;
    final Map<String, double> categoryTotals = {};

    for (final transaction in filtered) {
      final category = transaction.category.isEmpty
          ? 'General'
          : transaction.category;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + transaction.amount;
    }

    int colorIndex = 0;
    return categoryTotals.entries.map((entry) {
      final color = categoryColors[colorIndex % categoryColors.length];
      colorIndex++;
      return ChartDataModel(label: entry.key, value: entry.value, color: color);
    }).toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  // Monthly Trends Data
  List<MonthlyData> getMonthlyTrendsData() {
    final filtered = _filteredTransactions;
    final Map<String, MonthlyData> monthlyData = {};

    // Initialize months
    for (final transaction in filtered) {
      final date = _extractDateTime(transaction.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = MonthlyData(
          month: _getMonthName(date.month),
          income: 0,
          expense: 0,
          netFlow: 0,
          toReceive: 0,
          toGive: 0,
        );
      }
    }

    // Add transaction data
    for (final transaction in filtered) {
      final date = _extractDateTime(transaction.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final existing = monthlyData[monthKey]!;

      if (transaction.expense) {
        monthlyData[monthKey] = MonthlyData(
          month: existing.month,
          income: existing.income,
          expense: existing.expense + transaction.amount,
          netFlow: existing.income - (existing.expense + transaction.amount),
          toReceive: existing.toReceive,
          toGive: existing.toGive,
        );
      } else {
        monthlyData[monthKey] = MonthlyData(
          month: existing.month,
          income: existing.income + transaction.amount,
          expense: existing.expense,
          netFlow: (existing.income + transaction.amount) - existing.expense,
          toReceive: existing.toReceive,
          toGive: existing.toGive,
        );
      }
    }

    // Add entity data (opening balances)
    for (final entity in _entities) {
      // Assuming entities have a creation date, you might need to adjust this
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      if (monthlyData.containsKey(monthKey)) {
        final existing = monthlyData[monthKey]!;
        if (entity.status == TransactionStatus.toReceive) {
          monthlyData[monthKey] = MonthlyData(
            month: existing.month,
            income: existing.income,
            expense: existing.expense,
            netFlow: existing.netFlow,
            toReceive: existing.toReceive + entity.openingBalance,
            toGive: existing.toGive,
          );
        } else {
          monthlyData[monthKey] = MonthlyData(
            month: existing.month,
            income: existing.income,
            expense: existing.expense,
            netFlow: existing.netFlow,
            toReceive: existing.toReceive,
            toGive: existing.toGive + entity.openingBalance,
          );
        }
      }
    }

    return monthlyData.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // Cash Flow Data (Entities)
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

    return [
      ChartDataModel(
        label: 'To Receive',
        value: totalToReceive,
        color: toReceiveColor,
      ),
      ChartDataModel(label: 'To Give', value: totalToGive, color: toGiveColor),
    ];
  }

  // Combined Overview Data
  List<ChartDataModel> getCombinedData() {
    final expenseIncomeData = getExpenseIncomeData();
    final cashFlowData = getCashFlowData();

    return [...expenseIncomeData, ...cashFlowData];
  }

  // Summary Statistics
  Map<String, double> getSummaryStats() {
    final filtered = _filteredTransactions;
    double totalIncome = 0;
    double totalExpense = 0;
    double totalToReceive = 0;
    double totalToGive = 0;

    for (final transaction in filtered) {
      if (transaction.expense) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    for (final entity in _entities) {
      if (entity.status == TransactionStatus.toReceive) {
        totalToReceive += entity.openingBalance;
      } else {
        totalToGive += entity.openingBalance;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netIncome': totalIncome - totalExpense,
      'totalToReceive': totalToReceive,
      'totalToGive': totalToGive,
      'netCashFlow': totalToReceive - totalToGive,
      'netWorth': (totalIncome - totalExpense) + (totalToReceive - totalToGive),
    };
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

  // Get data based on selected chart type
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
        return 'Income vs Expense';
      case ChartType.categoryBreakdown:
        return 'Category Breakdown';
      case ChartType.monthlyTrends:
        return 'Monthly Trends';
      case ChartType.cashFlow:
        return 'Cash Flow (To Receive/Give)';
      case ChartType.combined:
        return 'Financial Overview';
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
}
