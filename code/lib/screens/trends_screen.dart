// lib/screens/trends_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../services/trend_service.dart';
import '../widgets/trend_chart.dart';
import '../models/trend_point.dart';
import '../utils/constants.dart';
import 'report_screen.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});
  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  // Our selected date range
  DateTime _from = DateTime.now().subtract(const Duration(days: 6));
  DateTime _to = DateTime.now();

  // Which symptom types are shown
  late Map<String, bool> _show;

  // Computed insight text
  String _insight = '';

  @override
  void initState() {
    super.initState();
    // Start with all types visible
    _show = {for (var t in kSymptomTypes) t: true};
  }

  Future<void> _pickDate(bool isFrom) async {
    final initial = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked;
        if (_from.isAfter(_to)) _from = _to;
      }
    });
  }

  void _updateInsight(Map<String, List<TrendPoint>> series) {
    // Pick the first visible series that has ≥2 points
    for (var entry in series.entries) {
      final pts = entry.value;
      if (pts.length >= 2) {
        final change = pts.last.value - pts.first.value;
        final name = entry.key.toLowerCase();
        if (change.abs() < 0.5) {
          _insight = 'Your $name is steady.';
        } else if (change < 0) {
          _insight = 'Your $name has improved.';
        } else {
          _insight = 'Your $name has worsened.';
        }
        return;
      }
    }
    _insight = 'Not enough data for insight.';
  }

  void _compare(Map<String, List<TrendPoint>> series) {
    // Find best correlation pair
    double bestR = 0;
    String bestPair = '';
    final keys = series.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      for (var j = i + 1; j < keys.length; j++) {
        final a = series[keys[i]]!, b = series[keys[j]]!;
        final mapB = {for (var p in b) p.date: p.value};
        final common = a.where((p) => mapB.containsKey(p.date)).toList();
        if (common.length < 2) continue;
        // compute Pearson
        final xs = common.map((p) => p.value).toList();
        final ys = common.map((p) => mapB[p.date]!).toList();
        final r = _pearson(xs, ys);
        if (r.abs() > bestR.abs()) {
          bestR = r;
          bestPair = '${keys[i]} & ${keys[j]}';
        }
      }
    }
    setState(() {
      _insight =
          bestPair.isEmpty
              ? 'No significant correlation.'
              : '$bestPair vary ${bestR > 0 ? 'together' : 'oppositely'}.';
    });
  }

  double _pearson(List<double> x, List<double> y) {
    final n = x.length;
    final mx = x.reduce((a, b) => a + b) / n;
    final my = y.reduce((a, b) => a + b) / n;
    double num = 0, dx2 = 0, dy2 = 0;
    for (var i = 0; i < n; i++) {
      final dx = x[i] - mx, dy = y[i] - my;
      num += dx * dy;
      dx2 += dx * dx;
      dy2 += dy * dy;
    }
    return dx2 * dy2 == 0 ? 0 : num / sqrt(dx2 * dy2);
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogProvider>().logs;

    // Build our series map dynamically
    final series = <String, List<TrendPoint>>{};
    for (var type in kSymptomTypes) {
      if (_show[type] == true) {
        series[type] = TrendService.instance.computeRange(
          logs,
          type,
          _from,
          _to,
        );
      }
    }

    // Recompute insight
    _updateInsight(series);

    // Determine which chips to show (only those with data)
    final available = series.keys.where((t) => series[t]!.isNotEmpty).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Date pickers
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.date_range),
                    label: Text('${_from.month}/${_from.day}/${_from.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.date_range),
                    label: Text('${_to.month}/${_to.day}/${_to.year}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter chips
            Wrap(
              spacing: 8,
              children: [
                for (var t in available)
                  FilterChip(
                    label: Text(t),
                    selected: _show[t]!,
                    onSelected: (v) => setState(() => _show[t] = v),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TrendChart(series: series, from: _from, to: _to),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Insight box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('INSIGHT: $_insight'),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _compare(series),
                  child: const Text('COMPARE'),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportScreen()),
                      ),
                  child: const Text('REPORT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
