import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class ExpenseTile extends StatelessWidget {
  final String title;
  final String amount;
  final String image;
  const ExpenseTile({super.key, required this.title, required this.amount, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(left: 14, top: 15, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,  
                  ),
                ),

                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.navBarIcon,
                    fontWeight: FontWeight.normal,                  
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}