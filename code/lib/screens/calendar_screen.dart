// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import 'log_symptom_screen.dart';
import '../models/log_entry.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime.now();
  DateTime _sel = DateTime.now();

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
  void _next() =>
      setState(() => _month = DateTime(_month.year, _month.month + 1, 1));

  List<DateTime> get _days {
    final cnt = DateUtils.getDaysInMonth(_month.year, _month.month);
    return [
      for (int i = 1; i <= cnt; i++) DateTime(_month.year, _month.month, i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<LogProvider>();
    final dayLogs =
        prov.logs
            .where(
              (l) =>
                  l.date.year == _sel.year &&
                  l.date.month == _sel.month &&
                  l.date.day == _sel.day,
            )
            .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LogSymptomScreen(),
                settings: RouteSettings(arguments: _sel),
              ),
            ),
      ),
      body: Column(
        children: [
          // Month nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _prev,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: _next,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          // Day strip
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final d = _days[i];
                final sel =
                    d.year == _sel.year &&
                    d.month == _sel.month &&
                    d.day == _sel.day;
                final has = prov.logs.any(
                  (l) =>
                      l.date.year == d.year &&
                      l.date.month == d.month &&
                      l.date.day == d.day,
                );
                return GestureDetector(
                  onTap: () => setState(() => _sel = d),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? Theme.of(context).colorScheme.primary : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(d),
                          style: TextStyle(color: sel ? Colors.white : null),
                        ),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 18,
                            color: sel ? Colors.white : null,
                          ),
                        ),
                        if (has)
                          Icon(
                            Icons.circle,
                            size: 6,
                            color:
                                sel
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.secondary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Logs list
          Expanded(
            child: ListView.builder(
              itemCount: dayLogs.length,
              itemBuilder: (_, i) {
                final entry = dayLogs[i];
                return Dismissible(
                  key: ValueKey(entry),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => prov.remove(entry),
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(entry.symptoms.map((s) => s.type).join(', ')),
                      subtitle: Text(entry.note),
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
