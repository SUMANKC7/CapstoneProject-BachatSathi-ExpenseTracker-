
import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddDates extends StatelessWidget {
  const AddDates({super.key});

  @override
  Widget build(BuildContext context) {
final addTransactionProvider = Provider.of<TransactionDataProvider>(context);

    return ElevatedButton(
      onPressed: () {
        
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.summaryBorder,
        fixedSize: Size(double.maxFinite, 52),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          addTransactionProvider.formattedDate,
          style: TextStyle(fontSize: 17, color: AppColors.transactiontype),
        ),
      ),
    );
  }
}
