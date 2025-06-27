import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class SettingsTitleText extends StatelessWidget {
  final String title;
  const SettingsTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        color: AppColors.textTitleColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}