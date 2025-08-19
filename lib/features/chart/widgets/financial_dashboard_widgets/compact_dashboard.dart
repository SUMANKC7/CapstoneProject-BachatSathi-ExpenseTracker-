import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/screen/chart_screen.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/compact_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'compact_stat_card.dart';

class CompactDashboard extends StatelessWidget {
  const CompactDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        final stats = provider.getSummaryStats();
        final netIncome = stats['netIncome'] ?? 0;
        final netWorth = stats['netWorth'] ?? 0;

        return RefreshIndicator(
          onRefresh: provider.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CompactStatCard(
                        title: 'Net Income',
                        value: netIncome,
                        icon: Icons.account_balance_wallet,
                        color: netIncome >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CompactStatCard(
                        title: 'Net Worth',
                        value: netWorth,
                        icon: Icons.savings,
                        color: netWorth >= 0 ? Colors.purple : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const CompactCharts(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChartScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics, size: 20),
                        label: const Text('View Charts'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.refreshData,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
