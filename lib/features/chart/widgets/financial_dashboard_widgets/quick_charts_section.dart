import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'chart_tile.dart';

class QuickChartsSection extends StatelessWidget {
  final ChartProvider provider;
  final double maxWidth;
  final bool compact;

  const QuickChartsSection({
    super.key,
    required this.provider,
    required this.maxWidth,
    required this.compact,
  });

  int _chartCols(double w) {
    if (w >= 1100) return 2;
    return 1;
  }

  double _chartAspect(double w) {
    if (w < 400) return 0.8;
    if (w < 600) return 1.0;
    if (w < 900) return 1.2;
    if (w < 1200) return 1.4;
    if (w < 1500) return 1.6;
    return 1.8;
  }

  @override
  Widget build(BuildContext context) {
    const charts = <ChartType>[
      ChartType.expenseIncome,
      ChartType.categoryBreakdown,
      ChartType.cashFlow,
      ChartType.monthlyTrends,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Charts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (compact) ...[
          for (final type in charts)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ChartTile(
                chartType: type,
                height: 240,
                provider: provider,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ChartTile(
              chartType: ChartType.combined,
              height: 300,
              provider: provider,
            ),
          ),
        ] else ...[
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _chartCols(maxWidth),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: _chartAspect(maxWidth),
            ),
            children: [
              for (final type in charts)
                ChartTile(chartType: type, height: 240, provider: provider),
            ],
          ),
        ],
      ],
    );
  }
}
