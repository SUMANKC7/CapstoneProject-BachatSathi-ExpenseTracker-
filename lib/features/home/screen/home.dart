import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/screen/partyscreen.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleText(title: 'Today'),
              const SpentTodayCard(),
              const SizedBox(height: 20),

              // Calculate totals from the transaction stream
              StreamBuilder<List<AllTransactionModel>>(
                stream: context
                    .read<AddTransactionProvider>()
                    .repository
                    .listenToTransactions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      children: [
                        RecieveGive(
                          amount: "Rs.0",
                          account: 'To Receive',
                          onClicked: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartiesScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 15),
                        RecieveGive(
                          amount: "Rs.0",
                          account: "To Pay",
                          onClicked: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartiesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  final transactions = snapshot.data!;
                  final income = transactions
                      .where((t) => !t.expense)
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final expenses = transactions
                      .where((t) => t.expense)
                      .fold(0.0, (sum, t) => sum + t.amount);

                  return Row(
                    children: [
                      RecieveGive(
                        amount: "Rs.${income.toStringAsFixed(2)}",
                        account: 'Income',
                        onClicked: () {
                          // Navigate to income transactions if needed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PartiesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      RecieveGive(
                        amount: "Rs.${expenses.toStringAsFixed(2)}",
                        account: "Expenses",
                        onClicked: () {
                          // Navigate to expense transactions if needed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PartiesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
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
                    stream: transactionProvider.repository
                        .listenToTransactions(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              "No ${switchProvider.selectedIndex == 0 ? "Income" : "Expense"} records found.",
                              style: TextStyle(color: Colors.grey.shade600),
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
                                "Rs. ${transaction.amount.toStringAsFixed(2)}",
                            amountColor: transaction.expense
                                ? Colors.red
                                : Colors.green,
                          );
                        },
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
    );
  }
}
