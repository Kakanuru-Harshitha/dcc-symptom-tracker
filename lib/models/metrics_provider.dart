import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/daily_metrics.dart';

class MetricsProvider extends ChangeNotifier {
  late final Box<DailyMetrics> _box;

  MetricsProvider() {
    _box = Hive.box<DailyMetrics>('metrics');
  }

  List<DailyMetrics> get all => _box.values.toList();

  DailyMetrics? forDate(DateTime d) {
    return _box.values.firstWhere(
      (m) => _sameDay(m.date, d),
      orElse: () => DailyMetrics(date: d),
    );
  }

  void upsert(DailyMetrics m) {
    final idx =
        _box.values.toList().indexWhere((x) => _sameDay(x.date, m.date));
    (idx == -1) ? _box.add(m) : _box.putAt(idx, m);
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
