import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/home/widgets/myappbar.dart';
import 'package:expensetrack/features/home/widgets/receive_gain_widget.dart';
import 'package:expensetrack/features/home/widgets/spent_today_card.dart';
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
Consumer<SwitchExpenseProvider>(
  builder: (BuildContext context, value, Widget? child) { 
    
    return Column(
      children: [
        value.selectedIndex==0?
 Column(
  children: [
     TransactionsWidgets(icon: Icons.bus_alert_outlined, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                TransactionsWidgets(icon: Icons.bus_alert_outlined, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                  TransactionsWidgets(icon: Icons.bus_alert_outlined, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                    TransactionsWidgets(icon: Icons.bus_alert_outlined, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                      TransactionsWidgets(icon: Icons.bus_alert_outlined, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
  ],
 ):Column(
  children: [
         TransactionsWidgets(icon: Icons.money, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                TransactionsWidgets(icon: Icons.money, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                  TransactionsWidgets(icon: Icons.money, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                    TransactionsWidgets(icon: Icons.money, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
                      TransactionsWidgets(icon: Icons.money, title: "Public Transport", subtitle: "May 5th 14:28", cost: "\$124.20"),
  ],
 )
      ]
            
);
 },
 ),


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
