
import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/transactions/widgets/add_transaction_bottomsheet.dart';
import 'package:expensetrack/features/transactions/widgets/filter_widget.dart';
import 'package:expensetrack/features/transactions/widgets/summary_widget.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        centerTitle: true,
        title: Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [AddTransactionBottomsheet(), SizedBox(width: 6)],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              TitleText(title: "Filters"),

              //For the time Filtering
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 10,
                spacing: 13,
                children: [
                  FilterTime(filterdate: "Last 7 days"),
                  FilterTime(filterdate: "This month"),
                  FilterTime(filterdate: "Last month"),
                  FilterTime(filterdate: "Custom"),
                ],
              ),
              TitleText(title: "Summary"),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Summary(
                    title: 'Income',
                    amount: '\$2,500',
                    size: size.width * 0.855 / 2.0,
                  ),
                  Summary(
                    title: "Expenses",
                    amount: "\$1,200",
                    size: size.width * 0.855 / 2.0,
                  ),
                ],
              ),
              Summary(
                title: "Balance",
                amount: "\$1,300",
                size: size.width * 0.9,
              ),
              TitleText(title: "Transactions"),
              TransactionsWidgets(
                icon: CupertinoIcons.shopping_cart,
                title: "Supermarket",
                subtitle: "Groceries",
                cost: "-\$85.50",
              ),
              TransactionsWidgets(
                icon: CupertinoIcons.briefcase,
                title: "Tech Solutions Inc.",
                subtitle: "Salary",
                cost: "+\$2,500",
              ),
              TransactionsWidgets(
                icon: Icons.restaurant_outlined,
                title: "Cafe Bristro",
                subtitle: "Dining",
                cost: "-\$45.75",
              ),
              TransactionsWidgets(
                icon: Icons.lightbulb_outline_rounded,
                title: "Power Company",
                subtitle: "Utilities",
                cost: "-\$120.00",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
