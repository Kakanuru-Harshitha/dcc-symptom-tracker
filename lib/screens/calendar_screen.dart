// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/log_provider.dart';
import '../models/metrics_provider.dart';
import 'log_symptom_screen.dart';
import '../models/log_entry.dart';
import '../models/daily_metrics.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime.now();
  DateTime _sel   = DateTime.now();

  void _prev() => setState(() {
        _month = DateTime(_month.year, _month.month - 1, 1);
      });
  void _next() => setState(() {
        _month = DateTime(_month.year, _month.month + 1, 1);
      });

  List<DateTime> get _days {
    final cnt = DateUtils.getDaysInMonth(_month.year, _month.month);
    return [
      for (var i = 1; i <= cnt; i++) DateTime(_month.year, _month.month, i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final logProv     = context.watch<LogProvider>();
    final metricsProv = context.watch<MetricsProvider>();

    final allLogs    = logProv.logs;
    final allMetrics = metricsProv.all;

    final dayLogs = allLogs.where((l) =>
        l.date.year  == _sel.year &&
        l.date.month == _sel.month &&
        l.date.day   == _sel.day).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LogSymptomScreen(),
              settings: RouteSettings(arguments: _sel),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // ── Month nav ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
            ],
          ),

          // ── Day strip ──────────────────────────────
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final d = _days[i];
                final sel = d.year == _sel.year &&
                            d.month == _sel.month &&
                            d.day == _sel.day;

                final hasLog = allLogs.any((l) =>
                    l.date.year  == d.year &&
                    l.date.month == d.month &&
                    l.date.day   == d.day);

                final hasMetric = allMetrics.any((m) =>
                    m.date.year  == d.year &&
                    m.date.month == d.month &&
                    m.date.day   == d.day);

                final hasAny = hasLog || hasMetric;

                return GestureDetector(
                  onTap: () => setState(() => _sel = d),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(d),
                            style: TextStyle(color: sel ? Colors.white : null)),
                        Text('${d.day}',
                            style: TextStyle(
                                fontSize: 18,
                                color: sel ? Colors.white : null)),
                        if (hasAny)
                          Icon(Icons.circle,
                              size: 6,
                              color: sel
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // ── Logs list with Edit/Delete ────────────
          Expanded(
            child: ListView.builder(
              itemCount: dayLogs.length,
              itemBuilder: (_, i) {
                final entry = dayLogs[i];
                final globalIndex = allLogs.indexOf(entry);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(entry.symptoms.map((s) => s.type).join(', ')),
                    subtitle: Text(entry.note),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LogSymptomScreen(
                                  entry: entry,
                                  index: globalIndex,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            logProv.remove(entry);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
