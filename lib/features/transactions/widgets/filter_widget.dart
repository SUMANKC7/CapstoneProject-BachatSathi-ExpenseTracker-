import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class FilterTime extends StatelessWidget {
  final String filterdate;
  const FilterTime({super.key, required this.filterdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.05,
      // width: MediaQuery.sizeOf(context).width * 0.3,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.filterColor,
      ),
      child: Center(
        child: Text(
          filterdate,
          style: TextStyle(
            color: AppColors.filterTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
