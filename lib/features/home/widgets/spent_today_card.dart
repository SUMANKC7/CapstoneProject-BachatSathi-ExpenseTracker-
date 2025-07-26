import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class SpentTodayCard extends StatelessWidget {
  const SpentTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.22,
          width: double.infinity,
          decoration: BoxDecoration(
        
            gradient: LinearGradient(
              colors: [
                     Color(0xFFC8E6C9), // Light Green
    Color(0xFFB3E5FC), // Pale Sky Blue
              ],
              // begin: Alignment.topLeft,
              // end: Alignment.bottomRight
            ),
            // color: AppColors.greenAccent,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Positioned(
          top: 22,
          left: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Balance",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppColors.navBarSelected,
                ),
              ),
              SizedBox(height: 7),
              Text(
                "\$ 120",
                style: TextStyle(
                  letterSpacing: 2.0,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navBarSelected,
                ),
              ),
            ],
          ),
        ),
        Positioned(top: 22, right: 22, child: Icon(Icons.more_horiz,color: AppColors.textBlack,)),
        Positioned(
          bottom: 18,
          left: 10,
          child: IncomeExpense(
            color: Colors.green,
            title: "Income",
            amount: "\$120", myicon: Icons.arrow_downward,
          ),
        ),

        Positioned(
          bottom: 18,
          right: 22,
          child: IncomeExpense(
            color: Color(0xFFFF8A80),
            title: "Expense",
            amount: '\$120', myicon: Icons.arrow_upward,
          ),
        ),
      ],
    );
  }
}

class IncomeExpense extends StatelessWidget {
  final Color color;
  final String title;
  final String amount;
  final IconData myicon;
  const IncomeExpense({
    super.key,
    required this.color,
    required this.title,
    required this.amount, required this.myicon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(myicon, color: color),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.navBarSelected,
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        Padding(
          padding: EdgeInsetsGeometry.only(left: 25),
          child: Text(
            amount,
            style: TextStyle(
              letterSpacing: 2.0,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.navBarSelected,
            ),
          ),
        ),
      ],
    );
  }
}
