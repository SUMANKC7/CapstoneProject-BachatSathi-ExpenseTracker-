import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
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

              Row(
                children: [
                  RecieveGive(
                    amount: "Rs.100",
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
                  const SizedBox(width: 15),
                  RecieveGive(
                    amount: "Rs.200",
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
              ),

              const SizedBox(height: 20),
              const TitleText(title: "This month"),
              const SizedBox(height: 10),
              const IncomeExpenseToggle(
                firstIndex: 'Income',
                secondIndex: 'Expense',
              ),
              const SizedBox(height: 10),

              Consumer2<PartiesProvider, SwitchExpenseProvider>(
                builder: (context, partiesProvider, switchProvider, _) {
                  // Filter based on toggle
                  final filteredParties = partiesProvider.parties.where((
                    party,
                  ) {
                    return switchProvider.selectedIndex == 0
                        ? party
                              .toReceive // Show "To Receive"
                        : !party.toReceive; // Show "To Pay"
                  }).toList();

                  if (filteredParties.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          "No ${switchProvider.selectedIndex == 0 ? "To Receive" : "To Pay"} records found.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredParties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
                      return TransactionsWidgets(
                        icon: party.toReceive
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        title: party.name,
                        subtitle: DateFormat.yMMMd().format(party.date),
                        cost: "Rs. ${party.openingBalance}",
                        amountColor: party.toReceive
                            ? Colors.green
                            : Colors.red,
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
