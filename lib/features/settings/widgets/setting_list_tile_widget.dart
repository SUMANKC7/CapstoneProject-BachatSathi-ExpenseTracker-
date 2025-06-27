
import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        constraints: BoxConstraints(minHeight: 40, minWidth: 40),
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.filterColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 28),
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
          letterSpacing: 0.001,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.transactiontype,
        ),
      ),
    );
  }
}
