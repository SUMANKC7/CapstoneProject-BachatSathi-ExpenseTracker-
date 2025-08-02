import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class TransactionsWidgets extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String cost;
  const TransactionsWidgets({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          height: 60,
          width: 60,
          // height: size.height * 0.06,
          // width: size.width * 0.13,
          constraints: BoxConstraints(minWidth: 50),

          decoration: BoxDecoration(
            color: AppColors.filterColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, size: 27)),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.filterTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.transactiontype,
        ),
      ),
      trailing: Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          cost,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.filterTextColor,
          ),
        ),
      ),
    );
  }
}
