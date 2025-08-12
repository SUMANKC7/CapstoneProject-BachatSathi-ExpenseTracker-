import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/widgets/add_transaction_bottomsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- MAIN SCREEN WIDGET ---
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // State for the category filter
  final ValueNotifier<String> _selectedCategoryFilter = ValueNotifier('all');
  // TODO: Add state for date filters (e.g., 'This month', 'Last 7 days')
  final ValueNotifier<String> _selectedDateFilter = ValueNotifier('This month');

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
    // The main stream of transactions from Firestore
    final Stream<QuerySnapshot> txStream = FirebaseFirestore.instance
        .collection('Transactions')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F9,
      ), // A soft, clean background color
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: txStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionView(context, docs);
        },
      ),
    );
  }

  // --- UI BUILDING METHODS ---

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
    List<QueryDocumentSnapshot> docs,
  ) {
    // Calculate summaries based on the full list of documents
    final double income = _calculateTotal(docs, isExpense: false);
    final double expense = _calculateTotal(docs, isExpense: true);
    final double balance = income - expense;

    // Get unique categories for the filter button
    final categories = _extractCategories(docs);

    return Column(
      children: [
        // This part is scrollable
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
                income: income,
                expense: expense,
                balance: balance,
              ),
              const SizedBox(height: 24),
              _TransactionListHeader(
                categories: categories,
                selectedCategoryNotifier: _selectedCategoryFilter,
              ),
              const SizedBox(height: 12),
              _TransactionList(
                docs: docs,
                selectedCategoryNotifier: _selectedCategoryFilter,
              ),
              const SizedBox(height: 120), // Padding for the bottom buttons
            ],
          ),
        ),
        // This part is fixed at the bottom
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
          ],
        ),
      ),
    );
  }

  // --- HELPER & LOGIC METHODS ---

  double _calculateTotal(
    List<QueryDocumentSnapshot> docs, {
    required bool isExpense,
  }) {
    return docs
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          // Your logic might use 'expense' or 'isIncome'
          bool docIsExpense = data.containsKey('expense')
              ? (data['expense'] as bool)
              : !(data.containsKey('income')
                    ? (data['income'] as bool)
                    : false);
          return docIsExpense == isExpense;
        })
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final amount = data['amount'];
          if (amount is num) return amount.toDouble();
          if (amount is String) return double.tryParse(amount) ?? 0.0;
          return 0.0;
        })
        .fold(0.0, (sum, amount) => sum + amount);
  }

  Set<String> _extractCategories(List<QueryDocumentSnapshot> docs) {
    final categories = <String>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category']?.toString();
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    return categories;
  }
}

// --- REUSABLE & MODULAR WIDGETS ---

// A consistent header style for sections
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

// Date filter chips
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
                    // TODO: Add logic to filter transactions by date
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

// Summary cards section
class _SummarySection extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const _SummarySection({
    required this.income,
    required this.expense,
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
                amount: income,
                color: AppColors.green,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expenses',
                amount: expense,
                color: AppColors.expenseColor!,
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(title: 'Balance', amount: balance, isLarge: true),
      ],
    );
  }
}

// A single summary card
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
      symbol: '\$',
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

// The header for the transaction list with the filter button
class _TransactionListHeader extends StatelessWidget {
  final Set<String> categories;
  final ValueNotifier<String> selectedCategoryNotifier;

  const _TransactionListHeader({
    required this.categories,
    required this.selectedCategoryNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _SectionHeader(title: "Transactions"),
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
                // 'All' option first
                final allItems = <PopupMenuEntry<String>>[
                  _buildPopupMenuItem(
                    context: context,
                    value: 'all',
                    label: 'All Categories',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: selectedCategory == 'all',
                  ),
                  if (categories.isNotEmpty) const PopupMenuDivider(),
                ];

                // Add other categories
                final categoryItems = categories
                    .map(
                      (category) => _buildPopupMenuItem(
                        context: context,
                        value: category,
                        label: category,
                        icon: Icons.label_outline_rounded,
                        isSelected: selectedCategory == category,
                      ),
                    )
                    .toList();

                return [...allItems, ...categoryItems];
              },
            );
          },
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

// The main list of transactions
class _TransactionList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final ValueNotifier<String> selectedCategoryNotifier;

  const _TransactionList({
    required this.docs,
    required this.selectedCategoryNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedCategoryNotifier,
      builder: (context, selectedCategory, child) {
        final filteredDocs = selectedCategory == 'all'
            ? docs
            : docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return (data['category']?.toString() ?? '') == selectedCategory;
              }).toList();

        if (filteredDocs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No transactions found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (selectedCategory != 'all')
                  Text(
                    "for category '$selectedCategory'",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            return _TransactionTile(data: doc.data() as Map<String, dynamic>);
          },
        );
      },
    );
  }
}

// A single transaction tile
class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TransactionTile({required this.data});

  Map<String, dynamic> _parseTransactionData() {
    bool isExpense = data.containsKey('expense')
        ? (data['expense'] as bool)
        : !(data.containsKey('income') ? (data['income'] as bool) : true);
    final isIncome = !isExpense;

    final title = data['title']?.toString() ?? 'Untitled';

    String dateText = '';
    if (data['date'] is Timestamp) {
      dateText = DateFormat.yMMMd().format(
        (data['date'] as Timestamp).toDate(),
      );
    } else if (data['date'] is String) {
      final parsed = DateTime.tryParse(data['date']);
      if (parsed != null) dateText = DateFormat.yMMMd().format(parsed);
    }

    double amount = 0.0;
    final amtRaw = data['amount'];
    if (amtRaw is num) {
      amount = amtRaw.toDouble();
    } else if (amtRaw is String) {
      amount = double.tryParse(amtRaw) ?? 0.0;
    }

    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final amountColor = isIncome ? AppColors.green : AppColors.expenseColor;
    final costText =
        "${isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)}";

    return {
      'icon': icon,
      'title': title,
      'dateText': dateText,
      'cost': costText,
      'amountColor': amountColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final transaction = _parseTransactionData();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: (transaction['amountColor'] as Color).withOpacity(
            0.1,
          ),
          child: Icon(
            transaction['icon'],
            color: transaction['amountColor'],
            size: 24,
          ),
        ),
        title: Text(
          transaction['title'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          transaction['dateText'],
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Text(
          transaction['cost'],
          style: TextStyle(
            color: transaction['amountColor'],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// The fixed Add Income/Expense buttons at the bottom
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

// A single styled button for adding income or expense
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
