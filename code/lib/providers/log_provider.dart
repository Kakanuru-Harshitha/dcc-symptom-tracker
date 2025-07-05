// lib/providers/log_provider.dart
import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class LogProvider extends ChangeNotifier {
  final List<LogEntry> _logs = [];

  /// Read‐only view of the logs
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Called on startup (you can hook up persistence here later)
  void load() {
    // For now, nothing to load.
    // Later you could read from disk / database here.
  }

  /// Add a new log entry
  void add(LogEntry entry) {
    _logs.add(entry);
    notifyListeners();
  }

  /// Remove an existing entry
  void remove(LogEntry entry) {
    _logs.remove(entry);
    notifyListeners();
  }
}
