import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String title;
  const TitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: AppColors.textTitleColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}