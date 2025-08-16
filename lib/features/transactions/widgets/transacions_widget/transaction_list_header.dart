import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/widgets/summary_section.dart';
import 'package:flutter/material.dart';

class TransactionListHeader extends StatelessWidget {
  final Set<String> categories;
  final ValueNotifier<String> selectedCategoryNotifier;
  final ValueNotifier<String> selectedSortNotifier;

  const TransactionListHeader({
    super.key,
    required this.categories,
    required this.selectedCategoryNotifier,
    required this.selectedSortNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SectionHeader(title: "Transactions"),
        Row(
          children: [
            if (categories.isNotEmpty)
              ValueListenableBuilder<String>(
                valueListenable: selectedCategoryNotifier,
                builder: (context, selectedCategory, child) {
                  return PopupMenuButton<String>(
                    onSelected: (String category) {
                      selectedCategoryNotifier.value = category;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            category == 'all'
                                ? 'Showing all transactions'
                                : 'Filtering by: $category',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.textBlack,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Filter by category',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (BuildContext context) {
                      return [
                        _buildPopupMenuItem(
                          context: context,
                          value: 'all',
                          label: 'All Transactions',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: selectedCategory == 'all',
                        ),
                        ...categories.map(
                          (category) => _buildPopupMenuItem(
                            context: context,
                            value: category,
                            label: category,
                            icon: category == 'Income'
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            isSelected: selectedCategory == category,
                          ),
                        ),
                      ];
                    },
                  );
                },
              ),
            const SizedBox(width: 8),
            ValueListenableBuilder<String>(
              valueListenable: selectedSortNotifier,
              builder: (context, selectedSort, child) {
                return PopupMenuButton<String>(
                  onSelected: (String sortOption) {
                    selectedSortNotifier.value = sortOption;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sorting by: $sortOption'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: AppColors.textBlack,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Sort transactions',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      _buildPopupMenuItem(
                        context: context,
                        value: 'latest',
                        label: 'Latest First',
                        icon: Icons.access_time_rounded,
                        isSelected: selectedSort == 'latest',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'high_to_low',
                        label: 'Amount High → Low',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: selectedSort == 'high_to_low',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'low_to_high',
                        label: 'Amount Low → High',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: selectedSort == 'low_to_high',
                      ),
                      _buildPopupMenuItem(
                        context: context,
                        value: 'name_az',
                        label: 'Name A → Z',
                        icon: Icons.sort_by_alpha_rounded,
                        isSelected: selectedSort == 'name_az',
                      ),
                    ];
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.summaryBorder : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.summaryBorder : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
