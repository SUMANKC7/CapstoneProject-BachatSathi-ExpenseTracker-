import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

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
              // Chart Type Selector
              _buildChartTypeSelector(provider),

              // Summary Stats
              _buildSummaryStats(provider),

              // Chart Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildChart(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartTypeSelector(ChartProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ChartType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_getChartTypeLabel(type)),
              selected: provider.selectedChartType == type,
              onSelected: (selected) {
                if (selected) provider.setChartType(type);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryStats(ChartProvider provider) {
    final stats = provider.getSummaryStats();
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Net Income',
              stats['netIncome'] ?? 0,
              Icons.account_balance_wallet,
              stats['netIncome']! >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Net Cash Flow',
              stats['netCashFlow'] ?? 0,
              Icons.swap_horiz,
              stats['netCashFlow']! >= 0 ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Net Worth',
              stats['netWorth'] ?? 0,
              Icons.trending_up,
              stats['netWorth']! >= 0 ? Colors.purple : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ChartProvider provider) {
    switch (provider.selectedChartType) {
      case ChartType.expenseIncome:
      case ChartType.categoryBreakdown:
      case ChartType.cashFlow:
      case ChartType.combined:
        return _buildPieChart(provider);
      case ChartType.monthlyTrends:
        return _buildLineChart(provider);
    }
  }

  Widget _buildPieChart(ChartProvider provider) {
    final data = provider.getCurrentChartData() as List<ChartDataModel>;

    if (data.isEmpty || data.every((element) => element.value == 0)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data available for selected period'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          provider.chartTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: data.map((item) {
                      final total = data.fold(
                        0.0,
                        (sum, item) => sum + item.value,
                      );
                      final percentage = total > 0
                          ? (item.value / total) * 100
                          : 0;

                      return PieChartSectionData(
                        value: item.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        color: item.color,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(flex: 1, child: _buildLegend(data)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(ChartProvider provider) {
    final data = provider.getMonthlyTrendsData();

    if (data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No trend data available'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          provider.chartTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1000,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            data[index].month,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrency(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!),
              ),
              lineBarsData: [
                // Income line
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.income);
                  }).toList(),
                  isCurved: true,
                  color: ChartProvider.incomeColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ChartProvider.incomeColor.withOpacity(0.1),
                  ),
                ),
                // Expense line
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.expense);
                  }).toList(),
                  isCurved: true,
                  color: ChartProvider.expenseColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ChartProvider.expenseColor.withOpacity(0.1),
                  ),
                ),
                // Net flow line
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.netFlow);
                  }).toList(),
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                  dashArray: [5, 5],
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // tooltipBgColor: Colors.blueGrey,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      const textStyle = TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      String label;
                      switch (touchedSpot.barIndex) {
                        case 0:
                          label = 'Income: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        case 1:
                          label = 'Expense: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        case 2:
                          label = 'Net: ${_formatCurrency(touchedSpot.y)}';
                          break;
                        default:
                          label = _formatCurrency(touchedSpot.y);
                      }
                      return LineTooltipItem(label, textStyle);
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        // Legend for line chart
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLineLegendItem('Income', ChartProvider.incomeColor),
              _buildLineLegendItem('Expense', ChartProvider.expenseColor),
              _buildLineLegendItem('Net Flow', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(List<ChartDataModel> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatCurrency(item.value),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _getChartTypeLabel(ChartType type) {
    switch (type) {
      case ChartType.expenseIncome:
        return 'Income vs Expense';
      case ChartType.categoryBreakdown:
        return 'Categories';
      case ChartType.monthlyTrends:
        return 'Monthly Trends';
      case ChartType.cashFlow:
        return 'Cash Flow';
      case ChartType.combined:
        return 'Overview';
    }
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

  String _formatCurrency(double amount) {
    if (amount.abs() >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

// Alternative Bar Chart Widget for better category visualization
class CategoryBarChart extends StatelessWidget {
  final ChartProvider provider;

  const CategoryBarChart({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = provider.getCategoryBreakdownData();

    if (data.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    // Take only top 8 categories for better visualization
    final topCategories = data.take(8).toList();
    final maxValue = topCategories.fold(
      0.0,
      (max, item) => item.value > max ? item.value : max,
    );

    return Column(
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${topCategories[group.x.toInt()].label}\n'
                      '${_formatCurrency(rod.toY)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < topCategories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            topCategories[index].label.length > 8
                                ? '${topCategories[index].label.substring(0, 8)}...'
                                : topCategories[index].label,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrency(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 50,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!),
              ),
              barGroups: topCategories.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value,
                      color: entry.value.color,
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount.abs() >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

// Compact Chart Card for Dashboard
class ChartCard extends StatelessWidget {
  final ChartProvider provider;
  final ChartType chartType;
  final double height;

  const ChartCard({
    Key? key,
    required this.provider,
    required this.chartType,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getChartTitle(chartType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(_getChartTitle(chartType)),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildMiniChart(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildMiniChart()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChart() {
    switch (chartType) {
      case ChartType.expenseIncome:
        return _buildMiniPieChart(provider.getExpenseIncomeData());
      case ChartType.categoryBreakdown:
        return _buildMiniPieChart(
          provider.getCategoryBreakdownData().take(5).toList(),
        );
      case ChartType.cashFlow:
        return _buildMiniPieChart(provider.getCashFlowData());
      case ChartType.monthlyTrends:
        return _buildMiniLineChart();
      case ChartType.combined:
        return _buildMiniPieChart(provider.getCombinedData());
    }
  }

  Widget _buildMiniPieChart(List<ChartDataModel> data) {
    if (data.isEmpty || data.every((element) => element.value == 0)) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.grey)),
      );
    }

    return PieChart(
      PieChartData(
        sections: data.map((item) {
          final total = data.fold(0.0, (sum, item) => sum + item.value);
          final percentage = total > 0 ? (item.value / total) * 100 : 0;

          return PieChartSectionData(
            value: item.value,
            title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
            color: item.color,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 25,
        sectionsSpace: 1,
      ),
    );
  }

  Widget _buildMiniLineChart() {
    final data = provider.getMonthlyTrendsData();

    if (data.isEmpty) {
      return const Center(
        child: Text('No trend data', style: TextStyle(color: Colors.grey)),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.netFlow);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle(ChartType type) {
    switch (type) {
      case ChartType.expenseIncome:
        return 'Income vs Expense';
      case ChartType.categoryBreakdown:
        return 'Top Categories';
      case ChartType.monthlyTrends:
        return 'Monthly Trends';
      case ChartType.cashFlow:
        return 'Cash Flow';
      case ChartType.combined:
        return 'Overview';
    }
  }
}
