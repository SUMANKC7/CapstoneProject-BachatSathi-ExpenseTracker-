import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  final double toReceive;
  final double toGive;
  final double balance;

  const SummarySection({
    super.key,
    required this.toReceive,
    required this.toGive,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Income',
                amount: toReceive,
                color: AppColors.green,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expenses',
                amount: toGive,
                color: AppColors.expenseColor!,
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(title: 'Net Balance', amount: balance, isLarge: true),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color? color;
  final IconData? icon;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.amount,
    this.color,
    this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: isLarge ? 26 : 20,
              fontWeight: FontWeight.bold,
              color: isLarge
                  ? (amount < 0 ? AppColors.expenseColor : Colors.black87)
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}
