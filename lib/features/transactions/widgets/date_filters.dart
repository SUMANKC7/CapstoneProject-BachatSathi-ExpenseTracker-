import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class DateFilterSection extends StatelessWidget {
  final ValueNotifier<String> selectedFilter;
  const DateFilterSection({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final filters = ["Last 7 days", "This month", "Last month", "Custom"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return ValueListenableBuilder<String>(
            valueListenable: selectedFilter,
            builder: (context, value, child) {
              final isSelected = value == filter;
              return ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.backgroundColor
                        : AppColors.navBarSelected,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedFilter.value = filter;
                  }
                },
                backgroundColor: AppColors.softTeal,
                selectedColor: Colors.blue.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.summaryBorder,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.summaryBorder.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
