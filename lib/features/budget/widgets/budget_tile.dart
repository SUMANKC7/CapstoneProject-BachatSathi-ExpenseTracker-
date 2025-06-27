
import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class BudgetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String totalBudget;
  final String expenses;
  const BudgetTile({super.key, required this.icon, required this.title, required this.totalBudget, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(
        spacing: 25,
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 40,minWidth: 40),
                height: 60,
        width: 60,
                decoration: BoxDecoration(
                  color: AppColors.filterColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 30,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      fontFamily: "serif",
                    ),
                  ),
                  Text(
                    "$expenses/ $totalBudget",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: "serif",
                      color: AppColors.subTextGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 10,
            padding: EdgeInsets.only(right: 25),
            child: LinearProgressIndicator(
              color: AppColors.navBarSelected,
              backgroundColor: AppColors.filterColor,
              value: 0.4,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
