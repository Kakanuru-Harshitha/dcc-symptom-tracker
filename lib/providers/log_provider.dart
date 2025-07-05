// lib/providers/log_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/log_entry.dart';
import '../services/database_service.dart';

class LogProvider extends ChangeNotifier {
  final Database _db = DatabaseService().db;
  final List<LogEntry> _logs = [];

  /// Read‐only view of the logs
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Load all logs from the SQLite 'logs' table
  Future<void> load() async {
    final rows = await _db.query('logs', orderBy: 'date ASC');
    _logs.clear();
    for (final r in rows) {
      try {
        // 'data' column is a JSON string of the entry map
        final Map<String, dynamic> m = {
          ...jsonDecode(r['data'] as String) as Map<String, dynamic>,
          'id': r['id'],
        };
        _logs.add(LogEntry.fromMap(m));
      } catch (_) {
        // skip malformed rows
      }
    }
    notifyListeners();
  }

  /// Add a new log entry (and persist it)
  Future<void> add(LogEntry entry) async {
    final id = await _db.insert('logs', {
      'date': entry.date.millisecondsSinceEpoch,
      'data': jsonEncode(entry.toMap()),
    });
    entry.id = id;
    _logs.add(entry);
    notifyListeners();
  }

  /// Remove an existing entry (and delete from DB)
  Future<void> remove(LogEntry entry) async {
    if (entry.id != null) {
      await _db.delete('logs', where: 'id = ?', whereArgs: [entry.id]);
    }
    _logs.removeWhere((e) => e.id == entry.id);
    notifyListeners();
  }

  /// Replace the entry at [index] with [entry] (and update DB)
  Future<void> updateAt(int index, LogEntry entry) async {
    if (entry.id != null) {
      await _db.update(
        'logs',
        {
          'date': entry.date.millisecondsSinceEpoch,
          'data': jsonEncode(entry.toMap()),
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      _logs[index] = entry;
      notifyListeners();
    }
  }
}
