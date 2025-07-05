import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/log_provider.dart';
import '../models/metrics_provider.dart';
import '../services/trend_service.dart';
import '../services/ai_service.dart';
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
  DateTime _from = DateTime.now().subtract(const Duration(days: 6));
  DateTime _to = DateTime.now();

  late Map<String, bool> _show;
  bool _loadingInsight = false;
  String _insight = '';

  @override
  void initState() {
    super.initState();
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

  // ───────────────────────────────────────────────────────── AI insight
  Future<void> _updateAiInsight() async {
    setState(() => _loadingInsight = true);

    final logs =
        context
            .read<LogProvider>()
            .logs
            .where((l) => !l.date.isBefore(_from) && !l.date.isAfter(_to))
            .toList();

    final metrics =
        context
            .read<MetricsProvider>()
            .all
            .where((m) => !m.date.isBefore(_from) && !m.date.isAfter(_to))
            .toList();

    final raw = await AiService.instance.generateInsight(
      logs,
      metrics,
      _from,
      _to,
    );

    setState(() {
      _loadingInsight = false;
      _insight = _cleanMarkdown(raw);
    });
  }

  // remove **, _ , ` and bullet asterisks
  String _cleanMarkdown(String s) => s.replaceAll(RegExp(r'[*`_]'), '').trim();

  // ───────────────────────────────────────────────────────── Correlation
  void _compare(Map<String, List<TrendPoint>> series) {
    double bestR = 0;
    String bestPair = '';
    final keys = series.keys.toList();

    for (var i = 0; i < keys.length; i++) {
      for (var j = i + 1; j < keys.length; j++) {
        final a = series[keys[i]]!, b = series[keys[j]]!;
        final mapB = {for (var p in b) p.date: p.value};
        final common = a.where((p) => mapB.containsKey(p.date)).toList();
        if (common.length < 2) continue;

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

  // ───────────────────────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogProvider>().logs;

    // build time-series map
    final series = <String, List<TrendPoint>>{};
    for (var t in kSymptomTypes) {
      if (_show[t] == true) {
        series[t] = TrendService.instance.computeRange(logs, t, _from, _to);
      }
    }
    final available = series.keys.where((t) => series[t]!.isNotEmpty).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // date range row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text('${_from.month}/${_from.day}/${_from.year}'),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text('${_to.month}/${_to.day}/${_to.year}'),
                    onPressed: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // symptom filter chips
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

            // chart box
            SizedBox(
              height: 280,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TrendChart(series: series, from: _from, to: _to),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // insight area
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  _loadingInsight
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                        _insight.isEmpty
                            ? 'Tap COMPARE or INSIGHT for analysis.'
                            : _insight,
                        style: const TextStyle(fontSize: 14),
                      ),
            ),
            const SizedBox(height: 14),

            // action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _compare(series),
                  child: const Text('COMPARE'),
                ),
                ElevatedButton(
                  onPressed: _updateAiInsight,
                  child: const Text('INSIGHT'),
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
