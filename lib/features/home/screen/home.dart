import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/screen/partyscreen.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_summary_cards.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Add refresh key to force StreamBuilder rebuild
  int _refreshKey = 0;

  // Callback method for when transactions are updated
  void _onTransactionUpdated() {
    setState(() {
      _refreshKey++;
    });

    // Optional: Show feedback
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
      appBar: const MyAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleText(title: 'Today'),
                StreamBuilder<List<AllTransactionModel>>(
                  stream: context
                      .read<AddTransactionProvider>()
                      .repository
                      .listenToTransactions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SpentTodayCard(
                        totalBalance: 0,
                        income: 0,
                        expense: 0,
                      );
                    }

                    final transactions = snapshot.data!;
                    final income = transactions
                        .where((t) => !t.expense)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final expenses = transactions
                        .where((t) => t.expense)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final totalBalance = income - expenses;

                    return SpentTodayCard(
                      totalBalance: totalBalance,
                      income: income,
                      expense: expenses,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Calculate totals from the transaction stream
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PartiesScreen()),
                    );
                  },
                  child: PartiesSummaryCards(),
                ),

                const SizedBox(height: 20),
                const TitleText(title: "This month"),
                const SizedBox(height: 10),
                const IncomeExpenseToggle(
                  firstIndex: 'Income',
                  secondIndex: 'Expense',
                ),
                const SizedBox(height: 10),

                // Transaction list with toggle filter
                Consumer2<AddTransactionProvider, SwitchExpenseProvider>(
                  builder: (context, transactionProvider, switchProvider, _) {
                    return StreamBuilder<List<AllTransactionModel>>(
                      key: ValueKey('transactions_$_refreshKey'),
                      stream: transactionProvider.repository
                          .listenToTransactions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState(switchProvider.selectedIndex);
                        }

                        final transactions = snapshot.data!;

                        // Filter based on toggle
                        final filteredTransactions = transactions.where((
                          transaction,
                        ) {
                          return switchProvider.selectedIndex == 0
                              ? !transaction
                                    .expense // Show Income
                              : transaction.expense; // Show Expense
                        }).toList();

                        if (filteredTransactions.isEmpty) {
                          return _buildEmptyState(switchProvider.selectedIndex);
                        }

                        return Column(
                          children: [
                            // Show count of transactions
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${filteredTransactions.length} ${switchProvider.selectedIndex == 0 ? "Income" : "Expense"} records",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Tap to edit",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTransactions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final transaction = filteredTransactions[index];
                                return TransactionsWidgets(
                                  icon: transaction.expense
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  title: transaction.title,
                                  subtitle: DateFormat.yMMMd().format(
                                    transaction.date,
                                  ),
                                  cost:
                                      "Rs. ${NumberFormat("#,##0.00").format(transaction.amount)}",
                                  amountColor: transaction.expense
                                      ? Colors.red
                                      : Colors.green,
                                  transaction:
                                      transaction, // Pass the transaction model
                                  onTransactionUpdated:
                                      _onTransactionUpdated, // Pass the callback
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(int selectedIndex) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              selectedIndex == 0 ? Icons.trending_up : Icons.trending_down,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No ${selectedIndex == 0 ? "Income" : "Expense"} Records",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start by adding your first ${selectedIndex == 0 ? "income" : "expense"} transaction.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Method for pull-to-refresh
  Future<void> _refreshData() async {
    setState(() {
      _refreshKey++;
    });

    // Add a small delay to show refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
