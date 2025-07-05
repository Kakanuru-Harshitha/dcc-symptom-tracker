import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trend_point.dart';

/// Smooth multi-line symptom chart.
class TrendChart extends StatelessWidget {
  final Map<String, List<TrendPoint>> series;
  final DateTime from, to;

  const TrendChart({
    required this.series,
    required this.from,
    required this.to,
    super.key,
  });

  static const _palette = [
    Color(0xff1E88E5),
    Color(0xffF4511E),
    Color(0xff43A047),
    Color(0xff8E24AA),
    Color(0xffFB8C00),
    Color(0xff3949AB),
  ];

  @override
  Widget build(BuildContext context) {
    // filter visible points
    final visible =
        series.entries
            .where(
              (e) => e.value.any(
                (p) => !p.date.isBefore(from) && !p.date.isAfter(to),
              ),
            )
            .toList();
    if (visible.isEmpty) {
      return const Center(child: Text('No data in this range'));
    }

    final totalDays = to.difference(from).inDays;
    final lines = <LineChartBarData>[];

    for (var i = 0; i < visible.length; i++) {
      final pts =
          visible[i].value
              .where((p) => !p.date.isBefore(from) && !p.date.isAfter(to))
              .map(
                (p) =>
                    FlSpot(p.date.difference(from).inDays.toDouble(), p.value),
              )
              .toList()
            ..sort((a, b) => a.x.compareTo(b.x));

      if (pts.isEmpty) continue;

      lines.add(
        LineChartBarData(
          spots: pts,
          isCurved: true,
          color: _palette[i % _palette.length],
          barWidth: 3, // thicker line
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (s, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: _palette[i % _palette.length],
                  strokeWidth: 0,
                ),
          ),
        ),
      );
    }

    // bottom-axis label builder
    Widget bottomTitle(double v, TitleMeta _) {
      final dt = from.add(Duration(days: v.round()));
      return Text(
        '${dt.month}/${dt.day}',
        style: const TextStyle(fontSize: 10),
      );
    }

    final rawInt = totalDays / 4;
    final bottomIntv = rawInt < 1 ? 1.0 : rawInt.ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // legend
        Wrap(
          spacing: 12,
          children: [
            for (var i = 0; i < visible.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 4,
                    color: _palette[i % _palette.length],
                  ),
                  const SizedBox(width: 4),
                  Text(visible[i].key, style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: totalDays.toDouble(),
              minY: 0,
              maxY: 10,
              gridData: const FlGridData(
                show: true,
                horizontalInterval: 2,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(bottom: BorderSide(), left: BorderSide()),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomIntv,
                    reservedSize: 30,
                    getTitlesWidget: bottomTitle,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 28,
                    getTitlesWidget:
                        (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: lines,
            ),
          ),
        ),
      ],
    );
  }
}
