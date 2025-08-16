import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/widgets/transacions_widget/add_button.dart';
import 'package:flutter/material.dart';

class FixedBottomButtons extends StatelessWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const FixedBottomButtons({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AddButton(
                color: AppColors.addIncome,
                icon: Icons.add,
                title: "Add Income",
                onPressed: onAddIncome,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AddButton(
                color: AppColors.addExpensee,
                icon: Icons.remove,
                title: "Add Expense",
                onPressed: onAddExpense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
