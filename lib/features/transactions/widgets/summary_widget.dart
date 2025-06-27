import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  final String title;
  final String amount;
  final double size;
  const Summary({
    super.key,
    required this.title,
    required this.amount,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.summaryBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.filterTextColor, fontSize: 15),
          ),
          Text(
            amount,
            style: TextStyle(color: AppColors.textTitleColor, fontSize: 24),
          ),
        ],
      ),
    );
  }
}