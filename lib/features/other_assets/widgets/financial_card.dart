import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';
import 'package:flutter/material.dart';

class FinancialCard<T extends FinancialData> extends StatelessWidget {
  final T data;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const FinancialCard({
    super.key,
    required this.data,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Icon(
                    data.isPositive ? Icons.trending_up : Icons.trending_down,
                    color: data.isPositive ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                data.mainValue,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.changeValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: data.isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
