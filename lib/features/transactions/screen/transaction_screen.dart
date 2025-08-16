import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/widgets/add_transaction_bottomsheet.dart';
import 'package:expensetrack/features/transactions/widgets/date_filters.dart';
import 'package:expensetrack/features/transactions/widgets/summary_section.dart';
import 'package:expensetrack/features/transactions/widgets/transacions_widget/fixed_bottom_buttons.dart';
import 'package:expensetrack/features/transactions/widgets/transacions_widget/transaction_list.dart';
import 'package:expensetrack/features/transactions/widgets/transacions_widget/transaction_list_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ValueNotifier<String> _selectedCategoryFilter = ValueNotifier('all');
  final ValueNotifier<String> _selectedDateFilter = ValueNotifier('This month');
  final ValueNotifier<String> _selectedSortFilter = ValueNotifier('latest');

  // Add a key to force rebuild of StreamBuilder when needed
  int _refreshKey = 0;

  void _openBottomSheet(BuildContext context, String name, int key) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddTransactionBottomsheet(transactionName: name, itemkey: key),
    );
  }

  // Add this callback method for when transactions are updated/deleted
  void _onTransactionUpdated() {
    setState(() {
      _refreshKey++;
    });

    // Optional: Show a subtle feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction updated successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(),
      body: StreamBuilder<List<AllTransactionModel>>(
        key: ValueKey(
          _refreshKey,
        ), // Use the refresh key to rebuild when needed
        stream: context
            .read<AddTransactionProvider>()
            .repository
            .listenToTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionView(context, transactions);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.arrow_back, color: Colors.black87),
      centerTitle: true,
      title: const Text(
        "Transactions",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black87,
        ),
      ),
      actions: [
        // Add refresh button to manually refresh data
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black87),
          onPressed: _onTransactionUpdated,
          tooltip: 'Refresh transactions',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTransactionView(
    BuildContext context,
    List<AllTransactionModel> transactions,
  ) {
    final double income = _calculateIncome(transactions);
    final double expenses = _calculateExpenses(transactions);
    final double balance = income - expenses;
    final categories = _extractCategories(transactions);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).primaryColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics:
                  const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
              children: [
                const SizedBox(height: 16),
                const SectionHeader(title: "Date Filters"),
                const SizedBox(height: 12),
                DateFilterSection(selectedFilter: _selectedDateFilter),
                const SizedBox(height: 24),
                const SectionHeader(title: "Summary"),
                const SizedBox(height: 12),
                SummarySection(
                  toReceive: income,
                  toGive: expenses,
                  balance: balance,
                ),
                const SizedBox(height: 24),
                TransactionListHeader(
                  categories: categories,
                  selectedCategoryNotifier: _selectedCategoryFilter,
                  selectedSortNotifier: _selectedSortFilter,
                ),
                const SizedBox(height: 12),
                TransactionList(
                  selectedCategoryNotifier: _selectedCategoryFilter,
                  selectedSortNotifier: _selectedSortFilter,
                  transactions: transactions,
                  onTransactionUpdated:
                      _onTransactionUpdated, // Pass the callback
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        FixedBottomButtons(
          onAddIncome: () => _openBottomSheet(context, 'Income', 0),
          onAddExpense: () => _openBottomSheet(context, 'Expense', 1),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Transactions Found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Get started by adding your first income or expense transaction.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.add_circle,
                    label: 'Add Income',
                    color: Colors.green,
                    onTap: () => _openBottomSheet(context, 'Income', 0),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActionButton(
                    icon: Icons.remove_circle,
                    label: 'Add Expense',
                    color: Colors.red,
                    onTap: () => _openBottomSheet(context, 'Expense', 1),
                  ),
                ],
              ),
              const Spacer(),
              FixedBottomButtons(
                onAddIncome: () => _openBottomSheet(context, 'Income', 0),
                onAddExpense: () => _openBottomSheet(context, 'Expense', 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red[400],
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Something Went Wrong",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    error.length > 100
                        ? '${error.substring(0, 100)}...'
                        : error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this method for pull-to-refresh functionality
  Future<void> _refreshData() async {
    setState(() {
      _refreshKey++;
    });

    // Add a small delay to show refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  double _calculateIncome(List<AllTransactionModel> transactions) {
    return transactions
        .where((transaction) => !transaction.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculateExpenses(List<AllTransactionModel> transactions) {
    return transactions
        .where((transaction) => transaction.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Set<String> _extractCategories(List<AllTransactionModel> transactions) {
    final categories = <String>{};
    for (final transaction in transactions) {
      if (transaction.expense) {
        categories.add('Expense');
      } else {
        categories.add('Income');
      }
    }
    return categories;
  }

  @override
  void dispose() {
    _selectedCategoryFilter.dispose();
    _selectedDateFilter.dispose();
    _selectedSortFilter.dispose();
    super.dispose();
  }
}
