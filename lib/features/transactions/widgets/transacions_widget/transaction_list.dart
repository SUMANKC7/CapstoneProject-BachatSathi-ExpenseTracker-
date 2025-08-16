import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/widgets/transacions_widget/transaction_tile.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final ValueNotifier<String> selectedCategoryNotifier;
  final ValueNotifier<String> selectedSortNotifier;
  final List<AllTransactionModel> transactions;
  final VoidCallback?
  onTransactionUpdated; // Callback for when transaction is updated

  const TransactionList({
    super.key,
    required this.selectedCategoryNotifier,
    required this.selectedSortNotifier,
    required this.transactions,
    this.onTransactionUpdated,
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
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return TransactionTile(
                  transaction: filteredTransactions[index],
                  onTransactionUpdated: onTransactionUpdated,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No transactions match your current filters",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
