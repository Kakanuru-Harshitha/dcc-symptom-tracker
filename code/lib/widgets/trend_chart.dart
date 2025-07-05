// lib/widgets/trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trend_point.dart';

/// Multi‐line time‐series chart with even spacing and clean MM/DD bottom labels.
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
    // Filter out any series with no points in-range
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

    // Total days between from→to
    final totalDays = to.difference(from).inDays;
    // Build one LineChartBarData per visible symptom
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
          barWidth: 2.5,
          dotData: const FlDotData(show: true),
        ),
      );
    }

    // Axis label builders
    Widget bottomTitle(double v, TitleMeta _) {
      final day = v.round();
      final dt = from.add(Duration(days: day));
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${dt.month}/${dt.day}',
          style: const TextStyle(fontSize: 10),
        ),
      );
    }

    // Determine bottom‐axis interval (approx four segments)
    final rawInterval = totalDays / 4;
    final bottomInterval = rawInterval < 1 ? 1.0 : rawInterval.ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (var i = 0; i < visible.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
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
        // Chart
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
                // Bottom: only MM/DD
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomInterval,
                    reservedSize: 32, // give room for labels
                    getTitlesWidget: bottomTitle,
                  ),
                ),
                // Left: 0–10
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 40,
                    getTitlesWidget:
                        (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                  ),
                ),
                // Hide top & right
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
