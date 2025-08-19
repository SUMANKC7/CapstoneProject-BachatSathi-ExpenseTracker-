import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';

class EnhancedLineChart extends StatefulWidget {
  final ChartProvider provider;
  final double height;
  final bool showMultipleLines;
  final bool isFullScreen;

  const EnhancedLineChart({
    super.key,
    required this.provider,
    this.height = 300,
    this.showMultipleLines = false,
    this.isFullScreen = false,
  });

  @override
  State<EnhancedLineChart> createState() => _EnhancedLineChartState();
}

class _EnhancedLineChartState extends State<EnhancedLineChart> {
  List<bool> selectedLines = [true, true, true]; // Income, Expense, NetFlow

  @override
  Widget build(BuildContext context) {
    final data = widget.provider.getMonthlyTrendsData();

    if (data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No trend data available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (widget.showMultipleLines) _buildLegendToggle(),
        SizedBox(
          height: widget.height,
          child: Padding(
            padding: EdgeInsets.all(widget.isFullScreen ? 16.0 : 8.0),
            child: LineChart(_buildLineChartData(data)),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleChip('Income', ChartProvider.incomeColor, 0),
          _buildToggleChip('Expense', ChartProvider.expenseColor, 1),
          _buildToggleChip('Net Flow', Colors.blue, 2),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, Color color, int index) {
    final isSelected = selectedLines[index];
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedLines[index] = selected;
        });
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
    );
  }

  LineChartData _buildLineChartData(List<MonthlyTrendData> data) {
    // Calculate value ranges for all selected lines
    List<double> allValues = [];

    if (widget.showMultipleLines) {
      if (selectedLines[0]) allValues.addAll(data.map((d) => d.income));
      if (selectedLines[1]) allValues.addAll(data.map((d) => d.expense));
      if (selectedLines[2]) allValues.addAll(data.map((d) => d.netFlow));
    } else {
      allValues = data.map((d) => d.netFlow).toList();
    }

    final minValue = allValues.isEmpty
        ? 0
        : allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.isEmpty
        ? 100
        : allValues.reduce((a, b) => a > b ? a : b);

    // Add padding to the range
    final range = maxValue - minValue;
    final paddedMin = range == 0 ? minValue - 100 : minValue - (range * 0.1);
    final paddedMax = range == 0 ? maxValue + 100 : maxValue + (range * 0.1);

    return LineChartData(
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: paddedMin.toDouble(),
      maxY: paddedMax.toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: range > 0 ? range / 5 : 1000,
        verticalInterval: data.length > 6 ? 2 : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: value == 0
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            strokeWidth: value == 0 ? 1 : 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 0.5);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: widget.isFullScreen ? 60 : 50,
            interval: range > 0 ? range / 4 : 1000,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _formatCurrency(value),
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: widget.isFullScreen ? 11 : 9,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: widget.isFullScreen ? 35 : 25,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < data.length) {
                // Show every month for full screen, every other for mini
                final shouldShow =
                    widget.isFullScreen || data.length <= 4 || index % 2 == 0;

                if (!shouldShow) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Text(
                        data[index].month,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isFullScreen ? 11 : 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (widget.isFullScreen &&
                          data[index].year != DateTime.now().year)
                        Text(
                          data[index].year.toString(),
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 8,
                          ),
                        ),
                    ],
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
      lineBarsData: _buildLineBarsData(data),
    );
  }

  List<LineChartBarData> _buildLineBarsData(List<MonthlyTrendData> data) {
    List<LineChartBarData> lines = [];

    if (widget.showMultipleLines) {
      // Income line
      if (selectedLines[0]) {
        lines.add(
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.income);
            }).toList(),
            isCurved: true,
            color: ChartProvider.incomeColor,
            barWidth: widget.isFullScreen ? 3 : 2,
            dotData: FlDotData(
              show: widget.isFullScreen,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: ChartProvider.incomeColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

      // Expense line
      if (selectedLines[1]) {
        lines.add(
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.expense);
            }).toList(),
            isCurved: true,
            color: ChartProvider.expenseColor,
            barWidth: widget.isFullScreen ? 3 : 2,
            dotData: FlDotData(
              show: widget.isFullScreen,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: ChartProvider.expenseColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

      // Net Flow line
      if (selectedLines[2]) {
        lines.add(
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.netFlow);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: widget.isFullScreen ? 3 : 2,
            dotData: FlDotData(
              show: widget.isFullScreen,
              getDotPainter: (spot, percent, barData, index) {
                final value = data[index].netFlow;
                return FlDotCirclePainter(
                  radius: 3,
                  color: value >= 0
                      ? ChartProvider.netFlowPositiveColor
                      : ChartProvider.netFlowNegativeColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
              applyCutOffY: true,
              cutOffY: 0,
            ),
          ),
        );
      }
    } else {
      // Single net flow line
      lines.add(
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.netFlow);
          }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: widget.isFullScreen ? 3 : 2,
          dotData: FlDotData(
            show: widget.isFullScreen,
            getDotPainter: (spot, percent, barData, index) {
              final value = data[index].netFlow;
              return FlDotCirclePainter(
                radius: widget.isFullScreen ? 4 : 2,
                color: value >= 0
                    ? ChartProvider.netFlowPositiveColor
                    : ChartProvider.netFlowNegativeColor,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
            applyCutOffY: true,
            cutOffY: 0,
          ),
        ),
      );
    }

    return lines;
  }

  String _formatCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value.abs() >= 100) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
