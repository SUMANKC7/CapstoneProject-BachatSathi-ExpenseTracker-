import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'stat_card.dart';

class SummaryStats extends StatelessWidget {
  final ChartProvider provider;

  const SummaryStats({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.getSummaryStats();
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Net Income',
              value: stats['netIncome'] ?? 0,
              icon: Icons.account_balance_wallet,
              color: stats['netIncome']! >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              title: 'Net Cash Flow',
              value: stats['netCashFlow'] ?? 0,
              icon: Icons.swap_horiz,
              color: stats['netCashFlow']! >= 0 ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              title: 'Net Worth',
              value: stats['netWorth'] ?? 0,
              icon: Icons.trending_up,
              color: stats['netWorth']! >= 0 ? Colors.purple : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
