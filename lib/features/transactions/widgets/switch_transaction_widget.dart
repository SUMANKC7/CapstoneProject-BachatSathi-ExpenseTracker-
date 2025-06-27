
import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchTransactionWidget extends StatelessWidget {
  const SwitchTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionDataProvider>(context);
    final toggleButton = provider.income;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          toggleButton? "Income" : "Expense",
          style: TextStyle(
            fontSize: 17,
            color: toggleButton
                ? AppColors.green
                : AppColors.expenseColor,
          ),
        ),
        Switch(
          value: toggleButton,
          onChanged: (value) {
            provider.switchExpense(value);
          },
          activeColor: AppColors.green,
          inactiveThumbColor: AppColors.expenseColor,
          trackOutlineColor: WidgetStateColor.transparent,
          inactiveTrackColor: AppColors.summaryBorder,
          thumbIcon: WidgetStatePropertyAll(Icon(Icons.attach_money_outlined)),
        ),
      ],
    );
  }
}
