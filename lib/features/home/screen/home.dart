import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/entity/screen/addentity.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
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
              /// Today’s section
              const TitleText(title: 'Today'),
              const SpentTodayCard(),
              const SizedBox(height: 20),

              Row(
                children: [
                  RecieveGive(
                    amount: "Rs.100",
                    account: 'To Receive',
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEntity(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  RecieveGive(
                    amount: "Rs.200",
                    account: "To Pay",
                    onClicked: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const TitleText(title: "This month"),
              const SizedBox(height: 10),

              /// Income / Expense toggle
              const IncomeExpenseToggle(
                firstIndex: 'Income',
                secondIndex: 'Expense',
              ),
              const SizedBox(height: 10),

              /// Transactions List like in Transactions Screen
              Consumer2<SwitchExpenseProvider, TransactionDataProvider>(
                builder: (context, switchProvider, txProvider, _) {
                  // Filtered transactions based on toggle
                  final filteredTransactions = txProvider.transactions.where((
                    tx,
                  ) {
                    return switchProvider.selectedIndex == 0
                        ? !tx
                              .expense // Income only
                        : tx.expense; // Expense only
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
                      final tx = filteredTransactions[index];
                      return TransactionsWidgets(
                        icon: tx.expense
                            ? Icons
                                  .arrow_upward // Expense icon
                            : Icons.arrow_downward, // Income icon
                        title: tx.title,
                        subtitle: Provider.of<TransactionDataProvider>(
                          context,
                          listen: false,
                        ).formatDate(tx.date),

                        cost: "Rs. ${tx.amount}",
                        amountColor: tx.expense ? Colors.red : Colors.green,
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
