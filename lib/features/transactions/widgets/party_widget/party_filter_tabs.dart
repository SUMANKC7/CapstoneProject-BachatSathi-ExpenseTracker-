import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesFilterTabs extends StatelessWidget {
  const PartiesFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: 'All',
                  isSelected: provider.selectedFilter == null,
                  onTap: () => provider.setFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'To Give',
                  isSelected:
                      provider.selectedFilter == TransactionStatus.toGive,
                  onTap: () => provider.setFilter(TransactionStatus.toGive),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'To Receive',
                  isSelected:
                      provider.selectedFilter == TransactionStatus.toReceive,
                  onTap: () => provider.setFilter(TransactionStatus.toReceive),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Settled',
                  isSelected:
                      provider.selectedFilter == TransactionStatus.settled,
                  onTap: () => provider.setFilter(TransactionStatus.settled),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
