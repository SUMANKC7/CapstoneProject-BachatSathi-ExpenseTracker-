import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCard extends StatelessWidget {
  final ChartProvider provider;
  final ChartType chartType;
  final double height;

  const ChartCard({
    super.key,
    required this.provider,
    required this.chartType,
    this.height = 200,
  });

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
                              child: Column(
                                children: [
                                  Expanded(child: _buildMiniChart()),
                                  const SizedBox(height: 16),
                                  _buildLegend(
                                    _getChartData(),
                                    isFullScreen: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildMiniChart()),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildLegend(_getChartData())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ChartDataModel> _getChartData() {
    switch (chartType) {
      case ChartType.expenseIncome:
        return provider.getExpenseIncomeData();
      case ChartType.categoryBreakdown:
        return provider.getCategoryBreakdownData().take(5).toList();
      case ChartType.cashFlow:
        return provider.getCashFlowData();
      case ChartType.monthlyTrends:
        // For line chart, we'll create dummy legend data
        return [
          ChartDataModel(label: 'Net Flow Trend', value: 0, color: Colors.blue),
        ];
      case ChartType.combined:
        return provider.getCombinedData();
    }
  }

  Widget _buildLegend(List<ChartDataModel> data, {bool isFullScreen = false}) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final fontSize = isFullScreen ? 14.0 : 10.0;
    final itemHeight = isFullScreen ? 32.0 : 24.0;
    final dotSize = isFullScreen ? 12.0 : 8.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFullScreen) ...[
            Text(
              'Legend',
              style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...data.map((item) {
            final percentage = _calculatePercentage(item, data);
            return Container(
              height: itemHeight,
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isFullScreen &&
                            chartType != ChartType.monthlyTrends) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  double _calculatePercentage(ChartDataModel item, List<ChartDataModel> data) {
    if (chartType == ChartType.monthlyTrends) return 0.0;

    final total = data.fold(0.0, (sum, item) => sum + item.value);
    return total > 0 ? (item.value / total) * 100 : 0;
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
            radius: 50, // Slightly smaller to make room for legend
            titleStyle: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 20,
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

    // Find min and max values for better scaling
    final values = data.map((d) => d.netFlow).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // Add some padding to the range
    final range = maxValue - minValue;
    final paddedMin = minValue - (range * 0.1);
    final paddedMax = maxValue + (range * 0.1);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: paddedMin,
        maxY: paddedMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: range > 0 ? range / 4 : 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: range > 0 ? range / 3 : 1000,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrency(value),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  // Show every other month for better readability in small charts
                  if (data.length > 4 && index % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    data[index].month,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.netFlow);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 2,
                  color: Colors.blue,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      return value.toStringAsFixed(0);
    }
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
