import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_type_selector.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/chart_area.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/summary_stat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Charts'),
        actions: [
          Consumer<ChartProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<ChartTimeRange>(
                onSelected: provider.setTimeRange,
                itemBuilder: (context) => ChartTimeRange.values.map((range) {
                  return PopupMenuItem(
                    value: range,
                    child: Text(_getTimeRangeLabel(range)),
                  );
                }).toList(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.timeRangeLabel),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              ChartTypeSelector(provider: provider),
              SummaryStats(provider: provider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChartArea(provider: provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTimeRangeLabel(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.week:
        return 'Last 7 Days';
      case ChartTimeRange.month:
        return 'Last Month';
      case ChartTimeRange.threeMonths:
        return 'Last 3 Months';
      case ChartTimeRange.sixMonths:
        return 'Last 6 Months';
      case ChartTimeRange.year:
        return 'Last Year';
      case ChartTimeRange.all:
        return 'All Time';
    }
  }
}
