import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';

class TimeRangeHeader extends StatelessWidget {
  final ChartProvider provider;

  const TimeRangeHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
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
