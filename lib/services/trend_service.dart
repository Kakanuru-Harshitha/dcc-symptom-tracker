// lib/services/trend_service.dart
import '../models/log_entry.dart';
import '../models/trend_point.dart';

/// A service to compute time-series TrendPoint lists for any symptom type.
class TrendService {
  TrendService._internal();
  static final TrendService instance = TrendService._internal();
  factory TrendService() => instance;

  /// Returns one TrendPoint per calendar day between [from] and [to]
  /// by averaging all severities of [type] logged on that day.
  List<TrendPoint> computeRange(
    List<LogEntry> logs,
    String type,
    DateTime from,
    DateTime to,
  ) {
    // Group severities by date
    final Map<DateTime, List<int>> accum = {};
    for (var log in logs) {
      if (log.date.isBefore(from) || log.date.isAfter(to)) continue;
      // Extract severities for this type
      final sev = log.symptoms
          .where((s) => s.type == type)
          .map((s) => s.severity)
          .toList();
      if (sev.isEmpty) continue;
      // Normalize to midnight
      final key = DateTime(log.date.year, log.date.month, log.date.day);
      accum.putIfAbsent(key, () => []).addAll(sev);
    }

    // Build sorted TrendPoint list
    final pts = accum.entries
        .map((e) {
          final avg = e.value.reduce((a, b) => a + b) / e.value.length;
          return TrendPoint(date: e.key, value: avg);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return pts;
  }
}
