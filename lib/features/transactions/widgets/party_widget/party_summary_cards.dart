import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesSummaryCards extends StatelessWidget {
  const PartiesSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          // Loading placeholders
          return Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Container(
                    height: 80,
                    margin: EdgeInsets.only(right: index == 0 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'To Receive',
                  amount: provider.totalToReceive,
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'To Give',
                  amount: provider.totalToGive,
                  color: Colors.red,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
