// lib/widgets/calendar_strip.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class CalendarStrip extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  const CalendarStrip({required this.onDateSelected, super.key});
  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  DateTime _sel = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogProvider>().logs;
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (_, i) {
          final d = DateTime.now().subtract(Duration(days: 13 - i));
          final has = logs.any((l) =>
              l.date.year==d.year &&
              l.date.month==d.month &&
              l.date.day==d.day);
          final sel = d.year==_sel.year&&d.month==_sel.month&&d.day==_sel.day;
          return GestureDetector(
            onTap: (){
              setState(()=>_sel=d);
              widget.onDateSelected(d);
            },
            child: Container(
              width:60,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: sel?Theme.of(context).colorScheme.primary:null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(DateFormat('E').format(d),
                      style: TextStyle(color: sel?Colors.white:null)),
                  Text(DateFormat('d').format(d),
                      style: TextStyle(
                          fontSize:18,
                          color: sel?Colors.white:null)),
                  if(has)
                    Icon(Icons.circle,
                        size:8,
                        color: sel?Colors.white:Theme.of(context).colorScheme.secondary)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
