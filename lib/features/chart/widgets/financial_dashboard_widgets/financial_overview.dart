import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/statcard.dart';
import 'package:flutter/material.dart';

class FinancialOverview extends StatelessWidget {
  final Map<String, double> stats;
  final double maxWidth;

  const FinancialOverview({
    super.key,
    required this.stats,
    required this.maxWidth,
  });

  int _statCols(double w) {
    if (w >= 1200) return 6;
    if (w >= 1024) return 4;
    if (w >= 800) return 3;
    return 2;
  }

  double _aspect(double w) {
    if (w >= 1400) return 2.6;
    if (w >= 1100) return 2.2;
    if (w >= 900) return 1.9;
    return 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final netIncome = stats['netIncome'] ?? 0;
    final netWorth = stats['netWorth'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _statCols(maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _aspect(maxWidth),
          ),
          children: [
            StatCard(
              title: 'Total Income',
              value: stats['totalIncome'] ?? 0,
              icon: Icons.trending_up,
              color: Colors.green,
              subtitle: 'Money earned',
            ),
            StatCard(
              title: 'Total Expense',
              value: stats['totalExpense'] ?? 0,
              icon: Icons.trending_down,
              color: Colors.red,
              subtitle: 'Money spent',
            ),
            StatCard(
              title: 'Net Income',
              value: netIncome,
              icon: Icons.account_balance_wallet,
              color: netIncome >= 0 ? Colors.green : Colors.red,
              subtitle: 'Income - Expense',
            ),
            StatCard(
              title: 'Net Worth',
              value: netWorth,
              icon: Icons.savings,
              color: netWorth >= 0 ? Colors.purple : Colors.red,
              subtitle: 'Total financial position',
            ),
            StatCard(
              title: 'To Receive',
              value: stats['totalToReceive'] ?? 0,
              icon: Icons.call_received,
              color: Colors.blue,
              subtitle: 'Money owed to you',
            ),
            StatCard(
              title: 'To Give',
              value: stats['totalToGive'] ?? 0,
              icon: Icons.call_made,
              color: Colors.orange,
              subtitle: 'Money you owe',
            ),
          ],
        ),
      ],
    );
  }
}
