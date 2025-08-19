import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/chart_card.dart';
import 'package:flutter/material.dart';

class ChartTile extends StatelessWidget {
  final ChartType chartType;
  final double height;
  final ChartProvider provider;

  const ChartTile({
    super.key,
    required this.chartType,
    required this.height,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        // Ensure minimum height for legend display
        constraints: BoxConstraints(
          minHeight: height + 40, // Extra space for legend
        ),
        padding: const EdgeInsets.all(12.0),
        child: RepaintBoundary(
          child: ChartCard(
            provider: provider,
            chartType: chartType,
            height: height,
          ),
        ),
      ),
    );
  }
}
