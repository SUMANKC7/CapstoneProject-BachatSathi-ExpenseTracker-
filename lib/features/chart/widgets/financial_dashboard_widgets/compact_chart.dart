import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/chart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompactCharts extends StatelessWidget {
  const CompactCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChartProvider>();
    const chartOrder = <ChartType>[
      ChartType.expenseIncome,
      ChartType.categoryBreakdown,
      ChartType.cashFlow,
      ChartType.monthlyTrends,
      ChartType.combined,
    ];

    return Column(
      children: [
        for (final t in chartOrder)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RepaintBoundary(
                  child: ChartCard(
                    provider: provider,
                    chartType: t,
                    height: t == ChartType.combined ? 300 : 240,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
