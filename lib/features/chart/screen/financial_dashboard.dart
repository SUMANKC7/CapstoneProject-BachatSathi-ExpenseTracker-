import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fully responsive dashboard:
/// - Shows ALL quick charts on every screen size (stacked on small, grid on large)
/// - Adaptive stat & chart grids
/// - Friendly loading/error states
/// - Smooth refresh UX
/// - Uses your existing ChartProvider, ChartCard, ChartType, ChartScreen
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
                    child: Text(_getTimeRangeLabel(range)),
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
            // Initial loading
            if (provider.isLoading && provider.transactions.isEmpty) {
              return const _CenteredLoader(title: 'Loading financial data…');
            }

            // Initial error
            if (provider.error != null && provider.transactions.isEmpty) {
              return _CenteredError(
                message: provider.error!,
                onRetry: provider.refreshData,
              );
            }

            // Empty (no data in selected range)
            if (!provider.isLoading && provider.transactions.isEmpty) {
              return _CenteredError(
                message: 'No transactions found for this period.',
                icon: Icons.inbox_outlined,
                onRetry: provider.refreshData,
                retryLabel: 'Refresh',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isCompact = width < 640; // <640px: phone layout
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
                              _buildTimeRangeHeader(provider, context),
                              const SizedBox(height: 20),
                              _FinancialOverview(
                                stats: provider.getSummaryStats(),
                                maxWidth: width,
                              ),
                              const SizedBox(height: 24),
                              _QuickChartsSection(
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

  /// Header showing selected time range + inline warning if any
  Widget _buildTimeRangeHeader(ChartProvider provider, BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: color),
          const SizedBox(width: 8),
          Text(
            'Period: ${provider.timeRangeLabel}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          if (provider.error != null)
            Tooltip(
              message: provider.error,
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
              ),
            ),
        ],
      ),
    );
  }
}

/// Overview cards with fully responsive grid
class _FinancialOverview extends StatelessWidget {
  final Map<String, double> stats;
  final double maxWidth;
  const _FinancialOverview({required this.stats, required this.maxWidth});

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
            _StatCard(
              title: 'Total Income',
              value: stats['totalIncome'] ?? 0,
              icon: Icons.trending_up,
              color: Colors.green,
              subtitle: 'Money earned',
            ),
            _StatCard(
              title: 'Total Expense',
              value: stats['totalExpense'] ?? 0,
              icon: Icons.trending_down,
              color: Colors.red,
              subtitle: 'Money spent',
            ),
            _StatCard(
              title: 'Net Income',
              value: netIncome,
              icon: Icons.account_balance_wallet,
              color: netIncome >= 0 ? Colors.green : Colors.red,
              subtitle: 'Income - Expense',
            ),
            _StatCard(
              title: 'Net Worth',
              value: netWorth,
              icon: Icons.savings,
              color: netWorth >= 0 ? Colors.purple : Colors.red,
              subtitle: 'Total financial position',
            ),
            _StatCard(
              title: 'To Receive',
              value: stats['totalToReceive'] ?? 0,
              icon: Icons.call_received,
              color: Colors.blue,
              subtitle: 'Money owed to you',
            ),
            _StatCard(
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

/// Quick charts section that ALWAYS shows all charts.
/// On compact screens: stacked column or horizontal carousel.
/// On wide screens: responsive grid (1-2 columns based on width).
class _QuickChartsSection extends StatelessWidget {
  final ChartProvider provider;
  final double maxWidth;
  final bool compact;
  const _QuickChartsSection({
    required this.provider,
    required this.maxWidth,
    required this.compact,
  });

  int _chartCols(double w) {
    if (w >= 1100) return 2;
    return 1;
  }

  double _chartAspect(double w) {
    if (w < 400) return 0.8; // very small phones → taller
    if (w < 600) return 1.0; // normal phones
    if (w < 900) return 1.2; // large phones / small tablets
    if (w < 1200) return 1.4; // tablets
    if (w < 1500) return 1.6; // small desktop
    return 1.8; // large desktop
  }

  @override
  Widget build(BuildContext context) {
    // All quick charts you have in the UI
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

        // Compact: stacked cards (scrollable vertically) or swipe carousel when really tight
        if (compact) ...[
          // If the device is very narrow, keep height tighter
          for (final type in charts)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ChartTile(
                chartType: type,
                height: 240,
                provider: provider,
              ),
            ),
          // Also add a combined chart at the end for a holistic view (if you use it)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _ChartTile(
              chartType: ChartType.combined,
              height: 300,
              provider: provider,
            ),
          ),
        ] else ...[
          // Wide screens: grid layout
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
                _ChartTile(chartType: type, height: 240, provider: provider),
            ],
          ),
        ],
      ],
    );
  }
}

/// Card wrapper around your ChartCard widget
class _ChartTile extends StatelessWidget {
  final ChartType chartType;
  final double height;
  final ChartProvider provider;
  const _ChartTile({
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
      child: Padding(
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

/// Reusable stat card
class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact dashboard kept for direct use if you need it elsewhere (now shows ALL charts too).
class CompactDashboard extends StatelessWidget {
  const CompactDashboard({Key? key}) : super(key: key);

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
                // You can show the same header as the main screen by passing provider from above if desired.
                // For portability, we render a simpler version here:
                Row(
                  children: [
                    Expanded(
                      child: _CompactStatCard(
                        title: 'Net Income',
                        value: netIncome,
                        icon: Icons.account_balance_wallet,
                        color: netIncome >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompactStatCard(
                        title: 'Net Worth',
                        value: netWorth,
                        icon: Icons.savings,
                        color: netWorth >= 0 ? Colors.purple : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // All quick charts stacked in compact layout
                const _CompactCharts(),
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

class _CompactCharts extends StatelessWidget {
  const _CompactCharts();

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

class _CompactStatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // prevent unbounded height
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // prevent overflow
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              // makes sure large numbers scale down
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _formatCurrency(value),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly center loader
class _CenteredLoader extends StatelessWidget {
  final String title;
  const _CenteredLoader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(title),
        ],
      ),
    );
  }
}

/// Friendly center error with retry
class _CenteredError extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;
  final IconData icon;
  final String retryLabel;

  const _CenteredError({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final errColor = Theme.of(context).colorScheme.error.withOpacity(0.8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: errColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

// ----------------- Shared helpers -----------------

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

String _formatCurrency(double amount) {
  if (amount.abs() >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(1)} Cr';
  } else if (amount.abs() >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)} L';
  } else if (amount.abs() >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
