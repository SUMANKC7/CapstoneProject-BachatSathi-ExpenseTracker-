import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/widgets/expense_tile.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              TitleText(title: 'Today'),

              SpentTodayCard(),
              
              Row(
                spacing: 15,
                children: [
                  RecieveGive(
                    amount: "\$100",
                    account: 'To Receive',
                    onClicked: () {},
                  ),
                  RecieveGive(
                    amount: "\$200",
                    account: "To Pay",
                    onClicked: () {},
                  ),
                ],
              ),

              TitleText(title: "This month"),

              const IncomeExpenseToggle(),

              // ExpenseTile(
              //   title: 'Income',
              //   amount: '\$6000',
              //   image: 'assets/images/pic.jpg',
              // ),

              // ExpenseTile(
              //   title: 'Expenses',
              //   amount: '\$3200',
              //   image: 'assets/images/expense.jpg',
              // ),
              SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
