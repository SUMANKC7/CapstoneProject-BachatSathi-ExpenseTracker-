import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/widgets/add_transaction_bottomsheet.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _openBottomSheet(BuildContext context, String name, int key) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddTransactionBottomsheet(transactionName: name, itemkey: key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(),
      body: StreamBuilder<List<AllTransactionModel>>(
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 16),
              const _SectionHeader(title: "Date Filters"),
              const SizedBox(height: 12),
              _DateFilterSection(selectedFilter: _selectedDateFilter),
              const SizedBox(height: 24),
              const _SectionHeader(title: "Summary"),
              const SizedBox(height: 12),
              _SummarySection(
                toReceive: income,
                toGive: expenses,
                balance: balance,
              ),
              const SizedBox(height: 24),
              _TransactionListHeader(
                categories: categories,
                selectedCategoryNotifier: _selectedCategoryFilter,
                selectedSortNotifier: _selectedSortFilter,
              ),
              const SizedBox(height: 12),
              _TransactionList(
                selectedCategoryNotifier: _selectedCategoryFilter,
                selectedSortNotifier: _selectedSortFilter,
                transactions: transactions,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        _FixedBottomButtons(
          onAddIncome: () => _openBottomSheet(context, 'Income', 0),
          onAddExpense: () => _openBottomSheet(context, 'Expense', 1),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No Transactions Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Get started by adding a new income or expense.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Spacer(),
          _FixedBottomButtons(
            onAddIncome: () => _openBottomSheet(context, 'Income', 0),
            onAddExpense: () => _openBottomSheet(context, 'Expense', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              "Something Went Wrong",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the stream
                context
                    .read<AddTransactionProvider>()
                    .repository
                    .listenToTransactions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _DateFilterSection extends StatelessWidget {
  final ValueNotifier<String> selectedFilter;
  const _DateFilterSection({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final filters = ["Last 7 days", "This month", "Last month", "Custom"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return ValueListenableBuilder<String>(
            valueListenable: selectedFilter,
            builder: (context, value, child) {
              final isSelected = value == filter;
              return ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.backgroundColor
                        : AppColors.navBarSelected,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedFilter.value = filter;
                  }
                },
                backgroundColor: AppColors.softTeal,
                selectedColor: Colors.blue.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.summaryBorder,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.summaryBorder.withOpacity(0.3),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double toReceive;
  final double toGive;
  final double balance;

  const _SummarySection({
    required this.toReceive,
    required this.toGive,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Income',
                amount: toReceive,
                color: AppColors.green,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expenses',
                amount: toGive,
                color: AppColors.expenseColor!,
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(title: 'Net Balance', amount: balance, isLarge: true),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color? color;
  final IconData? icon;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.amount,
    this.color,
    this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: isLarge ? 26 : 20,
              fontWeight: FontWeight.bold,
              color: isLarge
                  ? (amount < 0 ? AppColors.expenseColor : Colors.black87)
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionListHeader extends StatelessWidget {
  final Set<String> categories;
  final ValueNotifier<String> selectedCategoryNotifier;
  final ValueNotifier<String> selectedSortNotifier;

  const _TransactionListHeader({
    required this.categories,
    required this.selectedCategoryNotifier,
    required this.selectedSortNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _SectionHeader(title: "Transactions"),
        Row(
          children: [
            if (categories.isNotEmpty)
              ValueListenableBuilder<String>(
                valueListenable: selectedCategoryNotifier,
                builder: (context, selectedCategory, child) {
                  return PopupMenuButton<String>(
                    onSelected: (String category) {
                      selectedCategoryNotifier.value = category;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            category == 'all'
                                ? 'Showing all transactions'
                                : 'Filtering by: $category',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.textBlack,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Filter by category',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (BuildContext context) {
                      return [
                        _buildPopupMenuItem(
                          context: context,
                          value: 'all',
                          label: 'All Transactions',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: selectedCategory == 'all',
                        ),
                        ...categories.map(
                          (category) => _buildPopupMenuItem(
                            context: context,
                            value: category,
                            label: category,
                            icon: category == 'Income'
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            isSelected: selectedCategory == category,
                          ),
                        ),
                      ];
                    },
                  );
                },
              ),
            const SizedBox(width: 8),
            ValueListenableBuilder<String>(
              valueListenable: selectedSortNotifier,
              builder: (context, selectedSort, child) {
                return PopupMenuButton<String>(
                  onSelected: (String sortOption) {
                    selectedSortNotifier.value = sortOption;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sorting by: $sortOption'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: AppColors.textBlack,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Sort transactions',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      _buildPopupMenuItem(
                        context: context,
                        value: 'latest',
                        label: 'Latest First',
                        icon: Icons.access_time_rounded,
                        isSelected: selectedSort == 'latest',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'high_to_low',
                        label: 'Amount High → Low',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: selectedSort == 'high_to_low',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'low_to_high',
                        label: 'Amount Low → High',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: selectedSort == 'low_to_high',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'name_az',
                        label: 'Name A → Z',
                        icon: Icons.sort_by_alpha_rounded,
                        isSelected: selectedSort == 'name_az',
                      ),
                    ];
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.summaryBorder : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.summaryBorder : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final ValueNotifier<String> selectedCategoryNotifier;
  final ValueNotifier<String> selectedSortNotifier;
  final List<AllTransactionModel> transactions;

  const _TransactionList({
    required this.selectedCategoryNotifier,
    required this.selectedSortNotifier,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedCategoryNotifier,
      builder: (context, selectedCategory, _) {
        return ValueListenableBuilder<String>(
          valueListenable: selectedSortNotifier,
          builder: (context, selectedSort, _) {
            List<AllTransactionModel> filteredTransactions =
                selectedCategory == 'all'
                ? transactions
                : transactions.where((transaction) {
                    final category = transaction.expense ? 'Expense' : 'Income';
                    return category == selectedCategory;
                  }).toList();

            filteredTransactions.sort((a, b) {
              if (selectedSort == 'latest') {
                return b.date.compareTo(a.date);
              } else if (selectedSort == 'high_to_low') {
                return b.amount.compareTo(a.amount);
              } else if (selectedSort == 'low_to_high') {
                return a.amount.compareTo(b.amount);
              } else if (selectedSort == 'name_az') {
                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
              }
              return 0;
            });

            if (filteredTransactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "No transactions found for selected filters",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _TransactionTile(
                  transaction: filteredTransactions[index],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AllTransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.expense;
    final icon = isExpense
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final amountColor = isExpense ? AppColors.expenseColor : AppColors.green;
    final costText =
        "${isExpense ? '-' : '+'}Rs. ${NumberFormat("#,##0.00").format(transaction.amount)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: amountColor?.withOpacity(0.1),
          child: Icon(icon, color: amountColor, size: 24),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMd().format(transaction.date),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (transaction.category.isNotEmpty)
              Text(
                transaction.category,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              costText,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              isExpense ? 'Expense' : 'Income',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedBottomButtons extends StatelessWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _FixedBottomButtons({
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _AddButton(
                color: AppColors.addIncome,
                icon: Icons.add,
                title: "Add Income",
                onPressed: onAddIncome,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AddButton(
                color: AppColors.addExpensee,
                icon: Icons.remove,
                title: "Add Expense",
                onPressed: onAddExpense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _AddButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
