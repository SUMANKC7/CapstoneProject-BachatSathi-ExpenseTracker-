import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/screen/chart_screen.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/centered_states.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/financial_overview.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/helper.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/quick_charts_section.dart';
import 'package:expensetrack/features/chart/widgets/financial_dashboard_widgets/time_range_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinancialDashboard extends StatelessWidget {
  const FinancialDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        elevation: 0,
        actions: [
          Consumer<ChartProvider>(
            builder: (context, provider, child) {
              return Tooltip(
                message: provider.isLoading ? 'Refreshing…' : 'Refresh data',
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: provider.isLoading
                        ? const SizedBox(
                            key: ValueKey('spin'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(key: ValueKey('ref'), Icons.refresh),
                  ),
                  onPressed: provider.isLoading ? null : provider.refreshData,
                ),
              );
            },
          ),
          PopupMenuButton<ChartTimeRange>(
            onSelected: (range) {
              context.read<ChartProvider>().setTimeRange(range);
            },
            itemBuilder: (context) => ChartTimeRange.values
                .map(
                  (range) => PopupMenuItem(
                    value: range,
                    child: Text(getTimeRangeLabel(range)),
                  ),
                )
                .toList(),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.date_range),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ChartProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.transactions.isEmpty) {
              return const CenteredLoader(title: 'Loading financial data…');
            }

            if (provider.error != null && provider.transactions.isEmpty) {
              return CenteredError(
                message: provider.error!,
                onRetry: provider.refreshData,
              );
            }

            if (!provider.isLoading && provider.transactions.isEmpty) {
              return CenteredError(
                message: 'No transactions found for this period.',
                icon: Icons.inbox_outlined,
                onRetry: provider.refreshData,
                retryLabel: 'Refresh',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isCompact = width < 640;
                return RefreshIndicator(
                  onRefresh: provider.refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TimeRangeHeader(provider: provider),
                              const SizedBox(height: 20),
                              FinancialOverview(
                                stats: provider.getSummaryStats(),
                                maxWidth: width,
                              ),
                              const SizedBox(height: 24),
                              QuickChartsSection(
                                provider: provider,
                                maxWidth: width,
                                compact: isCompact,
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ChartScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.analytics),
                                  label: const Text('View Detailed Charts'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
