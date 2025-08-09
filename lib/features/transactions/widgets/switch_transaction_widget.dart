import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchTransactionWidget extends StatelessWidget {
  const SwitchTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionDataProvider>(
      builder: (context, provider, _) {
        // If isExpense is true → show Expense, else → show Income
        final isIncomeSelected = !provider.isExpense;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isIncomeSelected ? "Income" : "Expense",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isIncomeSelected
                    ? AppColors.green
                    : AppColors.expenseColor,
              ),
            ),
            Switch(
              value: isIncomeSelected,
              onChanged: (value) {
                provider.setTransactionType(!value);
                // Flip value because provider tracks expense
              },
              activeColor: AppColors.green,
              inactiveThumbColor: AppColors.expenseColor,
              inactiveTrackColor: AppColors.summaryBorder,
              trackOutlineColor: WidgetStateColor.transparent,
              thumbIcon: const WidgetStatePropertyAll(
                Icon(Icons.attach_money_outlined),
              ),
            ),
          ],
        );
      },
    );
  }
}
