import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddDates extends StatelessWidget {
  const AddDates({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionDataProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () {
            provider.pickDate(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label Text ("Date")
                Text(
                  "Date",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(
                  height: 4,
                ), // Small spacing between label and value
                // Date Row (Icon + Selected Date)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.formattedSelectedDate,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
