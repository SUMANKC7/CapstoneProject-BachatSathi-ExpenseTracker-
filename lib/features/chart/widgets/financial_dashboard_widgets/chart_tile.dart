import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:expensetrack/features/chart/widgets/chart_widget/chart_card.dart';
import 'package:flutter/rendering.dart';

class ChartTile extends StatelessWidget {
  final ChartType chartType;
  final double height;
  final ChartProvider provider;

  /// Key for repaint boundary
  final GlobalKey repaintKey = GlobalKey();

  ChartTile({
    super.key,
    required this.chartType,
    required this.height,
    required this.provider,
  });

  /// Capture chart as PNG bytes (Uint8List)
  Future<Uint8List?> captureChartBytes() async {
    try {
      final boundary =
          repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing chart: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(minHeight: height + 40),
        padding: const EdgeInsets.all(12.0),
        child: RepaintBoundary(
          key: repaintKey, // 👈 important
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
